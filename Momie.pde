class Momie {
  // Position de la momie dans le labyrinthe (coordonnées en grille)
  float posX, posY;
  // Vitesse de déplacement
  float moveSpeed = 0.02;
  // Direction de déplacement (en radians)
  float heading;
  // Compteur pour changer de direction de temps en temps
  int changeCounter = 0;
 
  float noiseTimeFactor = 0.01;
  
  // Dimensions de la momie
  float bodyWidth = 70, bodyHeight = 200, bodyDepth = 60;
  float headRadius = 35;
  
  // Variables pour la bandelette spirale
  float spiralStripWidth = 3;
  float spiralOffset = 100;
  int spiralTurns = 14; // Nombre de tours de la bandelette du haut en bas
  
   
 
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
  
  if (!collides(newX, newY,'m')) {
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
      if (!collides(newX, newY,'m')) {
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
      if  (!collides(newX, newY,'m')){
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


// --- FONCTIONS DE DESSIN DU CORPS ---

float getBodyScale(float y, float halfHeight) {
  float normY = map(y, -halfHeight, halfHeight, 0, 1);

  if (normY < 0.35) {
    return map(pow(normY/0.35, 1.2), 0, 1, 0.55, 1.0);
  } else if (normY < 0.65) {
    return 1.0;
  } else {
    return map(pow((normY-0.65)/0.35, 0.8), 0, 1, 1.0, 0.65);
  }
}

PVector getBodyPoint(float angle, float height, float halfHeight, float maxWidth, float maxDepth) {
  float y = map(height, 0, PI, -halfHeight, halfHeight);
  float baseScale = getBodyScale(y, halfHeight);

  // Modulations organiques
  float vertUndulation = 1.0 + 0.08 * sin(height * 5.0);
  float horizUndulation = 1.0 + 0.06 * sin(angle * 4.0) * sin(map(y, -halfHeight, halfHeight, 0, PI));
  float noiseValue = noise(cos(angle) * 0.15, sin(angle) * 0.15, y * 0.05) * 2.0 - 1.0;
  float scale = baseScale * vertUndulation * horizUndulation * (1.0 + 0.03 * noiseValue);

  // Légère asymétrie
  float asymFactor = 1.0 + 0.05 * sin(angle);

  // Dimensions actuelles
  float currentHW = (maxWidth * scale * asymFactor) / 2.0;
  float currentHD = (maxDepth * scale) / 2.0;

  // Courbure de la colonne
  float spineOffset = 0.02 * maxDepth * sin(map(y, -halfHeight, halfHeight, -PI/2, PI/2));

  // Coordonnées
  float x = currentHW * cos(angle);
  float z = currentHD * sin(angle) + spineOffset;

  // Déformations des bandages
  float bandageOffset = 0.01 * maxWidth * sin(y * 25.0) * cos(angle * 2.0);
  x += bandageOffset * cos(angle);
  z += bandageOffset * sin(angle);

  return new PVector(x, y, z);
}

void setNoiseFill(float x, float y, float z, float time) {
  // Paramètres du motif de bandages
  float bandagePattern = sin(y * 20.0 + sin(atan2(z, x) * 3.0) * 0.5);
  float noiseValue = noise(x * 0.05, y * 0.05, z * 0.05 + time);
  float ageNoise = noise(x * 0.02, y * 0.02, z * 0.02 - time * 0.5) * 0.5;

  // Couleurs de base
  float r = 220 - 40 * abs(bandagePattern) - 20 * ageNoise;
  float g = 200 - 40 * abs(bandagePattern) - 20 * ageNoise;
  float b = 170 - 50 * abs(bandagePattern) - 20 * ageNoise;

  // Accentuer les creux
  if (bandagePattern < -0.7) {
    r -= 15;
    g -= 15;
    b -= 15;
  }

  // Taches d'usure
  if (noiseValue < 0.3) {
    float stainIntensity = (0.3 - noiseValue) * 3;
    r -= 40 * stainIntensity;
    g -= 20 * stainIntensity;
    b -= 30 * stainIntensity;
  }

  r = constrain(r, 140, 230);
  g = constrain(g, 120, 210);
  b = constrain(b, 100, 180);

  colorMode(RGB, 255);
  fill(r, g, b);
}

// Fonction pour les couleurs de la bandelette spirale
void setSpiralStripFill(float angle, float y, float time, float progress) {
  // Paramètres pour texture distinctive mais cohérente
  float stripAge = noise(angle * 0.1, y * 0.1, time * 0.5) * 0.8;
  float stripPattern = sin(angle * 5.0 + y * 0.5 + progress * 6.0);

  // Variation de couleur basée sur la position verticale (tête/pieds)
  float verticalFade = map(progress, 0, 1, 0.9, 1.1);

  // Couleurs légèrement plus vives que les bandages de base
  float r = 230 * verticalFade - 35 * abs(stripPattern) - 25 * stripAge;
  float g = 210 * verticalFade - 35 * abs(stripPattern) - 25 * stripAge;
  float b = 175 * verticalFade - 40 * abs(stripPattern) - 25 * stripAge;

  // Accentuer les plis
  if (stripPattern < -0.6) {
    r -= 20;
    g -= 15;
    b -= 15;
  }

  // Taches d'antiquité
  if (stripAge > 0.7) {
    float stainIntensity = (stripAge - 0.7) * 3;
    r -= 35 * stainIntensity;
    g -= 15 * stainIntensity;
    b -= 25 * stainIntensity;
  }

  r = constrain(r, 155, 240);
  g = constrain(g, 130, 220);
  b = constrain(b, 110, 190);

  colorMode(RGB, 255);
  fill(r, g, b);
}

void drawBody() {
  int detailU = 24; // Horizontal
  int detailV = 40; // Vertical
  float halfHeight = bodyHeight / 2.0;
  float time = frameCount * noiseTimeFactor;

  beginShape(QUADS);
  for (int i = 0; i < detailV; i++) {
    float v1 = map(i, 0, detailV, 0, PI);
    float v2 = map(i + 1, 0, detailV, 0, PI);

    for (int j = 0; j < detailU; j++) {
      float u1 = map(j, 0, detailU, 0, TWO_PI);
      float u2 = map(j + 1, 0, detailU, 0, TWO_PI);

      PVector p1 = getBodyPoint(u1, v1, halfHeight, bodyWidth, bodyDepth);
      PVector p2 = getBodyPoint(u2, v1, halfHeight, bodyWidth, bodyDepth);
      PVector p3 = getBodyPoint(u2, v2, halfHeight, bodyWidth, bodyDepth);
      PVector p4 = getBodyPoint(u1, v2, halfHeight, bodyWidth, bodyDepth);

      setNoiseFill(p1.x, p1.y, p1.z, time);
      vertex(p1.x, p1.y, p1.z);
      setNoiseFill(p2.x, p2.y, p2.z, time);
      vertex(p2.x, p2.y, p2.z);
      setNoiseFill(p3.x, p3.y, p3.z, time);
      vertex(p3.x, p3.y, p3.z);
      setNoiseFill(p4.x, p4.y, p4.z, time);
      vertex(p4.x, p4.y, p4.z);
    }
  }
  endShape();
}

// --- NOUVELLE FONCTION: BANDELETTE SPIRALE DE LA TÊTE AUX PIEDS ---
//fonction modifiée pour calculer les points de la spirale de manière plus cohérente
PVector getSpiralPoint(float angle, float height, boolean includeHead) {
  float totalHeight = bodyHeight;
  float topOffset = 0;

  if (includeHead) {
    totalHeight += headRadius * 2;
    topOffset = headRadius;
  }

  float y = map(height, 0, 1, -totalHeight/2 - topOffset, totalHeight/2);

  // Différencier la partie tête de la partie corps
  if (y < -bodyHeight/2) {
    // Position sur la tête
    float headY = y + bodyHeight/2;
    float headProgress = map(headY, -headRadius*2, 0, 0, 1);
    float radius = headRadius * sin(PI * headProgress);

    // Position sur la sphère de la tête
    float headAngle = angle; // Pas besoin d'offset, gardons la continuité
    float x = radius * cos(headAngle);
    float z = radius * sin(headAngle);

    return new PVector(x, y, z);
  } else {
    // Position sur le corps
    float bodyHeight = this.bodyHeight; // Utiliser la vraie hauteur, pas PI
    float bodyProgress = map(y, -bodyHeight/2, bodyHeight/2, 0, 1);
    float bodyAngle = angle;

    // Obtenir le point correspondant sur le corps
    PVector bodyPoint = getBodyPoint(bodyAngle, map(bodyProgress, 0, 1, 0, PI),
      bodyHeight/2, bodyWidth, bodyDepth);

    return bodyPoint;
  }
}

// Fonction modifiée pour dessiner la spirale avec transition fluide
void drawSpiralStrip() {
  float time = frameCount * noiseTimeFactor;
  int detailV = 120; // Plus de points pour plus de précision
  int detailW = 5;   // Points pour la largeur de la bandelette

  boolean includeHead = true;

  // Dessiner les segments de la bandelette spirale
  for (int i = 0; i < detailV-1; i++) {
    float h1 = map(i, 0, detailV-1, 0, 1);
    float h2 = map(i+1, 0, detailV-1, 0, 1);

    // Calculer l'angle de la spirale en fonction de la hauteur
    float baseAngle1 = spiralTurns * TWO_PI * h1 + spiralOffset;
    float baseAngle2 = spiralTurns * TWO_PI * h2 + spiralOffset;

    // Variation de l'angle selon la hauteur pour éviter l'aspect trop mécanique
    float angleVariation1 = sin(h1 * 4 * PI) * 0.05;
    float angleVariation2 = sin(h2 * 4 * PI) * 0.05;

    float angle1 = baseAngle1 + angleVariation1;
    float angle2 = baseAngle2 + angleVariation2;

    // Calculer la largeur de la bandelette avec variation
    float baseWidth = spiralStripWidth;
    float widthVariation1 = sin(h1 * 8 * PI + time) * 1.5;
    float widthVariation2 = sin(h2 * 8 * PI + time) * 1.5;

    float stripWidth1 = baseWidth + widthVariation1;
    float stripWidth2 = baseWidth + widthVariation2;

    // Obtenir le point central sur la spirale
    PVector center1 = getSpiralPoint(angle1, h1, includeHead);
    PVector center2 = getSpiralPoint(angle2, h2, includeHead);

    // Calculer les normales pour l'orientation de la bandelette
    // Direction verticale (le long de la spirale)
    PVector dir = PVector.sub(center2, center1);
    dir.normalize();

    // Déterminer si les points sont sur la tête ou le corps
    boolean onHead1 = center1.y < -bodyHeight/2;
    boolean onHead2 = center2.y < -bodyHeight/2;

    // Amélioration: créer une transition douce entre la tête et le corps
    float transition1 = 0;
    float transition2 = 0;
    float transitionStart = -bodyHeight/2;
    float transitionLength = bodyHeight * 0.1; // 10% du corps pour la transition

    if (center1.y >= transitionStart && center1.y <= transitionStart + transitionLength) {
      transition1 = map(center1.y, transitionStart, transitionStart + transitionLength, 1, 0);
    }

    if (center2.y >= transitionStart && center2.y <= transitionStart + transitionLength) {
      transition2 = map(center2.y, transitionStart, transitionStart + transitionLength, 1, 0);
    }

    // Direction perpendiculaire à la spirale (pour la largeur de la bandelette)
    PVector normal1 = new PVector();
    PVector normal2 = new PVector();

    if (onHead1) {
      // Sur la tête, la normale est radiale
      normal1.x = center1.x;
      normal1.y = 0;
      normal1.z = center1.z;
      normal1.normalize();
    } else {
      // Sur le corps, la normale est tangentielle à la surface
      PVector surfaceNormal = new PVector(center1.x, 0, center1.z);
      surfaceNormal.normalize();

      // Direction tangentielle au corps
      normal1.x = -sin(angle1);
      normal1.y = 0;
      normal1.z = cos(angle1);
      normal1.normalize();

      // Mélanger avec la normale de surface pour coller au corps
      normal1 = PVector.lerp(normal1, surfaceNormal, 0.6);
      normal1.normalize();
    }

    // Pour le second point (peut être sur une partie différente)
    if (onHead2) {
      normal2.x = center2.x;
      normal2.y = 0;
      normal2.z = center2.z;
      normal2.normalize();
    } else {
      PVector surfaceNormal = new PVector(center2.x, 0, center2.z);
      surfaceNormal.normalize();

      normal2.x = -sin(angle2);
      normal2.y = 0;
      normal2.z = cos(angle2);
      normal2.normalize();

      normal2 = PVector.lerp(normal2, surfaceNormal, 0.6);
      normal2.normalize();
    }

    // Gérer la transition entre la tête et le corps
    if (transition1 > 0) {
      PVector headNormal = new PVector(center1.x, 0, center1.z);
      headNormal.normalize();

      PVector bodyNormal = new PVector(-sin(angle1), 0, cos(angle1));
      bodyNormal.normalize();
      bodyNormal = PVector.lerp(bodyNormal, headNormal, 0.6);
      bodyNormal.normalize();

      normal1 = PVector.lerp(bodyNormal, headNormal, transition1);
      normal1.normalize();
    }

    if (transition2 > 0) {
      PVector headNormal = new PVector(center2.x, 0, center2.z);
      headNormal.normalize();

      PVector bodyNormal = new PVector(-sin(angle2), 0, cos(angle2));
      bodyNormal.normalize();
      bodyNormal = PVector.lerp(bodyNormal, headNormal, 0.6);
      bodyNormal.normalize();

      normal2 = PVector.lerp(bodyNormal, headNormal, transition2);
      normal2.normalize();
    }

    // Direction perpendiculaire aux deux premières (épaisseur de la bandelette)
    PVector binormal1 = normal1.cross(dir);
    binormal1.normalize();

    PVector binormal2 = normal2.cross(dir);
    binormal2.normalize();

    // Dessiner la section de bandelette comme un ruban
    beginShape(TRIANGLE_STRIP);
    for (int j = 0; j <= detailW; j++) {
      float w = map(j, 0, detailW, -0.5, 0.5);
      float t1 = h1;
      float t2 = h2;

      // Ajouter des ondulations à la bandelette
      float wave1 = sin(t1 * 20 + w * 5 + time * 2) * 0.7;
      float wave2 = sin(t2 * 20 + w * 5 + time * 2) * 0.7;

      // Calculer les points des bords de la bandelette
      PVector offset1 = PVector.mult(normal1, w * stripWidth1);
      PVector p1 = PVector.add(center1, offset1);
      p1.x += wave1 * binormal1.x * abs(w);
      p1.y += wave1 * binormal1.y * abs(w);
      p1.z += wave1 * binormal1.z * abs(w);

      PVector offset2 = PVector.mult(normal2, w * stripWidth2);
      PVector p2 = PVector.add(center2, offset2);
      p2.x += wave2 * binormal2.x * abs(w);
      p2.y += wave2 * binormal2.y * abs(w);
      p2.z += wave2 * binormal2.z * abs(w);

      // Coloration des bandelettes avec variation selon la position
      setSpiralStripFill(angle1 + w, p1.y, time, t1);
      vertex(p1.x, p1.y, p1.z);

      setSpiralStripFill(angle2 + w, p2.y, time, t2);
      vertex(p2.x, p2.y, p2.z);
    }
    endShape();
  }
}


  // --- FONCTIONS DE DESSIN DE LA TÊTE ---
  
  PVector sphereToCartesian(float r, float lon, float lat) {
    float x = r * cos(lat) * cos(lon);
    float y = r * sin(lat);
    float z = r * cos(lat) * sin(lon);
    return new PVector(x, y, z);
  }
  
  void deformToSkull(PVector p, float radius) {
    // Déformations pour un crâne réaliste
    if (p.z < 0) p.z *= 1.15;  // Alonger l'arrière
    if (abs(p.x) > radius * 0.4) p.x *= 0.9;  // Aplatir les côtés
    if (p.y > radius * 0.2) p.y *= 0.85;  // Aplatir le menton
    if (p.y < -radius * 0.2 && p.z > 0) p.z *= 1.1;  // Renflement du front
  
    // Ondulations des bandages
    float angle = atan2(p.z, p.x);
    float bandageOffset = 0.03 * radius * sin(p.y * 15.0) * cos(angle * 3.0);
    p.x += bandageOffset * cos(angle);
    p.z += bandageOffset * sin(angle);
  }
  
  void drawEyeSocket(float size, float depth) {
    int detail = 12;
    beginShape(TRIANGLE_FAN);
  
    // Centre et contour de l'orbite
    vertex(0, 0, -depth);
    for (int i = 0; i <= detail; i++) {
      float angle = map(i, 0, detail, 0, TWO_PI);
      float x = size * cos(angle);
      float y = size * sin(angle) * 0.8;
      vertex(x, y, 0);
    }
    endShape();
  }
  
  void drawHead() {
    pushMatrix();
    translate(0, -bodyHeight/2 - headRadius * 0.7, 0);
    rotateX(radians(-10)); // Légère inclinaison
  
    int detail = 20;
    float time = frameCount * noiseTimeFactor;
  
    beginShape(QUADS);
    for (int i = 0; i < detail; i++) {
      float lat1 = map(i, 0, detail, -HALF_PI, HALF_PI);
      float lat2 = map(i + 1, 0, detail, -HALF_PI, HALF_PI);
  
      for (int j = 0; j < detail; j++) {
        float lon1 = map(j, 0, detail, 0, TWO_PI);
        float lon2 = map(j + 1, 0, detail, 0, TWO_PI);
  
        PVector p1 = sphereToCartesian(headRadius, lon1, lat1);
        PVector p2 = sphereToCartesian(headRadius, lon2, lat1);
        PVector p3 = sphereToCartesian(headRadius, lon2, lat2);
        PVector p4 = sphereToCartesian(headRadius, lon1, lat2);
  
        deformToSkull(p1, headRadius);
        deformToSkull(p2, headRadius);
        deformToSkull(p3, headRadius);
        deformToSkull(p4, headRadius);
  
        setNoiseFill(p1.x, p1.y, p1.z, time);
        vertex(p1.x, p1.y, p1.z);
        setNoiseFill(p2.x, p2.y, p2.z, time);
        vertex(p2.x, p2.y, p2.z);
        setNoiseFill(p3.x, p3.y, p3.z, time);
        vertex(p3.x, p3.y, p3.z);
        setNoiseFill(p4.x, p4.y, p4.z, time);
        vertex(p4.x, p4.y, p4.z);
      }
    }
    endShape();
  
    // Yeux
    drawEyes();
  
    popMatrix();
  }
  
  void drawEyes() {
    pushStyle();
    fill(255, 20, 15);  // Couleur plus foncée pour les orbites
  
    float eyeSize = headRadius * 0.25;
    float eyeDepth = headRadius * 0.3;
    float eyeSpacing = headRadius * 0.3;
    float eyeHeight = -headRadius * 0.1;
  
    // Œil gauche
    pushMatrix();
    translate(eyeSpacing, eyeHeight, headRadius * 0.8);
    rotateY(radians(-40));
    drawEyeSocket(eyeSize, eyeDepth);
    popMatrix();
  
    // Œil droit
    pushMatrix();
    translate(-eyeSpacing, eyeHeight, headRadius * 0.8);
    rotateY(radians(40));
    drawEyeSocket(eyeSize, eyeDepth);
    popMatrix();
  
    popStyle();
  }
  
  // --- FONCTIONS DE DESSIN DES BRAS ---
  
  void drawArms() {
    drawArm(true);  // Bras droit
    drawArm(false); // Bras gauche
  }
  
  void drawArm(boolean isRightArm) {
    float side = isRightArm ? 1.0 : -1.0;
    float armWidth = bodyWidth * 0.3;
    float armLength = bodyHeight * 0.5;
  
    pushMatrix();
  
    // Position de l'épaule
    translate(side * (bodyWidth/2 * 0.85), -bodyHeight/3.5, bodyDepth/4 * 0.6);
  
    // Rotation de l'épaule
    rotateX(PI/2);
    rotateY(side * PI/2);
    rotateZ(side * PI/10);
  
    // Partie supérieure du bras
    pushMatrix();
    translate(0, armLength * 0.2, 0);
    drawLimb(armWidth * 0.9, armLength * 0.45, 1.0, isRightArm);
    popMatrix();
  
    // Coude et avant-bras
    translate(0, armLength * 0.42, 0);
    rotateY(-PI);
  
    pushMatrix();
    translate(0, armLength * 0.25, 0);
    drawLimb(armWidth * 0.85, armLength * 0.5, 0.8, isRightArm);
    popMatrix();
  
    // Main
    translate(0, armLength * 0.47, 0);
    rotateX(PI/6);
    drawHand(armWidth * 0.75, isRightArm);
  
    popMatrix();
  }
  
  void drawLimb(float width, float length, float taperFactor, boolean isRightArm) {
    int detailU = 12; // Horizontal
    int detailV = 8;  // Vertical
    float time = frameCount * noiseTimeFactor;
  
    for (int i = 0; i < detailV; i++) {
      float v1 = map(i, 0, detailV, -1, 1);
      float v2 = map(i+1, 0, detailV, -1, 1);
  
      float scale1 = 1.0 - (1.0 - taperFactor) * abs(v1);
      float scale2 = 1.0 - (1.0 - taperFactor) * abs(v2);
  
      float radius1 = (width/2) * scale1;
      float radius2 = (width/2) * scale2;
  
      float y1 = v1 * (length/2);
      float y2 = v2 * (length/2);
  
      beginShape(QUADS);
  
      for (int j = 0; j < detailU; j++) {
        float u1 = map(j, 0, detailU, 0, TWO_PI);
        float u2 = map(j+1, 0, detailU, 0, TWO_PI);
  
        // Variations organiques
        float noise1 = noise(cos(u1) * 0.5, sin(u1) * 0.5, v1 + time * 0.1);
        float noise2 = noise(cos(u2) * 0.5, sin(u2) * 0.5, v1 + time * 0.1);
        float noise3 = noise(cos(u2) * 0.5, sin(u2) * 0.5, v2 + time * 0.1);
        float noise4 = noise(cos(u1) * 0.5, sin(u1) * 0.5, v2 + time * 0.1);
  
        float bulge = 0.15;
        float bulgeFreq = 6.0;
  
        float muscleFactor1 = sin(v1 * bulgeFreq) * bulge * noise1;
        float muscleFactor2 = sin(v1 * bulgeFreq) * bulge * noise2;
        float muscleFactor3 = sin(v2 * bulgeFreq) * bulge * noise3;
        float muscleFactor4 = sin(v2 * bulgeFreq) * bulge * noise4;
  
        float r1 = radius1 * (1.0 + muscleFactor1);
        float r2 = radius1 * (1.0 + muscleFactor2);
        float r3 = radius2 * (1.0 + muscleFactor3);
        float r4 = radius2 * (1.0 + muscleFactor4);
  
        float flattenFactor = 0.8;
  
        float x1 = r1 * cos(u1);
        float z1 = r1 * sin(u1) * flattenFactor;
  
        float x2 = r2 * cos(u2);
        float z2 = r2 * sin(u2) * flattenFactor;
  
        float x3 = r3 * cos(u2);
        float z3 = r3 * sin(u2) * flattenFactor;
  
        float x4 = r4 * cos(u1);
        float z4 = r4 * sin(u1) * flattenFactor;
  
        // Courbure naturelle
        float curveFactor = 0.1 * (isRightArm ? -1.0 : 1.0);
        float curveOffset1 = sin(map(v1, -1, 1, 0, PI)) * curveFactor * width;
        float curveOffset2 = sin(map(v2, -1, 1, 0, PI)) * curveFactor * width;
  
        setNoiseFill(x1 + curveOffset1, y1, z1, time);
        vertex(x1 + curveOffset1, y1, z1);
        setNoiseFill(x2 + curveOffset1, y1, z2, time);
        vertex(x2 + curveOffset1, y1, z2);
        setNoiseFill(x3 + curveOffset2, y2, z3, time);
        vertex(x3 + curveOffset2, y2, z3);
        setNoiseFill(x4 + curveOffset2, y2, z4, time);
        vertex(x4 + curveOffset2, y2, z4);
      }
  
      endShape();
    }
  }
  
  void drawHand(float width, boolean isRightArm) {
    float side = isRightArm ? 1.0 : -1.0;
    float palmLength = width * 0.7;
    float fingerLength = width * 0.8;
    float fingerWidth = width * 0.15;
  
    // Paume
    pushMatrix();
    translate(0, palmLength/2, 0);
    drawLimb(width, palmLength, 0.9, isRightArm);
    popMatrix();
  
    // Doigts
    translate(0, palmLength, 0);
  
    // Créer 4 doigts (pouce + 3 doigts)
    for (int i = 0; i < 4; i++) {
      pushMatrix();
  
      float offsetX = map(i, 0, 3, side * -width/2.5, side * width/2.5);
  
      if (i == 0) { // Pouce
        offsetX = side * width/2.5;
        translate(offsetX, -palmLength * 0.3, width * 0.1);
        rotateZ(side * PI/4);
        rotateX(PI/8);
  
        // Pouce plus court et plus large
        drawLimb(fingerWidth * 1.2, fingerLength * 0.7, 0.6, false);
      } else {
        translate(offsetX, 0, 0);
        rotateX(map(i, 1, 3, PI/30, PI/15));
  
        // Doigt du milieu légèrement plus long
        float currFingerLength = fingerLength * (i == 2 ? 1.1 : 1.0);
        drawLimb(fingerWidth, currFingerLength, 0.6, false);
      }
  
      popMatrix();
    }
  }


  void display() {
    // Conversion des coordonnées de grille vers les coordonnées monde
    translate(posX * wallH, posY * wallH, -30); 

    // Dessiner la momie
    noStroke();
    rotateX(-PI/2);
    rotateY(heading + PI/2);
    scale(0.20);
    drawBody();
    drawHead();
    drawArms();
    // Dessiner la bandelette spirale
    drawSpiralStrip();
  }
}
