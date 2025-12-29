// ghost.pde
enum GhostType { RED, PINK, BLUE, ORANGE }

class Ghost {
  PVector _position;
  PVector _direction;
  GhostType _type;
  int _color;
  float _speed;
  
  Ghost(GhostType type, PVector startGridPos, Board board) {
    _type = type;
    
    // On calcule la position en pixels (centre de la case)
    _position = board.getCellCenter((int)startGridPos.x, (int)startGridPos.y);
    
    _direction = new PVector(1, 0); // Commence vers la droite
    _speed = 1.0; // Vitesse, ajustez si nécessaire
    
    // Couleur selon le type
    switch(type) {
      case RED:    _color = color(255, 0, 0); break;
      case PINK:   _color = color(255, 184, 255); break;
      case BLUE:   _color = color(0, 255, 255); break;
      case ORANGE: _color = color(255, 184, 82); break;
    }
  }

  void update(Board board, Hero pacman) {
    // 1. Déplacement
    _position.add(PVector.mult(_direction, _speed));
    
    // 2. Gestion des intersections (IA)
    // On vérifie si le fantôme est au centre d'une case
    if (isAtCenter(board)) {
       chooseNextDirection(board, pacman);
    }
  }
  
  // Vérifie si le fantôme est bien centré sur une case
  boolean isAtCenter(Board board) {
     float centerX = (int(_position.x / board._cellSize) * board._cellSize) + board._cellSize/2.0;
     float centerY = (int(_position.y / board._cellSize) * board._cellSize) + board._cellSize/2.0;
     return dist(_position.x, _position.y, centerX, centerY) < _speed;
  }
  
  // Choix de la direction à la prochaine intersection
  void chooseNextDirection(Board board, Hero pacman) {
    PVector target = getTarget(pacman, board);
    
    int gridX = int(_position.x / board._cellSize);
    int gridY = int(_position.y / board._cellSize);
    
    // Directions : Haut, Bas, Gauche, Droite
    PVector[] dirs = { new PVector(0,-1), new PVector(0,1), new PVector(-1,0), new PVector(1,0) };
    
    PVector bestDir = _direction;
    float minDist = 999999;
    boolean found = false;
    
    for (PVector d : dirs) {
      // Interdit de faire demi-tour immédiat (sauf cul-de-sac)
      if (d.x == -_direction.x && d.y == -_direction.y) continue;
      
      int nextX = gridX + (int)d.x;
      int nextY = gridY + (int)d.y;
      
      // Si ce n'est pas un mur
      if (!board.isWall(nextX, nextY)) {
         float dToTarget = dist(nextX, nextY, target.x, target.y);
         if (dToTarget < minDist) {
            minDist = dToTarget;
            bestDir = d;
            found = true;
         }
      }
    }
    
    if (found) _direction = bestDir;
    else _direction.mult(-1); // Demi-tour si coincé
    
    // Recalage parfait au centre pour tourner proprement
    _position = board.getCellCenter(gridX, gridY);
  }
  
  // Cible selon la personnalité (Annexe A du PDF)
  PVector getTarget(Hero pacman, Board board) {
    PVector pacGrid = new PVector(int(pacman._position.x/board._cellSize), int(pacman._position.y/board._cellSize));
    
    if (_type == GhostType.RED) return pacGrid; // Vise Pacman
    if (_type == GhostType.PINK) {
       // Vise 4 cases devant (simplifié)
       PVector t = pacGrid.copy().add(PVector.mult(pacman._direction, 4));
       return t;
    }
    // Les autres (Bleu/Orange) visent aléatoirement pour l'instant
    return new PVector(random(board._nbCellsX), random(board._nbCellsY));
  }

  void drawIt() {
    fill(_color);
    noStroke();
    ellipse(_position.x, _position.y, 20, 20); // Corps
    rectMode(CENTER);
    rect(_position.x, _position.y + 5, 20, 10); // Bas du corps
  }
}
