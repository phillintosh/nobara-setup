#!/usr/bin/env bash
#
# Nobara — Alltag
#
# Installiert die übrigen Programme. Läuft ohne Schaden mehrfach:
# was schon da ist, wird übersprungen.
#
# Aufruf:
#   curl -fsSL https://nxgr.de/nobara-alltag | bash
#
# Voraussetzung: basis.sh ist gelaufen (Flathub ist eingetragen).
# Was kein Skript kann, steht im README.

set -euo pipefail

blau()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
gruen() { printf '    \033[0;32m✓ %s\033[0m\n' "$*"; }
grau()  { printf '    \033[0;90m· %s\033[0m\n' "$*"; }
warn()  { printf '    \033[0;33m! %s\033[0m\n' "$*"; }

command -v dnf >/dev/null 2>&1 || { echo "Nur für Nobara/Fedora." >&2; exit 1; }
flatpak remotes --columns=name | grep -qx 'flathub' || {
    echo "Flathub fehlt — erst basis.sh laufen lassen." >&2; exit 1; }

blau "Anmeldung für sudo"
sudo -v
( set +e
  while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 30; done
) &
sudo_schleife=$!
trap 'kill "$sudo_schleife" 2>/dev/null || true' EXIT

blau "Systemupdate (dauert)"
nobara-sync cli || warn "nobara-sync übersprungen"
flatpak update -y || warn "flatpak update übersprungen"

blau "Programme aus den Systemquellen"
sudo dnf install -y \
    firefox thunderbird filezilla gimp \
    gamescope steam \
    hunspell-de langpacks-de
gruen "Firefox, Thunderbird, Filezilla, Gimp, Gamescope, Steam, Rechtschreibung"

blau "Wine und winetricks (für Affinity)"
sudo dnf install -y winehq-staging winetricks
grau "installiert: $(wine --version 2>/dev/null || echo unbekannt)"

blau "Librewolf"
if rpm -q librewolf >/dev/null 2>&1; then
    grau "ist schon installiert"
else
    # --overwrite, damit ein zweiter Lauf nach einem Abbruch nicht scheitert
    sudo dnf config-manager addrepo --overwrite \
        --from-repofile=https://repo.librewolf.net/librewolf.repo
    sudo dnf install -y librewolf
    gruen "Librewolf installiert"
    grau "about:config noch von Hand setzen, siehe README"
fi

blau "Flatpaks"
# --system: auf Rechnern mit zusätzlichem Benutzer-Remote wäre "flathub"
# sonst mehrdeutig und --noninteractive bräche ab.
sudo flatpak install --system -y --noninteractive flathub \
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
    # Das || "" ist nötig: unter set -e würde die Zuweisung sonst das
    # ganze Skript beenden, sobald curl oder grep leer ausgehen.
    tsm_url=$(curl -fsSL \
        https://api.github.com/repos/exceptionptr/tsm-app-linux/releases/latest \
        2>/dev/null | grep -o 'https://[^"]*\.noarch\.rpm' | head -1) || tsm_url=""
    if [ -n "$tsm_url" ]; then
        tsm_rpm=$(mktemp --suffix=.rpm)
        if curl -fsSL "$tsm_url" -o "$tsm_rpm" && sudo dnf install -y "$tsm_rpm"; then
            gruen "TSM installiert ($(basename "$tsm_url"))"
        else
            warn "TSM ließ sich nicht installieren, von Hand nachholen"
        fi
        rm -f "$tsm_rpm"
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
        2>/dev/null | grep -o 'https://[^"]*\.AppImage' | head -1) || wowup_url=""
    if [ -n "$wowup_url" ] && curl -fsSL "$wowup_url" -o "$HOME/.local/bin/WowUp.AppImage"; then
        chmod +x "$HOME/.local/bin/WowUp.AppImage"
        gruen "WoWUp geholt ($(basename "$wowup_url"))"
        grau "Menüeintrag legt das AppImage nicht selbst an"
    else
        rm -f "$HOME/.local/bin/WowUp.AppImage"
        warn "WoWUp-Download nicht gefunden, von Hand nachholen"
    fi
fi

blau "Aufräumen"
sudo flatpak uninstall --system --unused -y >/dev/null 2>&1 || true
gruen "ungenutzte Laufzeitumgebungen entfernt"

blau "Fertig — jetzt neu starten"
cat <<'ENDE'

    Nach dem Systemupdate gehört ein Neustart dazu.

    Danach die Handarbeit, die kein Skript übernehmen kann:

      · Fensterverhalten  "Verhindern unerwünschter Aktivierung" auf Keine
      · Uhr               aus der Software-Verwaltung
      · OpenRGB           Profil anlegen und in den Autostart
      · NAS               smb-Adresse in Dolphin (Adresse: Enpass)
      · Dropbox           Paket von dropbox.com/install-linux laden
      · Librewolf         drei Werte in about:config
      · Thunderbird       Adressbuch und Kalender (Adressen: Enpass)
      · Enpass            Autostart um -minimize ergänzen
      · WoWUp             Menüeintrag anlegen
      · Affinity          Installer über Wine, siehe README
      · Battle.net        als Nicht-Steam-Spiel in Steam eintragen

    Die vollständige Anleitung steht im README des Repos.

ENDE
