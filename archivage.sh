#!/bin/bash

# importer le fichier conf
. "/home/justin/Documents/Cours/FISE2/S7/FISE-INFORX1/Scripting System/mini-projet/archive.conf"

# 
wget --no-check-certificate "$archiveURL"

archive=${archiveURL##*/}

# TODO Voir pour le warning
unzip "$archive"

# sqldump
currentSql=$()
# Stocker la somme précédente dans la conf

# Archivage
# TODO être plus spécifique sur le nom
tar -czf $(date +'%Y%d%m').tgz *.sql

# Ménage
rm -vf *.sql *.zip

# Pousser sur le serveur, avec SSH ou SFTP par ex
#scp fichier destination

# Logs

# Mail
