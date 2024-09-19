---
documentclass: article
geometry:
- top=2cm
- right=2cm
- bottom=2cm
- left=2cm
papersize: a4
fontsize: 12pt
toc: true
numbersections: true
linkcolor: blue
lang: fr-FR

title: Utilitaire d'archivage
subtitle: Documentation utilisateur
author:
- Justin Bossard
- Antoine Feuillette
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
- [`OpenSSH`] : pour communiquer avec le serveur de sauvegarde

## Serveur d'archivage

Le serveur d'archivage doit également être un système GNU/Linux muni de [`GNU coreutils`]. [`OpenSSH`] doit également être installé et le serveur accessible et configuré.

Enfin, [`findutils`](https://www.gnu.org/software/findutils/) doit être installé pour pouvoir supprimer les fichiers plus anciens que la durée de conservation paramétrée.

# Utilisation

Pour exécuter le script, lui donner les bonnes permissions (`chmod +x /path/to/archive.sh`{.bash}), puis l'exécuter (`/path/to/archive.sh`{.bash}). À chaque exécution, il faut saisir deux fois le mot de passe de l'utilisateur SSH renseigné dans la configuration. Pour que le script soit totalement autonome, voir [plus loin](#ssh).

Le script est configurable via le fichier `archive.conf`, voir la [section suivante](#configuration) pour plus de détails.

*Il ne faut rien ajouter dans le dossier pour le bon fonctionnement du script*. De plus, l'archive renseignée doit contenir uniquement le dump SQL, sans sous-dossier ni autres fichiers.

# Configuration


Ce script est entièrement configurable via les variables présentes dans le fichier `archive.conf`.

On peut y définir :

- `archiveURL` : l'URL de l'archive contenant le dump SQL à traiter.
- `adresseArchivage` : le serveur sur lequel on veut sauvegarder l'archive du dump.
- `dumpSqlPrec` : somme de contrôle du dernier dump SQL traité.
- `mail` : mail à informer lors de l'exécution du programme.
- `emplacementLog` : définit où enregistrer le log du programme. Par défaut sur `./archive.log`.


## Configuration du SSH pour une exécution en autonomie {#ssh}

Pour plus d'informations : <https://www.cyberciti.biz/tips/ssh-public-key-based-authentication-how-to.html>.

Pour une exécution entièrement autonome, il est nécessaire d'authentifier sa machine par clés SSH auprès du serveur d'archivage. Pour cela, depuis la machine sur laquelle on va exécuter le script :

1. `ssh-keygen -t rsa`{.bash}

   Un mot de passe est demandé, si aucun n'est voulu presser Entrée deux fois.
   
2. `ssh-copy-id -i ~/.ssh/id_rsa.pub $username@$ip`{.bash}

   Avec `$username`{.bash} le nom d'utilisateur sur le serveur d'archivage et `$ip`{.bash} l'adresse IP du serveur. Le mot de passe de l'utilisateur du serveur doit être renseigné.

## Configuration du Cron pour une exécution quotidienne

Pour exécuter le script tous les jours à 3h00, avec un cron déjà configuré, après `crontab -e` (depuis un utilisateur qui a les droits nécessaires pour exécuter le script), ajouter à la fin du fichier ouvert :

```
0 3 * * * /path/to/archive.sh
```

