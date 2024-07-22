#!/bin/bash

# Funktion zur Überprüfung, ob das Skript mit sudo-Rechten ausgeführt wird
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Bitte führen Sie das Skript mit Sudo-Rechten aus."
        exit 1
    fi
}

# Funktion zum Erstellen von Verzeichnissen
create_directories() {
    read -p "Geben Sie die Verzeichnisse ein, die erstellt werden sollen (Komma getrennt): " dir_input
    IFS=',' read -r -a dir_array <<< "$dir_input"
    for dir in "${dir_array[@]}"; do
        mkdir -p "$dir"
        echo "Verzeichnis $dir erstellt."
    done
}

# Funktion zum Erstellen von Gruppen
create_groups() {
    read -p "Geben Sie die Gruppen ein, die erstellt werden sollen (Komma getrennt): " group_input
    IFS=',' read -r -a group_array <<< "$group_input"
    for group in "${group_array[@]}"; do
        groupadd "$group"
        echo "Gruppe $group erstellt."
    done
}

# Funktion zum Erstellen von Benutzern
create_users() {
    read -p "Geben Sie den Benutzernamen ein: " username
    read -p "Geben Sie das Verzeichnis für den Benutzer ein: " user_dir
    read -p "Geben Sie die Hauptgruppe für den Benutzer ein: " main_group
    read -p "Geben Sie die Nebengruppen ein (Komma getrennt, leer lassen wenn keine): " sub_groups

    if [ ! -d "$user_dir" ]; then
        mkdir -p "$user_dir"
        echo "Benutzerverzeichnis $user_dir erstellt."
    fi

    if [ -z "$sub_groups" ]; then
        useradd -m -d "$user_dir" -s /bin/bash -g "$main_group" "$username"
    else
        IFS=',' read -r -a sub_group_array <<< "$sub_groups"
        sub_group_str=$(IFS=, ; echo "${sub_group_array[*]}")
        useradd -m -d "$user_dir" -s /bin/bash -g "$main_group" -G "$sub_group_str" "$username"
    fi

    echo "$username:$username" | chpasswd
    echo "Benutzer $username erstellt und Passwort gesetzt."
}

# Hauptmenü-Funktion
main_menu() {
    while true; do
        echo "Wählen Sie eine Option:"
        echo "1) Verzeichnisse erstellen"
        echo "2) Gruppen erstellen"
        echo "3) Benutzer erstellen"
        echo "4) Beenden"
        read -p "Option: " option

        case $option in
            1) create_directories ;;
            2) create_groups ;;
            3) create_users ;;
            4) exit 0 ;;
            *) echo "Ungültige Option. Bitte wählen Sie erneut." ;;
        esac
    done
}

# Überprüfen, ob das Skript mit Sudo-Rechten ausgeführt wird
check_sudo

# Hauptmenü anzeigen
main_menu
