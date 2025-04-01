class Momie {
  // Position de la momie dans le labyrinthe (coordonnées en grille)
  float posX, posY;
  // Vitesse de déplacement
  float moveSpeed = 0.02;
  // Direction de déplacement (en radians)
  float heading;
  // Compteur pour changer de direction de temps en temps
  int changeCounter = 0;
  
  Momie(float x, float y) {
    posX = x;
    posY = y;
    heading = random(TWO_PI);
  }
  
void update() {
  changeCounter++;
  if (changeCounter > 60) {
    changeCounter = 0;
    // Ajoute une petite variation à l'angle courant
    heading += random(-PI/8, PI/8);
  }
  
  // Essai de déplacement avec l'angle courant
  float newX = posX + cos(heading) * moveSpeed;
  float newY = posY + sin(heading) * moveSpeed;
  
  if (!collides(newX, newY)) {
    posX = newX;
    posY = newY;
  } else {
    // Si collision, essayer quelques ajustements d'angle
    boolean moved = false;
    float deltaAngle = PI/16; // incrément d'angle
    // Essayer plusieurs ajustements (jusqu'à 4 incréments)
    for (int i = 1; i <= 4 && !moved; i++) {
      // Tester en tournant à gauche
      float testHeading = heading - deltaAngle * i;
      newX = posX + cos(testHeading) * moveSpeed;
      newY = posY + sin(testHeading) * moveSpeed;
      if (!collides(newX, newY)) {
         heading = testHeading;
         posX = newX;
         posY = newY;
         moved = true;
         break;
      }
      // Tester en tournant à droite
      testHeading = heading + deltaAngle * i;
      newX = posX + cos(testHeading) * moveSpeed;
      newY = posY + sin(testHeading) * moveSpeed;
      if  (!collides(newX, newY)){
         heading = testHeading;
         posX = newX;
         posY = newY;
         moved = true;
         break;
      }
    }
    // Si aucune direction ajustée ne permet le déplacement, choisir une nouvelle direction aléatoire
    if (!moved) {
      heading = random(TWO_PI);
    }
  }
}

  
  void display() {
    pushMatrix();
    // Conversion des coordonnées de grille vers les coordonnées monde
    translate(posX * wallH, posY * wallH, -10);  // ajustez la coordonnée Z selon vos besoins
    // On affiche la momie sous forme d'une sphère jaune (vous pouvez utiliser une texture ou un modèle 3D)
    fill(255, 200, 0);
    noStroke();
    sphere(10);  // Taille de la momie
    popMatrix();
  }
}
