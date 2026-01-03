// effects.pde

class ScorePopup {
  PVector _position;
  String _text;
  int _timer;      // Durée de vie du texte
  int _color;
  
  ScorePopup(float x, float y, int points, int c) {
    _position = new PVector(x, y);
    _text = "+" + points;
    _color = c;
    _timer = 60; // Le texte reste affiché pendant 60 frames (environ 1 seconde)
  }
  
  void update() {
    _timer--;
    _position.y -= 1; // Le texte monte doucement vers le haut
  }
  
  void drawIt() {
    // Calcul de la transparence (alpha) pour faire un fondu à la fin
    // map(valeur, min1, max1, min2, max2) permet de convertir la durée de vie en opacité
    float alpha = map(_timer, 0, 60, 0, 255);
    
    fill(_color, alpha); // Couleur avec transparence
    textAlign(CENTER, CENTER);
    textSize(18); // Taille du texte
    text(_text, _position.x, _position.y);
  }
  
  // Indique si le texte doit être supprimé (timer fini)
  boolean isDead() {
    return _timer <= 0;
  }
}

// --- AJOUT DANS effects.pde ---

class InfoMessage {
  String _text;
  int _timer;
  int _color;
  
  InfoMessage(String text, int c) {
    _text = text;
    _color = c;
    _timer = 120; // Reste affiché 2 secondes (120 frames)
  }
  
  void update() {
    _timer--;
  }
  
  void drawIt() {
    // Effet de clignotement ou de fondu
    float alpha = 255;
    if (_timer < 30) alpha = map(_timer, 0, 30, 0, 255);
    
    fill(_color, alpha);
    textAlign(CENTER, CENTER);
    textSize(40); // Gros texte
    text(_text, width/2, height/2); // Pile au milieu
  }
  
  boolean isDead() {
    return _timer <= 0;
  }
}
