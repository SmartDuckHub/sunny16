# Sunny 16 Calculator

Een grafische Sunny 16-belichtingshulp voor analoge fotografie, geschreven in
FreeBasic (fblite-dialect, QBasic-compatibel). Kies je weertype en de
ISO-waarde van je filmrolletje met de pijltjestoetsen, en het programma
berekent het bijbehorende diafragma en de sluitertijd.

Getest en werkend op **Linux**, **Windows** en **MS-DOS (via DOSBox)**.

## Kenmerken

- Grafische weerselectie (zonnig, licht bewolkt, bewolkt, zwaar bewolkt,
  schaduw/zonsondergang) met bijpassend pictogram per weertype
- Grafische filmrolletje-selectie (ISO 100 / 200 / 400 / 800 / 1600), elk met
  een eigen kleurcode op het etiket
- Automatische berekening van het diafragma (volgens de Sunny 16-vuistregel)
  en de dichtstbijzijnde standaard sluitertijd bij 1 / ISO
- Hoofdmenu in klassieke MS-Edit-stijl: dubbele-lijn kader, blauwe
  achtergrond en een menubalk
- Ingebouwde uitlegpagina over de Sunny 16-regel
- SCREEN 12 (640x480, 16 kleuren, VGA-compatibel) — werkt daardoor ook op
  systemen/emulators die alleen klassieke VGA-schermmodi ondersteunen

## Bediening

| Toets            | Werking                                              |
|-------------------|-------------------------------------------------------|
| Pijltjes links/rechts | Vorige/volgende optie selecteren                  |
| Enter             | Selectie bevestigen                                   |
| F1                | Uitleg over de Sunny 16-regel tonen                   |
| F2                | Sunny 16 starten (vanuit het menu), of op elk moment tijdens de flow meteen opnieuw beginnen |
| F10 of Q          | Programma direct afsluiten                            |

F1, F2, F10 en Q werken op elk moment, ook tijdens de weer-, film- en
resultaatschermen.

*Let op:* op sommige systemen/vensterbeheerders lijkt F10 gereserveerd te
zijn voor iets anders. Gebruik in dat geval gewoon `Q` om af te sluiten.

## Compileren

Vereist een FreeBasic-compiler (`fbc`).

```
fbc sunny16.bas
```

De dialect-instelling (`fblite`, QBasic-compatibel) staat al in de
broncode via de `#lang "fblite"`-richtlijn bovenaan het bestand, dus een
losse `-lang`-vlag op de commandoregel is niet nodig. Wil je dat toch
expliciet meegeven, dan kan dat ook:

```
fbc -lang fblite sunny16.bas
```

Dit levert een uitvoerbaar bestand op (`sunny16` op Linux, `sunny16.exe`
op Windows/DOS).

### MS-DOS / DOSBox

Compileer op Linux of Windows zoals hierboven, en draai het resulterende
`.exe`-bestand vervolgens in DOSBox. Omdat het programma in de
QBasic-compatibele `fblite`-dialect is geschreven en gebruikmaakt van de
klassieke SCREEN 12-modus, gedraagt het zich consistent op alle drie de
platformen.

## Licentie

BSD 3-Clause License

Copyright (c) 2026 Marcel "SmartDuck" Beekman
