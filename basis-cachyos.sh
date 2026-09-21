#!/usr/bin/env bash
#
# CachyOS — Basis
#
# Bringt das Nötigste auf ein frisches System, damit ab hier mit Claude
# weitergearbeitet werden kann: Enpass für die Passwörter, VS Code und
# Claude Code als Werkzeug.
#
# Aufruf:
#   curl -fsSL https://nxgr.de/cachy-basis | bash
#
# Das Gegenstück für Nobara ist basis.sh. Gleiche Schritte, andere
# Paketverwaltung.

set -euo pipefail

blau()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
gruen() { printf '    \033[0;32m✓ %s\033[0m\n' "$*"; }
grau()  { printf '    \033[0;90m· %s\033[0m\n' "$*"; }
warn()  { printf '    \033[0;33m! %s\033[0m\n' "$*"; }

if ! command -v pacman >/dev/null 2>&1; then
    echo "Dieses Skript ist für CachyOS bzw. Arch gedacht. Abbruch." >&2
    exit 1
fi
if [ "$(id -u)" -eq 0 ]; then
    echo "Nicht als root ausführen — AUR-Pakete werden als Benutzer gebaut." >&2
    exit 1
fi

blau "Anmeldung für sudo"
sudo -v
( set +e
  while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 30; done
) &
sudo_schleife=$!
trap 'kill "$sudo_schleife" 2>/dev/null || true' EXIT

blau "System auf Stand bringen"
# Vollständiges Upgrade, nicht nur -Sy: Neue Pakete gegen alte Bibliotheken
# zu installieren ist auf Arch der Weg in ein kaputtes System.
sudo pacman -Syu --noconfirm
gruen "auf Stand"

blau "AUR-Helfer"
# Enpass, VS Code, TSM und WoWUp liegen alle im AUR. Ohne Helfer
# geht auf CachyOS wenig. paru ist dort seit September 2026 nicht mehr
# vorinstalliert, deshalb die Kaskade.
if command -v paru >/dev/null 2>&1; then
    AUR=paru; grau "paru ist da"
elif command -v yay >/dev/null 2>&1; then
    AUR=yay;  grau "yay ist da"
elif sudo pacman -S --needed --noconfirm paru >/dev/null 2>&1; then
    AUR=paru; gruen "paru aus den CachyOS-Quellen installiert"
else
    grau "kein Helfer in den Quellen, yay wird gebaut"
    bau=$(mktemp -d)
    if sudo pacman -S --needed --noconfirm base-devel git \
       && git clone -q https://aur.archlinux.org/yay-bin.git "$bau/yay-bin" \
       && ( cd "$bau/yay-bin" && makepkg -si --noconfirm ); then
        rm -rf "$bau"
        AUR=yay; gruen "yay gebaut"
    else
        rm -rf "$bau"
        warn "Kein AUR-Helfer verfügbar. Enpass und VS Code kommen aus dem"
        warn "AUR, ohne Helfer geht es hier nicht weiter."
        warn "Von Hand: sudo pacman -S --needed base-devel git"
        warn "           git clone https://aur.archlinux.org/yay-bin.git"
        warn "           cd yay-bin && makepkg -si"
        exit 1
    fi
fi

# Ein fehlgeschlagener AUR-Bau soll melden, was fehlt, statt das Skript
# wortlos zu beenden — dort werden Quellen geladen und Schlüssel geprüft,
# das ist die wahrscheinlichste Störung.
aur_install() {
    if "$AUR" -S --needed --noconfirm "$@"; then
        return 0
    else
        warn "$* ließ sich nicht aus dem AUR bauen"
        return 1
    fi
}

blau "Flathub eintragen"
sudo pacman -S --needed --noconfirm flatpak >/dev/null
if flatpak remotes --system --columns=name | grep -qx 'flathub'; then
    grau "war schon eingetragen"
else
    sudo flatpak remote-add --system --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo
    gruen "Flathub eingetragen"
fi

blau "Enpass"
if pacman -Qq enpass-bin >/dev/null 2>&1; then
    grau "ist schon installiert"
else
    if aur_install enpass-bin; then
        gruen "Enpass installiert"
    else
        warn "ohne Enpass fehlen später alle privaten Adressen"
    fi
fi

blau "Visual Studio Code"
# Bewusst visual-studio-code-bin aus dem AUR, nicht "code" aus extra:
# Letzteres ist der quelloffene Bau ohne Zugang zum Microsoft-Marktplatz,
# dort fehlt die Claude-Code-Erweiterung.
if pacman -Qq visual-studio-code-bin >/dev/null 2>&1; then
    grau "ist schon installiert"
else
    if aur_install visual-studio-code-bin; then
        gruen "VS Code installiert"
    else
        warn "ohne VS Code fehlt die Oberfläche für Claude Code"
    fi
fi

blau "Claude Code"
if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; then
    grau "ist schon installiert"
else
    curl -fsSL https://claude.ai/install.sh | bash
    gruen "Claude Code installiert"
fi
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) grau "~/.local/bin liegt nicht im PATH — neue Shell öffnen" ;;
esac

blau "Basis steht"
cat <<'ENDE'

    Von Hand, in dieser Reihenfolge:

    1. Enpass öffnen, "vorhandenen Tresor wiederherstellen", Quelle
       WebDAV. Adresse, Zugang und Master-Passwort kommen vom Telefon
       oder vom Zettel, nicht aus dem Tresor selbst. README, Abschnitt 3.
    2. Enpass-Autostart um  -minimize  ergänzen.
    3. In der sicheren Notiz "Nobara Einrichtung" stehen die privaten
       Adressen: NAS, Adressbuch, Kalender.

    Dann weiter mit:

    curl -fsSL https://nxgr.de/cachy-alltag | bash

ENDE
