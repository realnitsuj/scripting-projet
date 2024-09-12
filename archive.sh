#!/bin/bash

# Importer le fichier conf
. "./archive.conf"

echo "$archiveURL"

# Vérifier si l'URL existe
if wget -q --spider "$archiveURL"; then
	# Télécharger l'archive
	wget -q "$archiveURL"

	# Stocker le nom de l'archive
	archive=${archiveURL##*/}

	# Décompresser l'archive
	unzip -q "$archive"

	# sqldump
	currentSql=$()
	# Stocker la somme précédente dans un fichier externe caché

	# Archiver le nouveau dump
	# TODO être plus spécifique sur le nom
	tar -czf "$(date +'%Y%d%m')".tgz ./*.sql

	# Supprimer les fichiers inutiles
	rm -vf ./*.sql ./*.zip

	# Pousser sur le serveur, avec SSH ou SFTP par ex
	#scp fichier destination

	# Logs

	# Mail
else
	echo "L'URL de l'archive renseignée n'existe pas."
fi
