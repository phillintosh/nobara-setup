# Nobara — neues System einrichten

Zwei Skripte plus die Schritte, die kein Skript übernehmen kann.

## Schnellstart

**Nobara** (Fedora-Unterbau, `dnf`):

```bash
# Teil 1 — Basis: Flathub, Enpass, VS Code, Claude Code
curl -fsSL https://nxgr.de/nobara-basis | bash

# Neu starten, dann:

# Teil 2 — Alltag: alle übrigen Programme
curl -fsSL https://nxgr.de/nobara-alltag | bash
```

**CachyOS** (Arch-Unterbau, `pacman` und AUR):

```bash
curl -fsSL https://nxgr.de/cachy-basis | bash

# Neu starten, dann:

curl -fsSL https://nxgr.de/cachy-alltag | bash
```

Die Abschnitte unten beschreiben **Nobara**. Was auf CachyOS abweicht, steht
gesammelt im Abschnitt „CachyOS statt Nobara".

Nach dem ersten Befehl steht genug, um ab hier mit Claude weiterzuarbeiten.
Beide Skripte laufen ohne Schaden mehrfach.

Wer wissen will, wohin ein Kurzlink zeigt, hängt ein `+` an — das nennt das
Ziel, statt es auszuführen:

```bash
curl -fsSL https://nxgr.de/nobara-basis+
```

Wer die Befehle lieber ganz liest, klont statt zu pipen:

```bash
git clone https://github.com/phillintosh/nobara-setup.git
cd nobara-setup
less basis.sh && ./basis.sh              # Nobara
less basis-cachyos.sh && ./basis-cachyos.sh   # CachyOS
```

## Wie die Abschnitte zu lesen sind

Jede Überschrift unten sagt, wer den Abschnitt erledigt:

| Kennzeichen | Bedeutung |
|---|---|
| *basis.sh* / *alltag.sh* | Das Skript macht es, nichts abzutippen |
| *Handarbeit* | Kein Skript kann das, Schritt für Schritt folgen |
| *gemischt* | Installation per Skript, Einstellungen von Hand |

**Reine Handarbeit**, auch nach beiden Skripten: Fensterverhalten, Uhr,
OpenRGB-Profil, NAS, Dropbox, Librewolf-`about:config`, Thunderbird-Konten,
Enpass-Autostart, Affinity und Battle.net. Auf Nobara kommt der
WoWUp-Menüeintrag dazu; auf CachyOS legt ihn das AUR-Paket selbst an.

**Feste Regel:** Dropbox bleibt wie unten beschrieben (RPM von der Webseite,
Nautilus-Paket). Andere Wege haben Probleme gemacht. Der Befehl dort steht
bewusst ohne `-y`.

**Private Adressen** — NAS, Adressbuch, Kalender — stehen nicht in diesem
Repo, sondern in Enpass unter der sicheren Notiz „Nobara Einrichtung".

**Woher ein neues Programm kommt:** erst `dnf`, dann Flatpak. Was ins System
greift, gehört ins System — Dateimanager-Erweiterungen, Entwicklungswerkzeuge,
Fernwartung. Was nur ein Fenster ist, darf gekapselt sein.

Stand: 2026-09-21 · Nobara 44 und CachyOS (Arch)

---

## 0. Vor der Installation (an einem anderen Rechner)  ·  *Handarbeit, an einem anderen Rechner*

> Dieser Abschnitt gilt für **Nobara**. Für CachyOS gelten dieselben drei
> Schritte — ISO laden, Prüfsumme vergleichen, Stick schreiben — nur mit dem
> Abbild von cachyos.org und der dort angegebenen Prüfsumme. Balena Etcher
> liegt auf Arch im AUR (`balena-etcher`), der Stick wird aber ohnehin an
> einem Rechner geschrieben, der schon läuft.

**ISO prüfen**

    Nobara-44-Official-2026-08-28.iso
    sha256sum: 7527b2091a0e2de04a2939e24e9a65331431719a238dc2ca2d08acddd1da296b

    sha256sum ~/Downloads/Nobara-44-Official-2026-08-28.iso

**Balena Etcher** (schreibt den Stick)

Repo-Anleitung: https://github.com/balena-io/etcher#redhat-rhel-and-fedora-based-package-repository-gnulinux-x86x64

    cd ~/Downloads
    sudo dnf install -y ./balena-etcher-*.rpm

> Dateiname nicht auf eine Version festnageln, die Nummer wechselt.

---

## 1. Grundlage  ·  *basis.sh und alltag.sh*

**Paketquellen und Gamescope**

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo dnf install -y gamescope

**Systemupdate**

    nobara-sync cli && flatpak update -y && flatpak uninstall --unused -y

Danach neu starten.

> Der zweite Flatpak-Befehl räumt Laufzeitumgebungen weg, die kein Programm
> mehr braucht. Ohne ihn sammeln sich alte Fassungen an: gemessen am
> 2026-09-20 lagen 8,7 GB auf der Platte, davon nur 1,4 GB die Programme
> selbst.

**Deutsche Rechtschreibprüfung**

    sudo dnf install -y hunspell-de langpacks-de

---

## 2. Systemeinstellungen (KDE)  ·  *Handarbeit*

- **Fensterverhalten** → „Verhindern unerwünschter Aktivierung" → **Keine**
- **NAS verbinden:** `smb://`-Adresse in die Adresszeile von Dolphin
  (Adresse in Enpass, sichere Notiz „Nobara Einrichtung")
- **Uhr installieren** (aus der Software-Verwaltung). Steht so in den alten
  Notizen, der genaue Schritt ist nicht mehr festgehalten — hier nur als
  Erinnerung, dass es zu tun ist.
- **OpenRGB:**
  1. Profil erstellen und anpassen
  2. Systemeinstellungen → Autostart → OpenRGB hinzufügen
  3. Bei diesem Eintrag als Argumente eintragen:
     `--profile NAME.orp --startminimized`

---

## 3. Passwörter und Dateien  ·  *gemischt*

**Enpass**

    sudo curl -fsSL https://yum.enpass.io/enpass-yum.repo -o /etc/yum.repos.d/enpass.repo
    sudo dnf install -y enpass

Danach in den Autostart-Eintrag `-minimize` ergänzen. **Das macht kein
Skript.**

**Tresor über WebDAV einbinden.** Enpass ist nach der Installation leer. Der
Tresor liegt auf dem eigenen WebDAV-Server und wird beim ersten Start geholt:

1. Enpass öffnen → **vorhandenen Tresor wiederherstellen** (nicht „neu
   anlegen", das legt einen zweiten an).
2. Als Quelle **WebDAV** wählen.
3. Adresse, Benutzername und Passwort des WebDAV-Zugangs eingeben.
4. Master-Passwort des Tresors eingeben.

> ⚠️ **Diese vier Angaben dürfen nicht nur im Tresor stehen.** Sie sind der
> Schlüssel zu ihm selbst — wer sie dort ablegt, sperrt sich auf einem
> frischen Rechner aus. Sie kommen vom Telefon, auf dem Enpass schon
> eingerichtet ist, oder von einem Zettel. Nicht aus dieser Datei und nicht
> aus dem NAS, dessen Adresse ihrerseits im Tresor steht.

Erst danach sind NAS, Adressbuch und Kalender greifbar, und erst danach
ergeben die Verweise auf die sichere Notiz „Nobara Einrichtung" unten einen
Sinn.

**Dropbox** — bleibt unverändert

Paket von https://www.dropbox.com/install-linux laden, dann:

    cd ~/Downloads
    sudo dnf install ./nautilus-dropbox-*.rpm

> ⚠️ **Auf CachyOS geht das so nicht** — Arch kennt keine RPM-Pakete. Der
> nächstliegende Weg wäre `dropbox` und `nautilus-dropbox` aus dem AUR; beide
> packen denselben offiziellen Dropbox-Daemon, nur anders verpackt. Das ist
> eine echte Abweichung von der Regel „Dropbox bleibt, wie es ist", deshalb
> steht sie in keinem Skript und wartet auf eine Entscheidung. Siehe „Offen
> für die nächste Runde".

**Filezilla**

    sudo dnf install -y filezilla

---

## 4. Browser und Mail  ·  *gemischt*

**Firefox und Thunderbird**

    sudo dnf install -y firefox thunderbird

Thunderbird danach verbinden. Die beiden Adressen stehen in Enpass unter der
sicheren Notiz **„Nobara Einrichtung"**:

- Adressbuch (CardDAV)
- Kalender (CalDAV)

**Librewolf**

    sudo dnf config-manager addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo
    sudo dnf install -y librewolf

Danach `about:config`:

- `browser.startup.page` → `3` (gespeicherte Tabs)
- `identity.fxaccounts.enabled` → `true` (Synchronisierung)
- Schildsymbol neben der Adresse → Cookies freigeben

---

## 5. Kommunikation  ·  *alltag.sh*

    flatpak install -y flathub \
      org.telegram.desktop \
      com.discordapp.Discord \
      us.zoom.Zoom \
      com.anydesk.Anydesk

> **AnyDesk** ist der einzige Wackelkandidat unter den Flatpaks: Fernwartung,
> Sandbox und Wayland vertragen sich schlecht. Klemmt die Bildschirmübertragung
> oder die Eingabe, das offizielle RPM von anydesk.com nehmen.

**Teamspeak 3**

    flatpak install -y flathub com.teamspeak.TeamSpeak3

> Auf Flathub liegt unter `com.teamspeak.TeamSpeak` auch TeamSpeak 6, das ist
> aber noch eine Beta (6.0.0-beta4.1, Stand 2026-09-20).

---

## 6. Notizen und Medien  ·  *alltag.sh*

    flatpak install -y flathub \
      com.notesnook.Notesnook \
      com.spotify.Client \
      org.jdownloader.JDownloader

---

## 7. Grafik  ·  *gemischt*

**Gimp**

    sudo dnf install -y gimp

**Affinity (über Wine)**

Installer: https://downloads.affinity.studio/Affinity%20x64.exe
Anleitung: https://github.com/seapear/AffinityOnLinux/blob/main/Guides/Wine/Guide.md

> Wine nimmt nur die **.exe** an. Das MSIX-Paket, das die Download-Seite
> voreingestellt anbietet, funktioniert nicht — dort „Enterprise (Intel/AMD)"
> auswählen.

1. Wine und winetricks aus Nobaras eigener Quelle

        sudo dnf install -y winehq-staging winetricks

   Prüfen: `wine --version` muss **11** oder höher zeigen.

2. Prefix anlegen

        export WINEPREFIX="/home/phil/.affinity"
        wineboot --init

   Der `export` gilt nur in dieser Shell. In einer neuen Shell die Zeile
   wiederholen, bevor es weitergeht.

3. Laufzeit-Bausteine nachrüsten

        winetricks --unattended --force remove_mono vcrun2022 dotnet48 corefonts win11

   .NET 4.8 braucht 10 bis 20 Minuten und sieht zwischendurch aus, als hinge
   es fest. Das ist normal.

4. Affinity installieren

        wine "/home/phil/Downloads/Affinity x64.exe"

   Meldungen des Windows-Installers lassen sich in der Regel mit „Nein"
   wegklicken.

5. Starten

        wine "$WINEPREFIX/drive_c/Program Files/Affinity/Affinity/Affinity.exe"

   Für einen Menü- oder Autostart-Eintrag muss `WINEPREFIX=/home/phil/.affinity`
   davorstehen, sonst greift Wine auf `~/.wine` zu.

---

## 8. Entwicklung  ·  *basis.sh*

**Claude Code**

    curl -fsSL https://claude.ai/install.sh | bash

> Nativer Installer, kein npm. Landet unter `~/.local/share/claude/versions/`
> mit einem Verweis in `~/.local/bin/claude`. Liegt `~/.local/bin` nicht im
> PATH, hilft eine neue Shell. Die Anmeldung läuft beim ersten Start.

**Visual Studio Code** (Microsoft-Repo, nicht Flatpak)

    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    sudo dnf check-update
    sudo dnf install -y code

> Bewusst kein Flatpak: dort sitzt das eingebaute Terminal in der Sandbox und
> sieht die node-, python- und git-Umgebung des Systems nicht. Erweiterungen
> wie Claude Code brauchen ebenfalls Zugriff auf das Hostsystem.

> **ComfyUI** stand hier ebenfalls, ist am 2026-09-20 vorerst
> herausgenommen worden.

---

## 9. Spiele  ·  *gemischt*

**Battle.net** (über Steam mit Proton)

1. Installer `Battle.net-Setup.exe` von https://www.blizzard.com/download
   herunterladen.

2. In Steam: **Spiele → Ein Nicht-Steam-Spiel hinzufügen → Durchsuchen**.
   Beim Dateityp auf **Alle Dateien** stellen, sonst taucht die `.exe` in der
   Auswahl nicht auf.

3. Den neuen Eintrag anklicken → **Eigenschaften → Kompatibilität** →
   „Verwendung eines bestimmten Steam-Play-Kompatibilitätswerkzeugs erzwingen"
   → **Proton - Experimental**.

   > Stand 2026-09-20 läuft der bestehende Prefix damit (Proton 11.0-100).
   > Ebenfalls installiert sind Proton 8.0 und Proton 9.0 (Beta).

4. Eintrag starten und den Installer durchlaufen lassen.

5. Danach zeigt der Steam-Eintrag noch auf den Installer. In den
   **Eigenschaften** auf die installierte Anwendung umbiegen. Den Pfad dafür
   ermitteln:

        find /home/phil/.local/share/Steam/steamapps/compatdata -maxdepth 6 -iname "Battle.net.exe"

   - **Ziel:** der gefundene Pfad, in Anführungszeichen
   - **Ausführen in:** derselbe Pfad ohne `Battle.net.exe`

   > Die Nummer im Pfad vergibt Steam beim Hinzufügen des Eintrags. Sie ist
   > nach einer Neuinstallation eine andere, deshalb steht sie hier nicht fest.

6. **Startoptionen** für Gamescope:

        gamescope -W 1920 -H 1080 -f -O AUSGANG --force-grab-cursor -- %command%

   > `AUSGANG` durch den Anschluss des Spielmonitors ersetzen. Nachsehen mit
   > `kscreen-doctor -o`, unter X11 mit `xrandr --listmonitors`.
   > Am 2026-09-20 lagen an: `DP-2` (links) und `HDMI-A-2` (rechts).

**TSM (TradeSkillMaster)**

Das Projekt veröffentlicht ein fertiges RPM. Der Befehl holt immer die
neueste Fassung, ohne dass eine Versionsnummer hier festgeschrieben wird:

    curl -s https://api.github.com/repos/exceptionptr/tsm-app-linux/releases/latest \
      | grep -o 'https://[^"]*\.noarch\.rpm' | head -1 \
      | xargs curl -L -o /tmp/tsm-app.rpm
    sudo dnf install -y /tmp/tsm-app.rpm

Start danach: `tsm-app`

> Die App braucht Python 3.11+ und PySide6, beides zieht das RPM mit.
> Sie erkennt WoW-Installationen unter Wine, Lutris und Steam selbst.

**WoWUp**

Nur als AppImage veröffentlicht, es gibt kein Flatpak und kein RPM:

    mkdir -p ~/.local/bin
    curl -s https://api.github.com/repos/WowUp/WowUp/releases/latest \
      | grep -o 'https://[^"]*\.AppImage' | head -1 \
      | xargs curl -L -o ~/.local/bin/WowUp.AppImage
    chmod +x ~/.local/bin/WowUp.AppImage

> AppImages brauchen `fuse`, das auf Nobara bereits installiert ist. Einen
> Menüeintrag legt das AppImage nicht selbst an.

**Wowhead**

Kein Linux-Programm. Die Webseite braucht keine Installation, und der
**Wowhead Client**, der Spieldaten hochlädt, gibt es ausschließlich für
Windows (geprüft am 2026-09-20). Wer ihn braucht, müsste ihn wie Battle.net
über Wine oder Lutris betreiben.

---

## CachyOS statt Nobara

Dieselben Programme, andere Paketverwaltung. Die Schritte und die Reihenfolge
sind gleich, nur die Befehle unterscheiden sich. Was von Hand zu tun ist,
ändert sich nicht.

| | Nobara | CachyOS |
|---|---|---|
| Paketverwaltung | `dnf` | `pacman` |
| Systemupdate | `nobara-sync cli` | `pacman -Syu` |
| Fremde Pakete | COPR und eigene Repos | AUR über `paru` oder `yay` |
| Enpass | eigenes yum-Repo | AUR `enpass-bin` |
| VS Code | Microsoft-Repo | AUR `visual-studio-code-bin` |
| Librewolf | eigenes Repo einrichten | `pacman -S librewolf`, liegt in `extra` |
| Wine | `winehq-staging` aus Nobaras Copr | `wine-staging` aus `extra` |
| TSM | RPM über die GitHub-Schnittstelle | AUR `tsm-app` |
| WoWUp | AppImage von Hand | AUR `wowup-bin` |
| Steam | `dnf install steam` | `multilib` muss aktiv sein |
| Dropbox | RPM von der Webseite | siehe Warnung in Abschnitt 3 |
| Deutsche Oberflächen | `langpacks-de` | `firefox-i18n-de`, `thunderbird-i18n-de` |
| Flatpak selbst | ist vorinstalliert | `pacman -S flatpak` im Basis-Skript |

**Vier Stellen, die auf CachyOS besondere Aufmerksamkeit brauchen:**

**Der AUR-Helfer ist die Voraussetzung für fast alles.** Enpass, VS Code, TSM
und WoWUp liegen alle im AUR. `paru` war bei CachyOS lange vorinstalliert,
ist es seit September 2026 aber nicht mehr, weil das Projekt lange ruht — der
letzte Stand dort ist vom Januar 2026, die letzte Fassung vom Juli 2025. Das Basis-Skript sucht deshalb der Reihe
nach: vorhandenes `paru`, vorhandenes `yay`, `paru` aus den CachyOS-Quellen,
und baut zur Not `yay-bin` selbst.

**VS Code muss aus dem AUR kommen, nicht aus `extra`.** Das Paket `code` in
den Arch-Quellen ist der quelloffene Bau ohne Zugang zum
Microsoft-Marktplatz. Die Claude-Code-Erweiterung gibt es dort nicht. Nötig
ist `visual-studio-code-bin`.

**`multilib` muss aktiv sein, sonst fehlt Steam.** Nur Steam — `wine-staging`
liegt in `extra` und zieht keine `lib32`-Abhängigkeiten, es läuft auch ohne.
Bei CachyOS ist multilib ab Werk eingeschaltet. Ist es aus, nimmt das
Alltag-Skript Steam aus der Liste und macht weiter, statt an dieser Stelle
abzubrechen.

**Librewolf ist auf CachyOS einfacher**: Es liegt inzwischen in den offiziellen
Arch-Quellen, das Einrichten eines Fremdrepos entfällt. Die drei Werte in
`about:config` bleiben trotzdem Handarbeit.

---

## Offen für die nächste Runde

Punkte, die noch entschieden werden müssen:

1. **Dropbox auf CachyOS.** Arch kennt keine RPM-Pakete, der bisherige Weg
   greift dort nicht. Die AUR-Pakete `dropbox` und `nautilus-dropbox` packen
   denselben offiziellen Daemon, sind aber nicht derselbe Weg. Weil die Regel
   ausdrücklich „Dropbox bleibt, wie es ist" lautet, entscheidet das Phil,
   nicht das Skript.
2. **Wowhead Client:** Wird er überhaupt gebraucht? Er läuft nur unter Wine,
   das Addon selbst sammelt auch ohne ihn.

### Beim Aufräumen bereits korrigiert

- `sudo snapd refresh` hieß richtig `sudo snap refresh` — inzwischen ganz
  entfallen, siehe „Paketwege“ unten
- `WINEPREFIX="home/phil/..."` → `/home/phil/...` (führender Schrägstrich
  fehlte an drei Stellen, auch beim Installer-Pfad)
- `identity.fxaccounts.enabled auf 1` → `true` (ist ein Ja/Nein-Wert)
- `-y` bei den dnf- und flatpak-Befehlen gesetzt, mit einer Ausnahme:
  Dropbox bleibt unverändert, dort wird bewusst nachgefragt
- Balena-Etcher-Dateiname von der festen Version `2.1.6` gelöst

### Affinity, überarbeitet am 2026-09-20

- **WineHQ-Fremdquelle entfällt.** Nobara 44 liefert Wine selbst mit
  (`winehq-staging` 11.13 aus Nobaras Copr, auf diesem Rechner bereits
  installiert). Die alte Notiz richtete ein WineHQ-Repo für **Fedora 41** ein,
  das dort nur Wine 10.18 hat. Damit fallen auch `sudo rm -f` auf eine fremde
  Repo-Datei und `gpgcheck=0` weg.
- **Drei Schritte entfallen durch Wine 11.** Der Herstellerleitfaden verlangt
  ab Wine 10.17 zusätzlich `Windows.winmd`, eine `wintypes.dll` und einen
  Bibliotheks-Override in `winecfg` — ab Wine 11 nicht mehr. Diese drei
  Schritte fehlten in der alten Notiz ohnehin, also hätte sie so nicht
  funktioniert.
- **Weg A (`python3-pyqt6`) ist raus.** Das war die Abhängigkeit für das
  grafische Installer-Skript von AffinityOnLinux, das wir nicht nehmen. Jetzt
  gibt es nur noch einen Weg.
- **winetricks bleibt.** Es lässt sich nicht herausnehmen: `vcrun2022`,
  `dotnet48` und `corefonts` müssen in den Prefix, und auch das offizielle
  Installer-Skript des Projekts bricht ohne winetricks ab. Neu ist, dass es
  jetzt mitinstalliert wird statt unerwähnt vorausgesetzt zu werden.
- **Hinweis ergänzt, dass nur die .exe funktioniert.** Die Download-Seite
  bietet als Erstes ein MSIX-Paket an, das unter Wine nicht läuft.

### Paketwege, entschieden am 2026-09-20

- **Snap ist raus.** `snapd`, der `/snap`-Symlink und `snap refresh` standen in
  den Notizen, aber auf dem Rechner war snapd nie installiert und kein einziges
  Snap vorhanden. Drei Befehle weniger, darunter der heikle `ln -s`.
- **Regel festgehalten:** erst `dnf`, dann Flatpak. Sechs der acht genutzten
  Flatpaks stehen in keinem Repo, dort gibt es ohnehin keine Wahl.
- **VS Code nur noch über das Microsoft-Repo.** So läuft es auf dem Rechner
  bereits (Version 1.134.0). Der Flatpak sperrt das eingebaute Terminal in die
  Sandbox und schneidet es von node, python und git ab.
- **Discord bleibt Flatpak**, obwohl es das Paket auch im `terra`-Repo gibt.
  Discord sperrt den Login, wenn ein Update aussteht, und Flathub zieht
  schneller nach als ein Distributionspaket.
- **Aufräumbefehl ins Update aufgenommen.** `flatpak uninstall --unused -y`
  entfernt Laufzeitumgebungen, die kein Programm mehr braucht. Am 2026-09-20
  lagen zwei NVIDIA-Runtimes zu je 822 MB parallel auf der Platte.
- **AnyDesk als Vorbehalt vermerkt**, siehe Abschnitt 5.

### Battle.net, erneuert am 2026-09-20

- **Der feste Monitor-Ausgang ist raus.** Die alte Startoption nannte
  `HDMI-A-1`, den es nicht mehr gibt. Statt eines festen Werts steht dort
  jetzt ein Platzhalter mit einer Notiz, wie er zu ermitteln ist.
- **Die feste Prefix-Nummer ist raus.** `2885867330` vergibt Steam beim
  Hinzufügen des Eintrags, nach einer Neuinstallation steht dort eine andere
  Zahl. Statt des festen Pfads steht jetzt der `find`-Befehl da, der ihn in
  einem Zug ermittelt.
- **Der fehlende Vorschritt ist ergänzt:** Installer laden, als Nicht-Steam-
  Spiel eintragen, Proton erzwingen, installieren, danach den Eintrag auf die
  installierte Anwendung umbiegen. Das erklärt auch, warum Ziel und
  „Ausführen in" überhaupt von Hand gesetzt werden müssen.

### Programme ergänzt am 2026-09-20

- **TSM:** Das Projekt veröffentlicht ein fertiges `.noarch.rpm`. Der fehlende
  Installationsschritt ist damit ein Befehl, der die neueste Fassung über die
  GitHub-Schnittstelle auflöst — ohne Versionsnummer in der Notiz.
- **Teamspeak:** Liegt auf Flathub (`com.teamspeak.TeamSpeak3`, 3.6.2). Die
  Webseiten-Anleitung entfällt. TeamSpeak 6 ist dort noch Beta.
- **WoWUp:** Nur als AppImage, kein Flatpak und kein RPM. Auch hier löst der
  Befehl die neueste Fassung selbst auf. Zuletzt v2.23.1 vom 2026-08-31, das
  Projekt wird also gepflegt.
- **Wowhead:** Gibt es für Linux nicht. Die Downloadseite nennt ausschließlich
  Windows. Als Notiz vermerkt statt als Schritt.
- **ComfyUI** ist auf Wunsch vorerst herausgenommen.

### Tresor-Weg ergänzt, 2026-09-20

Die Prüfung hatte als letzte Lücke gemeldet, dass Enpass zwar installiert
wird, der Tresor aber leer bleibt und alle privaten Adressen genau darin
liegen. Der Weg ist WebDAV, er steht jetzt in Abschnitt 3 — mitsamt der
Warnung, dass Adresse, Zugang und Master-Passwort nicht im Tresor selbst
abgelegt werden dürfen.

### Nach der Prüfung überarbeitet, 2026-09-20

Ein Prüflauf gegen die Frage „kommt ein Fremder damit ans Ziel" brachte
18 Befunde. Zwei davon waren echte Fehler, die das Alltag-Skript mitten im
Lauf beendet hätten:

- **Die Rückfallzweige waren nicht erreichbar.** Unter `set -euo pipefail`
  übernimmt eine Zuweisung wie `url=$(curl … | grep …)` den Rückgabewert der
  Pipeline. Ging `grep` leer aus — etwa weil das Stundenkontingent der
  GitHub-Schnittstelle erschöpft war — endete das Skript sofort, statt die
  vorgesehene Warnung auszugeben. WoWUp, das Aufräumen und die
  Handarbeitsliste am Ende entfielen dann stillschweigend. Behoben mit einem
  ausdrücklichen `|| url=""`, nachgestellt und gegengeprüft.
- **`flatpak install --noninteractive` brach ab**, sobald neben dem
  System-Remote noch ein Benutzer-Remote namens `flathub` eingetragen war:
  „found in multiple installations". Genau so steht es auf dem jetzigen
  Rechner. Behoben durch ein ausdrückliches `--system`.

Weiter behoben: `dnf config-manager addrepo` scheiterte beim zweiten Lauf
(jetzt `--overwrite`), `grep '^flathub'` hätte auch `flathub-beta` als
Treffer gewertet (jetzt `grep -qx`), die Prüfung auf Claude Code fand eine
frische Installation im selben Terminal nicht, `flatpak update` fehlte, der
Neustart nach dem Systemupdate wurde nicht erwähnt, Steam war vorausgesetzt
aber nirgends installiert, und die Handarbeitsliste im Skript war kürzer als
die im README.

Am README: Die Schnellstart-Befehle zeigten auf eine tote Adresse, ohne dass
irgendwo die Dateinamen oder ein Klon-Weg standen. Claude Code wurde vom
Skript installiert, kam im README aber nicht vor. Jede Überschrift sagt
jetzt, wer den Abschnitt erledigt.

Nicht übernommen wurde der Hinweis, die „Uhr" sei eine Aufgabe ohne Weg —
das ist so gewollt, sie steht ausdrücklich nur als Erinnerung.

### Kurzlinks, 2026-09-20

Die Skripte laufen über `nxgr.de`, den eigenen Kurzlink-Dienst auf dem
Server in Deutschland — kein fremder Anbieter im Datenpfad. Angelegt und
geprüft vom Group-Chat, hier gegengeprüft: dreimal 302 auf die richtige
Adresse, und `curl -fsSL https://nxgr.de/nobara-basis` liefert tatsächlich
den Skriptkopf.

Die Kennungen `nobara-basis`, `nobara-alltag` und `nobara-setup` stehen
dauerhaft und werden nie wiederverwendet. Zieht ein Ziel um, wird der Link
umgehängt statt neu vergeben.

> Ein Kurzlink ist ein Glied mehr in der Kette: Wer sein Ziel ändern kann,
> führt Code auf jedem frisch eingerichteten Rechner aus. Ändern kann das
> heute allein Phil. Wer dem Befehl trotzdem nicht traut, hängt ein `+` an
> und sieht das Ziel, bevor etwas läuft.

`curl`-Aufrufe werden nicht mitgezählt, der Dienst erkennt Maschinen am
User-Agent. Die Installationsaufrufe verfälschen die Klickzahlen also nicht.

### CachyOS ergänzt, 2026-09-21

Zwei eigene Skripte statt Verzweigungen in den bestehenden. Nobara und
CachyOS unterscheiden sich in fast jedem Befehl, eine gemeinsame Datei mit
Weichen wäre schwerer zu lesen als zwei getrennte.

Alle Paketnamen sind gegen die echten Quellen geprüft, nicht aus dem Kopf
geschrieben: die offiziellen Arch-Quellen über `archlinux.org/packages` und
das AUR über dessen Schnittstelle. Dabei kamen drei Dinge heraus, die man
sonst falsch gemacht hätte.

**Librewolf liegt inzwischen in `extra`** (156.0.0_1-1). Weder AUR noch
Fremdrepo nötig, anders als auf Nobara. Die alte Annahme „Librewolf kommt
immer aus einer eigenen Quelle" stimmt für Arch nicht mehr.

**`code` aus `extra` wäre die falsche Wahl** — das ist der quelloffene Bau
ohne Microsoft-Marktplatz, also ohne die Claude-Code-Erweiterung. Genau die
braucht Phil ab dem ersten Schritt.

**`paru` ist bei CachyOS nicht mehr vorinstalliert**, seit September 2026.
Das Projekt ruht seit Januar 2026, die letzte Fassung ist vom Juli 2025. Ein Skript, das `paru` einfach
voraussetzt, wäre auf einem frischen Rechner sofort gescheitert. Deshalb die
Kaskade im Basis-Skript.

Offen geblieben ist Dropbox: Der Weg über ein RPM von der Webseite hat auf
Arch kein Gegenstück, und die Regel dazu ist ausdrücklich, dass nichts
geändert wird. Das steht als Entscheidung bei Phil, nicht im Skript.

### Nach der Konsistenzprüfung überarbeitet, 2026-09-21

Ein Prüflauf gegen die Frage „sind beide Systemfassungen ein Guss" brachte
18 Befunde. Drei davon waren schwer.

- **Die multilib-Warnung war keine.** Steam liegt ausschließlich im Repo
  `multilib`. Das Skript warnte zwar, wenn dieses Repo fehlt, installierte
  Steam aber vier Zeilen später im selben Sammelbefehl wie acht andere
  Pakete. Ohne multilib wäre pacman mit „target not found" ausgestiegen und
  hätte unter `set -e` alles Weitere mitgerissen — Wine, die Flatpaks, TSM,
  WoWUp und die Handarbeitsliste. Jetzt kommt Steam nur in die Liste, wenn
  das Repo da ist.
- **Das Aufräumen hätte fremde Pakete entfernt.** `pacman -Qtdq` listet die
  verwaisten Pakete des ganzen Systems, nicht die dieses Skripts, und
  `pacman -Rns` hätte sie mitsamt Abhängigkeiten entfernt. Die Nobara-Fassung
  räumt an derselben Stelle nur Flatpak-Laufzeitumgebungen auf. Der Schritt
  ist ersatzlos gestrichen.
- **`pacman -Sy` gefolgt von `pacman -S` ist auf Arch der Weg in ein kaputtes
  System** — neue Pakete gegen alte Bibliotheken. Ersetzt durch ein
  vollständiges `-Syu`.

Dazu die Fehlerbehandlung: Der letzte Zweig der AUR-Kaskade und die beiden
AUR-Aufrufe im Basis-Skript standen nackt da. Schlug ein Bau fehl — bei
Quellpaketen die wahrscheinlichste Störung —, endete das Skript wortlos, noch
vor dem Schlusstext mit den Enpass-Schritten. Belegt war das daran, dass die
Funktion `warn()` zwar definiert, aber kein einziges Mal aufgerufen wurde.

**Zwei Befunde betrafen die Nobara-Fassung**, nicht die neue:

- **OpenRGB fehlte dort.** Beide Handarbeitslisten verlangen, ein
  OpenRGB-Profil anzulegen, aber nur das CachyOS-Skript installierte das
  Programm. Auf Nobara liegt es in `nobara-updates` und ist jetzt ergänzt.
- **Der Flathub-Wächter prüfte einen anderen Geltungsbereich als der spätere
  Befehl.** `flatpak remotes` listet System- und Benutzer-Remotes, installiert
  wird aber mit `--system`. Gibt es nur ein Benutzer-Remote namens `flathub`,
  ging die Prüfung durch und der Install scheiterte. Das ist die Rückseite
  genau des Fehlers, der am 20.09. mit `--system` behoben wurde — beim
  Beheben wurde damals nur die eine Hälfte angefasst. Jetzt prüfen alle vier
  Skripte mit `--system`.

Außerdem fehlten die deutschen Oberflächen: `langpacks-de` hat auf Arch kein
Sammelpaket, `firefox-i18n-de` und `thunderbird-i18n-de` sind jetzt einzeln
drin. Ohne sie wären Firefox und Thunderbird auf Englisch gestartet.
