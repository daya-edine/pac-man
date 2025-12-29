class Bonus {
  boolean _isActive;     
  int _lastSpawnTime;    
  final int SPAWN_INTERVAL = 30000; // 30 secondes
  
  Bonus() {
    _isActive = false;
    _lastSpawnTime = millis();
  }
  
  void update(Board board) {
    // Si le bonus n'est pas là, on attend le bon moment pour le faire apparaître
    if (!_isActive) {
      if (millis() - _lastSpawnTime > SPAWN_INTERVAL) {
        spawn(board);
      }
    }
  }
  
  void spawn(Board board) {
    PVector pos = board.getRandomNonWallPosition();
    if (pos != null) {
      // On modifie directement le tableau du Board
      board._cells[(int)pos.x][(int)pos.y] = TypeCell.BONUS;
      _isActive = true;
      println("Bonus apparu !");
    }
  }
  
  // Appelé par le Héros quand il mange le fruit
  void eat() {
    _isActive = false;        
    _lastSpawnTime = millis(); // On relance le compteur
    println("Bonus mangé ! Prochain dans 30s.");
  }
  
  // Plus besoin de drawIt ici car c'est board.drawIt() qui dessine la case BONUS !
  void drawIt(Board board) {
     // Laisser vide ou supprimer
  }
}
