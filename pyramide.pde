class Pyramide {
  // Dimensions de la pyramide
  float baseWidth;  // Dimension sur l'axe X
  float baseLength; // Dimension sur l'axe Y
  float height;     // Dimension sur l'axe Z (négatif car -Z est haut)

  // Dimensions du sol de sable
  float sandBaseSize; // Taille du carré de sable (X et Y)

  // Position dans l'espace (centre de la base)
  PVector position; // Coordonnées du monde (x, y, z) où la base est centrée

  // Textures
  PImage textureStone;
  PImage textureSand;
  
  // Facteurs de répétition pour les textures
  float stoneTileFactor;
  float sandTileFactor;  // Répétition de la texture sable
  int terrainResolution; // Nombre de subdivisions par côté
  float noiseScale;      // Échelle du bruit pour la taille des collines
  float heightAmplitude; // Hauteur max des collines
  float[][] terrainHeights; // Stockage des hauteurs pré-calculées (relatives à position.z)

  // Constructeur MODIFIÉ pour inclure les paramètres du terrain
  Pyramide(float worldX, float worldY, float worldZ, // Position de la base
           float baseW, float baseL, float h, // Dimensions Pyramide
           float terrainSize, float stoneTiling, // Taille terrain, tiling pierre
           // Nouveaux paramètres pour le terrain :
           float sandTiling, int resolution, float nScale, float hAmplitude)
  {
    // worldX, worldY, worldZ: Coordonnées où placer le centre de la base de la pyramide
    position = new PVector(worldX-2000, worldY+2000, worldZ-250); 
    baseWidth = baseW*10;
    baseLength = baseL*10;
    height = h*10; // La hauteur sera appliquée sur l'axe Z négatif
    sandBaseSize = terrainSize*10;
    
    
    stoneTileFactor = stoneTiling;
    sandTileFactor = sandTiling;
    terrainResolution = resolution;
    noiseScale = nScale;
    heightAmplitude = hAmplitude;

    loadTextures();

    // Initialiser et générer les hauteurs du terrain
    // Note: +1 car N subdivisions nécessitent N+1 vertices par côté
    terrainHeights = new float[terrainResolution + 1][terrainResolution + 1];
    generateTerrainHeights();
    


    // Stocker les facteurs de tiling
    sandTileFactor = sandTiling;
    stoneTileFactor = stoneTiling;

    loadTextures();
  }

  // Chargement des textures
  void loadTextures() {
    textureStone = loadImage("stonesPyramide.tif");

    textureSand = loadImage("sand.tif");
  }
  
  
  /**
   * Génère les hauteurs du terrain en utilisant le bruit de Perlin
   * et les stocke dans le tableau terrainHeights.
   * Les hauteurs sont relatives au niveau Z de base (position.z).
   */
  void generateTerrainHeights() {
    float halfSize = sandBaseSize / 2.0;
    for (int i = 0; i <= terrainResolution; i++) {
      for (int j = 0; j <= terrainResolution; j++) {
        // Coordonnées X et Y du point actuel sur la grille dans le monde
        // (centrées autour de 0, car on translat_era à position.x, position.y plus tard)
        float x = map(i, 0, terrainResolution, -halfSize, halfSize);
        float y = map(j, 0, terrainResolution, -halfSize, halfSize);

        // Calculer la valeur de bruit de Perlin pour ce point
        // On utilise les coordonnées monde * échelle pour que la taille des collines
        // dépende de noiseScale et non de la résolution.
        float noiseValue = noise(x * noiseScale, y * noiseScale);

        // Mapper la valeur de bruit (0 à 1) à l'amplitude de hauteur désirée
        float h = map(noiseValue, 0, 1, 0, heightAmplitude); // Hauteur relative

        terrainHeights[i][j] = h;
      }
    }
  }


  // Dessiner la pyramide et le sol de sable
  void display() {
    pushMatrix();

    // Positionnement dans l'espace au centre de la base prévu
    translate(position.x, position.y, position.z);

    // Dessiner le sol de sable (à la coordonnée Z de la position)
    drawSandBase();

    // Dessiner la pyramide (sa base sera à la coordonnée Z de la position)
    drawPyramide();

    popMatrix();
    textureMode(IMAGE);         // remets le mode UV en pixels
    textureWrap(CLAMP);  
  }

  // Dessiner le sol de sable
  void drawSandBase() {

    pushMatrix(); 
    textureMode(NORMAL); 
    textureWrap(REPEAT);
    
    noStroke();

    float cellSize = sandBaseSize / terrainResolution;
    float halfSize = sandBaseSize / 2.0;

    // Itérer sur chaque cellule de la grille pour dessiner un QUAD
    for (int i = 0; i < terrainResolution; i++) {
      for (int j = 0; j < terrainResolution; j++) {

        // Obtenir les hauteurs pré-calculées des 4 coins de la cellule
        float h00 = terrainHeights[i][j];         // Hauteur au coin (i, j)
        float h10 = terrainHeights[i+1][j];       // Hauteur au coin (i+1, j)
        float h11 = terrainHeights[i+1][j+1];   // Hauteur au coin (i+1, j+1)
        float h01 = terrainHeights[i][j+1];     // Hauteur au coin (i, j+1)

        // Calculer les coordonnées X, Y locales des 4 coins
        float x0 = -halfSize + i * cellSize;
        float y0 = -halfSize + j * cellSize;
        float x1 = x0 + cellSize;
        float y1 = y0 + cellSize;

        // Calculer les coordonnées de texture (U, V) pour les 4 coins, en appliquant le tiling
        float u0 = map(i,   0, terrainResolution, 0, sandTileFactor);
        float v0 = map(j,   0, terrainResolution, 0, sandTileFactor);
        float u1 = map(i+1, 0, terrainResolution, 0, sandTileFactor);
        float v1 = map(j+1, 0, terrainResolution, 0, sandTileFactor);

        // Dessiner le QUAD pour cette cellule de terrain
        // L'ordre des sommets est anti-horaire vu de -Z (haut) pour des normales correctes
        beginShape(QUADS);
        texture(textureSand);
        // Coin (i, j) - inférieur gauche local
        vertex(x0, y0, h00, u0, v0);
        // Coin (i+1, j) - inférieur droit local
        vertex(x1, y0, h10, u1, v0);
         // Coin (i+1, j+1) - supérieur droit local
        vertex(x1, y1, h11, u1, v1);
        // Coin (i, j+1) - supérieur gauche local
        vertex(x0, y1, h01, u0, v1);
        endShape();
      }
    }

    popMatrix(); // Restaurer le style/transformations
  }


  // Dessiner la pyramide
  void drawPyramide() {
    float halfWidth = baseWidth / 2;
    float halfLength = baseLength / 2;
    float peakZ = -height;

    pushMatrix();
    textureMode(NORMAL);
    textureWrap(REPEAT);


    // --- Faces latérales (triangles) ---
    beginShape(TRIANGLES);
    texture(textureStone);

    float uFactor = stoneTileFactor*10;
    float vFactor = stoneTileFactor*10;

    // Face 1 (Y positif)
    vertex(-halfWidth,  halfLength, 0, 0 * uFactor    , 1 * vFactor); // Base Supérieur gauche
    vertex( halfWidth,  halfLength, 0, 1 * uFactor    , 1 * vFactor); // Base Supérieur droit
    vertex(         0,           0, -peakZ, 0.5 * uFactor  , 0 * vFactor); // Sommet

    // Face 2 (X positif)
    vertex( halfWidth,  halfLength, 0, 0 * uFactor    , 1 * vFactor);
    vertex( halfWidth, -halfLength, 0, 1 * uFactor    , 1 * vFactor);
    vertex(         0,           0, -peakZ, 0.5 * uFactor  , 0 * vFactor);

    // Face 3 (Y négatif)
    vertex( halfWidth, -halfLength, 0, 0 * uFactor    , 1 * vFactor);
    vertex(-halfWidth, -halfLength, 0, 1 * uFactor    , 1 * vFactor);
    vertex(         0,           0, -peakZ, 0.5 * uFactor  , 0 * vFactor);

    // Face 4 (X négatif)
    vertex(-halfWidth, -halfLength, 0, 0 * uFactor    , 1 * vFactor);
    vertex(-halfWidth,  halfLength, 0, 1 * uFactor    , 1 * vFactor);
    vertex(         0,           0, -peakZ, 0.5 * uFactor  , 0 * vFactor);

    endShape();
    popMatrix();

  }

  
}
