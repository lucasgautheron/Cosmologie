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
php compile.php
```

Usage script compile.php : 

```
php compile.php -V // verbose mode (affiche des messages informatifs au cours de la compilation)
php compile.php -S // run simulations (exécute toutes les simulations qui produisent certains plots, animations, etc. Peut prendre une quinzaine de minutes
```

## Dev

Version développement : http://lapth.sciencestechniques.fr/timeline/

