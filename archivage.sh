#!/bin/bash

# importer le fichier conf
. "/home/justin/Documents/Cours/FISE2/S7/FISE-INFORX1/Scripting System/mini-projet/archive.conf"

wget --no-check-certificate "$archiveURL"

archive=${archiveURL##*/}

# Voir pour le warning
unzip "$archive"

# Somme de contrôle (sqldump)
currentSql=$()
# Stocker la somme précédente dans la conf

#gzip *.sql > $(date +'%Y%d%m').tgz

tar -czf $(date +'%Y%d%m').tgz *.sql
rm -vf *.sql *.zip

# Pousser sur le serveur, avec SSH ou SFTP par ex
#scp fichier destination
