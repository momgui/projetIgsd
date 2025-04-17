class Ladder3D {
  // Dimensions de l'échelle
  float width;
  float height;
  float depth;
  int rungs;  // Nombre de barreaux
  
  // Position de l'échelle
  float x, y, z;
  
  // Couleurs
  color sideColor;
  color rungColor;
  
  // Le modèle 3D compilé
  PShape ladderModel;
  
  /**
   * Constructeur pour l'échelle 3D
   */
  Ladder3D(float x, float y, float z, float width, float height, float depth, int rungs) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.width = width;
    this.height = height;
    this.depth = depth;
    this.rungs = rungs;
    
    // Couleurs par défaut
    this.sideColor = color(139, 69, 19);  // Brun foncé pour les montants
    this.rungColor = color(160, 82, 45);  // Brun clair pour les barreaux
    
    // Construire le modèle
    buildLadderModel();
  }
  
  /**
   * Construit le modèle 3D de l'échelle
   */
  void buildLadderModel() {
    // Créer un groupe pour contenir toutes les parties de l'échelle
    ladderModel = createShape(GROUP);
    
    // Espacement entre les barreaux
    float rungSpacing = height / (rungs + 1);
    
    // Créer les deux montants verticaux
    PShape leftSide = createShape(BOX, depth, height, depth);
    leftSide.setFill(sideColor);
    leftSide.setStroke(false);
    
    PShape rightSide = createShape(BOX, depth, height, depth);
    rightSide.setFill(sideColor);
    rightSide.setStroke(false);
    
    // Position des montants
    float leftX = -width/2 + depth/2;
    float rightX = width/2 - depth/2;
    
    // Wrapper pour le montant gauche (le wrapper est important!)
    PShape leftSideWrapper = createShape(GROUP);
    leftSideWrapper.addChild(leftSide);
    
    // Wrapper pour le montant droit
    PShape rightSideWrapper = createShape(GROUP);
    rightSideWrapper.addChild(rightSide);
    
    // Ajouter les montants au modèle principal
    ladderModel.addChild(leftSideWrapper);
    ladderModel.addChild(rightSideWrapper);
    
    // Créer les barreaux horizontaux
    for (int i = 1; i <= rungs; i++) {
      float rungY = (i * rungSpacing) - (height/2);
      
      PShape rung = createShape(BOX, width, depth, depth);
      rung.setFill(rungColor);
      rung.setStroke(false);
      
      // Wrapper pour chaque barreau
      PShape rungWrapper = createShape(GROUP);
      rungWrapper.addChild(rung);
      
      // Ajouter le barreau au modèle principal
      ladderModel.addChild(rungWrapper);
    }
  }
  
  /**
   * Affiche l'échelle à sa position
   */
  void display() {
    pushMatrix();
    translate(x, y, z+10);
    rotateX(-PI/2);
    rotateY(PI/2);
    // Positionner les montants
    pushMatrix();
    translate(-width/2 + depth/2, 0, 0);
    shape(ladderModel.getChild(0));
    popMatrix();
    
    pushMatrix();
    translate(width/2 - depth/2, 0, 0);
    shape(ladderModel.getChild(1));
    popMatrix();
    
    // Positionner les barreaux
    for (int i = 0; i < rungs; i++) {
      int childIndex = i + 2;  // Les deux premiers enfants sont les montants
      if (childIndex < ladderModel.getChildCount()) {
        pushMatrix();
        translate(0, (i+1) * (height/(rungs+1)) - height/2, 0);
        shape(ladderModel.getChild(childIndex));
        popMatrix();
      }
    }
    
    popMatrix();
  }
}
