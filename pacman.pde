// pacman.pde

Board board;

void setup() {
  size(600, 600); // Taille de la fenêtre
  
  // Création du plateau : 
  // Position (0,0), Niveau 1, Taille des cases 20px
  board = new Board(new PVector(0, 0), 2, 25); 
}

void draw() {
  background(0); // Fond noir
  board.drawIt(); // Dessine le plateau
}
