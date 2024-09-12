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

## Fonction d'envoi de mail
function envoyerMail() {
    # TODO
    true;
}


# Vérifier si l'URL existe
if wget -q --spider "$archiveURL"; then

    # Télécharger l'archive
    wget -q "$archiveURL"

    # Stocker le nom de l'archive
    archive=${archiveURL##*/}

    # Décompresser l'archive
    unzip -q "$archive"

    # Stocker la somme de contrôle du nouveau dump
    currentChecksum=$(sha256sum ./*.sql | cut -d ' ' -f1)

    # Vérifier les changements
    if [[ "$(head -n 1 .prevChecksum)" != "$currentChecksum" ]]; then

	# Archiver le nouveau dump
	# TODO être plus spécifique sur le nom
	tar -czf "$(date +'%Y%d%m')".tgz ./*.sql

	# Supprimer les fichiers inutiles
	#rm -vf ./*.sql ./*.zip

	# Pousser sur le serveur, avec SSH ou SFTP par ex
	scp ./*.tgz "$usernameSSH@$adresseArchivage:$pathSSH"

	# Si tout va bien, actualiser la somme de contrôle
	echo "$currentChecksum" > .prevChecksum

	# Écrire le log de succès
	ecrireLog 0 "$currentChecksum"
	
	# Mail

    else

	# Afficher l'erreur à la sortie standard
	echo "Le dump a la même somme de contrôle que précédemment."

	# Écrire le log d'erreur
	ecrireLog 1 "$currentChecksum" "somme de contrôle identique à la dernière enregistrée."
	
	# Mail
	
    fi

else

    echo "L'URL de l'archive renseignée n'existe pas."

fi

