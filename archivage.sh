#!/bin/bash

# importer le fichier conf
. "/home/justin/Documents/Cours/FISE2/S7/FISE-INFORX1/Scripting System/mini-projet/archive.conf"

wget --no-check-certificate "$archive"

unzip ${archive##*/}

# Somme de contrôle (sqldump)
currentSql=$()
# Stocker la somme précédente dans la conf

gzip archive > $(date).tgz
rm -r archive

# Pousser sur le serveur, avec SSH ou SFTP par ex
#scp fichier destination
