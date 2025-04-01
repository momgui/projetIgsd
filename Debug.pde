class Debug {
  Debug() { }
  // Affiche la zone de collision du joueur en rouge
  void drawPlayerCollision(float posX, float posY, float wallH, float playerRadius) {
    pushStyle();
    noFill();
    stroke(255, 0, 0);
    strokeWeight(2);
    pushMatrix();
    // La position du joueur est convertie en coordonnées monde
    translate(posX * wallH, posY * wallH, -wallH + 1);
    // Le cercle a un diamètre égal à 2 * playerRadius * wallH
    ellipse(0, 0, playerRadius * 2 * wallH, playerRadius * 2 * wallH);
    popMatrix();
    popStyle();
  }

  // Affiche les zones de collision des murs en rouge
  void drawWallCollisions(char[][] labyrinthe, int labSize, float wallH) {
    pushStyle();
    noFill();
    stroke(255, 0, 0);
    strokeWeight(2);
    // Parcours de la grille pour dessiner le rectangle correspondant à chaque mur
    for (int j = 0; j < labSize; j++) {
      for (int i = 0; i < labSize; i++) {
        if (labyrinthe[j][i] == '#') {
          // Le centre de la cellule en coordonnées monde
          float centerX = i * wallH;
          float centerY = j * wallH;
          pushMatrix();
          // Positionner le rectangle de collision sur le sol (ici, z = -wallH + 1 pour le rendre visible)
          translate(centerX, centerY, -wallH + 1);
          rectMode(CENTER);
          rect(0, 0, wallH, wallH);
          popMatrix();
        }
      }
    }
    popStyle();
  }
}
