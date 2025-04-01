/**
 * Pyramide - Asset for projetIgsd
 * 
 * Classe permettant de créer une pyramide solide avec un sol de sable
 * Peut être utilisée comme asset dans le programme principal
 */

class Pyramide {
  // Dimensions de la pyramide
  float baseWidth;
  float baseLength;
  float height;
  
  // Dimensions du sol de sable
  float sandBaseSize;
  
  // Position dans l'espace
  PVector position;
  
  // Textures
  PImage textureStone;
  PImage textureSand;
  
  // Constructeur
  Pyramide(float x, float y, float z, float baseW, float baseL, float h, float sandSize) {
    position = new PVector(x, y, z);
    baseWidth = baseW;
    baseLength = baseL;
    height = h;
    sandBaseSize = sandSize;
    
    // Chargement des textures (à placer dans le dossier data)
    loadTextures();
  }
  
  // Chargement des textures
  void loadTextures() {
    try {
      textureStone = loadImage("stone_texture.jpg");
      textureSand = loadImage("sand_texture.jpg");
    } catch (Exception e) {
      // Si les textures ne sont pas trouvées, utiliser des couleurs par défaut
      println("Attention: Textures non trouvées. Utilisation des couleurs par défaut.");
      textureStone = null;
      textureSand = null;
    }
  }
  
  // Dessiner la pyramide et le sol de sable
  void display() {
    pushMatrix();
    
    // Positionnement dans l'espace
    translate(position.x, position.y, position.z);
    
    // Dessiner le sol de sable
    drawSandBase();
    
    // Dessiner la pyramide
    drawPyramide();
    
    popMatrix();
  }
  
  // Dessiner le sol de sable
  void drawSandBase() {
    pushMatrix();
    
    // Translation pour élever légèrement le sol au-dessus de 0
    translate(0, 2, 0);
    
    beginShape(QUADS);
    if (textureSand != null) {
      texture(textureSand);
      textureMode(NORMAL);
    } else {
      fill(245, 222, 179); // Couleur sable
    }
    
    // Dessiner le carré du sol
    float halfSize = sandBaseSize / 2;
    
    // Face supérieure du sol (avec texture)
    if (textureSand != null) {
      vertex(-halfSize, 0, -halfSize, 0, 0);
      vertex(halfSize, 0, -halfSize, 1, 0);
      vertex(halfSize, 0, halfSize, 1, 1);
      vertex(-halfSize, 0, halfSize, 0, 1);
    } else {
      vertex(-halfSize, 0, -halfSize);
      vertex(halfSize, 0, -halfSize);
      vertex(halfSize, 0, halfSize);
      vertex(-halfSize, 0, halfSize);
    }
    
    endShape();
    
    // Effet de dunes de sable
    drawSandDunes();
    
    popMatrix();
  }
  
  // Dessiner des dunes de sable pour un effet plus réaliste
  void drawSandDunes() {
    float duneHeight = 5;
    float duneSize = 50;
    float halfSize = sandBaseSize / 2;
    
    pushMatrix();
    
    if (textureSand != null) {
      fill(245, 222, 179, 200); // Semi-transparent
    } else {
      fill(245, 222, 179); // Couleur sable
    }
    
    // Créer plusieurs petites dunes aléatoires
    for (int i = 0; i < 15; i++) {
      float x = random(-halfSize + 50, halfSize - 50);
      float z = random(-halfSize + 50, halfSize - 50);
      
      // Éviter de placer des dunes sous la pyramide
      if (abs(x) < baseWidth/2 && abs(z) < baseLength/2) continue;
      
      pushMatrix();
      translate(x, 0, z);
      
      // Dessiner une dune
      beginShape();
      for (int angle = 0; angle < 360; angle += 10) {
        float rad = radians(angle);
        float xDune = cos(rad) * (duneSize/2);
        float zDune = sin(rad) * (duneSize/2);
        float yDune = duneHeight * (1 - abs(angle - 180) / 180.0);
        vertex(xDune, -yDune, zDune);
      }
      endShape(CLOSE);
      popMatrix();
    }
    
    popMatrix();
  }
  
  // Dessiner la pyramide
  void drawPyramide() {
    float halfWidth = baseWidth / 2;
    float halfLength = baseLength / 2;
    
    pushMatrix();
    
    // Si la texture existe, l'utiliser, sinon utiliser une couleur
    if (textureStone != null) {
      textureMode(NORMAL);
    } else {
      fill(210, 180, 140); // Couleur pierre
    }
    
    // Dessiner la base de la pyramide (face inférieure)
    beginShape(QUADS);
    if (textureStone != null) {
      texture(textureStone);
    }
    
    // Face inférieure (base)
    if (textureStone != null) {
      vertex(-halfWidth, 0, -halfLength, 0, 0);
      vertex(halfWidth, 0, -halfLength, 1, 0);
      vertex(halfWidth, 0, halfLength, 1, 1);
      vertex(-halfWidth, 0, halfLength, 0, 1);
    } else {
      vertex(-halfWidth, 0, -halfLength);
      vertex(halfWidth, 0, -halfLength);
      vertex(halfWidth, 0, halfLength);
      vertex(-halfWidth, 0, halfLength);
    }
    endShape();
    
    // Dessiner les faces de la pyramide
    beginShape(TRIANGLES);
    if (textureStone != null) {
      texture(textureStone);
    } else {
      fill(210, 180, 140); // Couleur pierre
    }
    
    // Face avant
    if (textureStone != null) {
      vertex(-halfWidth, 0, halfLength, 0, 1);
      vertex(halfWidth, 0, halfLength, 1, 1);
      vertex(0, -height, 0, 0.5, 0);
    } else {
      vertex(-halfWidth, 0, halfLength);
      vertex(halfWidth, 0, halfLength);
      vertex(0, -height, 0);
    }
    
    // Face droite
    if (textureStone != null) {
      vertex(halfWidth, 0, halfLength, 0, 1);
      vertex(halfWidth, 0, -halfLength, 1, 1);
      vertex(0, -height, 0, 0.5, 0);
    } else {
      vertex(halfWidth, 0, halfLength);
      vertex(halfWidth, 0, -halfLength);
      vertex(0, -height, 0);
    }
    
    // Face arrière
    if (textureStone != null) {
      vertex(halfWidth, 0, -halfLength, 0, 1);
      vertex(-halfWidth, 0, -halfLength, 1, 1);
      vertex(0, -height, 0, 0.5, 0);
    } else {
      vertex(halfWidth, 0, -halfLength);
      vertex(-halfWidth, 0, -halfLength);
      vertex(0, -height, 0);
    }
    
    // Face gauche
    if (textureStone != null) {
      vertex(-halfWidth, 0, -halfLength, 0, 1);
      vertex(-halfWidth, 0, halfLength, 1, 1);
      vertex(0, -height, 0, 0.5, 0);
    } else {
      vertex(-halfWidth, 0, -halfLength);
      vertex(-halfWidth, 0, halfLength);
      vertex(0, -height, 0);
    }
    
    endShape();
    
    // Ajouter quelques détails à la pyramide (entrée, etc.)
    addDetails();
    
    popMatrix();
  }
  
  // Ajouter des détails à la pyramide
  void addDetails() {
    float halfWidth = baseWidth / 2;
    float detailSize = baseWidth / 10;
    
    // Dessiner une entrée sur la face avant
    pushMatrix();
    translate(0, -detailSize, halfWidth);
    
    // Utiliser une couleur plus sombre pour l'entrée
    fill(30, 30, 30);
    
    // Entrée de la pyramide
    box(detailSize * 2, detailSize * 2, detailSize);
    
    popMatrix();
    
    // Ajouter quelques blocs autour de la pyramide
    pushMatrix();
    if (textureStone != null) {
      noStroke();
    } else {
      fill(190, 160, 120);
    }
    
    // Quelques blocs éparpillés
    for (int i = 0; i < 8; i++) {
      float angle = random(TWO_PI);
      float dist = random(baseWidth * 0.6, sandBaseSize * 0.4);
      float blockSize = random(10, 25);
      float x = cos(angle) * dist;
      float z = sin(angle) * dist;
      
      pushMatrix();
      translate(x, -blockSize/2, z);
      box(blockSize);
      popMatrix();
    }
    
    popMatrix();
  }
  
  // Méthode pour mettre à jour la position
  void setPosition(float x, float y, float z) {
    position.set(x, y, z);
  }
  
  // Méthode pour définir les dimensions
  void setDimensions(float baseW, float baseL, float h) {
    baseWidth = baseW;
    baseLength = baseL;
    height = h;
  }
  
  // Méthode pour définir la taille du sol de sable
  void setSandBaseSize(float size) {
    sandBaseSize = size;
  }
}

// Fonction exemple pour afficher la pyramide (pourra être importée dans main)
void setupPyramide() {
  // Créer les répertoires nécessaires si ce n'est pas déjà fait
  File dataFolder = new File(sketchPath("data"));
  if (!dataFolder.exists()) {
    dataFolder.mkdir();
  }
  
  // Définir les dimensions d'une pyramide
  float baseWidth = 200;
  float baseLength = 200;
  float height = 150;
  float sandSize = 500;
  
  // Créer une instance de pyramide
  Pyramide maPyramide = new Pyramide(0, 0, 0, baseWidth, baseLength, height, sandSize);
  
  // Créer des textures de base si elles n'existent pas
  createDefaultTextures();
  

}

// Fonction utilitaire pour créer des textures par défaut
void createDefaultTextures() {
  // Vérifier si les textures existent déjà
  File stoneTexture = new File(sketchPath("data/stone_texture.jpg"));
  File sandTexture = new File(sketchPath("data/sand_texture.jpg"));
  
  // Si les textures n'existent pas, créer des textures simples
  if (!stoneTexture.exists()) {
    PGraphics pg = createGraphics(512, 512);
    pg.beginDraw();
    pg.background(210, 180, 140);
    
    // Créer une texture de pierre
    for (int i = 0; i < 500; i++) {
      float x = random(pg.width);
      float y = random(pg.height);
      float s = random(5, 20);
      pg.noStroke();
      pg.fill(random(180, 200), random(150, 170), random(120, 140), random(100, 255));
      pg.ellipse(x, y, s, s);
    }
    
    // Ajouter des motifs de lignes pour imiter les jointures de pierre
    for (int i = 0; i < 20; i++) {
      pg.stroke(150, 130, 100, 150);
      pg.strokeWeight(random(1, 3));
      float y = random(pg.height);
      pg.line(0, y, pg.width, y + random(-50, 50));
    }
    
    for (int i = 0; i < 20; i++) {
      pg.stroke(150, 130, 100, 150);
      pg.strokeWeight(random(1, 3));
      float x = random(pg.width);
      pg.line(x, 0, x + random(-50, 50), pg.height);
    }
    
    pg.endDraw();
    pg.save(sketchPath("data/stone_texture.jpg"));
  }
  
  // Créer une texture de sable
  if (!sandTexture.exists()) {
    PGraphics pg = createGraphics(512, 512);
    pg.beginDraw();
    pg.background(245, 222, 179);
    
    // Ajouter du bruit pour imiter le sable
    for (int i = 0; i < 5000; i++) {
      pg.noStroke();
      pg.fill(random(235, 255), random(212, 232), random(169, 189), random(50, 150));
      float x = random(pg.width);
      float y = random(pg.height);
      pg.ellipse(x, y, random(1, 3), random(1, 3));
    }
    
    // Ajouter de légères ondulations
    for (int i = 0; i < 30; i++) {
      pg.stroke(230, 210, 170, 100);
      pg.strokeWeight(1);
      float y = random(pg.height);
      pg.noFill();
      pg.beginShape();
      for (int x = 0; x < pg.width; x += 5) {
        pg.curveVertex(x, y + sin(x * 0.05) * random(5, 15));
      }
      pg.endShape();
    }
    
    pg.endDraw();
    pg.save(sketchPath("data/sand_texture.jpg"));
  }
}
