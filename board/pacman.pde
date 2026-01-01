Board board;
Hero pacman;
Bonus currentBonus;
ArrayList<Ghost> ghosts; 
int score = 0;
// --- A AJOUTER ---
int lives = 3; 
// -----------------

ArrayList<ScorePopup> popups; 
// 1. AJOUT : Liste pour les messages au centre
ArrayList<InfoMessage> messages; 

// Pour détecter le changement d'état du bonus
boolean bonusWasActive = false;

int superModeTimer = 0;      
int ghostComboCount = 0;      
final int SUPER_MODE_DURATION = 600;

// --- AJOUTER CECI AU DEBUT DU FICHIER ---
enum GameState { MENU, GAME }
GameState currentState = GameState.MENU; // On commence sur le menu

// Variables pour le menu
String playerName = "";     
boolean isGuest = false;    
PFont pixelFont;

void setup() {
  size(600, 600);
  
  // --- AJOUTER CECI ---
  pixelFont = createFont("Monospaced", 32); // Police style rétro
  textFont(pixelFont);
  // --------------------
  board = new Board(new PVector(0, 0), 1, 25);
  pacman = new Hero(board);
  currentBonus = new Bonus();
  lives = 3;
  
  popups = new ArrayList<ScorePopup>(); 
  // Initialisation de la liste des messages
  messages = new ArrayList<InfoMessage>();
  
  ghosts = new ArrayList<Ghost>();
  int midX = board._nbCellsX / 2;
  int startY = 11; 
  PVector startPos = new PVector(midX, startY);
  
  ghosts.add(new Ghost(GhostType.RED, startPos, board));
  ghosts.add(new Ghost(GhostType.PINK, startPos, board));
  ghosts.add(new Ghost(GhostType.BLUE, startPos, board));
  ghosts.add(new Ghost(GhostType.ORANGE, startPos, board));
}

void draw() {
  // --- AJOUTER AU DÉBUT DE DRAW ---
  if (currentState == GameState.MENU) {
    drawMenu();
    return; // On arrête ici pour ne pas dessiner le jeu par dessous
  }
  background(0);
  
  // Gestion Super Mode
  if (superModeTimer > 0) {
    superModeTimer--;
    if (superModeTimer == 0) {
      for (Ghost g : ghosts) g.setFrightened(false);
      ghostComboCount = 0;
    }
  }

  // --- 2. DETECTION BONUS APPARU ---
  currentBonus.update(board);
  
  // Si le bonus est actif maintenant MAIS ne l'était pas avant -> Il vient d'apparaître !
  if (currentBonus._isActive && !bonusWasActive) {
     messages.add(new InfoMessage("FRUIT APPARU !", color(255, 200, 0)));
  }
  // On met à jour l'état pour la prochaine frame
  bonusWasActive = currentBonus._isActive;

  // Récupération des points
  int pointsGagnes = pacman.update(board, currentBonus);
  score += pointsGagnes;
  
  // Popups de score
  if (pointsGagnes == 50) {
     activateSuperMode();
     popups.add(new ScorePopup(pacman._position.x, pacman._position.y, 50, color(255, 183, 174)));
  }
  else if (pointsGagnes == 500) {
     popups.add(new ScorePopup(pacman._position.x, pacman._position.y, 500, color(255, 0, 0)));
     // On ajoute aussi un message au centre pour féliciter
     messages.add(new InfoMessage("DELICIEUX !", color(255, 0, 0)));
  }
  
  // Fantômes
  for (Ghost g : ghosts) {
    g.update(board, pacman, ghosts);
    
    if (dist(pacman._position.x, pacman._position.y, g._position.x, g._position.y) < 20) {
      if (g._isFrightened) {
        eatGhost(g);
      } else {
        // --- A REMPLACER PAR CECI ---
        handlePlayerDeath(); 
        return; // On arrête cette frame ici pour éviter des bugs d'affichage
        // ----------------------------
      }
    }
  }
  
  // Gestion des Popups (texte flottant)
  for (int i = popups.size() - 1; i >= 0; i--) {
    ScorePopup p = popups.get(i);
    p.update();
    if (p.isDead()) popups.remove(i);
  }
  
  // Gestion des Messages Centraux (Fruit apparu...)
  for (int i = messages.size() - 1; i >= 0; i--) {
    InfoMessage m = messages.get(i);
    m.update();
    if (m.isDead()) messages.remove(i);
  }
  
  // Dessin global
  drawGame();
}

// Fonction utilitaire pour tout dessiner (pour éviter de dupliquer le code)
void drawGame() {
  board.drawIt();
  pacman.drawIt();
  for (Ghost g : ghosts) g.drawIt();
  
  // Popups Score
  for (ScorePopup p : popups) p.drawIt();
  
  // Messages Centraux
  for (InfoMessage m : messages) m.drawIt();
  
  // Interface Score (Header)
  fill(0, 0, 0, 150);
  noStroke();
  rect(0, 0, width, 40); 
  
  fill(255); 
  textSize(20);
  textAlign(LEFT, CENTER);
  text("SCORE: " + score, 20, 20);
  
  textAlign(RIGHT, CENTER);
  text("HIGH SCORE: 10000", width - 20, 20);
  
  // --- A AJOUTER A LA FIN DE DRAWGAME ---
  // Dessin des vies (Cœurs) en bas à gauche
  for (int i = 0; i < lives; i++) {
    drawHeart(30 + (i * 35), height - 30, 25); 
  }
  // --------------------------------------
}

void activateSuperMode() {
  superModeTimer = SUPER_MODE_DURATION;
  ghostComboCount = 0; 
  for (Ghost g : ghosts) {
    g.setFrightened(true);
  }
}

void eatGhost(Ghost g) {
  int ghostScore = 200 * (int)pow(2, ghostComboCount);
  score += ghostScore;
  popups.add(new ScorePopup(g._position.x, g._position.y, ghostScore, color(0, 255, 255)));
  ghostComboCount++; 
  g.reset(); 
}

void keyPressed() {
  
  // --- AJOUTER CECI AU DÉBUT DE KEYPRESSED ---
  if (currentState == GameState.MENU) {
    // Si on n'est pas en mode invité, on tape le nom
    if (!isGuest) {
      if (key == BACKSPACE) {
        if (playerName.length() > 0) playerName = playerName.substring(0, playerName.length() - 1);
      } else if (key != CODED && key != ENTER && key != TAB && playerName.length() < 12) {
        playerName += key;
      }
    }
    // Entrée pour lancer
    if (key == ENTER && (playerName.length() > 0 || isGuest)) {
       currentState = GameState.GAME;
    }
    return; // On arrête ici pour ne pas bouger pacman pendant qu'on tape
  }
  // (Inchangé)
  if (key == CODED) {
    if (keyCode == UP)    pacman.setDirection(new PVector(0, -1));
    if (keyCode == DOWN)  pacman.setDirection(new PVector(0, 1));
    if (keyCode == LEFT)  pacman.setDirection(new PVector(-1, 0));
    if (keyCode == RIGHT) pacman.setDirection(new PVector(1, 0));
  } 
  else {
    if (key == 'z' || key == 'Z') pacman.setDirection(new PVector(0, -1));
    if (key == 's' || key == 'S') pacman.setDirection(new PVector(0, 1));
    if (key == 'q' || key == 'Q') pacman.setDirection(new PVector(-1, 0));
    if (key == 'd' || key == 'D') pacman.setDirection(new PVector(1, 0));
  }
}

// --- AJOUTER TOUT CECI À LA FIN DU FICHIER ---

void mousePressed() {
  if (currentState == GameState.MENU) {
    // Clic sur la case "Guest"
    if (mouseX > width/2 - 150 && mouseX < width/2 + 150 && mouseY > 380 && mouseY < 420) {
      isGuest = !isGuest;
    }
    // Clic sur le bouton "COMMENCER"
    if (mouseX > width/2 - 100 && mouseX < width/2 + 100 && mouseY > 480 && mouseY < 540) {
      if (playerName.length() > 0 || isGuest) {
        currentState = GameState.GAME;
      }
    }
  }
}

void drawMenu() {
  background(20); 
  
  // Titre PAC-MAN
  fill(255, 255, 0); 
  textAlign(CENTER, CENTER);
  textSize(80);
  text("PAC-MAN", width/2, 150);
  fill(255, 100); // Ombre
  text("PAC-MAN", width/2 + 4, 150 + 4);
  
  // Champ de saisie
  textSize(24);
  fill(255);
  text("ENTREZ VOTRE NOM :", width/2, 280);
  
  stroke(255, 255, 0); strokeWeight(2); noFill();
  rectMode(CENTER);
  rect(width/2, 330, 300, 50);
  
  fill(isGuest ? 100 : 255);
  text(playerName + (frameCount % 60 < 30 && !isGuest ? "_" : ""), width/2, 325);
  
  // Case Guest
  textSize(20);
  fill(isGuest ? 0 : 150, isGuest ? 255 : 150, isGuest ? 0 : 150);
  text("[ " + (isGuest ? "X" : " ") + " ] JOUER EN TANT QUE GUEST", width/2, 400);
  
  // Bouton Commencer
  boolean overStart = (mouseX > width/2 - 100 && mouseX < width/2 + 100 && mouseY > 480 && mouseY < 540);
  fill(overStart ? 255 : 0, overStart ? 255 : 0, overStart ? 0 : 200);
  noStroke();
  rect(width/2, 510, 200, 60, 10);
  
  fill(overStart ? 0 : 255);
  textSize(30);
  text("COMMENCER", width/2, 505);
  
  // Reset alignement pour le jeu
  textAlign(LEFT, TOP); 
}

// --- A AJOUTER A LA FIN DU FICHIER PACMAN.PDE ---

void handlePlayerDeath() {
  lives--; // On enlève une vie
  
  if (lives > 0) {
    // CAS 1 : Il reste des vies
    // On peut ajouter un petit message
    if (messages != null) messages.add(new InfoMessage("OUCH !", color(255, 0, 0)));
    
    // On remet tout le monde à sa place
    pacman.reset();
    for (Ghost g : ghosts) {
      g.reset(); // Cette fonction existe déjà dans votre ghoasts.pde 
    }
    
  } else {
    // CAS 2 : Plus de vies -> GAME OVER
    drawGame(); // Dessin final
    
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(50);
    text("GAME OVER", width/2, height/2);
    textSize(20);
    text("Score final: " + score, width/2, height/2 + 50);
    
    noLoop(); // Stop total du jeu
  }
}

void drawHeart(float x, float y, float size) {
  fill(255, 0, 0); // Rouge
  noStroke();
  // Forme simple de cœur avec deux cercles et un triangle
  ellipse(x - size/4, y - size/4, size/2, size/2);
  ellipse(x + size/4, y - size/4, size/2, size/2);
  triangle(x - size/2, y - size/6, x + size/2, y - size/6, x, y + size/2);
}
