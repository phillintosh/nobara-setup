#!/usr/bin/env bash
#
# Nobara — Basis
#
# Bringt das Nötigste auf ein frisches System, damit ab hier mit Claude
# weitergearbeitet werden kann: Enpass für die Passwörter, VS Code und
# Claude Code als Werkzeug.
#
# Aufruf:  curl -fsSL https://pkr8.de/basis | bash
#
# Alles Weitere erledigt alltag.sh. Was kein Skript kann, steht im README.

set -euo pipefail

blau()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
gruen() { printf '    \033[0;32m✓ %s\033[0m\n' "$*"; }
grau()  { printf '    \033[0;90m· %s\033[0m\n' "$*"; }

if ! command -v dnf >/dev/null 2>&1; then
    echo "Dieses Skript ist für Nobara bzw. Fedora gedacht. Abbruch." >&2
    exit 1
fi

blau "Anmeldung für sudo"
sudo -v
# sudo-Zeitstempel frisch halten, solange das Skript läuft
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

blau "Flathub eintragen"
if flatpak remotes | grep -q '^flathub'; then
    grau "war schon eingetragen"
else
    flatpak remote-add --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo
    gruen "Flathub eingetragen"
fi

blau "Enpass"
if rpm -q enpass >/dev/null 2>&1; then
    grau "ist schon installiert"
else
    sudo curl -fsSL https://yum.enpass.io/enpass-yum.repo \
        -o /etc/yum.repos.d/enpass.repo
    sudo dnf install -y enpass
    gruen "Enpass installiert"
    grau "Autostart-Eintrag später um -minimize ergänzen"
fi

blau "Visual Studio Code"
if rpm -q code >/dev/null 2>&1; then
    grau "ist schon installiert"
else
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    printf '%s\n' \
        '[code]' \
        'name=Visual Studio Code' \
        'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
        'enabled=1' \
        'autorefresh=1' \
        'type=rpm-md' \
        'gpgcheck=1' \
        'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' \
        | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
    sudo dnf install -y code
    gruen "VS Code installiert"
fi

blau "Claude Code"
if command -v claude >/dev/null 2>&1; then
    grau "ist schon installiert ($(claude --version 2>/dev/null || echo 'Version unbekannt'))"
else
    curl -fsSL https://claude.ai/install.sh | bash
    gruen "Claude Code installiert"
    if ! printf '%s' "$PATH" | grep -q "$HOME/.local/bin"; then
        grau "~/.local/bin liegt nicht im PATH — neue Shell öffnen"
    fi
fi

blau "Basis steht"
cat <<'ENDE'

    Als Nächstes:

    1. Enpass öffnen und den Tresor verbinden.
    2. Die sichere Notiz "Nobara Einrichtung" enthält die privaten
       Adressen (NAS, Adressbuch, Kalender).
    3. Weiter mit:  curl -fsSL https://pkr8.de/alltag | bash

ENDE
