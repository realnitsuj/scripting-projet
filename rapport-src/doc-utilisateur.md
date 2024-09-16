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
abstract: À voir si on met un abstract
---

# Dépendances

- [`wget`](https://www.gnu.org/software/wget/) : pour télécharger l'archive
- [`unzip`](https://infozip.sourceforge.net/UnZip.html) : pour extraire le dump SQL de l'archive
- [`tar`](https://www.gnu.org/software/tar/) : pour créer la nouvelle archive
- [`coreutils`](https://www.gnu.org/software/coreutils/), pour les commandes :
    - `date`, qui permet de nommer la nouvelle archive
    - `rm`, qui permet de nettoyer les fichiers après opération du script

# Utilisation

Cron blablabla

Il ne faut rien ajouter dans le dossier pour le bon fonctionnement du script. De plus, l'archive renseignée doit contenir uniquement le dump SQL, sans sous-dossier ni autres fichiers.

# Configuration

Ce script est entièrement configurable via les variables présentes dans le fichier `archive.conf`.

On peut y définir :

- `archiveURL` : l'URL de l'archive contenant le dump SQL à traiter.
- `adresseArchivage` : le serveur sur lequel on veut sauvegarder l'archive du dump.
- `dumpSqlPrec` : somme de contrôle du dernier dump SQL traité.
- `mail` : mail à informer lors de l'exécution du programme.
- `emplacementLog` : définit où enregistrer le log du programme. Par défaut sur `./archive.log`.
