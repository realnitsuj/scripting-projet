---
title: Utilitaire d'archivage
subtitle: Scripting system
author:
- Justin Bossard
- Antoine Feuillette
date: 9 octobre 2024
lang: fr-FR
slideNumber: true
controls: false
---

# Présentation de la structure

## Fichiers

```
.
|-  archive.sh      # Script
|-  archive.conf    # Fichier de configuration
|-  archive.log     # Logs du script, possibilité de modifier l'emplacement
|-  .prevChecksum   # Somme de contrôle du précédent fichier
```

## Organisation du script

3 fonctions pour une lisibilité accrues :

- `ecrireLog $1 $2`{.bash} : `$1` correspond au succès ou à l'échec de l'opération, `$2` correspond à la somme de contrôle du fichier ou au motif de l'erreur
- `envoyerMail $1 $2`{.bash} : `$2` correspond au corps du message en cas d'échec
- `combo $1 $2`{.bash} : combine les deux fonctions précédentes

## Organisation de la config

- Configuration générale
- Configuration du serveur SSH/SFTP
- Configuration des mails + serveur SMTP

# Réalisation des fonctionnalités demandées

## Serveur SFTP

## Vérification de modifications

## Envoi de mails

## Serveur Web

Apache blablabla

## Automatisation

::: notes
...
:::

# Démonstration

