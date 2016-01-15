# Histoire de la Cosmologie

http://histoiredelacosmlogie.fr/

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

# si première compilation, où si une simulation a changé :
php compile.php -V -S
# sinon :
php compile -V
```

## Dev

Version développement : http://lapth.sciencestechniques.fr/timeline/

