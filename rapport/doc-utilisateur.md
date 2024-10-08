---
title: Documentation utilisateur
---

<!--Lien par références :-->
[`GNU coreutils`]: https://www.gnu.org/software/coreutils/
[`OpenSSH`]: https://www.openssh.com/

\newpage
# Dépendances

## Ordinateur client

On considère un système GNU/Linux muni des commandes de bases, donc avec [`GNU coreutils`]. Ce script dépend en plus de :

- [`wget`](https://www.gnu.org/software/wget/) : pour télécharger l'archive
- [`unzip`](https://infozip.sourceforge.net/UnZip.html) : pour extraire le dump SQL de l'archive
- [`tar`](https://www.gnu.org/software/tar/) : pour créer la nouvelle archive
- [`OpenSSH`] : en client uniquement, pour communiquer avec le serveur de sauvegarde
- [`Mutt`](http://www.mutt.org/) : pour communiquer par mail. Si la fonctionnalité de mail est désactivé, cette dépendance peut-être omise

## Serveur d'archivage

Le serveur d'archivage doit également être un système GNU/Linux muni de [`GNU coreutils`], ainsi que de [`GNU findutils`](https://www.gnu.org/software/findutils/) (pour pouvoir supprimer les fichiers trop anciens). [`OpenSSH`] doit également être installé et le serveur accessible et configuré.

# Utilisation

Pour exécuter le script, il faut lui donner les bonnes permissions (`chmod +x /path/to/archive.sh`{.bash}), puis l'exécuter (`/path/to/archive.sh`{.bash}). À chaque exécution, il faut saisir deux fois le mot de passe de l'utilisateur SSH renseigné dans la configuration. Pour que le script soit totalement autonome, voir [plus loin](#ssh).

Le script est configurable via le fichier `archive.conf`, voir la section suivante pour plus de détails.

*Il ne faut rien ajouter dans le dossier pour le bon fonctionnement du script*.  
De plus, l'archive renseignée doit contenir uniquement le dump SQL, sans sous-dossier ni autres fichiers.

# Configuration du script

Ce script est entièrement configurable via les variables présentes dans le fichier `archive.conf`.

## Configuration générale

`emplacementLog`
:   Définit où les logs sont enregistrés. Attention, l'utilisateur qui exécute le script doit avoir les droits d'écriture dans le dossier parent.

    Par défaut sur `./archive.log`.

`logStdout`
:   En cas d'échec, redirige le motif à la sortie standard (`0`) ou pas (`1`).

    Par défaut sur `0`.

`archiveURL`
:   Définit l'emplacement de l'archive via une URL, accessible depuis l'ordinateur client.

## Serveur d'archivage

`adresseArchivage`
:   Adresse IP du serveur d'archivage, qui doit être accessible via SSH. Si le port 22 est utilisé, pas besoin de le préciser.

`usernameSSH`
:   Nom d'utilisateur à utiliser sur le serveur d'archivage

`pathSSH`
:   Chemin sur lequel enregistrer les archives sur le serveur. Le chemin doit déjà exister et être accessible en lecture et écriture pour l'utilisateur renseigné à `usernameSSH`.

`dureeConservation`
:   Durée à partir de laquelle les anciennes archives seront supprimées, en jours.

    Par défaut sur `30`.

## Envoi de mails

`envoyerMail`
:   Dans quel cas envoyer un mail, jamais (`0`), en cas d'échec de l'exécution (`1`) ou toujours (`2`).

    Par défaut sur `1`.

`mailDestinataires=(dest1@mail.org dest2@mail.org)`
:   Destinataires du mail, séparés par des espaces. Si cette liste est vide, et peu importe la valeur de `envoyerMail`, le programme quittera sans envoyer de mail et sans erreur.

`objSucces`
:   Objet du mail à envoyer en cas de succès.

    Par défaut sur `Archivage du $(date +'%d %B %Y') réussi`.

`objEchec`
:   Objet du mail à envoyer en cas d'échec.

    Par défaut sur `Archivage du $(date +'%d %B %Y') échoué`.

`joindreLog`
:   Dans quelle situation joindre le fichier de logs complet, jamais (`0`), en cas d'échec (`1`) ou toujours (`2`).  
    Attention, il s'agit du fichier de log entier, le motif d'échec, si c'est le cas, est toujours indiqué dans le corps du message.
	
	Par défaut sur `1`

`muttrcUtilisateur`
:   Utiliser le `~/.muttrc` de l'utilisateur (`0`) ou non (`1`).

    Par défaut sur `1`.

### Serveur SMTP

Ces options n'auront aucune incidence si `muttrcUtilisateur=0`.

`serveurHote`
:   Serveur SMTP qui gère l'envoi de mails.

`port`
:   Port sur lequel contacter le serveur. En général, on a :

    - `25` : sans chiffrement
	- `465` : chiffrement implicite (TLS/SSL)
	- `587` : chiffrement explicite (STARTTLS)

`mailEnvoyeur`
:   Mail envoyeur des informations de l'utilitaire, enregistré sur le serveur renseigné dans `serveurHote`.

`motDePasse`
:   Mot de passe associé au mail pour s'identifier sur `serveurHote`.


# Configuration de l'environnement

## Configuration du SSH pour une exécution en autonomie {#ssh}

Pour une exécution entièrement autonome, il est nécessaire d'authentifier sa machine par clés SSH auprès du serveur d'archivage. Pour cela, depuis la machine sur laquelle on va exécuter le script :

1. `ssh-keygen -t rsa`{.bash}

   Un mot de passe est demandé, si aucun n'est voulu presser Entrée deux fois.
   
2. `ssh-copy-id -i ~/.ssh/id_rsa.pub $username@$ip`{.bash}

   Avec `$username`{.bash} le nom d'utilisateur sur le serveur d'archivage et `$ip`{.bash} l'adresse IP du serveur. Le mot de passe de l'utilisateur du serveur doit être renseigné.
   
Suite à cela, la connexion au serveur via SSH pour l'utilisateur concerné ne devrait plus nécessiter de mot de passe pour la machine cliente.

## Configuration du Cron pour une exécution quotidienne

Pour exécuter le script tous les jours à 4 h 00, avec un cron déjà configuré, après `crontab -e` (depuis un utilisateur qui a les droits nécessaires pour exécuter le script), ajouter à la fin du fichier ouvert :

```
0 4 * * * /path/to/archive.sh
```

Avec `/path/to/archive.sh` le chemin vers le script.
