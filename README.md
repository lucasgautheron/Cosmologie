# Histoire de la Cosmologie

http://histoiredelacosmologie.fr/

Version developpement : http://cosmologie.sciencestechniques.fr/timeline/

Archive : http://cosmologie.sciencestechniques.fr/timeline/archive.tar.gz

[![Build Status](https://travis-ci.org/lucasgautheron/Cosmologie.svg?branch=master)](https://travis-ci.org/lucasgautheron/Cosmologie) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/lucasgautheron/Cosmologie?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Compiler

### Première exécution :

 * Clônage du répertoire
```
git clone https://github.com/lucasgautheron/Cosmologie.git
```
 * Installation des dépendances :
 
```
apt-get install libsaxonb-java gnuplot default-jre
```

Pour les animations/simulations il faut aussi :
```
apt-get install ffmpeg build-essential
```

### Compilation
 * Mettre à jour et compiler :

```
git pull
cd www/timeline

# si première compilation, ou si une simulation a changé :
php compile.php -V -S
# sinon :
php compile -V
```
