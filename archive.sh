#!/bin/bash

# Importer le fichier de configuration
source "./archive.conf"


###############################################
## Fonction d'écriture de log
# $1 : succès (0) / échec (1) de l'opération
# $2 : checksum du fichier concerné
# $3 : si échec, description
function ecrireLog() {
    if [[ $1 -eq 0 ]]; then
	echo "[ $(date +'%T - %d %b %Y') ] : Succès, checksum=$2" >> "$emplacementLog"
    else
	[[ $logStdout -eq 0 ]] && echo "$3"
	echo "[ $(date +'%T - %d %b %Y') ] : Échec, $3" >> "$emplacementLog"
    fi
}

## TODO Fonction d'envoi de mail
# $1 : succès (0) / échec (1)
# $2 : si échec, corps du message
function envoyerMail() {
    if [[ ${#mailDestinataires[*]} -ne 0 && (($1 -eq 1 && $envoyerMail -ne 0) || ($1 -eq 0 && $envoyerMail -eq 2)) ]]; then

	if [[ $muttrcUtilisateur -eq 0 ]]; then
	    echo "$([[ $1 -eq 0 ]] && echo L\'opération de ce jour est un succès || echo $2)" | \
		mutt -x \
		     -s "$([[ $1 -eq 0 ]] && echo $objSucces || echo $objEchec)" \
		     "$([[ ($1 -eq 0 && $joindreLog -eq 2) || ($1 -eq 1 && $joindreLog -eq 1)]] && echo -a $emplacementLog --)" \
		     "$(echo ${mailDestinataires[*]})"
	    
	else
	    echo "$([[ $1 -eq 0 ]] && echo L\'opération de ce jour est un succès || echo $2)" | \
		mutt -nx \
		     -e "set from = \"$mailEnvoyeur\"" \
		     -e "set smtp_pass = \"$motDePasse\"" \
		     -e "set smtp_url = \"smtps://$mailEnvoyeur@$serveurHote:$port\"" \
		     -s "$([[ $1 -eq 0 ]] && echo $objSucces || echo $objEchec)" \
		     "$([[ ($1 -eq 0 && $joindreLog -eq 2) || ($1 -eq 1 && $joindreLog -eq 1)]] && echo -a $emplacementLog --)" \
		     "$(echo ${mailDestinataires[*]})"
	fi
	
    fi

    # TODO : écrire dans les logs en cas d'échec, sans interrompre le programme (car il l'est par ailleurs dans tous les cas)
    [[ $? -ne 0 ]] && echo "Échec lors de l'envoi du mail."
}

###############################################
# Ménage sur le serveur d'archivage
if ! ssh "$usernameSSH@$adresseArchivage" "find $pathSSH -name *.tgz -type f -ctime +$dureeConservation -exec rm '{}' \; && exit"; then
    ecrireLog 1 "" "impossible d'accéder au serveur d'archivage renseigné via SSH, vérifier la configuration."
    # mail
    exit 1
fi

# Vérifier si l'URL existe
if ! wget -q "$archiveURL"; then
    ecrireLog 1 "" "URL renseignée inaccessible, ou \`wget\` inaccessible."
    # mail
    exit 1
fi

# Décompresser l'archive
if ! unzip -q ./*.zip; then
    ecrireLog 1 "" "erreur lors de l'invocation de \`unzip\`."
    # mail
    exit 1
fi

# Supprimer l'archive
rm -f ./*.zip

# Vérifier si il y a un seul fichier SQL
if [[ ! $(ls ./*.sql | wc -l) -eq 1 ]]; then
    ecrireLog 1 "" "structure d'archive à modifier, plusieurs fichiers SQL ou organisation inadéquate."
    # mail
    exit 1
fi

# Stocker la somme de contrôle du nouveau dump
if ! currentChecksum=$(sha256sum ./*.sql | cut -d ' ' -f1); then
    ecrireLog 1 "" "fichier SQL non trouvé, ou \`sha256sum\` inaccessible."
    # mail
    exit 1
fi


# Si la sauvegarde de somme de contrôle n'existe pas, la créer
[[ -f .prevChecksum ]] || touch .prevChecksum

# Vérifier les changements
if [[ "$(cat .prevChecksum)" == "$currentChecksum" ]]; then
    rm -f ./*.sql
    ecrireLog 1 "" "somme de contrôle identique à la dernière enregistrée."
    # Mail
    exit 1
fi

# Archiver le nouveau dump
if ! tar -czf "$(date +'%Y%d%m')".tgz ./*.sql; then
    ecrireLog 1 "" "erreur lors de la compression en tgz, vérifier que \`tar\` est installé et accessible."
    # mail
    exit 1
fi

# Supprimer le dump SQL
rm -f ./*.sql

# Pousser sur le serveur, avec SSH (SFTP)
if ! scp -q ./*.tgz "$usernameSSH@$adresseArchivage:$pathSSH"; then
    ecrireLog 1 "" "erreur lors de la connexion SSH au serveur d'archivage, vérifier les informations de connexion."
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

