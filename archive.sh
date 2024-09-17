#!/bin/bash

# Importer le fichier conf
. "./archive.conf"

## Fonction d'écriture de log
# $1 : succès (0) / échec (1) de l'opération
# $2 : checksum du fichier concerné
# $3 : si échec, description
function ecrireLog() {
    if [[ $1 -eq 0 ]]; then
	echo "[ $(date +'%T - %d %b %Y') ] : Succès, checksum=$2" >> "$emplacementLog"
    else
	echo "[ $(date +'%T - %d %b %Y') ] : Échec, $3" >> "$emplacementLog"
    fi
}

## TODO Fonction d'envoi de mail
# $1 : succès (0) / échec (1)
# $2 : si échec, corps du message
function envoyerMail() {
    if [[ $1 -eq 0 ]]; then
	echo "L'opération d'archivage de ce jour est un succès." | mail -n $([[ "$joindreLog" -eq 2 ]] && echo "-a $emplacementLog ") -- justin
	echo mail
    else
	echo "idem"
    fi

    [[ $? -ne 0 ]] && echo "Échec lors de l'envoi du mail."
}


# Ménage sur le serveur d'archivage
if ! ssh "$usernameSSH@$adresseArchivage" "find $pathSSH -type f -ctime $dureeConservation -exec rm '{}' \; && exit"; then
    echo "Impossible d'accéder au serveur d'archivage."
    ecrireLog 1 "" "impossible d'accéder au serveur d'archivage renseigné via SSH, vérifier la configuration."
    # mail
    exit 1
fi

# Vérifier si l'URL existe
if ! wget -q "$archiveURL"; then
    echo "L'URL de l'archive renseignée n'existe pas, ou \`wget\` n'est pas accessible."
    ecrireLog 1 "" "URL renseignée inaccessible, ou \`wget\` inaccessible."
    # mail
    exit 1
fi

# Décompresser l'archive
if ! unzip -q ./*.zip; then
    echo "Erreur lors de l'extraction, vérifier que \`unzip\` est bien installé et accessible."
    ecrireLog 1 "" "erreur lors de l'invocation de \`unzip\`."
    # mail
    exit 1
fi

# Supprimer l'archive
rm -f ./*.zip

# Vérifier si il y a un seul fichier SQL
if [[ ! $(ls ./*.sql | wc -l) -eq 1 ]]; then
    echo "Vérifier la structure de l'archive, possiblités de plusieurs fichiers SQL ou d'une organisation inadéquate."
    ecrireLog 1 "" "structure d'archive à modifier."
    # mail
    exit 1
fi

# Stocker la somme de contrôle du nouveau dump
if ! currentChecksum=$(sha256sum ./*.sql | cut -d ' ' -f1); then
    echo "Fichier SQL non trouvé, vérifier la structure de l'archive fournie, ou \`sha256sum\` n'est pas accessible."
    ecrireLog 1 "" "fichier SQL non trouvé, ou \`sha256sum\` inaccessible."
    # mail
    exit 1
fi


# Si la sauvegarde de somme de contrôle n'existe pas, la créer
[[ -f .prevChecksum ]] || touch .prevChecksum

# Vérifier les changements
if [[ "$(cat .prevChecksum)" == "$currentChecksum" ]]; then
    rm -f ./*.sql
    echo "Le dump a la même somme de contrôle que précédemment."
    ecrireLog 1 "" "somme de contrôle identique à la dernière enregistrée."
    # Mail
    exit 1
fi

# Archiver le nouveau dump
if ! tar -czf "$(date +'%Y%d%m')".tgz ./*.sql; then
    echo "Erreur lors de l'archivage, vérifier que l'archive contient un fichier SQL, sans sous-dossiers, et que \`tar\` est bien installé et accessible."
    ecrireLog 1 "" "erreur lors de la compression en tgz, vérifier que l'archive ne contient qu'un fichier SQL sans sous-dossiers, ou que \`tar\` est installé et accessible."
    # mail
    exit 1
fi

# Supprimer le dump SQL
rm -f ./*.sql

# Pousser sur le serveur, avec SSH (SFTP)
if ! scp -q ./*.tgz "$usernameSSH@$adresseArchivage:$pathSSH"; then
    echo "Erreur lors de la connexion SSH au serveur d'archivage, vérifier les informations fournies."
    ecrireLog 1 "" "erreur lors de la connexion au serveur d'archivage, vérifier les informations de connexion."
    # mail
    exit 1
fi

# Supprimer l'archive
rm -f ./*.tgz

# Actualiser la somme de contrôle
echo "$currentChecksum" > .prevChecksum

# Écrire le log de succès
ecrireLog 0 "$currentChecksum"

# Mail de succès
envoyerMail 0

exit 0

