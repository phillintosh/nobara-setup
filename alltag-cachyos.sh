#!/usr/bin/env bash
#
# CachyOS — Alltag
#
# Installiert die übrigen Programme. Läuft ohne Schaden mehrfach:
# was schon da ist, wird übersprungen.
#
# Aufruf:
#   curl -fsSL https://nxgr.de/cachy-alltag | bash
#
# Voraussetzung: basis-cachyos.sh ist gelaufen (AUR-Helfer und Flathub).
# Was kein Skript kann, steht im README.

set -euo pipefail

blau()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
gruen() { printf '    \033[0;32m✓ %s\033[0m\n' "$*"; }
grau()  { printf '    \033[0;90m· %s\033[0m\n' "$*"; }
warn()  { printf '    \033[0;33m! %s\033[0m\n' "$*"; }

command -v pacman >/dev/null 2>&1 || { echo "Nur für CachyOS/Arch." >&2; exit 1; }
[ "$(id -u)" -ne 0 ] || { echo "Nicht als root ausführen." >&2; exit 1; }
flatpak remotes --system --columns=name 2>/dev/null | grep -qx 'flathub' || {
    echo "Flathub fehlt — erst basis-cachyos.sh laufen lassen." >&2; exit 1; }

if   command -v paru >/dev/null 2>&1; then AUR=paru
elif command -v yay  >/dev/null 2>&1; then AUR=yay
else echo "Kein AUR-Helfer — erst basis-cachyos.sh laufen lassen." >&2; exit 1; fi
aur_install() { "$AUR" -S --needed --noconfirm "$@"; }

blau "Anmeldung für sudo"
sudo -v
( set +e
  while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 30; done
) &
sudo_schleife=$!
trap 'kill "$sudo_schleife" 2>/dev/null || true' EXIT

blau "multilib prüfen (für Steam)"
# Steam liegt ausschließlich im Repo multilib. Ohne dieses Repo würde
# pacman mit "target not found" abbrechen und unter set -e das ganze
# Skript beenden — deshalb wird Steam nur dann in die Liste genommen.
if grep -qE '^\s*\[multilib\]' /etc/pacman.conf; then
    grau "ist aktiv"
    MULTILIB=ja
else
    MULTILIB=nein
    warn "multilib ist abgeschaltet, Steam wird übersprungen"
    warn "zum Nachholen in /etc/pacman.conf die Zeilen [multilib] und"
    warn "Include entsperren, dann dieses Skript erneut laufen lassen"
fi

blau "Systemupdate (dauert)"
sudo pacman -Syu --noconfirm || warn "Systemupdate übersprungen"
flatpak update -y || warn "flatpak update übersprungen"

blau "Programme aus den Systemquellen"
pakete=(
    firefox thunderbird filezilla gimp
    gamescope openrgb librewolf
    hunspell-de firefox-i18n-de thunderbird-i18n-de
)
[ "$MULTILIB" = ja ] && pakete+=(steam)
sudo pacman -S --needed --noconfirm "${pakete[@]}"
gruen "Firefox, Thunderbird, Filezilla, Gimp, Gamescope, OpenRGB, Librewolf,"
gruen "Rechtschreibung und deutsche Oberflächen"
[ "$MULTILIB" = ja ] && gruen "Steam"
grau "Librewolf kommt hier aus extra — kein Fremdrepo nötig wie auf Nobara"
grau "about:config noch von Hand setzen, siehe README"

blau "Wine und winetricks (für Affinity)"
sudo pacman -S --needed --noconfirm wine-staging winetricks
grau "installiert: $(wine --version 2>/dev/null || echo unbekannt)"

blau "Flatpaks"
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

blau "TSM und WoWUp"
# Auf Arch liegen beide im AUR — kein Herunterladen von Hand nötig,
# anders als auf Nobara, wo die Adressen über die GitHub-Schnittstelle
# aufgelöst werden mussten.
for paket in tsm-app wowup-bin; do
    if pacman -Qq "$paket" >/dev/null 2>&1; then
        grau "$paket ist schon installiert"
    elif aur_install "$paket"; then
        gruen "$paket installiert"
    else
        warn "$paket ließ sich nicht bauen, von Hand nachholen"
    fi
done

blau "Aufräumen"
# Nur Flatpak-Laufzeitumgebungen, wie in der Nobara-Fassung. Verwaiste
# pacman-Pakete werden bewusst nicht entfernt: pacman -Qtdq listet die
# Waisen des ganzen Systems, nicht die dieses Skripts.
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
      · Dropbox           siehe README, auf Arch anders als auf Nobara
      · Librewolf         drei Werte in about:config
      · Thunderbird       Adressbuch und Kalender (Adressen: Enpass)
      · Enpass            Autostart um -minimize ergänzen
      · Affinity          Installer über Wine, siehe README
      · Battle.net        als Nicht-Steam-Spiel in Steam eintragen

    Die vollständige Anleitung steht im README des Repos.

ENDE
