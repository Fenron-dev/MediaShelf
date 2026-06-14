# GitHub-Issue-Workflow

GitHub Issues sind die verbindliche Quelle fuer offene Aufgaben, Fehler,
Funktionswuensche, Verbesserungen und manuelle Abnahmen in MediaShelf.

## Grundregeln

1. Vor Beginn einer Aufgabe wird nach einem bestehenden offenen oder geschlossenen
   Issue gesucht. Duplikate werden vermieden oder miteinander verlinkt.
2. Jeder neu erkannte, umsetzbare Punkt wird als Issue erfasst. Das gilt auch
   fuer Probleme und Verbesserungen, die waehrend einer anderen Aufgabe auffallen.
3. Ein Issue enthaelt einen klaren Umfang, pruefbare Akzeptanzkriterien und bei
   Bedarf eine Checkliste fuer die manuelle Nutzerpruefung.
4. Implementierungen, Commits und Pull Requests verlinken das Issue. Ein Issue
   wird erst geschlossen, wenn die Umsetzung geprueft und dokumentiert ist.
5. Ist eine Nutzerpruefung erforderlich, bleibt das Issue offen, bis die
   entsprechende Abnahme-Checkliste in GitHub abgehakt wurde.
6. Neue Erkenntnisse, Blockaden und geaenderte Entscheidungen werden direkt im
   Issue dokumentiert. Lokale TODO-Listen sind kein Ersatz fuer GitHub Issues.

## Empfohlene Struktur

- **Ausgangslage:** beobachtetes Problem oder Bedarf
- **Ziel:** erwartetes sichtbares Ergebnis
- **Umfang:** inbegriffene und bewusst ausgeschlossene Arbeiten
- **Akzeptanzkriterien:** technisch pruefbare Checkliste
- **Nutzerpruefung:** konkrete manuelle Schritte
- **Umsetzungsnachweis:** Commit, Pull Request oder Testergebnis

## Abschluss

Ein Issue gilt als erledigt, wenn alle zutreffenden Akzeptanzkriterien erfuellt
sind, automatisierte Pruefungen erfolgreich waren und eine verlangte
Nutzerabnahme abgeschlossen ist. Teilweise erledigte Punkte bleiben offen oder
werden als eigenes Folge-Issue ausgegliedert.

