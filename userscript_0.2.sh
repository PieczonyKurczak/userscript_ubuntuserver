#!/bin/bash

# Überprüfen, ob das Skript mit sudo-Rechten ausgeführt wird
if [ "$EUID" -ne 0 ]; then
    echo "ACHTUNG: Script MUSS mit sudo-rechten ausgeführt werden! Ende."
    exit 1
fi

# Funktion zur Eingabeaufforderung für Verzeichnisse
create_directories() {
    echo "Geben Sie die Verzeichnisse an, die Sie erstellen möchten (Komma getrennt):"
    read -p "Verzeichnisse: " directories
    IFS=',' read -r -a dir_array <<< "$directories"
    for dir in "${dir_array[@]}"; do
        sudo mkdir -p "$dir"
        echo "Verzeichnis erstellt: $dir"
    done
}

# Funktion zur Eingabeaufforderung für Gruppen
create_groups() {
    echo "Geben Sie die Gruppen an, die Sie erstellen möchten (Komma getrennt):"
    read -p "Gruppen: " groups
    IFS=',' read -r -a group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        sudo groupadd "$group"
        echo "Gruppe erstellt: $group"
    done
}

# Funktion zur Eingabeaufforderung für Benutzer
create_users() {
    while true; do
        read -p "Geben Sie den Benutzernamen ein (oder 'exit' zum Beenden): " username
        if [ "$username" == "exit" ]; then
            break
        fi
        read -p "Geben Sie das Benutzerverzeichnis für $username ein: " userdir
        read -p "Geben Sie die Hauptgruppe für $username ein: " maingroup
        read -p "Geben Sie die Nebengruppen für $username ein (Komma getrennt): " subgroup

        # Verzeichnis erstellen, falls nicht vorhanden
        if [ ! -d "$userdir" ]; then
            sudo mkdir -p "$userdir"
            echo "Benutzerverzeichnis erstellt: $userdir"
        fi

        # Benutzer erstellen
        sudo useradd -m -d "$userdir" -s /bin/bash -g "$maingroup" -G "$subgroup" "$username"
        echo "$username:$username" | sudo chpasswd
        echo "Benutzer erstellt: $username"
    done
}

# Hauptmenü
while true; do
    echo "Was möchten Sie tun?"
    echo "1. Verzeichnisse erstellen"
    echo "2. Gruppen erstellen"
    echo "3. Benutzer erstellen"
    echo "4. Beenden"
    read -p "Wählen Sie eine Option [1-4]: " choice

    case $choice in
        1) create_directories ;;
        2) create_groups ;;
        3) create_users ;;
        4) echo "Beenden..."; exit ;;
        *) echo "Ungültige Option, bitte wählen Sie zwischen 1 und 4." ;;
    esac
done
