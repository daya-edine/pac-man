// game.pde
 enum GameState { MENU, GAME }
class Game {
  Board board;
  Hero pacman;
  Bonus currentBonus;
  ArrayList<Ghost> ghosts; 
  int score = 0;
  int lives = 3;
  ArrayList<ScorePopup> popups; 
  ArrayList<InfoMessage> messages;
  boolean bonusWasActive = false;
  int superModeTimer = 0;      
  int ghostComboCount = 0;
  final int SUPER_MODE_DURATION = 600;

 
  GameState currentState = GameState.MENU;

  String playerName = "";     
  boolean isGuest = false;    
  PFont pixelFont;

  Game() {
    pixelFont = createFont("Monospaced", 32);
    textFont(pixelFont);
    
    board = new Board(new PVector(0, 0), 1, 25);
    pacman = new Hero(board);
    currentBonus = new Bonus();
    lives = 3;
    
    popups = new ArrayList<ScorePopup>();
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

  void update() {
    if (currentState == GameState.MENU) return;

    // Gestion Super Mode
    if (superModeTimer > 0) {
      superModeTimer--;
      if (superModeTimer == 0) {
        for (Ghost g : ghosts) g.setFrightened(false);
        ghostComboCount = 0;
      }
    }

    // Detection Bonus
    currentBonus.update(board);
    if (currentBonus._isActive && !bonusWasActive) {
       messages.add(new InfoMessage("FRUIT APPARU !", color(255, 200, 0)));
    }
    bonusWasActive = currentBonus._isActive;

    // Mise à jour Pacman
    int pointsGagnes = pacman.update(board, currentBonus);
    score += pointsGagnes;

    if (pointsGagnes == 50) {
       activateSuperMode();
       popups.add(new ScorePopup(pacman._position.x, pacman._position.y, 50, color(255, 183, 174)));
    } else if (pointsGagnes == 500) {
       popups.add(new ScorePopup(pacman._position.x, pacman._position.y, 500, color(255, 0, 0)));
       messages.add(new InfoMessage("DELICIEUX !", color(255, 0, 0)));
    }
    
    // Fantômes
    for (Ghost g : ghosts) {
      g.update(board, pacman, ghosts);
      if (dist(pacman._position.x, pacman._position.y, g._position.x, g._position.y) < 20) {
        if (g._isFrightened) {
          eatGhost(g);
        } else {
          handlePlayerDeath();
        }
      }
    }
    
    // Popups
    for (int i = popups.size() - 1; i >= 0; i--) {
      ScorePopup p = popups.get(i);
      p.update();
      if (p.isDead()) popups.remove(i);
    }
    
    // Messages
    for (int i = messages.size() - 1; i >= 0; i--) {
      InfoMessage m = messages.get(i);
      m.update();
      if (m.isDead()) messages.remove(i);
    }
  }

  void display() {
    if (currentState == GameState.MENU) {
      drawMenu();
    } else {
      background(0);
      drawGame();
    }
  }

  void drawGame() {
    board.drawIt();
    pacman.drawIt();
    for (Ghost g : ghosts) g.drawIt();
    for (ScorePopup p : popups) p.drawIt();
    for (InfoMessage m : messages) m.drawIt();
    
    fill(0, 0, 0, 150);
    noStroke();
    rectMode(CORNER);
    rect(0, 0, width, 40); 
    
    fill(255); 
    textSize(20);
    textAlign(LEFT, CENTER);
    text("SCORE: " + score, 20, 20);
    textAlign(RIGHT, CENTER);
    text("HIGH SCORE: 10000", width - 20, 20);
    
    for (int i = 0; i < lives; i++) {
      drawHeart(30 + (i * 35), height - 30, 25);
    }
  }

  void activateSuperMode() {
    superModeTimer = SUPER_MODE_DURATION;
    ghostComboCount = 0;
    for (Ghost g : ghosts) g.setFrightened(true);
  }

  void eatGhost(Ghost g) {
    int ghostScore = 200 * (int)pow(2, ghostComboCount);
    score += ghostScore;
    popups.add(new ScorePopup(g._position.x, g._position.y, ghostScore, color(0, 255, 255)));
    ghostComboCount++; 
    g.reset(); 
  }

  void handlePlayerDeath() {
    lives--;
    if (lives > 0) {
      if (messages != null) messages.add(new InfoMessage("OUCH !", color(255, 0, 0)));
      pacman.reset();
      for (Ghost g : ghosts) g.reset();
    } else {
      drawGame();
      fill(255, 0, 0);
      textAlign(CENTER, CENTER);
      textSize(50);
      text("GAME OVER", width/2, height/2);
      textSize(20);
      text("Score final: " + score, width/2, height/2 + 50);
      noLoop();
    }
  }

  void drawMenu() {
    background(20); 
    fill(255, 255, 0); 
    textAlign(CENTER, CENTER);
    textSize(80);
    text("PAC-MAN", width/2, 150);
    fill(255, 100);
    text("PAC-MAN", width/2 + 4, 150 + 4);
    
    textSize(24);
    fill(255);
    text("ENTREZ VOTRE NOM :", width/2, 280);
    
    stroke(255, 255, 0); strokeWeight(2); noFill();
    rectMode(CENTER);
    rect(width/2, 330, 300, 50);
    
    fill(isGuest ? 100 : 255);
    text(playerName + (frameCount % 60 < 30 && !isGuest ? "_" : ""), width/2, 325);
    
    textSize(20);
    fill(isGuest ? 0 : 150, isGuest ? 255 : 150, isGuest ? 0 : 150);
    text("[ " + (isGuest ? "X" : " ") + " ] JOUER EN TANT QUE GUEST", width/2, 400);
    
    boolean overStart = (mouseX > width/2 - 100 && mouseX < width/2 + 100 && mouseY > 480 && mouseY < 540);
    fill(overStart ? 255 : 0, overStart ? 255 : 0, overStart ? 0 : 200);
    noStroke();
    rect(width/2, 510, 200, 60, 10);
    
    fill(overStart ? 0 : 255);
    textSize(30);
    text("COMMENCER", width/2, 505);
    textAlign(LEFT, TOP); 
  }

  void handleKeyPressed() {
    if (currentState == GameState.MENU) {
      if (!isGuest) {
        if (key == BACKSPACE) {
          if (playerName.length() > 0) playerName = playerName.substring(0, playerName.length() - 1);
        } else if (key != CODED && key != ENTER && key != TAB && playerName.length() < 12) {
          playerName += key;
        }
      }
      if (key == ENTER && (playerName.length() > 0 || isGuest)) currentState = GameState.GAME;
      return;
    }

    if (key == CODED) {
      if (keyCode == UP)    pacman.setDirection(new PVector(0, -1));
      if (keyCode == DOWN)  pacman.setDirection(new PVector(0, 1));
      if (keyCode == LEFT)  pacman.setDirection(new PVector(-1, 0));
      if (keyCode == RIGHT) pacman.setDirection(new PVector(1, 0));
    } else {
      if (key == 'z' || key == 'Z') pacman.setDirection(new PVector(0, -1));
      if (key == 's' || key == 'S') pacman.setDirection(new PVector(0, 1));
      if (key == 'q' || key == 'Q') pacman.setDirection(new PVector(-1, 0));
      if (key == 'd' || key == 'D') pacman.setDirection(new PVector(1, 0));
    }
  }

  void handleMousePressed() {
    if (currentState == GameState.MENU) {
      if (mouseX > width/2 - 150 && mouseX < width/2 + 150 && mouseY > 380 && mouseY < 420) isGuest = !isGuest;
      if (mouseX > width/2 - 100 && mouseX < width/2 + 100 && mouseY > 480 && mouseY < 540) {
        if (playerName.length() > 0 || isGuest) currentState = GameState.GAME;
      }
    }
  }

  void drawHeart(float x, float y, float size) {
    fill(255, 0, 0);
    noStroke();
    ellipse(x - size/4, y - size/4, size/2, size/2);
    ellipse(x + size/4, y - size/4, size/2, size/2);
    triangle(x - size/2, y - size/6, x + size/2, y - size/6, x, y + size/2);
  }
}
