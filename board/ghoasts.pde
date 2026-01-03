// ghost.pde
enum GhostType { RED, PINK, BLUE, ORANGE }

class Ghost {
  PVector _position;
  PVector _direction;
  GhostType _type;
  int _color;
  float _speed;
  
  // --- AJOUTS ---
  PVector _startPosition; // Pour se souvenir du point de départ
  boolean _isFrightened;  // Est-ce que le fantôme a peur ?
  
  Ghost(GhostType type, PVector startGridPos, Board board) {
    _type = type;
    _position = board.getCellCenter((int)startGridPos.x, (int)startGridPos.y);
    _direction = new PVector(1, 0); 
    _speed = 1.0; 
    
    // --- AJOUT ---
    // On sauvegarde la position initiale exacte en pixels
    _startPosition = _position.copy();
    _isFrightened = false;
    
    switch(type) {
      case RED:    _color = color(255, 0, 0); break;
      case PINK:   _color = color(255, 184, 255); break;
      case BLUE:   _color = color(0, 255, 255); break;
      case ORANGE: _color = color(255, 184, 82); break;
    }
  }

  // --- NOUVELLE METHODE : Active/Désactive la peur ---
  void setFrightened(boolean frightened) {
    _isFrightened = frightened;
    // Optionnel : ralentir les fantômes quand ils ont peur (ex: vitesse / 2)
    // _speed = frightened ? 0.5 : 1.0; 
  }

  // --- NOUVELLE METHODE : Retour à la maison (mangé) ---
  void reset() {
    _position = _startPosition.copy(); // Retour immédiat
    _isFrightened = false;             // Redevient normal immédiatement
    // On peut aussi changer sa direction pour qu'il reparte
    _direction = new PVector(1, 0); 
  }

  void update(Board board, Hero pacman, ArrayList<Ghost> allGhosts) {
    // 1. Calcul de la future position théorique
    PVector velocity = PVector.mult(_direction, _speed);
    PVector futurePos = PVector.add(_position, velocity);
    
    boolean blocked = false;
    
    // 2. Vérification des collisions avec les collègues
    for (Ghost other : allGhosts) {
       if (other == this) continue;
       
       float d = dist(futurePos.x, futurePos.y, other._position.x, other._position.y);
       
       // Si un fantôme est très proche (< 30px)
       if (d < 30) {
          
          // CRITIQUE : On vérifie si l'autre est DEVANT nous
          // On crée un vecteur qui va de "Moi" vers "L'autre"
          PVector toOther = PVector.sub(other._position, _position);
          
          // Le produit scalaire (dot) nous dit si c'est devant (>0) ou derrière (<0)
          float isFront = _direction.dot(toOther);
          
          // On vérifie aussi s'ils vont dans la MEME direction (pour éviter les blocages face à face)
          float isSameDir = _direction.dot(other._direction);
          
          // On se bloque SEULEMENT si :
          // 1. On n'est pas au point de départ (zone de spawn)
          // 2. L'autre est devant nous (isFront > 0)
          // 3. L'autre va dans le même sens (isSameDir > 0) -> file indienne
          if (dist(_position.x, _position.y, _startPosition.x, _startPosition.y) > 50 
              && isFront > 0 
              && isSameDir > 0) {
             blocked = true;
             break; 
          }
       }
    }
    
    // 3. Si on n'est pas bloqué par un collègue devant, on avance
    if (!blocked) {
       _position.add(velocity);
    }

    // 4. Gestion des intersections (inchangée)
    if (isAtCenter(board)) {
       chooseNextDirection(board, pacman);
    }
  }
  
  boolean isAtCenter(Board board) {
     float centerX = (int(_position.x / board._cellSize) * board._cellSize) + board._cellSize/2.0;
     float centerY = (int(_position.y / board._cellSize) * board._cellSize) + board._cellSize/2.0;
     return dist(_position.x, _position.y, centerX, centerY) < _speed;
  }
  
  void chooseNextDirection(Board board, Hero pacman) {
    // Si effrayé, le comportement change (fuite ou aléatoire). 
    // Pour l'instant on garde le random via getTarget, mais on pourrait inverser la cible.
    PVector target = getTarget(pacman, board);
    
    int gridX = int(_position.x / board._cellSize);
    int gridY = int(_position.y / board._cellSize);
    PVector[] dirs = { new PVector(0,-1), new PVector(0,1), new PVector(-1,0), new PVector(1,0) };
    PVector bestDir = _direction;
    float minDist = 999999;
    boolean found = false;
    
    for (PVector d : dirs) {
      if (d.x == -_direction.x && d.y == -_direction.y) continue;
      int nextX = gridX + (int)d.x;
      int nextY = gridY + (int)d.y;
      
      if (!board.isWall(nextX, nextY)) {
         float dToTarget = dist(nextX, nextY, target.x, target.y);
         
         // Si effrayé, on cherche à MAXIMISER la distance (fuite) au lieu de minimiser
         // Mais pour faire simple ici, on garde la logique actuelle ou on fait full random
         if (_isFrightened) {
             // Astuce simple : target devient un point random loin pour simuler la panique
             // Ou on inverse la logique : if (dToTarget > maxDist) ...
         }

         if (dToTarget < minDist) {
            minDist = dToTarget;
            bestDir = d;
            found = true;
         }
      }
    }
    
    if (found) _direction = bestDir;
    else _direction.mult(-1); 
    
    _position = board.getCellCenter(gridX, gridY);
  }
  
  PVector getTarget(Hero pacman, Board board) {
    // Si effrayé, la cible est purement aléatoire (panique)
    if (_isFrightened) {
       return new PVector(random(board._nbCellsX), random(board._nbCellsY));
    }

    PVector pacGrid = new PVector(int(pacman._position.x/board._cellSize), int(pacman._position.y/board._cellSize));
    if (_type == GhostType.RED) return pacGrid; 
    if (_type == GhostType.PINK) {
       PVector t = pacGrid.copy().add(PVector.mult(pacman._direction, 4));
       return t;
    }
    return new PVector(random(board._nbCellsX), random(board._nbCellsY));
  }

  void drawIt() {
    // --- MODIFICATION : Gestion de la couleur si effrayé ---
    if (_isFrightened) {
      // Clignotement : Bleu la plupart du temps, Blanc à la fin ou par intermittence
      if (frameCount % 30 < 20) {
        fill(0, 0, 255); // Bleu foncé (Vulnerable)
      } else {
        fill(255);       // Blanc (Clignote)
      }
    } else {
      fill(_color); // Couleur normale
    }
    
    noStroke();
    ellipse(_position.x, _position.y, 20, 20); 
    rectMode(CENTER);
    rect(_position.x, _position.y + 5, 20, 10); 
  }
}
