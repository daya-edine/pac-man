class Hero {
  PVector _position;      
  PVector _direction;     
  float _speed;           
  float _size;            
  float _rotation; 
  
  Hero(Board board) {
    if (board._pacmanStart != null) {
      _position = board.getCellCenter((int)board._pacmanStart.x, (int)board._pacmanStart.y);
    } else {
      _position = new PVector(100, 100); 
    }
    
    _direction = new PVector(0, 0); 
    _speed = 2; 
    _size = board._cellSize * 0.6; 
    _rotation = 0; 
  }

  void setDirection(PVector newDir) {
    _direction = newDir;
    // Mise à jour de l'angle de rotation
    if (newDir.x == 1)  _rotation = 0;          
    if (newDir.y == 1)  _rotation = HALF_PI;    
    if (newDir.x == -1) _rotation = PI;         
    if (newDir.y == -1) _rotation = -HALF_PI;   
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
      if (col < 0 || col >= board._nbCellsX || row < 0 || row >= board._nbCellsY) return false;
      if (board._cells[col][row] == TypeCell.WALL) return false;
    }
    return true;
  }

  // --- MANGER (Gommes et Bonus) ---
  void eat(Board board, Bonus bonus) {
    int col = int(_position.x / board._cellSize);
    int row = int(_position.y / board._cellSize);
    
    if (col >= 0 && col < board._nbCellsX && row >= 0 && row < board._nbCellsY) {
      TypeCell cellType = board._cells[col][row];
      
      // 1. Gommes : On vide la case
      if (cellType == TypeCell.DOT || cellType == TypeCell.SUPER_DOT) {
        board._cells[col][row] = TypeCell.EMPTY; 
        // (Score += 10 ici plus tard)
      }
      
      // 2. Bonus : On vide la case ET on prévient le bonus
      else if (cellType == TypeCell.BONUS) {
        board._cells[col][row] = TypeCell.EMPTY; // Le fruit disparaît visuellement
        if (bonus != null) {
          bonus.eat(); // On reset le timer
        }
      }
    }
  }

  void update(Board board, Bonus bonus) {
    PVector velocity = PVector.mult(_direction, _speed);
    PVector futurePos = PVector.add(_position, velocity);
    
    if (canMoveTo(futurePos, board)) {
      _position = futurePos;
      eat(board, bonus);
    }
  }

  // --- DESSIN : Animation modifiée ---
  void drawIt() {
    fill(255, 255, 0); 
    noStroke();
    
    // Par défaut, la bouche est OUVERTE (quand il est à l'arrêt/vide)
    float mouthAngle = QUARTER_PI; 
    
    // Si Pac-Man BOUGE, alors on anime la bouche (Waka Waka)
    if (_direction.x != 0 || _direction.y != 0) {
       mouthAngle = map(sin(frameCount * 0.3), -1, 1, 0, QUARTER_PI);
    }

    pushMatrix(); 
    translate(_position.x, _position.y); 
    rotate(_rotation); 
    // Dessin de Pac-Man avec l'angle calculé
    arc(0, 0, _size, _size, mouthAngle, TWO_PI - mouthAngle);
    popMatrix(); 
  }
}
