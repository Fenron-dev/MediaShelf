# MediaShelf – Benutzerhandbuch

**Version 0.3.0** · Stand März 2026

---

## Inhaltsverzeichnis

1. [Übersicht](#1-übersicht)
2. [Installation](#2-installation)
3. [Erste Schritte](#3-erste-schritte)
4. [Bibliothek verwalten](#4-bibliothek-verwalten)
5. [Ansichten](#5-ansichten)
6. [Detail-Panel](#6-detail-panel)
7. [Tags & Sammlungen](#7-tags--sammlungen)
8. [Smart-Filter](#8-smart-filter)
9. [Custom Properties](#9-custom-properties)
10. [Medien-Wiedergabe & Queue](#10-medien-wiedergabe--queue)
11. [Datei-Operationen](#11-datei-operationen)
12. [Suche & Filter](#12-suche--filter)
13. [Einstellungen & Tastenkürzel](#13-einstellungen--tastenkürzel)
14. [Datenbank & Datensicherung](#14-datenbank--datensicherung)

---

## 1. Übersicht

MediaShelf ist ein plattformübergreifender Digitaler Asset-Manager für den Desktop.
Er hilft dabei, große Sammlungen von Fotos, Videos, Musik, E-Books, PDFs und anderen
Mediendateien zu organisieren, zu durchsuchen und wiederzugeben – ohne dass Dateien
aus ihren Ordnern bewegt werden müssen.

**Unterstützte Plattformen:** Linux, Windows, macOS, Android

**Unterstützte Dateitypen (Auswahl):**

| Kategorie | Formate |
|-----------|---------|
| Bilder | JPEG, PNG, GIF, WebP, HEIC, TIFF, BMP, SVG |
| Videos | MP4, MKV, AVI, MOV, WebM, FLV, und weitere |
| Audio | MP3, FLAC, AAC, M4A, M4B, OGG, WAV, OPUS |
| Dokumente | PDF, ePub, Markdown, TXT, HTML |
| Sonstige | Archive, Schriften, 3D-Modelle, Code-Dateien |

---

## 2. Installation

### Linux
1. `mediashelf-linux-x64.tar.gz` herunterladen und entpacken:
   ```bash
   tar -xzf mediashelf-linux-x64.tar.gz -C ~/Apps/MediaShelf
   ```
2. Ausführbar machen und starten:
   ```bash
   chmod +x ~/Apps/MediaShelf/mediashelf
   ~/Apps/MediaShelf/mediashelf
   ```
   > Alle Bibliotheken (libmpv, SQLite usw.) sind im Paket enthalten – keine
   > System-Abhängigkeiten nötig.

### Windows
1. `mediashelf-windows-x64.zip` herunterladen und entpacken.
2. `mediashelf.exe` starten.
   > Windows SmartScreen kann beim ersten Start warnen; „Trotzdem ausführen" wählen.

### macOS
1. `mediashelf-macos.zip` herunterladen und entpacken.
2. `mediashelf.app` in den Programme-Ordner ziehen.
3. Beim ersten Start: Rechtsklick → „Öffnen" (Gatekeeper-Bypass).

### Android
1. `mediashelf-android.apk` herunterladen.
2. In den Einstellungen „Installation aus unbekannten Quellen" erlauben.
3. APK installieren.

---

## 3. Erste Schritte

### Bibliothek öffnen

Beim Start erscheint der Willkommensbildschirm. Wähle eine Option:

- **Ordner als Bibliothek öffnen** – wählt einen bestehenden Ordner auf dem
  Dateisystem. MediaShelf legt darin einen versteckten Unterordner `.mediashelf/`
  an (Datenbank, Thumbnails).
- **Zuletzt geöffnete Bibliothek** – schneller Zugriff auf bekannte Bibliotheken.

### Erster Scan

Nach dem Öffnen scannt MediaShelf automatisch den Bibliotheksordner. Der Fortschritt
erscheint in der Toolbar (Datei-Zähler). Der Scan umfasst drei Phasen:

1. **Indexierung** – Dateipfade, Größen und MIME-Typen werden erfasst.
2. **Thumbnails** – Vorschaubilder werden im Hintergrund erzeugt.
3. **Metadaten** – Mediendaten (ID3, EXIF, PDF-Info) werden ausgelesen.

Ein manueller Re-Scan ist jederzeit über die 🔄-Schaltfläche möglich.

---

## 4. Bibliothek verwalten

### Import

Über das ⬇-Menü in der Toolbar können einzelne Dateien oder ganze Ordner
importiert (kopiert) werden:

- **Ordner importieren…** – kopiert den gesamten Ordnerinhalt in die Bibliothek.
- **Dateien importieren…** – kopiert ausgewählte Dateien.

Der Zielordner wird im Import-Dialog ausgewählt oder neu erstellt.

### Sidebar – Ordner-Baum

Die linke Sidebar zeigt die Ordnerstruktur der Bibliothek. Ein Klick auf einen
Ordner filtert die Hauptansicht auf dessen Inhalte.

- **Einzel-Klick** – zeigt nur den direkten Ordnerinhalt (nicht rekursiv).
- **Ordnerpfeil** – klappt Unterordner auf/zu.
- Dateianzahl steht in Klammern hinter dem Ordnernamen.

### Sidebar – Sammlungen & Smart-Filter

Unterhalb des Ordner-Baums erscheinen Sammlungen und Smart-Filter.
Über das **+**-Symbol können neue angelegt werden (→ [Abschnitt 7](#7-tags--sammlungen)).

---

## 5. Ansichten

### Rasteransicht

Standard-Ansicht mit Thumbnails. Die Thumbnail-Größe lässt sich über den
Schieberegler in der Toolbar stufenlos von 80 px bis 400 px anpassen.

### Listenansicht

Kompakte Tabellenzeilen mit Name, MIME-Typ, Größe und Änderungsdatum.
Umschalten: Toolbar-Schaltfläche (Raster ↔ Liste).

### Mehrfachauswahl

- **Langes Drücken / Rechtsklick** auf ein Asset aktiviert die Mehrfachauswahl.
- Weitere Assets durch Klick hinzufügen.
- Aktionen (Bewertung setzen, Tag hinzufügen, löschen, verschieben) gelten für
  alle markierten Assets.

### Sortierung & Filter

Die Toolbar enthält eine Suchleiste sowie Filter-Optionen für MIME-Typ, Rating
und Datum. Erweiterte Filterung → [Abschnitt 12](#12-suche--filter).

---

## 6. Detail-Panel

Das rechte Detail-Panel (ein-/ausblendbar über die Sidebar-Schaltfläche in der
Toolbar) zeigt alle Informationen zum ausgewählten Asset:

| Bereich | Inhalt |
|---------|--------|
| **Vorschau** | Thumbnail / Bild-Vorschau |
| **Dateiname & Pfad** | Name und relativer Pfad |
| **Bewertung** | 0–5 Sterne (Klick zum Setzen, nochmal Klicken zum Zurücksetzen) |
| **Farbmarkierung** | 6 Farben + Zurücksetzen |
| **Tags** | Chip-Liste; über „+" neue Tags hinzufügen |
| **Notiz** | Freitextfeld, wird automatisch gespeichert |
| **Medien-Template** | Typ-spezifische Metadaten (siehe unten) |
| **Custom Properties** | Benutzerdefinierte Felder (→ [Abschnitt 9](#9-custom-properties)) |
| **Orte** | Ordner und Sammlungen, in denen das Asset vorkommt |

### Medien-Templates

Je nach Dateityp erscheinen unterschiedliche Metadatenfelder:

- **Audio (MP3, M4B …):** Titel, Künstler, Album, Genre, Track-Nr., Jahr, Dauer, Bitrate, Sample-Rate
- **Video (MP4, MKV …):** Titel, Regisseur, Dauer, Auflösung, Bitrate, Jahr
- **Bild (JPEG, PNG …):** Abmessungen, Kameramodell, Aufnahmedatum
- **PDF / ePub:** Titel, Autor, Verlag, Seitenanzahl, Jahr

---

## 7. Tags & Sammlungen

### Tags

Tags sind freie Schlagwörter, die beliebig vielen Assets zugewiesen werden können.

- **Hinzufügen:** Detail-Panel → „+" neben der Tags-Überschrift → Namen eingeben.
- **Entfernen:** „×" auf dem Tag-Chip im Detail-Panel.
- **Hierarchie:** Tags können mit `/` geschachtelt werden, z. B. `Natur/Berge`.
  Die Sidebar zeigt sie als aufklappbaren Baum.
- **Filter:** Klick auf einen Tag in der Sidebar filtert alle Assets mit diesem Tag
  (inkl. aller Sub-Tags).

### Sammlungen (manuelle Listen)

Sammlungen sind manuell zusammengestellte Gruppen von Assets – ähnlich wie Playlisten.

- **Neu anlegen:** Sidebar → **+** → „Neue Sammlung".
- **Assets hinzufügen:** Asset(s) per Drag & Drop auf eine Sammlung in der Sidebar ziehen.
- **Asset entfernen:** Rechtsklick auf ein Asset in der Sammlungsansicht → „Aus Sammlung entfernen".

### Smart-Filter

Smart-Filter sind regelbasierte, dynamische Sammlungen (→ [Abschnitt 8](#8-smart-filter)).

---

## 8. Smart-Filter

Smart-Filter filtern die Bibliothek dynamisch anhand von Regeln und zeigen immer
den aktuellen Trefferstand.

### Neuen Smart-Filter anlegen

1. Sidebar → **+** → „Neuer Smart-Filter".
2. **Name** eingeben.
3. Logik wählen: **ALLE Regeln** (AND) oder **EINE Regel** (OR).
4. Regeln hinzufügen (→ Abschnitt unten).
5. **Speichern**.

### Verfügbare Regelfelder

| Feld | Operatoren | Hinweis |
|------|-----------|---------|
| Rating | ≥, ≤, = | Wert 0–5 |
| Color Label | ist, ist gesetzt, nicht gesetzt | Farbe aus Dropdown |
| Tag | ist | Exakter Tag-Name |
| File Type | beginnt mit, ist gleich, gesetzt, nicht gesetzt | z. B. `image/`, `audio/` |
| Extension | ist gleich | z. B. `mp3`, `pdf` |
| Resume | hat Resume, kein Resume | Für begonnene Wiedergabe |
| Custom Properties | enthält, ist gleich, ist gesetzt, nicht gesetzt | Benutzerdefinierte Felder |

### Smart-Filter bearbeiten / löschen

Rechtsklick auf den Smart-Filter in der Sidebar → „Bearbeiten" oder „Löschen".

---

## 9. Custom Properties

Custom Properties ermöglichen benutzerdefinierte Metadatenfelder, die für alle
Assets der Bibliothek verfügbar sind.

### Verwaltung

⋮-Menü (oben rechts) → **Custom Properties** → Dialog öffnet sich.

- **Neue Eigenschaft:** „Eigenschaft hinzufügen" → Name und Typ festlegen → Speichern.
- **Bearbeiten:** Stift-Symbol neben der Eigenschaft.
- **Löschen:** Papierkorb-Symbol → Bestätigung erforderlich.
  > Beim Löschen werden alle gespeicherten Werte dieser Eigenschaft unwiderruflich entfernt.

### Feldtypen

| Typ | Darstellung im Detail-Panel |
|-----|-----------------------------|
| Text | Einzeiliges Textfeld |
| Zahl | Numerisches Textfeld |
| Datum | Textfeld (Format: YYYY-MM-DD) |
| Ja/Nein | Checkbox |
| URL | Textfeld mit Link-Symbol |
| Auswahl (einfach) | Dropdown mit definierten Optionen |
| Auswahl (mehrfach) | Filter-Chips für Mehrfachauswahl |

### Werte eintragen

Im Detail-Panel erscheinen die benutzerdefinierten Felder unterhalb der
Medien-Template-Daten. Werte werden nach dem Verlassen des Feldes (Enter /
Tab / Klick außerhalb) automatisch gespeichert.

### In Smart-Filter nutzen

Im Smart-Filter-Editor erscheinen Custom Properties im Feld-Dropdown mit dem
Präfix des Eigenschaftsnamens. Verfügbare Operatoren: enthält, ist gleich,
ist gesetzt, nicht gesetzt.

---

## 10. Medien-Wiedergabe & Queue

### Dateien öffnen

- **Doppelklick** auf ein Audio- oder Video-Asset startet die Wiedergabe im Player.
- **Bilder:** Vollbild-Viewer mit Zoom und Schwenk.
- **PDFs / ePubs / Markdown:** Integrierter Dokumenten-Viewer.
- **Nicht unterstützte Formate:** werden mit der System-Standard-App geöffnet.

### Video-Player

| Taste / Aktion | Funktion |
|----------------|---------|
| `Space` | Pause / Wiedergabe |
| `F` | Vollbild ein/aus |
| `Escape` | Player schließen |
| `←` / Replay-10-Schaltfläche | 10 Sekunden zurück |
| `→` / Forward-30-Schaltfläche | 30 Sekunden vor |
| Geschwindigkeit (Toolbar oben) | 0,5× bis 2,0× |
| Klick ins Video | Pause / Wiedergabe |

### Audio-Player

Zeigt Albumcover-Platzhalter, Titel, Fortschrittsbalken und Geschwindigkeitsregler.
Der Ton läuft im Hintergrund weiter, wenn der Player-Screen verlassen wird –
der Mini-Player in der Toolbar übernimmt die Steuerung.

### Mini-Player (Hintergrundwiedergabe)

Der Mini-Player erscheint am unteren Rand, sobald ein Asset im Hintergrund spielt.

| Element | Funktion |
|---------|---------|
| ⏮ | Zum vorherigen Track in der Queue |
| ⏯ | Pause / Wiedergabe |
| ⏭ | Zum nächsten Track in der Queue |
| Track-Name | Klick öffnet den Vollbild-Player |
| `n / N` (z. B. „3 / 12") | Aktuelle Position in der Queue |
| Zeit | Aktuelle Position / Gesamtdauer |
| ⏹ | Wiedergabe stoppen und Queue leeren |

### Queue (Wiedergabeliste)

Beim Doppelklick auf ein abspielbares Asset wird automatisch eine Queue aus allen
abspielbaren Dateien der **aktuellen Ansicht** erstellt. Am Ende eines Tracks
startet der nächste automatisch.

**Queue-Persistenz:** Queue und aktuelle Position werden beim Schließen der App
gespeichert und beim nächsten Start der gleichen Bibliothek wiederhergestellt.
Die Wiedergabe muss manuell fortgesetzt werden (Pause → Play oder Player öffnen).

### Fortsetzen unterbrochener Wiedergabe

Wird ein Asset geöffnet, das bereits teilweise abgespielt wurde, fragt MediaShelf:
- **Fortsetzen** – springt zur gespeicherten Position.
- **Von vorne** – startet bei 0:00.

---

## 11. Datei-Operationen

### Rechtsklick-Kontextmenü (Einzeldatei)

| Aktion | Beschreibung |
|--------|-------------|
| Öffnen mit System-App | Startet die Standard-App des Betriebssystems |
| Dateipfad kopieren | Kopiert den absoluten Pfad in die Zwischenablage |
| In Ordner zeigen | Öffnet den enthaltenen Ordner im Dateimanager |
| Verschieben nach … | Verschiebt die Datei in einen anderen Bibliotheksordner |
| Kopieren nach … | Kopiert die Datei in einen anderen Bibliotheksordner |
| Löschen | Löscht die Datei unwiderruflich vom Datenträger |

### Mehrfachauswahl-Aktionen

- Bewertung für alle markierten Assets setzen
- Farbmarkierung für alle markierten Assets setzen
- Tag zu allen markierten Assets hinzufügen
- Alle markierten Assets löschen

### Drag & Drop

- Assets per Drag & Drop auf eine **Sammlung** in der Sidebar ziehen → Assets zur Sammlung hinzufügen.
- Assets per Drag & Drop auf einen **Ordner** in der Sidebar ziehen → Datei wird verschoben.

---

## 12. Suche & Filter

### Volltextsuche

Die Suchleiste in der Toolbar durchsucht Dateinamen, Notizen und Tag-Namen
gleichzeitig. Die Suche arbeitet mit Präfix-Matching (FTS5), d. h. `bach` findet
auch `bachkantate.mp3`.

### Schnellfilter

- **Tag-Klick in Sidebar** → filtert auf diesen Tag (inkl. Sub-Tags).
- **Ordner-Klick in Sidebar** → filtert auf diesen Ordner.
- **Sammlung / Smart-Filter** → zeigt nur Assets der Sammlung.
- **Orte-Chips im Detail-Panel** → klickbar, um direkt zum Ordner oder zur Sammlung zu springen.

### Erweiterte Filter (über Smart-Filter)

Für komplexe, gespeicherte Filter → [Abschnitt 8](#8-smart-filter).

---

## 13. Einstellungen & Tastenkürzel

### Toolbar-Elemente

| Element | Funktion |
|---------|---------|
| ☰ / ☰← | Sidebar ein-/ausblenden |
| Suchleiste | Volltextsuche |
| Größen-Schieberegler | Thumbnail-Größe (80–400 px) |
| Raster/Liste-Schaltfläche | Ansicht wechseln |
| ⬇ | Import (Ordner oder Dateien) |
| Sidebar-Symbol | Detail-Panel ein-/ausblenden |
| 🔄 | Bibliothek neu scannen |
| ⋮ | Menü (Aktivitätsprotokoll, Custom Properties, Bibliothek schließen) |

### Tastenkürzel

| Taste | Kontext | Funktion |
|-------|---------|---------|
| `Space` | Video / Audio Player | Pause / Wiedergabe |
| `F` | Video Player | Vollbild ein/aus |
| `Escape` | Video / Audio Player | Player schließen |
| `Rechtsklick` | Asset-Grid | Kontextmenü |
| `Langes Drücken` | Asset-Grid | Mehrfachauswahl aktivieren |

---

## 14. Datenbank & Datensicherung

### Speicherort

MediaShelf legt pro Bibliothek folgende Dateien an:

```
[Bibliotheksordner]/
└── .mediashelf/
    ├── library.db          ← SQLite-Datenbank (Assets, Tags, Sammlungen, Properties)
    └── thumbnails/         ← Thumbnail-Cache (kann jederzeit neu erzeugt werden)
```

### Datensicherung

Für eine vollständige Sicherung genügt es, die Datei `library.db` zu kopieren.
Thumbnails können aus den Originaldateien neu generiert werden und müssen nicht
gesichert werden.

### Datenbank-Schema-Versionen

| Schema-Version | Enthält |
|---------------|---------|
| 1 | Basis: Assets, Tags, Sammlungen, Aktivitätsprotokoll |
| 2 | Erweiterte Mediendaten (Künstler, Album, Bitrate, EXIF …) |
| 3 | Custom Properties (`property_definitions`, `asset_properties`) |

Migrationen laufen beim ersten Öffnen einer älteren Bibliothek automatisch.

### Datenbankintegrität

MediaShelf verwendet WAL-Modus und `foreign_keys=ON`. Fremdschlüssel-Kaskaden
stellen sicher, dass beim Löschen eines Assets alle zugehörigen Tags,
Collection-Einträge und Property-Werte automatisch entfernt werden.

---

*MediaShelf ist ein Open-Source-Projekt. Fehler melden und Verbesserungen vorschlagen:*
*[github.com/Fenron-dev/MediaShelf](https://github.com/Fenron-dev/MediaShelf)*
