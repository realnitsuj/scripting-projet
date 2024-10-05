- [x] Voir pour SQL dump
- [x] Créer les logs à chaque exécution
- [x] Voir comment envoyer les mails avec mutt
- [x] Faire un serveur depuis lequel
  - on peut récupérer le fichier sql
  - on pousse l'archive une fois les opérations effectuées
- [x] Sur le serveur d'archivage, supprimer les archives plus anciennes qu'une durée renseignée dans la conf
- [x] Mettre en place les test suggérés sur MOOTSE
    - [x] Vérifier que l'URL existe
    - [x] Vérifier que le zip a bien été téléchargé
    - [x] Vérifier que le zip contient bien le fichier attendu
    - [x] Vérifier que le SQL n'est pas la même que la veille
    - [x] Vérifier la connexion avec le serveur de destination
    - [x] Vérifier que le transfert a bien fonctionné
- [ ] Rédiger les rapports
    - [ ] Mémoire technique
        - [ ] Diagramme d'activité
        - [ ] Schéma pour les serveurs
        - [ ] Le reste
    - [ ] Documentation utilisateur
        - [ ] Voir si on détaille plus sur le Cron
        - [x] Le reste

# Structure

- `archive.sh` : le script principal
- `archive.conf` : le fichier de configuration
- `archive.log` : les journaux de l'utilitaire
- `.prevChecksum` : la somme de contrôle de fichier de la veille

# Rapports

Deux rapports à faire : une doc utilisateur et une doc technique. Pour la syntaxe markdown, j'utilise Pandoc pour convertir après, voir [la doc](https://pandoc.org/MANUAL.html) et pour [l'installer](https://pandoc.org/installing.html).

Pour faire des schémas propre (notamment si on veut faire un truc pour les serveurs), [PlantUML](https://plantuml.com/fr/) c'est hyper cool.

# Sources

- Pour authentification SSH par clé : <https://www.cyberciti.biz/tips/ssh-public-key-based-authentication-how-to.html>
- Pour Mutt, voir cette série : <https://www.unixmail.fr/tags/mutt/>

***

# FONCTIONNALITES ATTENDUES

Vous devez réaliser un système d'archivage qui permet de récupérer un fichier .zip en https sur un serveur Web et de l'archiver sur un serveur distant avec une durée de conservation paramètrable.

L'URL du fichier .zip à récupérer est toujours la même.

Ce fichier .zip contient un dump SQL (le fichier a toujours le même nom dans le zip).

Une fois le fichier dézippé, il faut le contrôler (que ce ne soit pas le même que la veille) et créer une nouvelle archive au format AAAADDMM.tgz que l'on va aller poser sur un serveur distant pour archivage.

Le serveur de destination pouvant être un serveur SMB/CIFS (Windows), NFS (Linux),  WEBDAV (cloud), serveur FTPS ou SFTP à votre convenance.

La durée de conservation des archives sur le serveur de destination sera paramètrable et vous devrez gérer la suppression des versions dépassant la durée de conservation.

## Quelques exemples de contrôle à prendre en compte dans le code ...

- L'URL de téléchargement existe.
- Le fichier .zip a bien été téléchargé.
- Le fichier .zip contient bien le fichier attendu.
- Le fichier .sql n'est pas le même que celui de la veille.
- L'archive .tgz avec le bon nom a bien été créé.
- La connexion avec le serveur de destination est bien fonctionnelle.
- Le transfert du fichier .tgz vers son stockage a bien fonctionné.

## Fichier de configuration

Les paramètres de configuration devront être stockés dans un fichier spécifique facilement modifable et dont l'organisation devra être exploitable simplement par un technicien (fichier texte de conf).

## Méthodes de transfert

La sauvegarde pourra être faite vers un serveur de type :

- SMB/CIFS
- NFS
- WEBDAV
- FTPS
- SFTP

Au moins une de ces méthodes est obligatoire à mettre en place dans le cadre de ce projet. 

## Historisation

Il devra être possible de stocker plusieurs versions des fichiers sauvegardés sur le serveur de destination. Cette fonctionnalité devra pouvoir être activée depuis le fichier de configuration en précisant la durée de conservation sur le serveur de destination. 

## Logs

En terme de supervision, le logiciel devra être capable de générer un fichier de log qui contiendra les éléments permettant de s'assurer que la sauvegarde s'est bien déroulée et de manière générale toutes les actions réussies ou échouées (notamment pour la partie épuration). Une attention particulière devra être apportée à ce système qui devra permettre d'identifier très facilement la cause de non exécution de la procédure.

## Email

La solution pourra également envoyer un mail (ou pas) aux destinataires paramétrables, au titre paramétrable dont le titre devra permettre de rapidement identifier si le processus a bien fonctionné ou pas. Il devra être possible d'attacher optionnellement le rapport de log créé précédemment.

Le corps du mail devra comporter un résumé succint du déroulement de la procédure. Le mail devra pouvoir être envoyé soit via le serveur de messagerie interne de la machine, soit en autonome en prenant en charge les protocoles SMTP et STMPS (tls ou ssl), en définissant le nom ou l'adresse IP du serveur SMTP/SMTPS ainsi que son port. L'authentification sur le serveur de messagerie devra également être gérée dans la configuration de l'utilitaire.

# AUTOMATISATION DU LANCEMENT

Le lancement de votre utilitaire devra être faite par un processus automatisé. L'utilisation d'un fichier CRON (https://fr.wikipedia.org/wiki/Cron) sera la méthode à privilégier mais vous êtes libres d'utiliser une autre méthode à condition de le justifier dans votre mémoire technique.

# REGLES DE REALISATION

Vous devez partir du principe que votre solution doit pouvoir être exploitée et reprise facilement sans vous.

Vous accorderez une attention particulière à l'organisation et la documentation du code.

~La solution devra être réalisée en python (programme principal) et/ou en scripts en faisant éventuellement appel à des commandes shell externes.~ bash le feu

Plus votre solution sera simple à mettre en place, mieux ce sera !

# LIVRABLES ATTENDUS

- code source
- fichier de configuration
- doc utilisateur d'installation (si vous avez des dépendances, pensez à les indiquer), d'exploitation et configuration
- mémoire technique (liste et utilisation des variables, organisation du code et du/des fichier(s), principes de fonctionnement, justification des choix techniques/fonctionnels) de votre méthodologie et toutes justifications sur vos choix organisationnels ou fonctionnels

# CRITERES PRIS EN COMPTE DANS LA NOTATION

- qualité et lisibilité du code
- couverture fonctionnelle
- qualité des documents connexes
- facilité de configuration
- facilité de suivi de la bonne réalisation/échec du processus
- présentation 
- qualité de votre démo, orale/exposé

# NOTES :

Ce projet donnera lieu à 3 notes : 

- la partie programme et ses éléments + démo + orale/exposé (40%), 
- la doc utilisateur (30%), 
- le mémoire technique explicitant le fonctionnement et vos choix  techniques (30%)

Durée de la présentation + démo : max 10 minutes.
