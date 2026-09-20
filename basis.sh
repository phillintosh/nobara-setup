#!/usr/bin/env bash
#
# Nobara — Basis
#
# Bringt das Nötigste auf ein frisches System, damit ab hier mit Claude
# weitergearbeitet werden kann: Enpass für die Passwörter, VS Code und
# Claude Code als Werkzeug.
#
# Aufruf:
#   curl -fsSL https://raw.githubusercontent.com/phillintosh/nobara-setup/main/basis.sh | bash
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
# sudo-Zeitstempel frisch halten. Eigene Subshell ohne set -e, damit ein
# einzelner Fehlschlag die Schleife nicht still beendet; endet mit dem Skript.
( set +e
  while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 30; done
) &
sudo_schleife=$!
trap 'kill "$sudo_schleife" 2>/dev/null || true' EXIT

blau "Flathub eintragen"
# Exakter Vergleich: "flathub-beta" darf nicht als "flathub" durchgehen.
if flatpak remotes --columns=name | grep -qx 'flathub'; then
    grau "war schon eingetragen"
else
    sudo flatpak remote-add --system --if-not-exists flathub \
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
# Nicht nur command -v: direkt nach der Installation liegt claude in
# ~/.local/bin, das in dieser Shell noch nicht im PATH sein muss.
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

    1. Enpass öffnen und den Tresor einbinden.
       Die Tresordatei liegt NICHT auf diesem Rechner — siehe README,
       Abschnitt 3.
    2. Enpass-Autostart um  -minimize  ergänzen.
    3. In der sicheren Notiz "Nobara Einrichtung" stehen die privaten
       Adressen: NAS, Adressbuch, Kalender.

    Dann weiter mit:

    curl -fsSL https://raw.githubusercontent.com/phillintosh/nobara-setup/main/alltag.sh | bash

ENDE
