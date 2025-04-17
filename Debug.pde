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
  

  float debugConeLength = 500;
  int numConeLines = 12; // Nombre de lignes pour dessiner le bord du cône
  
  // Fonction pour dessiner le cône de la spotlight en rouge
  void drawSpotlightCone(PVector origin, PVector direction, float angle, float length) {
    // --- Style pour le débogage ---
    pushStyle(); // Sauvegarde le style courant
    stroke(255, 0, 0); // Couleur rouge
    strokeWeight(1);   // Ligne fine
    noFill();          // Pas de remplissage
  
    // --- Calculs ---
    // S'assurer que la direction est normalisée (très important !)
    direction.normalize();
  
    float halfAngle = angle / 2.0;
    float radius = length * tan(halfAngle);
  
    // Point central de la base du cône
    PVector centerBase = PVector.add(origin, PVector.mult(direction, length));
  
    // --- Trouver des vecteurs perpendiculaires à la direction ---
    // Technique robuste : choisir un vecteur "haut" de base, sauf si direction est verticale
    PVector tempUp = new PVector(0, 1, 0); // Y-up (dans le système Processing, c'est Y-down)
    // Si la direction est (quasi) parallèle à tempUp, choisir un autre vecteur
    if (abs(direction.dot(tempUp)) > 0.99) {
      tempUp = new PVector(1, 0, 0); // Utiliser X-axis à la place
    }
  
    // Premier vecteur perpendiculaire (droite relative)
    PVector right = direction.cross(tempUp);
    right.normalize();
  
    // Deuxième vecteur perpendiculaire (haut relatif)
    PVector up = right.cross(direction); // direction est déjà normalisée, right aussi
    up.normalize(); // Normaliser le résultat final
  
    // --- Dessin ---
    // 1. Dessiner l'axe central
    line(origin.x, origin.y, origin.z, centerBase.x, centerBase.y, centerBase.z);
  
    // 2. Dessiner les lignes du bord du cône + le cercle de base
    beginShape(LINES); // Commence à collecter des paires de points pour les lignes
  
    PVector prevPointOnCircle = null;
  
    for (int i = 0; i <= numConeLines; i++) {
      float angleOnCircle = map(i, 0, numConeLines, 0, TWO_PI); // Angle autour de l'axe
  
      // Calculer le décalage sur le plan de base
      PVector offset = PVector.add(PVector.mult(right, radius * cos(angleOnCircle)),
                                  PVector.mult(up, radius * sin(angleOnCircle)));
  
      // Point sur la circonférence de la base
      PVector pointOnCircle = PVector.add(centerBase, offset);
  
      // Ligne depuis l'origine vers le point sur la base
      vertex(origin.x, origin.y, origin.z);
      vertex(pointOnCircle.x, pointOnCircle.y, pointOnCircle.z);
  
      // Ligne pour le cercle de base (connecte ce point au précédent)
      if (prevPointOnCircle != null) {
        vertex(prevPointOnCircle.x, prevPointOnCircle.y, prevPointOnCircle.z);
        vertex(pointOnCircle.x, pointOnCircle.y, pointOnCircle.z);
      }
      prevPointOnCircle = pointOnCircle;
    }
    endShape(); // Dessine toutes les lignes
  
    popStyle(); // Restaure le style précédent
  }
}
