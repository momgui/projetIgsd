import java.awt.Robot;
import java.awt.AWTException;

Robot robot;
boolean isWarping = false;


float playerRadius = 0.3; 
Debug debug;

// Variables de position et direction du joueur
int dirX = 0, dirY = 1;

// Variables de position et de direction
float posX = 1.0, posY = 1.0;  // Position initiale dans la grille du labyrinthe
float heading = 0;           // Angle horizontal (en radians)
float pitch = 0;             // Angle vertical (en radians)
float moveSpeed = 0.05;      // Vitesse de déplacement
float sensitivity = 0.005;   // Sensibilité de la souris

// Flags pour le mouvement
boolean moveForward = false, moveBackward = false, moveLeft = false, moveRight = false;

// Paramètres du labyrinthe
int labSize = 21;
char labyrinthe[][];
char sides[][][];
int level = 0;

// Formes et texture
PShape laby0;
PShape ceiling0;
PShape ceiling1;
PImage texture0;

// Dimensions pré-calculées
float wallH;


void setup() { 
  pixelDensity(2);
  randomSeed(2);
  texture0 = loadImage("stones.tif");
  fullScreen(P3D);  // Mode plein écran en 3D

  // Initialisation des tableaux
  labyrinthe = new char[labSize][labSize];
  sides = new char[labSize][labSize][4];


  noCursor();
  
  try {
    robot = new Robot();
  } catch (AWTException e) {
    e.printStackTrace();
  }
  
  // Recentrage initial
  robot.mouseMove(width/2, height/2);
  

  // Génération du labyrinthe
  generateLabyrinth(level);
  
  // Calcul préliminaire des dimensions des murs
  wallH = (float) height / labSize;
 
  
  // Construction des formes (murs, sols et plafonds)
  buildShapes();
  
  debug = new Debug();
}


void generateLabyrinth(int level) {
  int todig = 0;
  // Remplissage initial et initialisation des "sides"
  for (int j = 0; j < labSize; j++) {
    for (int i = 0; i < labSize; i++) {
      for (int k = 0; k < 4; k++) {
        sides[j][i][k] = 0;
      }
      if (j % 2 == 1 && i % 2 == 1) {
        labyrinthe[j][i] = '.';
        todig++;
      } else {
        labyrinthe[j][i] = '#';
      }
    }
  }
  
  // Algorithme de génération aléatoire
  int gx = 1, gy = 1;
  while (todig > 0) {
    int oldgx = gx, oldgy = gy;
    int alea = floor(random(0, 4));
    if (alea == 0 && gx > 1)
      gx -= 2;
    else if (alea == 1 && gy > 1)
      gy -= 2;
    else if (alea == 2 && gx < labSize - 2)
      gx += 2;
    else if (alea == 3 && gy < labSize - 2)
      gy += 2;
      
    if (labyrinthe[gy][gx] == '.') {
      todig--;
      labyrinthe[gy][gx] = ' ';
      labyrinthe[(gy + oldgy) / 2][(gx + oldgx) / 2] = ' ';
    }
  }
  
  // Définition de l'entrée et de la sortie
  if (level == 0) {
    labyrinthe[0][1] = ' ';             // entrée  
  }
  labyrinthe[labSize - 2][labSize - 1] = ' ';  // sortie
  
  // Détermination des "sides" en fonction des murs autour des cases vides
  for (int j = 1; j < labSize - 1; j++) {
    for (int i = 1; i < labSize - 1; i++) {
      if (labyrinthe[j][i] == ' ') {
        if (labyrinthe[j - 1][i] == '#' && labyrinthe[j + 1][i] == ' ' &&
            labyrinthe[j][i - 1] == '#' && labyrinthe[j][i + 1] == '#')
          sides[j - 1][i][0] = 1;
        if (labyrinthe[j - 1][i] == ' ' && labyrinthe[j + 1][i] == '#' &&
            labyrinthe[j][i - 1] == '#' && labyrinthe[j][i + 1] == '#')
          sides[j + 1][i][3] = 1;
        if (labyrinthe[j - 1][i] == '#' && labyrinthe[j + 1][i] == '#' &&
            labyrinthe[j][i - 1] == ' ' && labyrinthe[j][i + 1] == '#')
          sides[j][i + 1][1] = 1;
        if (labyrinthe[j - 1][i] == '#' && labyrinthe[j + 1][i] == '#' &&
            labyrinthe[j][i - 1] == '#' && labyrinthe[j][i + 1] == ' ')
          sides[j][i - 1][2] = 1;
      }
    }
  }
}


void nextLevel() {
  // Exemple : diminuer la taille pour le niveau suivant tout en gardant un nombre impair
  labSize -= 4;  
  posX = 1;
  posY = 1;
  // Réallocation des tableaux avec la nouvelle taille
  labyrinthe = new char[labSize][labSize];
  sides = new char[labSize][labSize][4];
  level++;
  generateLabyrinth(level);
  
  // Mise à jour des dimensions
  wallH = (float) width / labSize;
  // Vous pouvez aussi reconstruire vos formes si nécessaire
  buildShapes();
}





void buildShapes() {
  // Initialisation des formes pour les plafonds
  ceiling0 = createShape();
  ceiling1 = createShape();
  ceiling0.beginShape(QUADS);
  ceiling1.beginShape(QUADS);
  
  // Construction de la forme compilée pour les murs et sols
  laby0 = createShape();
  laby0.beginShape(QUADS);
  laby0.texture(texture0);
  laby0.noStroke();
  
  for (int j = 0; j < labSize; j++) {
    for (int i = 0; i < labSize; i++) {
      if (labyrinthe[j][i] == '#') {
        laby0.fill(i * 25, j * 25, 255 - i * 10 + j * 10);
        
        // Face supérieure du mur
        if (j == 0 || labyrinthe[j - 1][i] == ' ') {
          laby0.normal(0, -1, 0);
          for (int k = 0; k < 1; k++) {
            for (int l = -1; l < 1; l++) {
              laby0.vertex(i * wallH - wallH/2 + (k + 0)*wallH, j * wallH - wallH/2, (l + 0)*wallH,
                           k * texture0.width, (0.5 + l/ (2.0*1)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 1)*wallH, j * wallH - wallH/2, (l + 0)*wallH,
                           (k + 1) * texture0.width, (0.5 + l/(2.0*1)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 1)*wallH, j * wallH - wallH/2, (l + 1)*wallH,
                           (k + 1) * texture0.width, (0.5 + (l+1)/(2.0*1)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 0)*wallH, j * wallH - wallH/2, (l + 1)*wallH,
                           k * texture0.width, (0.5 + (l+1)/(2.0*1)) * texture0.height);
            }
          }
        }
        
        // Face inférieure du mur
        if (j == labSize - 1 || labyrinthe[j + 1][i] == ' ') {
          laby0.normal(0, 1, 0);
          for (int k = 0; k < 1; k++) {
            for (int l = -1; l < 1; l++) {
              laby0.vertex(i * wallH - wallH/2 + (k + 0)*wallH, j * wallH + wallH/2, (l + 1)*wallH,
                           (k + 0) * texture0.width, (0.5 + (l+1)/(2.0*1)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 1)*wallH, j * wallH + wallH/2, (l + 1)*wallH,
                           (k + 1) * texture0.width, (0.5 + (l+1)/(2.0*1)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 1)*wallH, j * wallH + wallH/2, (l + 0)*wallH,
                           (k + 1) * texture0.width, (0.5 + (l+0)/(2.0*1)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 0)*wallH, j * wallH + wallH/2, (l + 0)*wallH,
                           (k + 0) * texture0.width, (0.5 + (l+0)/(2.0*1)) * texture0.height);
            }
          }
        }
        
        // Face gauche du mur
        if (i == 0 || labyrinthe[j][i - 1] == ' ') {
          laby0.normal(-1, 0, 0);
          for (int k = 0; k < 1; k++) {
            for (int l = -1; l < 1; l++) {
              laby0.vertex(i * wallH - wallH/2, j * wallH - wallH/2 + (k + 0)*wallH, (l + 1)*wallH,
                           (k + 0) * texture0.width, (0.5 + (l+1)/(2.0*1)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2, j * wallH - wallH/2 + (k + 1)*wallH, (l + 1)*wallH,
                           (k + 1) * texture0.width, (0.5 + (l+1)/(2.0*1)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2, j * wallH - wallH/2 + (k + 1)*wallH, (l + 0)*wallH,
                           (k + 1) * texture0.width, (0.5 + (l+0)/(2.0*1)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2, j * wallH - wallH/2 + (k + 0)*wallH, (l + 0)*wallH,
                           (k + 0) * texture0.width, (0.5 + (l+0)/(2.0*1)) * texture0.height);
            }
          }
        }
        
        // Face droite du mur
        if (i == labSize - 1 || labyrinthe[j][i + 1] == ' ') {
          laby0.normal(1, 0, 0);
          for (int k = 0; k < 1; k++) {
            for (int l = -1; l < 1; l++) {
              laby0.vertex(i * wallH + wallH/2, j * wallH - wallH/2 + (k + 0)*wallH, (l + 0)*wallH,
                           (k + 0) * texture0.width, (0.5 + (l+0)/(2.0*1)) * texture0.height);
              laby0.vertex(i * wallH + wallH/2, j * wallH - wallH/2 + (k + 1)*wallH, (l + 0)*wallH,
                           (k + 1) * texture0.width, (0.5 + (l+0)/(2.0*1)) * texture0.height);
              laby0.vertex(i * wallH + wallH/2, j * wallH - wallH/2 + (k + 1)*wallH, (l + 1)*wallH,
                           (k + 1) * texture0.width, (0.5 + (l+1)/(2.0*1)) * texture0.height);
              laby0.vertex(i * wallH + wallH/2, j * wallH - wallH/2 + (k + 0)*wallH, (l + 1)*wallH,
                           (k + 0) * texture0.width, (0.5 + (l+1)/(2.0*1)) * texture0.height);
            }
          }
        }
        
        // Plafond vert (pour illustration) associé aux murs
        ceiling1.fill(32, 255, 0);
        ceiling1.vertex(i * wallH - wallH/2, j * wallH - wallH/2, wallH);
        ceiling1.vertex(i * wallH + wallH/2, j * wallH - wallH/2, wallH);
        ceiling1.vertex(i * wallH + wallH/2, j * wallH + wallH/2, wallH);
        ceiling1.vertex(i * wallH - wallH/2, j * wallH + wallH/2, wallH);
      } else {
        // Sol
        laby0.fill(192);
        laby0.vertex(i * wallH - wallH/2, j * wallH - wallH/2, -wallH, 0, 0);
        laby0.vertex(i * wallH + wallH/2, j * wallH - wallH/2, -wallH, 0, 1);
        laby0.vertex(i * wallH + wallH/2, j * wallH + wallH/2, -wallH, 1, 1);
        laby0.vertex(i * wallH - wallH/2, j * wallH + wallH/2, -wallH, 1, 0);
        
        // Dessus des murs pour le sol (plafond alternatif)
        ceiling0.fill(32);
        ceiling0.vertex(i * wallH - wallH/2, j * wallH - wallH/2, wallH);
        ceiling0.vertex(i * wallH + wallH/2, j * wallH - wallH/2, wallH);
        ceiling0.vertex(i * wallH + wallH/2, j * wallH + wallH/2, wallH);
        ceiling0.vertex(i * wallH - wallH/2, j * wallH + wallH/2, wallH);
      }
    }
  }
  
  laby0.endShape();
  ceiling0.endShape();
  ceiling1.endShape();
}

void showMinimap(){
  background(192);
  sphereDetail(6);
  // Caméra et perspective standard
  perspective();
  camera(width/2.0, height/2.0, (height/2.0)/tan(PI*30.0/180.0),
         width/2.0, height/2.0, 0, 0, 1, 0);
  noLights();
  stroke(0);
  
  // Affichage simple des murs sous forme de box
  for (int j = 0; j < labSize; j++) {
    for (int i = 0; i < labSize; i++) {
      if (labyrinthe[j][i] == '#') {
        fill(i * 25, j * 25, 255 - i * 10 + j * 10);
        pushMatrix();
        translate(wallH + i * wallH/8, wallH + j * wallH/8, wallH);
        box(wallH/10, wallH/10, 5);
        popMatrix();
      }
    }
  }

}

boolean collides(float x, float y) {
  // Conversion de la position du joueur en coordonnées monde
  float circleX = x * wallH;
  float circleY = y * wallH;
  float radiusWorld = playerRadius * wallH;
  
  // On ne vérifie que les cellules autour de la position du joueur
  int minI = max(0, int(x) - 1);
  int maxI = min(labSize - 1, int(x) + 1);
  int minJ = max(0, int(y) - 1);
  int maxJ = min(labSize - 1, int(y) + 1);
  
  for (int j = minJ; j <= maxJ; j++) {
    for (int i = minI; i <= maxI; i++) {
      if (labyrinthe[j][i] == '#') {
        // Coordonnées du rectangle (cellule du mur)
        float rectX = i * wallH - wallH/2;
        float rectY = j * wallH - wallH/2;
        float rectW = wallH;
        float rectH = wallH;
        
        // Calcul du point le plus proche sur le rectangle
        float nearestX = max(rectX, min(circleX, rectX + rectW));
        float nearestY = max(rectY, min(circleY, rectY + rectH));
        
        // Distance entre le cercle (joueur) et ce point
        float deltaX = circleX - nearestX;
        float deltaY = circleY - nearestY;
        
        if ((deltaX * deltaX + deltaY * deltaY) < (radiusWorld * radiusWorld)) {
          return true;  // Collision détectée
        }
      }
    }
  }
  return false;
}



void draw() {
  // Calcul des vecteurs de déplacement en fonction de l'angle horizontal
  float dx = cos(heading) * moveSpeed;
  float dy = sin(heading) * moveSpeed;
  // Vecteur perpendiculaire pour le strafe (mouvement latéral)
  float sx = -sin(heading) * moveSpeed;
  float sy = cos(heading) * moveSpeed;
  
  // Calcul de la nouvelle position selon les touches enfoncées
  float newX = posX;
  float newY = posY;
  if (moveForward) {
    newX += dx;
    newY += dy;
  }
  if (moveBackward) {
    newX -= dx;
    newY -= dy;
  }
  if (moveLeft) {
    newX -= sx;
    newY -= sy;
  }
  if (moveRight) {
    newX += sx;
    newY += sy;
  }



  // Vérification de collision
  if (!collides(newX, newY)) {
    posX = newX;
    posY = newY;
  } else {
    // Optionnel : gérer un glissement en vérifiant séparément l'axe X et Y
    // Par exemple :
    if (!collides(newX, posY)) posX = newX;
    if (!collides(posX, newY)) posY = newY;
  }

  showMinimap();
  
  // Configuration de la caméra en vue à la première personne
  float camX = posX * wallH;
  float camY = posY * wallH;
  float camZ = -15;  // Hauteur ou profondeur fixe pour la caméra
  // Calcul du point regardé en combinant heading et pitch
  float lookX = camX + cos(heading) * cos(pitch);
  float lookY = camY + sin(heading) * cos(pitch);
  float lookZ = camZ + sin(pitch);
  
  perspective(PI/3, (float)width/height, 1, 1000);
  camera(camX, camY, camZ, lookX, lookY, lookZ, 0, 0, -1);
  lightFalloff(0.0, 0.01, 0.0001);
  pointLight(255, 255, 255, posX*wallH, posY*wallH, 15);


  noStroke();
  // Affichage des formes compilées du labyrinthe
  shape(laby0, 0, 0);
  shape(ceiling0, 0, 0);
    
  // Appel de l'affichage du débogage pour les collisions
  //debug.drawPlayerCollision(posX, posY, wallH, playerRadius);
  //debug.drawWallCollisions(labyrinthe, labSize, wallH);



   
}

void keyPressed() {
  // Utilisation des touches WASD pour le déplacement
  if (key == 'z' || key == 'Z') {
    moveForward = true;
  }
  if (key == 's' || key == 'S') {
    moveBackward = true;
  }
  if (key == 'q' || key == 'Q') {
    moveLeft = true;
  }
  if (key == 'd' || key == 'D') {
    moveRight = true;
  }
  
  // Par exemple, si vous souhaitez quitter avec la touche Échap
  if (keyCode == ESC) {
    exit();
  }
}

void keyReleased() {
  if (key == 'z' || key == 'Z') {
    moveForward = false;
  }
  if (key == 's' || key == 'S') {
    moveBackward = false;
  }
  if (key == 'q' || key == 'Q') {
    moveLeft = false;
  }
  if (key == 'd' || key == 'D') {
    moveRight = false;
  }
}

void mouseMoved() {
  // On ignore les événements générés par le recentrage
  if (isWarping) {
    isWarping = false;
    return;
  }
  
  // Calcul du delta par rapport au centre de l'écran
  float deltaX = mouseX - width/2;
  float deltaY = mouseY - height/2;
  
  heading += deltaX * sensitivity;
  pitch -= deltaY * sensitivity;
  pitch = constrain(pitch, -HALF_PI + 0.1, HALF_PI - 0.1);
  
  // Recentrer le curseur
  isWarping = true;
  robot.mouseMove(width/2, height/2);
}
