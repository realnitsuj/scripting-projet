#!/bin/bash

# Importer le fichier conf
. "./archive.conf"

## Fonction d'écriture de log
# $1 : emplacement des logs
# $2 : checksum du fichier concerné
# $3 : succès (0) / échec (1) de l'opération
# $4 : si échec, description
function ecrireLog() {
	if [[ $3 -eq 0 ]]; then
		echo "[ $(date +'%T - %d %b %Y') ] : Succès, checksum=$2\n" >> "$1"
	else
		echo "[ $(date +'%T - %d %b %Y') ] Échec, $4" >> "$1"
	fi
}

## Fonction d'envoi de mail
function envoyerMail() {
	# TODO
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

	# Vérifier les cahngements
	if [[ "$(head -n 1 .prevChecksum)" != "$currentChecksum" ]]; then

		# Archiver le nouveau dump
		# TODO être plus spécifique sur le nom
		tar -czf "$(date +'%Y%d%m')".tgz ./*.sql

		# Supprimer les fichiers inutiles
		rm -vf ./*.sql ./*.zip

		# Pousser sur le serveur, avec SSH ou SFTP par ex
		#scp fichier destination

		# Si tout va bien, actualiser la somme de contrôle
		echo "$currentChecksum" > .prevChecksum

		# Logs

		# Mail
	else
		echo "Le dump a la même somme de contrôle que précédemment."
		# Mail
	fi

else

	echo "L'URL de l'archive renseignée n'existe pas."

fi

