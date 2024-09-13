- [x] Voir pour SQL dump
- [x] Créer les logs à chaque exécution
- [ ] Voir comment envoyer les mails avec mutt
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
- 
