# Changelog

Alle nennenswerten Änderungen an MediaShelf werden in dieser Datei dokumentiert.
Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/).
Versionierung folgt [Semantic Versioning](https://semver.org/lang/de/).

---

## [0.3.0] – 2026-03-21

### Neu
- **Playlist / Queue** — Beim Öffnen eines Audio- oder Video-Assets wird automatisch eine
  Wiedergabeliste aus allen abspielbaren Dateien der aktuellen Ansicht gebildet.
  Der Mini-Player zeigt Vor/Zurück-Tasten sowie die aktuelle Position in der Queue
  (z. B. „3 / 12"). Am Ende eines Tracks startet der nächste automatisch.
- **Queue-Persistenz** — Die aktuelle Queue (Reihenfolge + Index) wird in
  `SharedPreferences` gespeichert und nach einem App-Neustart wiederhergestellt.
  Die Wiedergabe muss vom Nutzer manuell fortgesetzt werden.
- **Custom Properties** — Benutzerdefinierte Eigenschaften pro Bibliothek (EAV-Muster).
  Typen: Text, Zahl, Datum, Ja/Nein, URL, Auswahl (einfach/mehrfach).
  Verwaltung über ⋮-Menü → „Custom Properties". Werte werden direkt im Detail-Panel
  bearbeitet und in Smart-Filter-Regeln als Bedingung genutzt (`prop:<id>`).
- **Metadaten-Extraktion** — Automatisches Auslesen von Mediendaten beim Scan:
  MP3/M4B (Titel, Künstler, Album, Genre, Track, Bitrate, Sample-Rate),
  MP4/MKV (Titel, Regisseur, Auflösung, Dauer, Bitrate),
  JPEG/PNG/HEIC (Abmessungen, Kameramodell, Aufnahmedatum),
  PDF/ePub (Titel, Autor, Verlag, Seitenanzahl).
- **Medien-Templates im Detail-Panel** — Das rechte Detail-Panel zeigt je nach Dateityp
  passende Metadatenfelder an (Audio, Video, Bild, Dokument).
- **F-Taste für Vollbild** — Im Video-Player schaltet `F` in den Vollbildmodus und zurück.
- **Listenansicht** — Alternative zur Rasteransicht mit kompakten Zeilen
  (Name, Typ, Größe, Datum). Umschalten über die Schaltfläche in der Toolbar.

### Geändert
- Datenbankschema Version 3: neue Tabellen `property_definitions` und
  `asset_properties` (Migration für bestehende Bibliotheken ab v0.2.x automatisch).
- Stop-Taste im Mini-Player löscht jetzt auch die aktuelle Queue.
- Smart-Filter-Editor unterstützt Custom Properties als Filterfelder.

### Behoben
- `DropdownButtonFormField.value` Deprecation im Properties-Dialog beseitigt.

---

## [0.2.6] – 2026-03-14

### Neu
- Metadaten-Extraktion (erste Implementierung), Listenansicht, Medien-Templates,
  farbige Sidebar-Einträge.

---

## [0.2.5] – 2026-03-07

### Neu
- Player-Controls-Layout überarbeitet, Tag-CRUD, Ordner erstellen,
  Dateien verschieben/kopieren.

---

## [0.2.4] – 2026-02-28

### Neu
- Stop-Schaltfläche, Sub-Tags, Drag-to-Sidebar, Orte-Navigation,
  Ordner-Dateianzahl in der Sidebar.

---

## [0.1.0] – 2026-01-xx

### Neu
- Erstveröffentlichung: Bibliothek öffnen/schließen, Dateien indexieren,
  Rasteransicht mit Thumbnails, Tag-System, Sammlungen, Bewertung,
  Farbmarkierung, Notizen, Audio/Video-Player, Bild-Viewer, PDF-Viewer,
  Markdown-Viewer, Smart-Filter, Aktivitätsprotokoll.
