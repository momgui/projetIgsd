On a commencé avec la correction du tp 6 pour partir d'une base solide.

1- modularisation du code : 
on a créé de nouvelles fonctions pour la génération du labyrithe et la création des PShape,
ça nous permet une meilleure lisibilité et c'est plus simple pour débuguer

2- les valeurs de wallW et wallH sont calculé à chaque frame. C'est une perte de ressource.
on les mets dans setup.

3- on avait un bug quand on change la taille de la fenêtre. On l'a réglé en suprimmant wallW
et en le l'unifiant avec wallH. De cette manière on garde des formes carré même en changeant d'écran.