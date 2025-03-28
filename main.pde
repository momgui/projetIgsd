// Variables de position et direction du joueur
int iposX = 1;
int iposY = -1;
int posX = iposX;
int posY = iposY;
int dirX = 0, dirY = 1;
int odirX = 0, odirY = 1;
final int WALLD = 1;

// Variables d'animation
int anim = 0;
boolean animT = false;
boolean animR = false;
boolean inLab = true;

// Paramètres du labyrinthe
final int LAB_SIZE = 21;
char labyrinthe[][];
char sides[][][];

// Formes et texture
PShape laby0;
PShape ceiling0;
PShape ceiling1;
PImage texture0;

// Dimensions pré-calculées
float wallH;
float wallH;

void setup() { 
  pixelDensity(2);
  randomSeed(2);
  texture0 = loadImage("stones.tif");
  fullScreen(P3D);  // Mode plein écran en 3D

  // Initialisation des tableaux
  labyrinthe = new char[LAB_SIZE][LAB_SIZE];
  sides = new char[LAB_SIZE][LAB_SIZE][4];

  // Génération du labyrinthe
  generateLabyrinth();
  
  // Calcul préliminaire des dimensions des murs
  wallH = (float) width / LAB_SIZE;
  wallH = (float) height / LAB_SIZE;
  
  // Construction des formes (murs, sols et plafonds)
  buildShapes();
}

void generateLabyrinth() {
  int todig = 0;
  // Remplissage initial et initialisation des "sides"
  for (int j = 0; j < LAB_SIZE; j++) {
    for (int i = 0; i < LAB_SIZE; i++) {
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
    else if (alea == 2 && gx < LAB_SIZE - 2)
      gx += 2;
    else if (alea == 3 && gy < LAB_SIZE - 2)
      gy += 2;
      
    if (labyrinthe[gy][gx] == '.') {
      todig--;
      labyrinthe[gy][gx] = ' ';
      labyrinthe[(gy + oldgy) / 2][(gx + oldgx) / 2] = ' ';
    }
  }
  
  // Définition de l'entrée et de la sortie
  labyrinthe[0][1] = ' ';             // entrée
  labyrinthe[LAB_SIZE - 2][LAB_SIZE - 1] = ' ';  // sortie
  
  // Détermination des "sides" en fonction des murs autour des cases vides
  for (int j = 1; j < LAB_SIZE - 1; j++) {
    for (int i = 1; i < LAB_SIZE - 1; i++) {
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
  
  for (int j = 0; j < LAB_SIZE; j++) {
    for (int i = 0; i < LAB_SIZE; i++) {
      if (labyrinthe[j][i] == '#') {
        laby0.fill(i * 25, j * 25, 255 - i * 10 + j * 10);
        
        // Face supérieure du mur
        if (j == 0 || labyrinthe[j - 1][i] == ' ') {
          laby0.normal(0, -1, 0);
          for (int k = 0; k < WALLD; k++) {
            for (int l = -WALLD; l < WALLD; l++) {
              laby0.vertex(i * wallH - wallH/2 + (k + 0)*wallH/WALLD, j * wallH - wallH/2, (l + 0)*wallH/WALLD,
                           k / (float)WALLD * texture0.width, (0.5 + l/ (2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 1)*wallH/WALLD, j * wallH - wallH/2, (l + 0)*wallH/WALLD,
                           (k + 1) / (float)WALLD * texture0.width, (0.5 + l/(2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 1)*wallH/WALLD, j * wallH - wallH/2, (l + 1)*wallH/WALLD,
                           (k + 1) / (float)WALLD * texture0.width, (0.5 + (l+1)/(2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 0)*wallH/WALLD, j * wallH - wallH/2, (l + 1)*wallH/WALLD,
                           k / (float)WALLD * texture0.width, (0.5 + (l+1)/(2.0*WALLD)) * texture0.height);
            }
          }
        }
        
        // Face inférieure du mur
        if (j == LAB_SIZE - 1 || labyrinthe[j + 1][i] == ' ') {
          laby0.normal(0, 1, 0);
          for (int k = 0; k < WALLD; k++) {
            for (int l = -WALLD; l < WALLD; l++) {
              laby0.vertex(i * wallH - wallH/2 + (k + 0)*wallH/WALLD, j * wallH + wallH/2, (l + 1)*wallH/WALLD,
                           (k + 0) / (float)WALLD * texture0.width, (0.5 + (l+1)/(2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 1)*wallH/WALLD, j * wallH + wallH/2, (l + 1)*wallH/WALLD,
                           (k + 1) / (float)WALLD * texture0.width, (0.5 + (l+1)/(2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 1)*wallH/WALLD, j * wallH + wallH/2, (l + 0)*wallH/WALLD,
                           (k + 1) / (float)WALLD * texture0.width, (0.5 + (l+0)/(2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2 + (k + 0)*wallH/WALLD, j * wallH + wallH/2, (l + 0)*wallH/WALLD,
                           (k + 0) / (float)WALLD * texture0.width, (0.5 + (l+0)/(2.0*WALLD)) * texture0.height);
            }
          }
        }
        
        // Face gauche du mur
        if (i == 0 || labyrinthe[j][i - 1] == ' ') {
          laby0.normal(-1, 0, 0);
          for (int k = 0; k < WALLD; k++) {
            for (int l = -WALLD; l < WALLD; l++) {
              laby0.vertex(i * wallH - wallH/2, j * wallH - wallH/2 + (k + 0)*wallH/WALLD, (l + 1)*wallH/WALLD,
                           (k + 0) / (float)WALLD * texture0.width, (0.5 + (l+1)/(2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2, j * wallH - wallH/2 + (k + 1)*wallH/WALLD, (l + 1)*wallH/WALLD,
                           (k + 1) / (float)WALLD * texture0.width, (0.5 + (l+1)/(2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2, j * wallH - wallH/2 + (k + 1)*wallH/WALLD, (l + 0)*wallH/WALLD,
                           (k + 1) / (float)WALLD * texture0.width, (0.5 + (l+0)/(2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH - wallH/2, j * wallH - wallH/2 + (k + 0)*wallH/WALLD, (l + 0)*wallH/WALLD,
                           (k + 0) / (float)WALLD * texture0.width, (0.5 + (l+0)/(2.0*WALLD)) * texture0.height);
            }
          }
        }
        
        // Face droite du mur
        if (i == LAB_SIZE - 1 || labyrinthe[j][i + 1] == ' ') {
          laby0.normal(1, 0, 0);
          for (int k = 0; k < WALLD; k++) {
            for (int l = -WALLD; l < WALLD; l++) {
              laby0.vertex(i * wallH + wallH/2, j * wallH - wallH/2 + (k + 0)*wallH/WALLD, (l + 0)*wallH/WALLD,
                           (k + 0) / (float)WALLD * texture0.width, (0.5 + (l+0)/(2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH + wallH/2, j * wallH - wallH/2 + (k + 1)*wallH/WALLD, (l + 0)*wallH/WALLD,
                           (k + 1) / (float)WALLD * texture0.width, (0.5 + (l+0)/(2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH + wallH/2, j * wallH - wallH/2 + (k + 1)*wallH/WALLD, (l + 1)*wallH/WALLD,
                           (k + 1) / (float)WALLD * texture0.width, (0.5 + (l+1)/(2.0*WALLD)) * texture0.height);
              laby0.vertex(i * wallH + wallH/2, j * wallH - wallH/2 + (k + 0)*wallH/WALLD, (l + 1)*wallH/WALLD,
                           (k + 0) / (float)WALLD * texture0.width, (0.5 + (l+1)/(2.0*WALLD)) * texture0.height);
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

void draw() {
  background(192);
  sphereDetail(6);
  if (anim > 0) anim--;
  
  // Caméra et perspective standard
  perspective();
  camera(width/2.0, height/2.0, (height/2.0)/tan(PI*30.0/180.0),
         width/2.0, height/2.0, 0, 0, 1, 0);
  noLights();
  stroke(0);
  
  // Affichage simple des murs sous forme de box
  for (int j = 0; j < LAB_SIZE; j++) {
    for (int i = 0; i < LAB_SIZE; i++) {
      if (labyrinthe[j][i] == '#') {
        fill(i * 25, j * 25, 255 - i * 10 + j * 10);
        pushMatrix();
        translate(wallH + i * wallH/8, wallH + j * wallH/8, wallH);
        box(wallH/10, wallH/10, 5);
        popMatrix();
      }
    }
  }
  
  // Affichage du joueur
  pushMatrix();
  fill(0, 255, 0);
  noStroke();
  translate(wallH + posX * wallH/8, wallH + posY * wallH/8, wallH);
  sphere(3);
  popMatrix();
  
  // Mise en place de la caméra pour la vue dans le labyrinthe
  stroke(0);
  if (inLab) {
    perspective(2 * PI / 3, (float)width/height, 1, 1000);
    if (animT)
      camera((posX - dirX * anim/20.0)*wallH, (posY - dirY * anim/20.0)*wallH, -15 + 2*sin(anim*PI/5.0),
             (posX - dirX * anim/20.0 + dirX)*wallH, (posY - dirY * anim/20.0 + dirY)*wallH, -15 + 4*sin(anim*PI/5.0), 
             0, 0, -1);
    else if (animR) {
      camera(posX*wallH, posY*wallH, -15, 
             (posX + (odirX*anim + dirX*(20-anim))/20.0)*wallH, (posY + (odirY*anim + dirY*(20-anim))/20.0)*wallH, -15 - 5*sin(anim*PI/20.0),
             0, 0, -1);
    } else {
      camera(posX*wallH, posY*wallH, -15, 
             (posX+dirX)*wallH, (posY+dirY)*wallH, -15,
             0, 0, -1);
    }
    lightFalloff(0.0, 0.01, 0.0001);
    pointLight(255, 255, 255, posX*wallH, posY*wallH, 15);
  } else {
    lightFalloff(0.0, 0.05, 0.0001);
    pointLight(255, 255, 255, posX*wallH, posY*wallH, 15);
  }
  
  noStroke();
  // Affichage des formes compilées du labyrinthe
  shape(laby0, 0, 0);
  if (inLab)
    shape(ceiling0, 0, 0);
  else
    shape(ceiling1, 0, 0);
}

void keyPressed() {
  if (key == 'l') inLab = !inLab;

  if (anim == 0 && keyCode == UP) {
    if (posX + dirX >= 0 && posX + dirX < LAB_SIZE &&
        posY + dirY >= 0 && posY + dirY < LAB_SIZE &&
        labyrinthe[posY + dirY][posX + dirX] != '#') {
      posX += dirX; 
      posY += dirY;
      anim = 20;
      animT = true;
      animR = false;
    }
  }
  if (anim == 0 && keyCode == DOWN &&
      labyrinthe[posY - dirY][posX - dirX] != '#') {
    posX -= dirX; 
    posY -= dirY;
  }
  if (anim == 0 && keyCode == LEFT) {
    odirX = dirX;
    odirY = dirY;
    anim = 20;
    int tmp = dirX; 
    dirX = dirY; 
    dirY = -tmp;
    animT = false;
    animR = true;
  }
  if (anim == 0 && keyCode == RIGHT) {
    odirX = dirX;
    odirY = dirY;
    anim = 20;
    animT = false;
    animR = true;
    int tmp = dirX; 
    dirX = -dirY; 
    dirY = tmp;
  }
}
