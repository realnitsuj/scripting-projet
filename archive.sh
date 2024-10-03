#!/bin/bash

# Importer le fichier de configuration
source "./archive.conf"

###############################################
## Fonction d'écriture de log
# $1 : succès (0) / échec (1) de l'opération
# $2 : si échec, description
#      si succès, checksum du fichier concerné
function ecrireLog() {
    if [[ $1 -eq 0 ]]; then
	echo "[ $(date +'%T - %d %b %Y') ] : Succès, checksum=$2" >> "$emplacementLog"
    else
	[[ $logStdout -eq 0 ]] && echo "$2"
	echo "[ $(date +'%T - %d %b %Y') ] : Échec, $2" >> "$emplacementLog"
    fi
}

## Fonction d'envoi de mail
# $1 : succès (0) / échec (1)
# $2 : si échec, corps du message
function envoyerMail() {
    if [[ ${#mailDestinataires[*]} -ne 0 && (($1 -eq 1 && $envoyerMail -eq 1) || $envoyerMail -eq 2) ]]; then

	if [[ $muttrcUtilisateur -eq 0 ]]; then
	    echo "$([[ $1 -eq 0 ]] && echo L\'opération de ce jour est un succès || echo $2)" | \
		mutt -x \
		     -s "$([[ $1 -eq 0 ]] && echo $objSucces || echo $objEchec)" \
		     $([[ $joindreLog -eq 2 || ($1 -eq 1 && $joindreLog -eq 1) ]] && echo "-a $emplacementLog --") \
		     "$(echo ${mailDestinataires[*]})"

	else
	    echo "$([[ $1 -eq 0 ]] && echo L\'opération d\'archivage de ce jour est un succès. || echo $2)" | \
		mutt -nx \
		     -e "set from = \"$mailEnvoyeur\"" \
		     -e "set smtp_pass = \"$motDePasse\"" \
		     -e "set smtp_url = \"smtps://$mailEnvoyeur@$serveurHote:$port\"" \
		     -e "set send_charset = \"utf-8\"" \
		     -s "$([[ $1 -eq 0 ]] && echo $objSucces || echo $objEchec)" \
		     $([[ $joindreLog -eq 2 || ($1 -eq 1 && $joindreLog -eq 1) ]] && echo "-a $emplacementLog --") \
		     "$(echo ${mailDestinataires[*]})"
	fi
    fi

    [[ $? -ne 0 ]] && ecrireLog 1 "erreur lors de l'envoi du mail."
}

## Fonction combo
# $1 : succès (0) / échec (1)
# $2 : si échec, description
#      si succès, checksum du fichier concerné
function combo() {
    if [[ "$1" -eq 0 ]]; then
        ecrireLog 0 "$2"
        envoyerMail 0
    else
        ecrireLog 1 "$2"
        envoyerMail 1 "L'opération d'archivage de ce jour a échoué pour le motif suivant : $2"
    fi
}

###############################################
# Ménage sur le serveur d'archivage
if ! ssh "$usernameSSH@$adresseArchivage" "find $pathSSH -name *.tgz -type f -ctime +$dureeConservation -exec rm '{}' \; && exit"; then
    combo 1 "impossible d'accéder au serveur d'archivage renseigné via SSH, vérifier la configuration."
    exit 1
fi

# Vérifier si l'URL existe
if ! wget -q "$archiveURL"; then
    combo 1 "URL renseignée inaccessible, ou \`wget\` n'est pas installé."
    exit 1
fi

# Décompresser l'archive
if ! unzip -q ./*.zip; then
    combo 1 "erreur lors de l'invocation de \`unzip\`."
    exit 1
fi

# Supprimer l'archive
rm -f ./*.zip

# Vérifier si il y a un seul fichier SQL
if [[ ! $(ls ./*.sql | wc -l) -eq 1 ]]; then
    combo 1 "structure d'archive à modifier, plusieurs fichiers SQL ou organisation inadéquate."
    exit 1
fi

# Stocker la somme de contrôle du nouveau dump
if ! currentChecksum=$(sha256sum ./*.sql | cut -d ' ' -f1); then
    combo 1 "fichier SQL non trouvé, ou \`sha256sum\` inaccessible."
    exit 1
fi

# Si la sauvegarde de somme de contrôle n'existe pas, la créer
touch .prevChecksum

# Vérifier les changements
if [[ "$(cat .prevChecksum)" == "$currentChecksum" ]]; then
    rm -f ./*.sql
    combo 1 "somme de contrôle identique à la dernière enregistrée."
    exit 1
fi

# Archiver le nouveau dump
if ! tar -czf "$(date +'%Y%d%m')".tgz ./*.sql; then
    combo 1 "erreur lors de la compression en tgz, vérifier que \`tar\` est installé et accessible."
    exit 1
fi

# Supprimer le dump SQL
rm -f ./*.sql

# Pousser sur le serveur, avec SSH (SFTP)
if ! scp -q ./*.tgz "$usernameSSH@$adresseArchivage:$pathSSH"; then
    combo 1 "erreur lors de la connexion SSH au serveur d'archivage, vérifier les informations de connexion."
    exit 1
fi

# Supprimer l'archive
rm -f ./*.tgz

# Actualiser la somme de contrôle
echo "$currentChecksum" > .prevChecksum

combo 0 "$currentChecksum"
exit 0
