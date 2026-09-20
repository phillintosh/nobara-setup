#!/usr/bin/env bash
#
# Nobara — Alltag
#
# Installiert die übrigen Programme. Läuft ohne Schaden mehrfach:
# was schon da ist, wird übersprungen.
#
# Aufruf:  curl -fsSL https://pkr8.de/alltag | bash
#
# Voraussetzung: basis.sh ist gelaufen (Flathub ist eingetragen).
# Was kein Skript kann, steht im README.

set -euo pipefail

blau()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
gruen() { printf '    \033[0;32m✓ %s\033[0m\n' "$*"; }
grau()  { printf '    \033[0;90m· %s\033[0m\n' "$*"; }
warn()  { printf '    \033[0;33m! %s\033[0m\n' "$*"; }

command -v dnf >/dev/null 2>&1 || { echo "Nur für Nobara/Fedora." >&2; exit 1; }
flatpak remotes | grep -q '^flathub' || {
    echo "Flathub fehlt — erst basis.sh laufen lassen." >&2; exit 1; }

blau "Anmeldung für sudo"
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

blau "Systemupdate (dauert)"
nobara-sync cli || warn "nobara-sync übersprungen"

blau "Programme aus den Systemquellen"
sudo dnf install -y \
    firefox thunderbird filezilla gimp \
    gamescope \
    hunspell-de langpacks-de
gruen "Firefox, Thunderbird, Filezilla, Gimp, Gamescope, Rechtschreibung"

blau "Wine und winetricks (für Affinity)"
sudo dnf install -y winehq-staging winetricks
grau "installiert: $(wine --version 2>/dev/null || echo unbekannt)"

blau "Librewolf"
if rpm -q librewolf >/dev/null 2>&1; then
    grau "ist schon installiert"
else
    sudo dnf config-manager addrepo \
        --from-repofile=https://repo.librewolf.net/librewolf.repo
    sudo dnf install -y librewolf
    gruen "Librewolf installiert"
    grau "about:config noch von Hand setzen, siehe README"
fi

blau "Flatpaks"
flatpak install -y --noninteractive flathub \
    org.telegram.desktop \
    com.discordapp.Discord \
    us.zoom.Zoom \
    com.anydesk.Anydesk \
    com.teamspeak.TeamSpeak3 \
    com.notesnook.Notesnook \
    com.spotify.Client \
    org.jdownloader.JDownloader
gruen "acht Flatpaks"

blau "TSM (TradeSkillMaster)"
if rpm -q tsm-app >/dev/null 2>&1; then
    grau "ist schon installiert"
else
    tsm_url=$(curl -fsSL \
        https://api.github.com/repos/exceptionptr/tsm-app-linux/releases/latest \
        | grep -o 'https://[^"]*\.noarch\.rpm' | head -1)
    if [ -n "$tsm_url" ]; then
        curl -fsSL "$tsm_url" -o /tmp/tsm-app.rpm
        sudo dnf install -y /tmp/tsm-app.rpm
        rm -f /tmp/tsm-app.rpm
        gruen "TSM installiert ($(basename "$tsm_url"))"
    else
        warn "TSM-Download nicht gefunden, von Hand nachholen"
    fi
fi

blau "WoWUp"
if [ -x "$HOME/.local/bin/WowUp.AppImage" ]; then
    grau "liegt schon in ~/.local/bin"
else
    mkdir -p "$HOME/.local/bin"
    wowup_url=$(curl -fsSL \
        https://api.github.com/repos/WowUp/WowUp/releases/latest \
        | grep -o 'https://[^"]*\.AppImage' | head -1)
    if [ -n "$wowup_url" ]; then
        curl -fsSL "$wowup_url" -o "$HOME/.local/bin/WowUp.AppImage"
        chmod +x "$HOME/.local/bin/WowUp.AppImage"
        gruen "WoWUp geholt ($(basename "$wowup_url"))"
    else
        warn "WoWUp-Download nicht gefunden, von Hand nachholen"
    fi
fi

blau "Aufräumen"
flatpak uninstall --unused -y >/dev/null 2>&1 || true
gruen "ungenutzte Laufzeitumgebungen entfernt"

blau "Fertig"
cat <<'ENDE'

    Es fehlt noch die Handarbeit, die kein Skript übernehmen kann:

      · Dropbox      Paket von dropbox.com/install-linux laden
      · Affinity     Installer über Wine, siehe README
      · Battle.net   als Nicht-Steam-Spiel in Steam eintragen
      · OpenRGB      Profil anlegen und in den Autostart
      · Librewolf    drei Werte in about:config
      · Thunderbird  Adressbuch und Kalender (Adressen: Enpass)
      · NAS          smb-Adresse in Dolphin (Adresse: Enpass)
      · Uhr          aus der Software-Verwaltung

    Die vollständige Anleitung steht im README des Repos.

ENDE
