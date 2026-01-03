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
  if (key == ESC) {
    key = 0; // Empêche Processing de quitter le programme
    game.togglePause();
  } else {
  game.handleKeyPressed();
  }
}

void mousePressed() {
  game.handleMousePressed();
}
