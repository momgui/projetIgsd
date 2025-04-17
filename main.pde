import java.awt.Robot;
import java.awt.AWTException;
boolean isClimbing = false; // Indique si le joueur est en train de monter à l'échelle
float climbSpeed = 0.2;    // Vitesse de montée de l'échelle
float climbTargetZ = 15;  
float camZ = -15;  // Hauteur ou profondeur fixe pour la caméra
boolean isPlayerDead = false;     // Indicateur si le joueur est mort
int deathTimestamp = 0;         // Moment où le joueur est mort (en millisecondes)
final int DEATH_MESSAGE_DURATION = 3000; // Durée d'affichage du message (3 secondes)

Robot robot;
boolean isWarping = false;

int scene = 1; // 0 : Désert, 1 : Pyramide/Labyrinthe, 1: écran de victoire,2: ecran de défaite
int etage = 0;



boolean[][] discovered;
float playerRadius = 0.3;
Debug debug;

// Variables de position et direction du joueur
int dirX = 0, dirY = 1;

// Variables de position et de direction
float posX = 19.0, posY = 18.0;  // Position initiale dans la grille du labyrinthe

// Pyramide comme asset
Pyramide pyramide;
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
PShape laby0, ceiling0, ladder0;
PImage texture0;

// Dimensions pré-calculées
float wallH;


// Paramètres du terrain
float tailleTerrain = 5000; // Taille totale du terrain
int resolutionTerrain = 80; // Nombre de quads par côté
float echelleBruit = 0.03;  // Taille des collines (plus petit = plus grandes collines)
float amplitudeHauteur = 300; // Hauteur max des collines

// Paramètres de la pyramide et du tiling
float largeurPyramide = 400;
float longueurPyramide = 400;
float hauteurPyramide = 250;
float repetitionPierre = 5.0;
float repetitionSable = 40.0; // Peut-être augmenter le tiling pour le grand terrain //<>//

Momie momie;
PShader desertEffect;

PShader horrorMazeShader;
// Variables pour contrôler l'intensité des effets
float pulseSpeed = 0.5;      // Vitesse de pulsation de l'éclairage
float flickerIntensity = 0.2;


Ladder3D ladder3D;

void setup() {
  pixelDensity(2);
  randomSeed(2);
  texture0 = loadImage("stones.tif");
  fullScreen(P3D);  // Mode plein écran en 3D

  // Création de la pyramide (position, dimensions)
  pyramide = new Pyramide(0, 0, 0, // Position base (x, y, z)
                          largeurPyramide, longueurPyramide, hauteurPyramide, // Dim pyramide
                          tailleTerrain, repetitionPierre, // Taille terrain, tiling pierre
                          repetitionSable, resolutionTerrain, echelleBruit, amplitudeHauteur); // Tiling sable & Params terrain}

  // Initialisation des tableaux
  labyrinthe = new char[labSize][labSize];
  sides = new char[labSize][labSize][4];


  noCursor();

  try {
    robot = new Robot();
  }
  catch (AWTException e) {
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

  discovered = new boolean[labSize][labSize];
  for (int j = 0; j < labSize; j++) {
    for (int i = 0; i < labSize; i++) {
      discovered[j][i] = false;
    }
  }
  discovered[int(posY)][int(posX)] = true;

  momie = new Momie(1.0, 1.0);


  // Charger le shader post-traitement
  desertEffect = loadShader("desertEffect.glsl");
  horrorMazeShader = loadShader("horrorMaze.glsl");
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
  // Marquer la sortie par 'X'
  labyrinthe[labSize - 2][labSize - 1] = 'X';

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
  etage += 1;
  if (etage == 4) {
      scene = 2;
  }
  labSize -= 4;
  posX = 1;
  posY = 1;
  labyrinthe = new char[labSize][labSize];
  sides = new char[labSize][labSize][4];
  level++;
  
  // Mise à jour des dimensions et reconstruction des formes
  wallH = (float) height / labSize;
  
  generateLabyrinth(level);
  // Reconstruire les formes avec la texture
  buildShapes();

  // Placement aléatoire de la momie pour ce nouvel étage
  float randomX, randomY;
  boolean positionValide = false;

  while (!positionValide) {
    randomX = floor(random(1, labSize - 1)); // Centre de la case
    randomY = floor(random(1, labSize - 1));

    if (!collides(randomX, randomY, 'm')) {
      momie.posX = randomX;
      momie.posY = randomY;
      positionValide = true;
    }
  }

  for (int j = 0; j < labSize; j++) {
    for (int i = 0; i < labSize; i++) {
      discovered[j][i] = false;
    }
  }
  discovered[int(posY)][int(posX)] = true;
}





void buildShapes() {
  // Réinitialisation des formes existantes
  laby0 = createShape();
  ceiling0 = createShape();
  ladder0 = createShape();

  ceiling0.beginShape(QUADS);

  laby0.beginShape(QUADS);
  laby0.texture(texture0);
  laby0.noStroke();


  for (int j = 0; j < labSize; j++) {
    for (int i = 0; i < labSize; i++) {
      if (labyrinthe[j][i] == '#'||labyrinthe[j][i] == 'X') {
        laby0.fill(i * 25, j * 25, 255 - i * 10 + j * 10);

        // Face supérieure du mur
        if (j == 0 || labyrinthe[j - 1][i] == ' ' || labyrinthe[j - 1][i] == 'X') {
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
        if (j == labSize - 1 || labyrinthe[j + 1][i] == ' ' || labyrinthe[j + 1][i] == 'X') {
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
        if ((i == 0 || labyrinthe[j][i - 1] == ' ') && labyrinthe[j][i] != 'X') {
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
        } else if (labyrinthe[j][i] == 'X') {
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

      // On place l'échelle sur le mur de droite de la cellule marquée 'X'
      if (labyrinthe[j][i] == 'X') {


        float centerX = i * wallH;
        float centerY = j * wallH;
        float wallX = centerX + wallH/2;  // Position du mur est
        
        // Dimensions de l'échelle
        float ladderWidth = wallH * 0.6;  // 60% de la largeur du mur
        float ladderHeight = wallH * 1.5; // 150% de la hauteur du mur
        float ladderDepth = wallH * 0.05; // 5% de l'épaisseur du mur
        int numRungs = 5;                 // Nombre de barreaux
        
        // Créer l'échelle
        ladder3D = new Ladder3D(
          wallX - ladderDepth/2,  // Positionner contre le mur
          centerY,                // Centrer sur la cellule
          -wallH + ladderHeight/2,// Base de l'échelle au niveau du sol
          ladderWidth,
          ladderHeight,
          ladderDepth,
          numRungs
        );
        
      }
    }
  }

  laby0.endShape();
  ceiling0.endShape();
}

void updateDiscovery() {
  int cellX = int(posX);
  int cellY = int(posY);

  // révéler les cellules voisines
  for (int j = cellY - 1; j <= cellY + 1; j++) {
    for (int i = cellX - 1; i <= cellX + 1; i++) {
      if (i >= 0 && i < labSize && j >= 0 && j < labSize) {
        discovered[j][i] = true;
      }
    }
  }
}


void showMinimap() {
  background(192);
  sphereDetail(6);
  // Caméra et perspective standard
  perspective();
  camera(width/2.0, height/2.0, (height/2.0)/tan(PI*30.0/180.0), width/2.0, height/2.0, 0, 0, 1, 0);
  noLights();
  stroke(0);

  // Affichage simple des murs sous forme de box
  for (int j = 0; j < labSize; j++) {
    for (int i = 0; i < labSize; i++) {
      if (labyrinthe[j][i] == '#' && discovered[j][i]) {
        fill(i * 25, j * 25, 255 - i * 10 + j * 10);
        pushMatrix();
        translate(60 + i * 60/8, 60 + j *60/8, 60);
        box(60/10, 60/10, 5);
        popMatrix();
      }
    }
  }
  pushMatrix();
  fill(0, 255, 0);
  noStroke();
  translate(50+posX*60/8, 50+posY*60/8, 50);
  sphere(3);
  popMatrix();
}

boolean collides(float x, float y, char obj) {
  float circleX = x * wallH;
  float circleY = y * wallH;
  float radiusWorld = playerRadius * wallH;

  int minI = max(0, int(x) - 1);
  int maxI = min(labSize - 1, int(x) + 1);
  int minJ = max(0, int(y) - 1);
  int maxJ = min(labSize - 1, int(y) + 1);

  for (int j = minJ; j <= maxJ; j++) {
    for (int i = minI; i <= maxI; i++) {
      if (labyrinthe[j][i] == '#' || (labyrinthe[j][i] == 'X' && obj == 'm')) {
        float rectX = i * wallH - wallH/2;
        float rectY = j * wallH - wallH/2;
        float rectW = wallH;
        float rectH = wallH;

        // Calcul du point le plus proche sur le rectangle de collision
        float nearestX = max(rectX, min(circleX, rectX + rectW));
        float nearestY = max(rectY, min(circleY, rectY + rectH));

        float deltaX = circleX - nearestX;
        float deltaY = circleY - nearestY;

        if ((deltaX * deltaX + deltaY * deltaY) < (radiusWorld * radiusWorld)) {
          return true;
        }
      }
    }
  }
  return false;
}


void triggerPlayerDeath() {
  if (!isPlayerDead) {
    isPlayerDead = true;
    deathTimestamp = millis(); // Enregistre le moment de la mort
    scene = 0;
  }
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
  if (scene == 1) {
    updateDiscovery();
    showMinimap();
  }
  
  

  // Configuration de la caméra en vue à la première personne
  float camX = posX * wallH;
  float camY = posY * wallH;
  // Calcul du point regardé en combinant heading et pitch
  float lookX = camX + cos(heading) * cos(pitch);
  float lookY = camY + sin(heading) * cos(pitch);
  float lookZ = camZ + sin(pitch);
  
  perspective(PI/3, (float)width/height, 1, 1000);
  camera(camX, camY, camZ, lookX, lookY, lookZ, 0, 0, -1);
  

  if (scene == 0) {

    // test pour l'entrée dans la pyramide
    if (newX+2000 < 2000 && newY+2000 > 2000) {
      scene = 1;
      posX = 1;
      posY = 1;
      newX = 1;
      newY = 1;
    }
    
    perspective(PI/3, (float)width/height, 1, 10000);
    lights();
    ambientLight(100, 100, 100);
    
    posX = newX;
    posY = newY;
    
    // Définir une couleur bleu ciel pour l'arrière-plan
    background(135, 206, 235);
    
    float sunDirX_norm = 1.0;
    float sunDirY_norm = 0.8;
    float sunDirZ_norm = -0.75;

    directionalLight(255, 255, 0,
                     sunDirX_norm, sunDirY_norm, sunDirZ_norm);
      
    //  Dessin du Soleil 3D
    pushMatrix();
    // Positionner le soleil très loin dans la direction *opposée* à la lumière directionnelle
    float sunDistance = 6000;
    translate(-sunDirX_norm * sunDistance,
              -sunDirY_norm * sunDistance,
              -sunDirZ_norm * sunDistance);
  
    // Faire briller le soleil et ignorer l'éclairage de la scène
    noStroke();
    fill(255, 255, 0); // Jaune vif
    emissive(255, 255, 0); // Le faire émettre sa propre lumière
    sphere(200);         // Taille du soleil visuel (ajuster au besoin)
    emissive(0, 0, 0);   // !!! IMPORTANT: Réinitialiser l'émission pour les objets suivants !!!
    popMatrix();  
    noStroke();
    
  
  
  
    pyramide.display();
    desertEffect.set("time", millis() / 1000.0); 
    
    // Appliquer le shader sur toute la scène
    filter(desertEffect);

  }
  
  if (scene == 1) {
       // --- Vérification de la collision Joueur-Momie ---
    if (!isPlayerDead) { // Ne vérifie que si le joueur n'est pas déjà mort
        float distanceSq = sq(posX - momie.posX) + sq(posY - momie.posY);
        float momieRadius = 0.3;
        float collisionRadiusSum = playerRadius + momieRadius;
        if (distanceSq < sq(collisionRadiusSum)) {
            triggerPlayerDeath();
        }
    }

    
    if (newX < 1.5 && newY < 0.5) {
      scene = 0;
    }
    
    // Vérification de collision
    if (!isClimbing) {
      if (!collides(newX, newY,'j')) {
        posX = newX;
        posY = newY;
      } else {
        // Gérer un glissement en vérifiant séparément l'axe X et Y
        if (!collides(newX, posY,'j')) posX = newX;
        if (!collides(posX, newY,'j')) posY = newY;
      }
    }
    
    
    noLights();
    pointLight(255, 255, 255, posX*wallH, posY*wallH, 15);
  
    noStroke();
  
    int cellX = int(posX);
    int cellY = int(posY);
    
    if (labyrinthe[cellY][cellX] == 'X' && !isClimbing) {
      isClimbing = true;
    }

    // Animation de montée de l'échelle
    if (isClimbing) {
      camZ += climbSpeed; // Augmente la position Z de la caméra pour simuler la montée
      if (camZ >= climbTargetZ) { // Vérifie si l'animation est terminée
        isClimbing = false;
        nextLevel();
        // Réinitialiser la position Z de la caméra à sa valeur par défaut après la montée
        camZ = -15;
        for (int j = 0; j < labSize; j++) {
          for (int i = 0; i < labSize; i++) {
            discovered[j][i] = false;
          }
        }
        discovered[int(posY)][int(posX)] = true;
      }
    }

  
  
      // Affichage des formes compilées du labyrinthe
      shape(laby0, 0, 0);
      shape(ceiling0, 0, 0);
  
  

      ladder3D.display();

  
      // Appel de l'affichage du débogage pour les collisions
      //debug.drawPlayerCollision(posX, posY, wallH, playerRadius);
      //debug.drawWallCollisions(labyrinthe, labSize, wallH);
  
      // Mise à jour et affichage de la momie
      momie.update();
      momie.display();
      
      
      
      horrorMazeShader.set("time", millis() / 1000.0);
      horrorMazeShader.set("pulseSpeed", pulseSpeed);
      horrorMazeShader.set("flickerIntensity", flickerIntensity);
      
      // Appliquer le shader
      filter(horrorMazeShader);
    }
  if (isPlayerDead) {
    // Vérifier si le délai d'affichage est toujours en cours
    if (millis() < deathTimestamp + DEATH_MESSAGE_DURATION) {
  
      // --- Configuration pour dessin 2D par-dessus la 3D ---
      pushMatrix(); // Sauvegarde la matrice de transformation actuelle
      pushStyle();  // Sauvegarde les styles actuels (couleur, taille texte, etc.)
  
      hint(DISABLE_DEPTH_TEST); // Permet de dessiner en 2D sans se soucier de la profondeur 3D
      camera(); // Réinitialise la caméra en mode 2D par défaut
      ortho();  // Utilise une projection orthographique (standard pour 2D)
  
      // --- Dessiner le texte ---
      textSize(80);              // Taille du texte 
      fill(200, 0, 0, 220);      // Couleur rouge semi-transparente
      textAlign(CENTER, CENTER); // Centrer le texte horizontalement et verticalement
      text("YOU DIED", width / 2, height / 2); // Afficher au centre
  
      // --- Restaurer l'état précédent ---
      hint(ENABLE_DEPTH_TEST); // Réactive le test de profondeur pour le prochain cycle de dessin 3D
      popStyle(); // Restaure les styles
      popMatrix(); // Restaure la matrice de transformation
  
      // !! Important: Rétablir la perspective pour le prochain frame 3D !!
      // Sinon la caméra restera en mode 2D/ortho
      perspective(PI/3, (float)width/height, 1, (scene == 0 ? 10000 : 1000));
      // La caméra 3D sera recalculée au début du prochain draw() de toute façon
  
    } 
  }
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
