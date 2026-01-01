// pacman.pde
Game game;

void setup() {
  size(600, 600);
  game = new Game();
}

void draw() {
  game.update();
  game.display();
}

void keyPressed() {
  game.handleKeyPressed();
}

void mousePressed() {
  game.handleMousePressed();
}
