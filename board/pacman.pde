Board board;
Hero pacman;
Bonus currentBonus;

void setup() {
  size(600, 600);
  board = new Board(new PVector(0, 0), 1, 25); 
  pacman = new Hero(board);
  currentBonus = new Bonus();
}

void draw() {
  background(0);
  
  // 1. Logique
  currentBonus.update(board);
  pacman.update(board, currentBonus); // Pac-Man peut manger le bonus
  
  // 2. Affichage
  board.drawIt(); // Le board dessine les murs, gommes ET le bonus (si TypeCell.BONUS)
  // currentBonus.drawIt(board); // Plus nécessaire si le board gère le dessin
  pacman.drawIt();
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
