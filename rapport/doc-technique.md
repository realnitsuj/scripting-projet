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
subtitle: Documentation technique
author:
- Justin Bossard
- Antoine Feuillette
---

# Utilisation des variables

# Organisation du script

# Principe de fonctionnement

<!--Ça peut être cool si on fait un schéma propre avec PlantUML pour montrer les connexions et interactions entre serveurs-->

![Diagramme d'activité](./activite.svg)

# Justification des choix techniques

## Envoi de mails

Pour configurer l'envoi des mails, il faut mettre en place les services suivants :

- `mailutils` ou `mutt` : pour l'interaction avec l'utilisateur, envoyer et lire des mail
- `sendmail`

## Serveur Web

