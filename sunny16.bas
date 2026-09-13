#lang "fblite"
' =========================================================
'  Sunny 16 
'  Copyright (c) 2026 Marcel "SmartDuck" Beekman
'  Licentie: BSD 3-clause
'
'  Taal: FreeBasic, geschreven in QBasic-compatibele stijl
'  Compileren:  fbc -lang fblite sunny16.bas
'
'  SCREEN 12 = 640x480, 16 kleuren (VGA-compatibel)
'  Tekstraster: 80 kolommen x 30 rijen (tekencel 8x16)
'
'  Hoofdmenu in MS-Edit-stijl: F1 = Help, F2 = Sunny 16 starten
'  (of, tijdens de flow, opnieuw beginnen), F10 of Q = Stoppen
'  (F10 lijkt op sommige systemen gereserveerd te zijn, vandaar
'  Q als alternatief). Deze drie toetsen werken op elk moment,
'  ook tijdens de weer-/film-/resultaatschermen.
' =========================================================

DECLARE SUB TekenFrame ()
DECLARE SUB TekenStart ()
DECLARE SUB TekenMenu ()
DECLARE SUB TekenRaamwerk ()
DECLARE SUB StartSunny16 ()
DECLARE SUB TekenIcon (idx AS INTEGER, cx AS INTEGER, cy AS INTEGER, selected AS INTEGER)
DECLARE SUB TekenLabels ()
DECLARE SUB TekenFilm (idx AS INTEGER, cx AS INTEGER, cy AS INTEGER, selected AS INTEGER)
DECLARE SUB TekenFilmLabels ()
DECLARE SUB ShowHelp ()
DECLARE SUB PrintUitleg (title AS STRING, uitleg AS STRING)
DECLARE SUB PrintResultaat (titel AS STRING, weerkeuze AS INTEGER, iso AS SINGLE)
DECLARE FUNCTION DiafragmaMapping$ (idx AS INTEGER)
DECLARE FUNCTION SluitertijdMapping$ (iso AS SINGLE)


' ----------------------
' Hoofdlus
' ----------------------
DIM k AS STRING
    
SCREEN 12
COLOR 15,1
CLS

DO
    TekenRaamwerk

    k = ""
    DO WHILE k = ""
        k = INKEY$
    LOOP

    IF LEN(k) = 2 AND (LEFT$(k, 1) = CHR$(0) OR LEFT$(k, 1) = CHR$(255)) THEN
        SELECT CASE ASC(RIGHT$(k, 1))
            CASE 59 ' F1
                ShowHelp
            CASE 60 ' F2
                StartSunny16
            CASE 68 ' F10
                EXIT DO
        END SELECT
    ELSEIF UCASE$(k) = "Q" THEN
        EXIT DO
    END IF
LOOP

COLOR 7,0
CLS
END

' ---------------------------------------------------------
' Tekent alleen het dubbele-lijn kader (zonder menubalk of
' achtergrondvulling). Wordt na elke schermwissel opnieuw
' aangeroepen zodat het kader nooit kan wegvallen.
' ---------------------------------------------------------
SUB TekenFrame
    DIM r AS INTEGER

    FOR r = 2 TO 28
        LOCATE r, 1: PRINT CHR$(186)
        LOCATE r, 80: PRINT CHR$(186)
    NEXT r
    LOCATE 2, 1: PRINT CHR$(201) + STRING$(78, CHR$(205)) + CHR$(187);
    LOCATE 29, 1: PRINT CHR$(200) + STRING$(78, CHR$(205)) + CHR$(188);
END SUB

' ---------------------------------------------------------
' Tekent het hoofdmenu: kader, blauwe achtergrond en een
' menubalk met de F-toetsen, zoals in klassiek MS-Edit.
' ---------------------------------------------------------
SUB TekenMenu
    ' menubalk
    LOCATE 3, 3
    COLOR 14, 1: PRINT "F1";
    COLOR 15, 1: PRINT "=Help   ";
    COLOR 14, 1: PRINT "F2";
    COLOR 15, 1: PRINT "=Sunny 16   ";
    COLOR 14, 1: PRINT "F10";
    COLOR 15, 1: PRINT "/";
    COLOR 14, 1: PRINT "Q";
    COLOR 15, 1: PRINT "=Stoppen"

    ' dunne scheidingslijn onder de menubalk
    LOCATE 4, 3: PRINT STRING$(76, CHR$(196))
END SUB

SUB TekenStart
    COLOR 15, 1
    LOCATE 15, 34: PRINT "SUNNY 16 CALCULATOR"
    LOCATE 17, 22: PRINT "Druk op F2 om de belichtingshulp te starten"
END SUB

SUB TekenRaamwerk
	LINE(10,32)-(630,440),1,BF
	TekenFrame
    TekenMenu
    TekenStart
END SUB


SUB PrintUitleg(titel AS STRING, uitleg AS STRING)
	LOCATE 6, 28: PRINT titel
    LOCATE 8, 23: PRINT uitleg
END SUB

SUB PrintResultaat(titel AS STRING, weerkeuze AS INTEGER, iso AS SINGLE)
	LOCATE 6, 38: PRINT "RESULTAAT"
    LOCATE 8, 5: PRINT "Weertype:     " + titel
    LOCATE 10, 5: PRINT "ISO:          " + LTRIM$(STR$(iso))
    LOCATE 12, 5: PRINT "Diafragma:    " + DiafragmaMapping$(weerKeuze)
    LOCATE 14, 5: PRINT "Sluitertijd:  " + SluitertijdMapping$(iso)
END SUB

' ---------------------------------------------------------
' De volledige Sunny 16-flow: weertype kiezen, ISO/filmrolletje
' kiezen, resultaat tonen. F1/F2/F10/Q werken op elk moment:
' F1 = help, F2 = meteen opnieuw beginnen, F10/Q = programma
' direct afsluiten. Zonder F2/F10/Q keert de flow na het
' resultaatscherm terug naar het hoofdmenu.
' ---------------------------------------------------------
SUB StartSunny16
    DIM iso AS SINGLE
    DIM weerKeuze AS INTEGER
    DIM filmKeuze AS INTEGER
    DIM k AS STRING
    DIM x(1 TO 5) AS INTEGER
    DIM isoWaarden(1 TO 5) AS INTEGER
    DIM i AS INTEGER
    DIM herstart AS INTEGER
	DIM titels(1 TO 5) AS STRING

	titels(1) = "Zonnig"
    titels(2) = "Licht bewolkt"
    titels(3) = "Bewolkt"
    titels(4) = "Zwaar bewolkt"
    titels(5) = "Schaduw"

    x(1) = 80: x(2) = 190: x(3) = 300: x(4) = 410: x(5) = 520
    

    isoWaarden(1) = 100
    isoWaarden(2) = 200
    isoWaarden(3) = 400
    isoWaarden(4) = 800
    isoWaarden(5) = 1600

    DO  ' herstart-lus: begint helemaal opnieuw als F2 wordt ingedrukt
        herstart = 0

        ' ---------- Scherm 1: weertype kiezen ----------
        LINE(10,32)-(630,440),1,BF
        TekenFrame
        TekenMenu
        PrintUitleg "KIES HET WEERTYPE", "Pijltjes = kiezen, ENTER = bevestigen"
        
        weerKeuze = 1
        DO
            FOR i = 1 TO 5
                TekenIcon i, x(i), 240, (i = weerKeuze)
            NEXT i
            TekenLabels

            k = ""
            DO WHILE k = ""
                k = INKEY$
            LOOP

            IF LEN(k) = 2 AND (LEFT$(k, 1) = CHR$(0) OR LEFT$(k, 1) = CHR$(255)) THEN
                SELECT CASE ASC(RIGHT$(k, 1))
                    CASE 75 ' links
                        weerKeuze = weerKeuze - 1
                        IF weerKeuze < 1 THEN weerKeuze = 5
                    CASE 77 ' rechts
                        weerKeuze = weerKeuze + 1
                        IF weerKeuze > 5 THEN weerKeuze = 1
                    CASE 59 ' F1 = help
                        ShowHelp
                        LINE(10,32)-(630,440),1,BF
                        TekenFrame
                        TekenMenu
                        PrintUitleg "KIES HET WEERTYPE", "Pijltjes = kiezen, ENTER = bevestigen"
                    CASE 60 ' F2 = opnieuw beginnen
                        herstart = 1
                        EXIT DO
                    CASE 68 ' F10 = programma stoppen
                        COLOR 7, 0
                        CLS
                        END
                END SELECT
            ELSEIF k = CHR$(13) THEN
                EXIT DO
            ELSEIF UCASE$(k) = "Q" THEN
                COLOR 7, 0
                CLS
                END
            END IF
        LOOP

        IF herstart = 0 THEN
            DO WHILE INKEY$ <> "": LOOP   ' buffer legen

            ' ---------- Scherm 2: filmrolletje (ISO) kiezen ----------
            LINE(10,32)-(630,440),1,BF
            TekenFrame
            TekenMenu
            PrintUitleg "KIES DE ISO-WAARDE VAN JE FILM", "Pijltjes = kiezen, ENTER = bevestigen"
            
            filmKeuze = 1
            DO
                FOR i = 1 TO 5
                    TekenFilm i, x(i), 240, (i = filmKeuze)
                NEXT i
                TekenFilmLabels

                k = ""
                DO WHILE k = ""
                    k = INKEY$
                LOOP

                IF LEN(k) = 2 AND (LEFT$(k, 1) = CHR$(0) OR LEFT$(k, 1) = CHR$(255)) THEN
                    SELECT CASE ASC(RIGHT$(k, 1))
                        CASE 75 ' links
                            filmKeuze = filmKeuze - 1
                            IF filmKeuze < 1 THEN filmKeuze = 5
                        CASE 77 ' rechts
                            filmKeuze = filmKeuze + 1
                            IF filmKeuze > 5 THEN filmKeuze = 1
                        CASE 59 ' F1 = help
                            ShowHelp
                            LINE(10,32)-(630,440),1,BF
                            TekenFrame
                            TekenMenu
                            PrintUitleg "KIES DE ISO-WAARDE VAN JE FILM", "Pijltjes = kiezen, ENTER = bevestigen"
                        CASE 60 ' F2 = opnieuw beginnen
                            herstart = 1
                            EXIT DO
                        CASE 68 ' F10 = programma stoppen
                            COLOR 7, 0
                            CLS
                            END
                    END SELECT
                ELSEIF k = CHR$(13) THEN
                    EXIT DO
                ELSEIF UCASE$(k) = "Q" THEN
                    COLOR 7, 0
                    CLS
                    END
                END IF
            LOOP
        END IF

        IF herstart = 0 THEN
            DO WHILE INKEY$ <> "": LOOP   ' buffer legen

            iso = isoWaarden(filmKeuze)

            ' ---------- Resultaat ----------
            LINE(10,32)-(630,440),1,BF
            TekenFrame
            TekenMenu
            PrintResultaat titels(weerKeuze), weerKeuze, iso
           
            DO
                k = ""
                DO WHILE k = ""
                    k = INKEY$
                LOOP

                IF LEN(k) = 2 AND (LEFT$(k, 1) = CHR$(0) OR LEFT$(k, 1) = CHR$(255)) THEN
                    SELECT CASE ASC(RIGHT$(k, 1))
                        CASE 59 ' F1 = help
                            ShowHelp
                            LINE(10,32)-(630,440),1,BF
                            TekenFrame
                            TekenMenu
                            PrintResultaat titels(weerKeuze), weerKeuze, iso
                        CASE 60 ' F2 = opnieuw beginnen
                            herstart = 1
                            EXIT DO
                        CASE 68 ' F10 = programma stoppen
                            COLOR 7, 0
                            CLS
                            END
                        CASE ELSE ' andere functietoets -> terug naar menu
                            EXIT DO
                    END SELECT
                ELSEIF UCASE$(k) = "Q" THEN
                    COLOR 7, 0
                    CLS
                    END
                ELSE ' willekeurige gewone toets -> terug naar menu
                    EXIT DO
                END IF
            LOOP
        END IF

    LOOP WHILE herstart = 1
END SUB

' ---------------------------------------------------------
' Tekent een weericoontje op positie (cx,cy) met een kader
' rondom, dat oplicht (wit) als het geselecteerd is.
' ---------------------------------------------------------
SUB TekenIcon (idx AS INTEGER, cx AS INTEGER, cy AS INTEGER, selected AS INTEGER)
    DIM boxcol AS INTEGER
    IF selected THEN boxcol = 14 ELSE boxcol = 8

    SELECT CASE idx

        CASE 1 ' Zonnig: gele zon met stralen
			LINE (cx - 35, cy - 35)-(cx + 35, cy + 35), 11, BF
            CIRCLE (cx, cy), 16, 14
            PAINT (cx, cy), 14, 14
            LINE (cx - 28, cy)-(cx - 20, cy), 14
            LINE (cx + 20, cy)-(cx + 28, cy), 14
            LINE (cx, cy - 28)-(cx, cy - 20), 14
            LINE (cx, cy + 20)-(cx, cy + 28), 14
            LINE (cx - 20, cy - 20)-(cx - 14, cy - 14), 14
            LINE (cx + 14, cy + 14)-(cx + 20, cy + 20), 14
            LINE (cx + 20, cy - 20)-(cx + 14, cy - 14), 14
            LINE (cx - 14, cy + 14)-(cx - 20, cy + 20), 14

        CASE 2 ' Licht bewolkt: zon deels achter wolk
			LINE (cx - 35, cy - 35)-(cx + 35, cy + 35), 11, BF
            CIRCLE (cx - 6, cy - 6), 14, 14
            PAINT (cx - 6, cy - 6), 14, 14
            CIRCLE (cx + 8, cy + 6), 14, 7
            PAINT (cx + 8, cy + 6), 7, 7
            CIRCLE (cx + 18, cy + 16), 14, 7
            PAINT (cx + 18, cy + 16), 7, 7

        CASE 3 ' Bewolkt: grijze wolk
			LINE (cx - 35, cy - 35)-(cx + 35, cy + 35), 11, BF
			CIRCLE (cx + 14, cy + 8), 10, 7
            PAINT (cx + 14, cy + 8), 7, 7
            CIRCLE (cx - 10, cy + 4), 12, 7
            PAINT (cx - 10, cy + 4), 7, 7
            CIRCLE (cx + 6, cy - 2), 15, 7
            PAINT (cx + 6, cy - 2), 7, 7
           
        CASE 4 ' Zwaar bewolkt: donkergrijze wolk
			LINE (cx - 35, cy - 35)-(cx + 35, cy + 35), 9, BF
            CIRCLE (cx + 14, cy + 8), 10, 8
            PAINT (cx + 14, cy + 8), 8, 8
            CIRCLE (cx - 10, cy + 4), 12, 8
            PAINT (cx - 10, cy + 4), 8, 8
            CIRCLE (cx + 6, cy - 2), 15, 8
            PAINT (cx + 6, cy - 2), 8, 8     

        CASE 5 ' Schaduw / zonsondergang: halve zon achter horizon
			LINE (cx - 35, cy - 35)-(cx + 35, cy + 35), 9, BF
            CIRCLE (cx, cy), 16, 12
            PAINT (cx, cy), 12, 12
            LINE (cx - 30, cy + 6)-(cx + 30, cy + 30), 2, BF

    END SELECT
    
    LINE (cx - 34, cy - 34)-(cx + 36, cy + 36), boxcol, B
    LINE (cx - 35, cy - 35)-(cx + 35, cy + 35), boxcol, B
END SUB

' ---------------------------------------------------------
' Zet de tekstlabels onder de weer-icoontjes
' ---------------------------------------------------------
SUB TekenLabels
    LOCATE 12, 6:  PRINT "Zonnig"
    LOCATE 12, 20: PRINT "Licht bew."
    LOCATE 12, 34: PRINT "Bewolkt"
    LOCATE 12, 47: PRINT "Zwaar bew."
    LOCATE 12, 63: PRINT "Schaduw"
END SUB

' ---------------------------------------------------------
' Tekent een filmrolletje-icoontje (versie van de gebruiker):
' liggend filmstrookje dat achter de cassette vandaan piept,
' zwarte romp, ellipsvormige spoelopening, gekleurd etiket.
' ---------------------------------------------------------
SUB TekenFilm (idx AS INTEGER, cx AS INTEGER, cy AS INTEGER, selected AS INTEGER)
    DIM boxcol AS INTEGER
    DIM labelcol AS INTEGER
    IF selected THEN boxcol = 14 ELSE boxcol = 8
    LINE (cx - 35, cy - 35)-(cx + 35, cy + 35), 0, BF
    LINE (cx - 34, cy - 34)-(cx + 36, cy + 36), boxcol, B
    LINE (cx - 35, cy - 35)-(cx + 35, cy + 35), boxcol, B
    SELECT CASE idx
        CASE 1: labelcol = 9    ' ISO 100  - blauw etiket
        CASE 2: labelcol = 10   ' ISO 200  - groen etiket
        CASE 3: labelcol = 14   ' ISO 400  - geel etiket
        CASE 4: labelcol = 12   ' ISO 800  - rood etiket
        CASE 5: labelcol = 13   ' ISO 1600 - magenta etiket
    END SELECT
    ' filmstrookje - liggend, wordt straks half bedekt door de romp,
    ' zodat het lijkt alsof het van achter de cassette vandaan piept
    LINE (cx - 32, cy - 6)-(cx - 8, cy + 18), 6, BF
    LINE (cx - 32, cy - 6)-(cx - 8, cy + 18), 15, B
    LINE (cx - 29, cy - 4)-(cx - 26, cy - 1), 0, BF
    LINE (cx - 23, cy - 4)-(cx - 20, cy - 1), 0, BF
    LINE (cx - 29, cy + 13)-(cx - 26, cy + 16), 0, BF
    LINE (cx - 23, cy + 13)-(cx - 20, cy + 16), 0, BF
    ' zwarte cassette-romp (dekt het rechterdeel van het strookje af)
    LINE (cx - 15, cy - 10)-(cx + 17, cy + 28), 0, BF
    LINE (cx - 15, cy - 10)-(cx + 17, cy + 28), 15, B
    ' ronde bovenkant met spoelopening, als ellipsen (aanzicht op de cilinder)
    LINE (cx - 15, cy - 10)-(cx + 17, cy - 10), 0
    CIRCLE (cx + 1, cy - 10), 16, 15, , , 0.4
    CIRCLE (cx + 1, cy - 10), 10, 15, , , 0.4
    ' etiket met kleurcode en tekstvakje
    LINE (cx - 15, cy + 2)-(cx + 17, cy + 24), labelcol, BF
    LINE (cx - 15, cy + 2)-(cx + 17, cy + 24), 15, B
    LINE (cx - 9, cy + 8)-(cx + 11, cy + 20), 15, BF
    LINE (cx - 6, cy + 12)-(cx + 8, cy + 12), labelcol
    LINE (cx - 6, cy + 16)-(cx + 3, cy + 16), labelcol
END SUB

' ---------------------------------------------------------
' Zet de tekstlabels onder de filmrolletjes
' ---------------------------------------------------------
SUB TekenFilmLabels
    LOCATE 12, 7:  PRINT "ISO 100"
    LOCATE 12, 21: PRINT "ISO 200"
    LOCATE 12, 35: PRINT "ISO 400"
    LOCATE 12, 48: PRINT "ISO 800"
    LOCATE 12, 61: PRINT "ISO 1600"
END SUB

' ---------------------------------------------------------
' Uitlegscherm over de Sunny 16 regel
' ---------------------------------------------------------
SUB ShowHelp
    LINE(10,32)-(630,440),1,BF
    TekenFrame
    LOCATE 4, 32: PRINT "UITLEG: SUNNY 16"

    LOCATE 6, 5:  PRINT "De 'Sunny 16'-regel is een vuistregel om zonder"
    LOCATE 7, 5:  PRINT "lichtmeter een goede belichting te bepalen bij"
    LOCATE 8, 5:  PRINT "daglicht."

    LOCATE 10, 5:  PRINT "Bij fel zonlicht (harde schaduwen) zet je het"
    LOCATE 11, 5:  PRINT "diafragma op f/16. De sluitertijd kies je dan"
    LOCATE 12, 5:  PRINT "ongeveer gelijk aan 1 / ISO-waarde, in seconden."

    LOCATE 14, 5: PRINT "Is er minder licht (bewolkt), dan open je het"
    LOCATE 15, 5: PRINT "diafragma verder (kleiner f-getal) om evenveel"
    LOCATE 16, 5: PRINT "licht binnen te laten, met dezelfde sluitertijd:"

    LOCATE 18, 8: PRINT "Zonnig (harde schaduw)         -> f/16"
    LOCATE 19, 8: PRINT "Licht bewolkt (zachte schaduw) -> f/11"
    LOCATE 20, 8: PRINT "Bewolkt (nauwelijks schaduw)   -> f/8"
    LOCATE 21, 8: PRINT "Zwaar bewolkt (geen schaduw)   -> f/5.6"
    LOCATE 22, 8: PRINT "Schaduw / zonsondergang        -> f/4"

    LOCATE 26, 5: PRINT "Druk op een toets om terug te gaan..."
    DO WHILE INKEY$ <> "": LOOP
    DO WHILE INKEY$ = "": LOOP
END SUB

' ---------------------------------------------------------
' Geeft het diafragma (f-getal) horend bij het weertype
' ---------------------------------------------------------
FUNCTION DiafragmaMapping$ (idx AS INTEGER)
    SELECT CASE idx
        CASE 1: DiafragmaMapping$ = "f/16"
        CASE 2: DiafragmaMapping$ = "f/11"
        CASE 3: DiafragmaMapping$ = "f/8"
        CASE 4: DiafragmaMapping$ = "f/5.6"
        CASE 5: DiafragmaMapping$ = "f/4"
        CASE ELSE: DiafragmaMapping$ = "?"
    END SELECT
END FUNCTION

' ---------------------------------------------------------
' Zoekt de dichtstbijzijnde standaard sluitertijd bij 1/ISO
' ---------------------------------------------------------
FUNCTION SluitertijdMapping$ (iso AS SINGLE)
    DIM doelen(1 TO 14) AS SINGLE
    DIM teksten(1 TO 14) AS STRING
    DIM doel AS SINGLE
    DIM beste AS INTEGER
    DIM diff AS SINGLE
    DIM minDiff AS SINGLE
    DIM i AS INTEGER

    doelen(1) = 1 / 8000: teksten(1) = "1/8000 sec"
    doelen(2) = 1 / 4000: teksten(2) = "1/4000 sec"
    doelen(3) = 1 / 2000: teksten(3) = "1/2000 sec"
    doelen(4) = 1 / 1000: teksten(4) = "1/1000 sec"
    doelen(5) = 1 / 500:  teksten(5) = "1/500 sec"
    doelen(6) = 1 / 250:  teksten(6) = "1/250 sec"
    doelen(7) = 1 / 125:  teksten(7) = "1/125 sec"
    doelen(8) = 1 / 60:   teksten(8) = "1/60 sec"
    doelen(9) = 1 / 30:   teksten(9) = "1/30 sec"
    doelen(10) = 1 / 15:  teksten(10) = "1/15 sec"
    doelen(11) = 1 / 8:   teksten(11) = "1/8 sec"
    doelen(12) = 1 / 4:   teksten(12) = "1/4 sec"
    doelen(13) = 1 / 2:   teksten(13) = "1/2 sec"
    doelen(14) = 1:       teksten(14) = "1 sec"

    doel = 1 / iso
    beste = 1
    minDiff = ABS(LOG(doelen(1)) - LOG(doel))

    FOR i = 2 TO 14
        diff = ABS(LOG(doelen(i)) - LOG(doel))
        IF diff < minDiff THEN
            minDiff = diff
            beste = i
        END IF
    NEXT i

    SluitertijdMapping$ = teksten(beste)
END FUNCTION
