On a commencé avec la correction du tp 6 pour partir d'une base solide.

1- modularisation du code : 
on a créé de nouvelles fonctions pour la génération du labyrithe et la création des PShape,
ça nous permet une meilleure lisibilité et c'est plus simple pour débuguer

2- les valeurs de wallW et wallH sont calculé à chaque frame. C'est une perte de ressource.
on les mets dans setup.

3- on avait un bug quand on change la taille de la fenêtre. On l'a réglé en suprimmant wallW
et en le l'unifiant avec wallH. De cette manière on garde des formes carré même en changeant d'écran.

4- on a implémenté le système de niveau, quand on atteint la fin du niveau on est téléporté au prochain
niveau qui est 4 cases plus petit. Problème de minimap elle grossit et prends trop de place en changeant
de niveau.

5- changements du système de mouvement. On a commencé a mettre en place un mouvement continue avec
clavier zqsd et souris. Problèmes au niveau de la collision, de la vision verticale et de l'emplacement sur la minimap

6- correction d'un problème sur la vision verticale. On ne pouvait pas regarder au dessus de nous et inversait la caméra
en regardant vers le bas.
Corrigé par la ligne: pitch = constrain(pitch, -HALF_PI + 0.1, HALF_PI - 0.1);

7- Correction d'un problème sur la vision horizontale. On ne pouvait pas tourner à 360 degré à cause du fait que la souris
atteint le bord de l'écran. Pour résoudre ça on a utilisé la bibliothèque java.awt.Robot qui nous permet d'avoir
un robot qui recentre la souris au centre de l'écran à chaque frame.

8- Ajout de zones de collision autour des murs mais ça ne marche pas encore parfaitement

9- Ajout d'un fichier Debug.pde avec des fonctions permettant de voir les zones de collision du joueur de des murs,
et correction des bugs lié aux collisions.

10- modification de la detection de l'accès au prochain niveau. Ajout d'un mur à la sortie et d'une échelle pour monter
au prochain niveau.

11 - ajout d'une momie pour l'instant représenté par une sphere et ajout des fonctions basiques comme le mouvement ou 
la détection des murs (pareil que pour le joueur)

12 - amélioration du déplacement de la momie, elle se déplace maintenant aléatoirement en changeant de direction à chaque
fois qu'elle touche un mur.

13 - ajout d'un système de scène avec soit 0 hors de la pyramide et 1 dedans. En fonction de la scène on affiche soit le labyrinthe
soit l'exterieur dans draw.

14 - ajout d'une pyramide et d'un sol basique

15 - ajout d'un ciel bleu et modification des lumières

16 - ajout de la logique d'entrée sortie dans la pyramide

17 - ajout de la condition de victoire et de l'écran de fin