class Hero {
  PVector _position;      
  PVector _direction;     
  PVector _nextDirection; // Direction tampon
  // --- A AJOUTER ICI ---
  PVector _startPosition; // Pour se souvenir d'où on vient
  // ---------------------
  
  float _speed;           
  float _size;            
  float _rotation;

  Hero(Board board) {
    if (board._pacmanStart != null) {
      _position = board.getCellCenter((int)board._pacmanStart.x, (int)board._pacmanStart.y);
    } else {
      _position = new PVector(100, 100);
    }
    // --- A AJOUTER JUSTE APRES ---
    _startPosition = _position.copy();
    // ---
    
    _direction = new PVector(0, 0); 
    _nextDirection = new PVector(0, 0);
    
    _speed = 3;
    _size = board._cellSize * 0.8; 
    _rotation = 0; 
  }

  void setDirection(PVector newDir) {
    _nextDirection = newDir;
    if (_direction.x == 0 && _direction.y == 0) {
      _direction = newDir;
    }
  }

  int update(Board board, Bonus bonus) {
    // 1. INPUT BUFFERING (Virage fluide)
    int gridX = int(_position.x / board._cellSize);
    int gridY = int(_position.y / board._cellSize);
    PVector cellCenter = board.getCellCenter(gridX, gridY);
    float distToCenter = dist(_position.x, _position.y, cellCenter.x, cellCenter.y);
    
    if (distToCenter < _speed) {
      PVector checkPos = PVector.add(cellCenter, PVector.mult(_nextDirection, board._cellSize));
      if (canMoveTo(checkPos, board)) {
        _position = cellCenter.copy(); 
        _direction = _nextDirection; 
      }
    }

    // 2. DEPLACEMENT
    PVector velocity = PVector.mult(_direction, _speed);
    PVector futurePos = PVector.add(_position, velocity);
    int points = 0;
    
    if (canMoveTo(futurePos, board)) {
      _position = futurePos;
      points = eat(board, bonus);
      
      // Gestion de la rotation
      if (_direction.x == 1)  _rotation = 0;
      if (_direction.y == 1)  _rotation = HALF_PI;    
      if (_direction.x == -1) _rotation = PI;
      if (_direction.y == -1) _rotation = -HALF_PI; 
      
    } else {
      // Recalage au centre si bloqué
      if (distToCenter < _speed * 2) {
         _position = cellCenter.copy();
      }
    }
    
    // --- 3. AJOUT : GESTION DU TUNNEL (TELEPORTATION) ---
    float boardWidthPixel = board._nbCellsX * board._cellSize;
    
    // Si on sort à GAUCHE (< 0), on va à DROITE
    if (_position.x < -_size/2) {
       _position.x = boardWidthPixel + _size/2;
    }
    // Si on sort à DROITE, on va à GAUCHE
    else if (_position.x > boardWidthPixel + _size/2) {
       _position.x = -_size/2;
    }
    
    return points;
  }

  boolean canMoveTo(PVector targetPos, Board board) {
    float r = _size / 2.0;
    PVector[] corners = {
      new PVector(targetPos.x - r, targetPos.y - r),
      new PVector(targetPos.x + r, targetPos.y - r),
      new PVector(targetPos.x - r, targetPos.y + r),
      new PVector(targetPos.x + r, targetPos.y + r)
    };
    
    for (PVector p : corners) {
      int col = int(p.x / board._cellSize);
      int row = int(p.y / board._cellSize);
      
      // --- MODIFICATION : On autorise le mouvement hors limites pour le tunnel ---
      // Si on est en dehors des colonnes (gauche/droite) mais dans une ligne valide, on autorise !
      if (col < 0 || col >= board._nbCellsX) {
         // On vérifie juste qu'on n'est pas aussi hors limites en Y
         if (row >= 0 && row < board._nbCellsY) {
            return true; // C'est le tunnel !
         }
      }
      
      // Vérifications normales
      if (row < 0 || row >= board._nbCellsY) return false;
      if (board._cells[col][row] == TypeCell.WALL) return false;
    }
    return true;
  }

  int eat(Board board, Bonus bonus) {
    // (Même code eat que précédemment...)
    int col = int(_position.x / board._cellSize);
    int row = int(_position.y / board._cellSize);
    int points = 0;
    if (col >= 0 && col < board._nbCellsX && row >= 0 && row < board._nbCellsY) {
      TypeCell cell = board._cells[col][row];
      if (cell == TypeCell.DOT) {
        board._cells[col][row] = TypeCell.EMPTY;
        points = 10;
      } else if (cell == TypeCell.SUPER_DOT) {
        board._cells[col][row] = TypeCell.EMPTY;
        points = 50;
      } else if (cell == TypeCell.BONUS) {
        board._cells[col][row] = TypeCell.EMPTY;
        if (bonus != null) bonus.eat();
        points = 500;
      }
    }
    return points;
  }
  
  void drawIt() {
    // (Même code drawIt que précédemment...)
    fill(255, 255, 0); 
    noStroke();
    float mouthAngle = QUARTER_PI;
    if (_direction.x != 0 || _direction.y != 0) {
       mouthAngle = map(sin(frameCount * 0.3), -1, 1, 0, QUARTER_PI);
    }
    pushMatrix(); 
    translate(_position.x, _position.y); 
    rotate(_rotation); 
    arc(0, 0, _size, _size, mouthAngle, TWO_PI - mouthAngle);
    popMatrix(); 
  }
  // --- A AJOUTER A LA FIN DE LA CLASSE ---
  void reset() {
    _position = _startPosition.copy(); // Retour case départ
    _direction = new PVector(0, 0);    // On s'arrête
    _nextDirection = new PVector(0, 0);
    _rotation = 0;
  }
}
