enum TypeCell {
  EMPTY, WALL, DOT, SUPER_DOT
}

class Board {
  TypeCell _cells[][];
  PVector _position;
  int _nbCellsX;
  int _nbCellsY;
  int _cellSize;
  
  // Pour mémoriser où Pac-Man doit commencer (sera récupéré par la classe Game/Hero plus tard)
  PVector _pacmanStart; 

  // --- MODIFICATION ICI : on demande le numéro du niveau, pas le fichier ---
  Board(PVector position, int levelNum, int cellSize) {
    _position = position;
    _cellSize = cellSize;
    
    // Construction automatique du chemin du fichier
    // Exemple : si levelNum = 1, ça cherche "levels/level1.txt"
    String filename = "levels/level" + levelNum + ".txt";
    
    // 1. Chargement du fichier
    String[] lines = loadStrings(filename);
    
    // Sécurité : si le fichier n'existe pas ou est vide
    if (lines == null || lines.length < 2) {
      println("ERREUR CRITIQUE : Le fichier " + filename + " est introuvable ou vide !");
      // On initialise un tableau vide pour éviter que le jeu plante totalement
      _cells = new TypeCell[1][1];
      _cells[0][0] = TypeCell.EMPTY;
      return; 
    }

    // 2. Calcul des dimensions
    // On ignore la première ligne (le titre)
    _nbCellsY = lines.length - 1; 
    _nbCellsX = lines[1].length();

    // 3. Initialisation du tableau
    _cells = new TypeCell[_nbCellsX][_nbCellsY];
    
    // 4. Remplissage case par case (Parsing)
    for (int y = 0; y < _nbCellsY; y++) {
      // On lit à partir de la ligne 1 (la ligne 0 est le titre)
      String currentLine = lines[y + 1]; 
      
      for (int x = 0; x < _nbCellsX; x++) {
        // Sécurité : si une ligne est plus courte que prévu
        char c = 'V'; 
        if (x < currentLine.length()) {
          c = currentLine.charAt(x);
        }
        
        // Analyse du caractère selon le fichier level1.txt fourni
        switch (c) {
          case 'x':
            _cells[x][y] = TypeCell.WALL;
            break;
          case 'o': 
            _cells[x][y] = TypeCell.DOT;
            break;
          case 'O': 
            _cells[x][y] = TypeCell.SUPER_DOT;
            break;
          case 'P':
            // C'est un vide, mais on note la position de départ pour PacMan
            _cells[x][y] = TypeCell.EMPTY;
            _pacmanStart = new PVector(x, y); 
            break;
          case 'V':
          default:
            _cells[x][y] = TypeCell.EMPTY;
            break;
        }
      }
    }
  }

  // Convertit les indices grille (i, j) en pixels (x, y) au centre de la case
  PVector getCellCenter(int i, int j) {
    float pixelX = _position.x + (i * _cellSize) + (_cellSize / 2.0);
    float pixelY = _position.y + (j * _cellSize) + (_cellSize / 2.0);
    return new PVector(pixelX, pixelY);
  }
  
  void drawIt() {
    // Si le tableau est mal initialisé (erreur de fichier), on ne dessine rien
    if (_cells == null) return;

    for (int x = 0; x < _nbCellsX; x++) {
      for (int y = 0; y < _nbCellsY; y++) {
        PVector center = getCellCenter(x, y);
        
        switch (_cells[x][y]) {
          case WALL:
            fill(33, 33, 222); // Bleu style arcade
            noStroke();
            rectMode(CENTER);
            rect(center.x, center.y, _cellSize, _cellSize);
            break;
            
          case DOT:
            fill(255, 183, 174); 
            noStroke();
            ellipse(center.x, center.y, _cellSize * 0.25, _cellSize * 0.25);
            break;
            
          case SUPER_DOT:
            fill(255, 183, 174);
            noStroke();
            // Effet simple de clignotement pour la super gomme (bonus visuel)
            if (frameCount % 30 < 15) { 
               ellipse(center.x, center.y, _cellSize * 0.6, _cellSize * 0.6);
            } else {
               ellipse(center.x, center.y, _cellSize * 0.4, _cellSize * 0.4);
            }
            break;
        }
      }
    }
  }
}
