# MediaShelf — Benutzerhandbuch

**Version 0.5** · Lokaler Digital Asset Manager für Desktop und Mobile

---

## Inhaltsverzeichnis

1. [Erste Schritte](#erste-schritte)
2. [Bibliothek verwalten](#bibliothek-verwalten)
3. [Dateien importieren](#dateien-importieren)
4. [Ansicht & Navigation](#ansicht-navigation)
5. [Suchen & Filtern](#suchen-filtern)
6. [Asset-Details & Metadaten](#asset-details-metadaten)
7. [Tags & Sammlungen](#tags-sammlungen)
8. [Playlists](#playlists)
9. [Medienwiedergabe](#medienwiedergabe)
10. [Mehrfachauswahl & Bulk-Aktionen](#mehrfachauswahl-bulk-aktionen)
11. [Dateien exportieren](#dateien-exportieren)
12. [Vault — Verschlüsselte Ablage](#vault)
13. [Bibliotheks-Schutz (App-Lock)](#bibliotheks-schutz)
14. [EmuVR-Plugin](#emuvr-plugin)
15. [Einstellungen](#einstellungen)
16. [Tastaturkürzel](#tastaturkurzel)

---

## Erste Schritte

### Was ist MediaShelf?

MediaShelf ist ein lokaler Digital Asset Manager (DAM). Er hilft dir, große Sammlungen von Bildern, Videos, Audio-Dateien, Dokumenten und 3D-Modellen auf deinem eigenen Gerät zu organisieren — ohne Cloud, ohne Abo.

### Erste Bibliothek einrichten

Beim ersten Start siehst du den Willkommens-Screen:

- **Bibliothek öffnen** — Wähle einen vorhandenen Ordner, der bereits Mediendateien enthält.
- **Neue Bibliothek erstellen** — Wähle einen leeren Ordner. MediaShelf legt darin automatisch den versteckten `.mediashelf`-Ordner mit Datenbank und Thumbnails an.

> **Tipp:** Eine Bibliothek ist einfach ein Ordner auf deiner Festplatte oder einem USB-Stick. Du kannst beliebig viele Bibliotheken haben und zwischen ihnen wechseln.

### Zuletzt geöffnete Bibliotheken

Der Willkommens-Screen zeigt deine zuletzt genutzten Bibliotheken. Klicke auf einen Eintrag, um ihn direkt zu öffnen. Mit dem **×**-Button entfernst du ihn aus der Liste (die Dateien bleiben dabei unberührt).

---

## Bibliothek verwalten

### Bibliothek scannen

Nach dem Öffnen einer Bibliothek kannst du mit dem **Scan**-Button in der Topbar einen Scan starten. Dabei werden:

1. **Scannen** — Neue und geänderte Dateien werden in die Datenbank aufgenommen.
2. **Thumbnails** — Vorschaubilder werden generiert und gecacht.
3. **Metadaten** — ID3-Tags, EXIF-Daten, Videoinformationen werden ausgelesen.

Ein laufender Scan zeigt Fortschritt und Phase in der Topbar an. Du kannst die Bibliothek während des Scans normal weiter nutzen.

### Aktivitäts-Log

Unter **Sidebar → Aktivität** findest du eine chronologische Liste aller Ereignisse: hinzugefügte, fehlende und wiederhergestellte Dateien. Dies hilft dir, Änderungen an deiner Bibliothek nachzuvollziehen.

---

## Dateien importieren

### Import starten

Klicke in der Topbar auf den **Import**-Button (Ordner-Symbol) und wähle:

- **Ordner importieren** — Importiert alle unterstützten Dateien aus einem Ordner und seinen Unterordnern.
- **Dateien importieren** — Wähle einzelne Dateien aus.

Alternativ kannst du Dateien und Ordner direkt **per Drag & Drop** auf das App-Fenster ziehen.

### Import-Dialog (3 Schritte)

**Schritt 1 — Pfad-Konfiguration**

- Zeigt alle Quelldateien mit Vorschau des Ziel-Pfads.
- **Pfad-Tiefe**: Stelle ein, wie viele Ordnerebenen in der Bibliothek erhalten bleiben sollen.
- **Sammlung spiegeln**: Legt automatisch eine Sammlung an, die die Ordnerstruktur des Imports abbildet.

**Schritt 2 — Duplikate**

Dateien, die bereits in der Bibliothek vorhanden sind, werden hier aufgelistet. Pro Duplikat kannst du wählen:

| Aktion | Beschreibung |
|---|---|
| Überspringen | Datei wird nicht importiert |
| Verknüpfen | Datei wird nicht kopiert, nur zur Sammlung hinzugefügt |
| Kopie importieren | Datei wird unter neuem Namen kopiert |

Mit den **Alle**-Buttons kannst du eine Aktion auf alle Duplikate auf einmal anwenden.

**Schritt 3 — Ergebnis**

Zeigt eine Zusammenfassung: wie viele Dateien kopiert, umbenannt, verknüpft oder übersprungen wurden. Fehler werden ebenfalls aufgelistet.

---

## Ansicht & Navigation

### Rasteransicht (Grid)

Die Standardansicht zeigt deine Assets als Kacheln mit Vorschaubild. Über den **Größen-Schieberegler** in der Topbar kannst du die Kachelgröße von 80 bis 400 Pixel anpassen.

Auf jeder Kachel siehst du:
- Vorschaubild (Thumbnail)
- Farb-Label (farbiger Balken oben)
- Bewertung (Sterne)
- Wiedergabedauer (bei Audio/Video)
- Resume-Badge (wenn eine Wiedergabe zwischengespeichert wurde)

### Listenansicht

Über den **Ansichts-Toggle** in der Topbar wechselst du zwischen Raster- und Listenansicht. Die Listenansicht zeigt kompakte Zeilen mit Typicon, Dateiname, Interpret und Dauer.

### Seitenleiste (Sidebar)

Die Sidebar links ist in klappbare Sektionen unterteilt:

| Sektion | Inhalt |
|---|---|
| Ordner | Ordnerstruktur der Bibliothek |
| Smarte Ordner | Gespeicherte Filterregeln |
| Sammlungen | Manuelle Gruppen |
| Tags | Alle vergebenen Tags |
| Playlists | Audio- und Video-Playlists |
| Vault | Verschlüsselte Ablage |

Jede Sektion kann mit einem Klick auf den Titel ein- und ausgeklappt werden. Der Zustand wird gespeichert.

### Detail-Panel

Das Panel rechts zeigt Informationen zum aktuell ausgewählten Asset. Es kann über den **Panel-Toggle** in der Topbar ein- und ausgeblendet werden.

### Topbar

Die Topbar enthält (von links nach rechts):

- Sidebar ein-/ausblenden
- Suchfeld
- Import-Button
- Scan-Button (mit Fortschrittsanzeige)
- Ansichtsgröße-Schieberegler
- Ansichts-Toggle (Grid/Liste)
- Detail-Panel ein-/ausblenden
- Weitere Optionen (Menü)

---

## Suchen & Filtern

### Volltextsuche

Tippe im Suchfeld der Topbar. Die Ansicht filtert sofort nach Dateiname, Pfad, Tags und Notizen. Das **×**-Symbol löscht die Suche.

### Ordner-Filter

Klicke in der Sidebar auf einen Ordner, um nur dessen Inhalte anzuzeigen. Mit dem **Unterordner-Toggle** (Baum-Symbol) entscheidest du, ob Unterordner eingeschlossen werden.

### Smarte Ordner

Smarte Ordner sind gespeicherte Filterregeln. Erstelle einen neuen über das **⚡-Symbol** in der Sidebar.

Im Editor kannst du beliebig viele Regeln kombinieren:

| Feld | Operatoren |
|---|---|
| Bewertung | ≥, ≤, = |
| Farb-Label | ist, ist gesetzt, nicht gesetzt |
| Tags | enthält, ist gleich |
| MIME-Typ | beginnt mit, ist gleich |
| Dateiendung | ist gleich |
| Resume | hat Resume, kein Resume |

Regeln werden mit **UND** (alle müssen zutreffen) oder **ODER** (mindestens eine muss zutreffen) verknüpft.

---

## Asset-Details & Metadaten

### Detail-Panel öffnen

Klicke auf ein Asset, um es im Detail-Panel rechts anzuzeigen. Ein Doppelklick öffnet es in der Vollbild-Ansicht (Viewer/Player).

### Bewertung

Klicke auf einen der **fünf Sterne** im Detail-Panel, um eine Bewertung zu vergeben. Ein weiterer Klick auf denselben Stern setzt die Bewertung zurück.

### Farb-Label

Wähle aus sechs Farben (Rot, Gelb, Grün, Blau, Lila und eine neutrale Option). Farb-Labels helfen beim schnellen visuellen Sortieren.

### Notiz

Das Notizfeld ist ein freies Textfeld für persönliche Anmerkungen. Änderungen werden automatisch gespeichert.

### Typ-spezifische Metadaten

Je nach Dateityp zeigt das Detail-Panel zusätzliche Informationen:

- **Audio**: Interpret, Album, Genre, Jahr, Dauer, Bitrate
- **Video**: Dauer, Auflösung, Codec
- **Bild**: Abmessungen, Aufnahmedatum, Kameramodell
- **Dokument**: Seitenanzahl, Autor, Verlag

### Custom Properties

Über **Eigenschaften verwalten** kannst du eigene Metadaten-Felder definieren. Unterstützte Typen:

`Text` · `Zahl` · `Ja/Nein` · `Datum` · `Auswahl` · `Mehrfachauswahl` · `Tags` · `Liste` · `URL`

### Verknüpfte Assets

Im Abschnitt **Verknüpfte Dateien** kannst du Assets miteinander verknüpfen (z.B. ein OBJ-Modell mit seinen Texturen). Klicke auf ein verknüpftes Asset, um direkt dorthin zu springen.

---

## Tags & Sammlungen

### Tags vergeben

Im Detail-Panel unter **Tags**: Tippe einen Tag-Namen und drücke Enter. Vorhandene Tags werden als Vorschläge angezeigt. Tags können hierarchisch sein (z.B. `Urlaub/Sommer/2024`).

### Tags in der Sidebar

Ein Klick auf einen Tag in der Sidebar filtert die Ansicht auf alle Assets mit diesem Tag.

### Sammlungen

Sammlungen sind manuelle Gruppen. Erstelle eine über das **Ordner+**-Symbol in der Sidebar-Sektion "Sammlungen".

Assets werden einer Sammlung zugewiesen über:
- Den Import-Dialog (Ordner-Spiegelung)
- Drag & Drop aus der Grid-Ansicht auf eine Sammlung in der Sidebar

---

## Playlists

### Playlist erstellen

Klicke auf das **Playlist+**-Symbol in der Sidebar. Playlists sind nach Medientyp getrennt (Audio / Video).

### Assets hinzufügen

Rechtsklick auf ein Asset → **Zur Playlist hinzufügen** → Playlist auswählen oder neue erstellen.

Im Detail-Panel (Abschnitt **Playlists**) siehst du alle Playlists, zu denen das Asset gehört.

### Playlist abspielen

Klicke in der Sidebar auf eine Playlist, um sie im Playlist-Screen zu öffnen. Dort kannst du:

- **Alle abspielen** — Startet die Wiedergabe von Anfang an.
- **Einzelne Tracks** anklicken — Startet ab dieser Position.
- **Reihenfolge ändern** — Ziehe Einträge per Drag & Drop um.
- **Einträge entfernen** — Klicke das **×**-Symbol neben einem Eintrag.

---

## Medienwiedergabe

### Player öffnen

Doppelklicke auf ein Audio- oder Video-Asset, um den Player zu öffnen. Alternativ: Rechtsklick → **Öffnen**.

### Audio-Player

Der Audio-Player zeigt:

- **Transport**: Play/Pause, Stop, 10s zurück, 30s vor
- **Fortschrittsleiste** — Klicken oder ziehen zum Springen
- **Zeitanzeige** — Aktuelle Position / Gesamtdauer
- **Lautstärke** — Schieberegler + Stummschalten
- **Wiedergabegeschwindigkeit** — 0,5× bis 2,0×

Der Audio-Player läuft im Hintergrund weiter, während du die Bibliothek durchstöberst.

### Video-Player

Zusätzlich zum Audio-Player:

- **Vollbild** — F-Taste oder Vollbild-Button; Klick auf das Video pausiert/spielt
- **Audiospuren** — Wechsel zwischen verfügbaren Audiospuren
- **Untertitel** — Untertitelspur auswählen oder deaktivieren
- **Wiedergabegeschwindigkeit** — 0,25× bis 2,0×

### Wiedergabe fortsetzen

Wenn du einen Film oder eine Folge mittendrin gestoppt hast, fragt der Player beim nächsten Öffnen, ob du von der gespeicherten Position fortfahren möchtest. Das **Resume-Badge** auf der Kachel zeigt an, dass ein Fortschritt gespeichert ist.

### Warteschlange (Queue)

Assets aus dem Grid können zur Warteschlange hinzugefügt werden. Die Queue-Anzeige im Player zeigt deine aktuelle Position (z.B. **3/12**). Über den Queue-Button öffnest du die vollständige Liste und kannst direkt zu einem Eintrag springen.

### Tastaturkürzel im Player

| Taste | Funktion |
|---|---|
| Leertaste | Play / Pause |
| F | Vollbild (Video) |
| Escape | Player schließen |

---

## Mehrfachauswahl & Bulk-Aktionen

### Mehrfachauswahl aktivieren

Klicke auf das **Checkbox-Symbol** einer Kachel (erscheint beim Hovern oben rechts), oder klicke bei gedrückter Shift-/Strg-Taste. Im Multi-Select-Modus zeigen alle Kacheln ihre Checkboxen.

### Bulk-Toolbar

Sobald mindestens ein Asset ausgewählt ist, erscheint die **Bulk-Toolbar** am unteren Bildschirmrand mit folgenden Aktionen:

| Aktion | Beschreibung |
|---|---|
| Bewertung | Setzt die Sternebewertung für alle ausgewählten Assets |
| Farb-Label | Weist allen ausgewählten Assets dieselbe Farbe zu |
| Tag hinzufügen | Fügt einen Tag zu allen ausgewählten Assets hinzu |
| Exportieren | Exportiert alle ausgewählten Dateien |
| Löschen | Entfernt alle ausgewählten Assets aus der Bibliothek |

Plugins (z.B. EmuVR) können eigene Buttons zur Bulk-Toolbar hinzufügen.

### Auswahl aufheben

Klicke den **×**-Button in der Bulk-Toolbar oder klicke in einen leeren Bereich des Grids.

---

## Dateien exportieren

### Export starten

Wähle Assets aus und klicke in der Bulk-Toolbar auf **Exportieren** (oder Rechtsklick → Export bei einem einzelnen Asset).

### Export-Optionen

- **Zielordner** — Wähle, wohin die Dateien exportiert werden.
- **Ordnerstruktur erhalten** — Gibt die Bibliotheks-Hierarchie im Zielordner wieder.
- **Flach exportieren** — Alle Dateien landen direkt im Zielordner ohne Unterordner.

---

## Vault — Verschlüsselte Ablage

### Was ist der Vault?

Der Vault ist eine passwortgeschützte Ablage innerhalb der Bibliothek. Dateien im Vault werden mit **AES-256-GCM** verschlüsselt auf der Festplatte gespeichert — ohne das richtige Passwort sind sie absolut nicht lesbar.

> **Wichtig:** Das Passwort wird niemals gespeichert. Wenn du es vergisst, gibt es keinen Wiederherstellungsweg. Bewahre dein Passwort sicher auf.

### Vault einrichten

Klicke in der Sidebar auf **Vault** (Schloss-Symbol, rot = gesperrt). Beim ersten Mal wirst du aufgefordert, ein Passwort zu wählen (mindestens 8 Zeichen) und es zu bestätigen.

### Vault entsperren

Klicke auf **Vault** in der Sidebar → Passwort eingeben → **Entsperren**. Das Schloss-Symbol wird grün.

### Dateien hinzufügen

Im entsperrten Vault-Screen:

1. Klicke auf den **+**-Button (oben rechts).
2. Wähle eine oder mehrere Dateien aus.
3. Die Dateien werden sofort verschlüsselt und im Vault gespeichert.

### Dateien im Vault verwalten

Klicke auf eine Vault-Kachel, um ein Kontextmenü zu öffnen:

| Aktion | Beschreibung |
|---|---|
| Öffnen / Vorschau | Datei wird temporär entschlüsselt und geöffnet |
| Entschlüsselt speichern | Du wählst einen Zielordner, die Datei wird entschlüsselt exportiert und aus dem Vault entfernt |
| Aus Vault löschen | Datei wird sicher gelöscht (verschlüsselte Datei wird vor dem Löschen überschrieben) |

### Vault sperren

Klicke auf das **Schloss**-Symbol oben rechts im Vault-Screen, oder klicke auf das Schloss-Symbol neben **Vault** in der Sidebar.

### Technische Details

| Eigenschaft | Wert |
|---|---|
| Verschlüsselung | AES-256-GCM (authentifiziert) |
| Schlüsselableitung | PBKDF2-HMAC-SHA256, 310.000 Iterationen |
| Passwort gespeichert | Nein — nur ein verschlüsselter Verifier |
| Dateinamen auf Disk | Zufällige UUIDs (`.enc`) |
| Sicheres Löschen | Dateien werden vor dem Löschen überschrieben |

---

## Bibliotheks-Schutz (App-Lock)

### Was ist der App-Lock?

Der App-Lock schützt eine Bibliothek mit einem Passwort. Wenn du diese Bibliothek öffnest — ob im Willkommens-Screen oder aus der Zuletzt-Liste — wirst du nach dem Passwort gefragt.

> **Hinweis:** Der App-Lock schützt den Zugang über MediaShelf. Die Dateien auf der Festplatte sind *nicht* verschlüsselt (dafür nutze den Vault oder VeraCrypt).

**Empfehlung für maximalen Schutz:** Speichere deine Bibliothek in einem [VeraCrypt](https://veracrypt.fr)-Container und aktiviere zusätzlich den App-Lock. So sind die Dateien selbst verschlüsselt (VeraCrypt) und die App zeigt sie nur nach Passwort-Eingabe (App-Lock).

### App-Lock einrichten

1. Öffne **Einstellungen** (Zahnrad-Symbol).
2. Wähle in der linken Spalte **Bibliotheks-Schutz**.
3. Aktiviere den Schalter **Bibliothek mit Passwort schützen**.
4. Vergib ein Passwort (mindestens 8 Zeichen) und bestätige es.

### Passwort ändern

In den Einstellungen unter **Bibliotheks-Schutz** → **Passwort ändern**.

### App-Lock deaktivieren

Schalter deaktivieren und Deaktivierung bestätigen.

### Dateinamen-Verschleierung

Wenn der App-Lock aktiv ist, kannst du zusätzlich die **Dateinamen-Verschleierung** aktivieren. Alle neu importierten Dateien erhalten dann zufällige UUID-Namen auf der Festplatte (z.B. `3f9a1b2c.jpg`). Wer in den Bibliotheksordner schaut, sieht keine echten Dateinamen.

> Diese Option betrifft nur **neue** Importe nach der Aktivierung. Bestehende Dateien werden nicht umbenannt.

---

## EmuVR-Plugin

Das EmuVR-Plugin ist ein optionales Modul zur Verwaltung von EmuVR-3D-Assets (OBJ/MTL/PNG/INI).

### Plugin aktivieren

**Einstellungen → Plugins verwalten → EmuVR UGC Manager** — Schalter aktivieren.

### Asset-Gruppen

EmuVR-Modelle bestehen aus mehreren Dateien (OBJ + MTL + PNG-Texturen + INI). Das Plugin erkennt diese Gruppen automatisch und zeigt sie im Detail-Panel zusammen an.

**Für das primäre OBJ-Asset** zeigt das Detail-Panel:

- **Tab "3D Vorschau"** — Interaktive 3D-Ansicht des Modells.
- **Tab "Dateien"** — Liste aller zugehörigen Companion-Dateien (MTL, PNG, INI).

**Für Companion-Dateien** (MTL, PNG, INI) zeigt das Detail-Panel einen Chip mit Rücksprung zum primären OBJ-Asset.

### EmuVR importieren

1. Rechtsklick in der Sidebar → **EmuVR Import** (oder über den Import-Button im EmuVR-Einstellungen-Tab).
2. Wähle den Import-Modus:
   - **Externer Ordner** — Scan eines EmuVR-Installationsordners.
   - **Bibliotheks-Rescan** — Bereits importierte Dateien erneut gruppieren.
3. Überprüfe die erkannten Gruppen und Tag-Vorschläge.
4. Starte den Import.

### EmuVR exportieren

1. Wähle OBJ-Assets per Mehrfachauswahl.
2. Klicke in der Bulk-Toolbar auf das **EmuVR-Symbol** (Gamepad).
3. Der Export-Dialog kopiert die Gruppen in die konfigurierte EmuVR-Ordnerstruktur:
   - Tag `EmuVR/Console` → `Custom/Consoles/`
   - Tag `EmuVR/Cart` → `Custom/Cartridges/`

### EmuVR-Einstellungen

**Einstellungen → Plugins → EmuVR → Einstellungen**:

- **EmuVR-Rootpfad** — Pfad zur EmuVR-Installation einstellen.
- Import-Wizard direkt starten.
- Tag-Routing-Übersicht anzeigen.

---

## Einstellungen

Öffne die Einstellungen über **Sidebar → Einstellungen** oder das Zahnrad-Symbol.

### Medien-Templates

Konfiguriere, welche Metadaten-Felder für jeden Medientyp angezeigt werden:

- **Audio, Video, Bild, Dokument** — Je ein Tab mit konfigurierbaren Feldern.
- Felder per Drag & Drop neu anordnen.
- Felder hinzufügen oder entfernen.

**Speicheroptionen** (Menü oben rechts):

| Option | Beschreibung |
|---|---|
| Global speichern | Gilt für alle Bibliotheken |
| Für Bibliothek speichern | Überschreibt globale Einstellung nur für diese Bibliothek |
| Bibliotheks-Override löschen | Stellt globale Einstellung wieder her |
| Auf Standard zurücksetzen | Setzt alle Templates zurück |
| Exportieren / Importieren | JSON-Datei für Backup oder Übertragung |

### Plugins verwalten

Aktiviere oder deaktiviere installierte Plugins. Klicke auf das Zahnrad-Symbol neben einem Plugin, um dessen eigene Einstellungen zu öffnen.

### Bibliotheks-Schutz

Konfiguriere App-Lock und Dateinamen-Verschleierung (siehe [Bibliotheks-Schutz](#bibliotheks-schutz)).

---

## Tastaturkürzel

### Allgemein

| Taste | Funktion |
|---|---|
| Escape | Aktuellen Screen / Dialog schließen |

### Audio- & Video-Player

| Taste | Funktion |
|---|---|
| Leertaste | Play / Pause umschalten |
| F | Vollbild ein-/ausschalten (Video) |
| Escape | Player schließen |

### Bild-Viewer

| Taste | Funktion |
|---|---|
| Escape | Viewer schließen |
| Mausrad | Heran-/Herauszoomen |
| Klick | Steuerelemente ein-/ausblenden |

### Dokument-Viewer

| Taste | Funktion |
|---|---|
| Escape | Viewer schließen |
| Scroll | Dokument scrollen |

---

## Häufige Fragen

**Wo werden meine Daten gespeichert?**
Alle Daten (Datenbank, Thumbnails, Vault-Dateien) liegen im versteckten `.mediashelf`-Ordner innerhalb deiner Bibliothek. Du kannst die gesamte Bibliothek auf einen USB-Stick kopieren oder verschieben — MediaShelf findet alles automatisch.

**Kann ich mehrere Bibliotheken haben?**
Ja. Jeder Ordner kann eine eigene Bibliothek sein. Du wechselst über den Willkommens-Screen zwischen ihnen.

**Was passiert, wenn ich den Vault-Schlüssel vergesse?**
Die verschlüsselten Dateien sind ohne Passwort nicht zugänglich und können nicht wiederhergestellt werden. Bewahre dein Passwort sicher auf (z.B. in einem Passwort-Manager).

**Werden meine Originaldateien beim Import verändert?**
Nein. MediaShelf kopiert Dateien in die Bibliothek und legt Thumbnails sowie Metadaten in `.mediashelf` ab. Deine Originaldateien bleiben unverändert.

**Wie groß wird der `.mediashelf`-Ordner?**
Das hängt von der Anzahl der Assets ab. Thumbnails (256×256px JPEG) benötigen ca. 15–30 KB pro Asset. Bei 10.000 Assets sind das ca. 150–300 MB.

**Kann ich MediaShelf auf mehreren Geräten nutzen?**
Die Bibliothek (mit `.mediashelf`) kann auf einem gemeinsamen Netzlaufwerk oder USB-Stick liegen. Gleichzeitiger Zugriff von mehreren Geräten wird jedoch nicht empfohlen.

---

*MediaShelf ist ein Open-Source-Projekt — Feedback und Beiträge sind willkommen.*
