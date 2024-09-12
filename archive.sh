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
if wget -q "$archiveURL"; then

    # Stocker le nom de l'archive
    #archive=${archiveURL##*/}

    # Décompresser l'archive
    if ! unzip -q ./*.zip; then
	echo "Erreur lors de l'extraction, vérifier que \`unzip\` est bien installé et accessible."
	ecrireLog 1 "..." "erreur à l'invocation de \`unzip\`."
	exit 1
    fi
        
    # Supprimer l'archive
    rm -f ./*.zip

    # Stocker la somme de contrôle du nouveau dump
    currentChecksum=$(sha256sum ./*.sql | cut -d ' ' -f1)

    # Si la sauvegarde de somme de contrôle n'existe pas, la créer
    if [[ ! -f .prevChecksum ]]; then
	touch .prevChecksum
    fi
    
    # Vérifier les changements
    if [[ "$(head -n 1 .prevChecksum)" != "$currentChecksum" ]]; then

	# Archiver le nouveau dump
	if ! tar -czf "$(date +'%Y%d%m')".tgz ./*.sql; then
	    echo "Erreur lors de l'archivage, vérifier que \`tar\` est bien installé et accessible."
	    exit 1
	fi

	# Supprimer le dump SQL
	rm -f ./*.sql

	# Pousser sur le serveur, avec SSH (SFTP)
	if ! scp ./*.tgz "$usernameSSH@$adresseArchivage:$pathSSH"; then
	    echo "Erreur lors de la connexion SSH au serveur distant, vérifier les informations fournies."
	    exit 1
	fi

	# Supprimer l'archive
	rm -f ./*.tgz
	
	# Actualiser la somme de contrôle
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
    ecrireLog 1 "..." "URL renseignée inaccessible. Voir dans \`archive.conf\`."
    exit 1

fi

