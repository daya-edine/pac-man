// pacman.pde

Board board;
Hero pacman;
Bonus currentBonus;
// Ajout de la liste des fantômes
ArrayList<Ghost> ghosts; 

void setup() {
  size(600, 600);
  board = new Board(new PVector(0, 0), 1, 25);
  pacman = new Hero(board);
  currentBonus = new Bonus();
  
  // Initialisation des fantômes
  ghosts = new ArrayList<Ghost>();
  
  // --- POSITIONNEMENT DES FANTÔMES ---
  // On calcule la colonne du milieu (largeur / 2)
  int midX = board._nbCellsX / 2; 
  // On fixe la ligne à 11 comme demandé
  int startY = 11; 
  
  PVector startPos = new PVector(midX, startY);
  
  // Création des 4 fantômes à cette position
  ghosts.add(new Ghost(GhostType.RED, startPos, board));
  ghosts.add(new Ghost(GhostType.PINK, startPos, board));
  ghosts.add(new Ghost(GhostType.BLUE, startPos, board));
  ghosts.add(new Ghost(GhostType.ORANGE, startPos, board));
}

void draw() {
  background(0);
  
  // 1. Logique
  currentBonus.update(board);
  pacman.update(board, currentBonus);
  
  // Mise à jour des fantômes
  for (Ghost g : ghosts) {
    g.update(board, pacman);
    
    // Test collision basique
    if (dist(pacman._position.x, pacman._position.y, g._position.x, g._position.y) < 20) {
      println("PERDU ! Touché par un fantôme.");
      // Ici vous pourrez gérer la perte de vie plus tard
      noLoop(); // Stoppe le jeu pour tester
    }
  }
  
  // 2. Affichage
  board.drawIt();
  pacman.drawIt();
  
  // Affichage des fantômes
  for (Ghost g : ghosts) {
    g.drawIt();
  }
}

void keyPressed() {
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
