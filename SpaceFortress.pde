String mode = "MENU";
boolean isStart;
Game game;
Menu menu;
Retry retry;
TopScore topScore;

PImage[] numberImg;
PImage bgImg;

void setup() {
  size(500, 500);
  
  game = new Game();
  menu = new Menu();
  retry = new Retry(game);
  topScore = new TopScore();
  
  isStart = true;
  
  bgImg = loadImage("bg.png");
  numberImg = new PImage[11];
  PImage allnumber = loadImage("numbers.png");
  for (int i = 0; i < 11; i++) {
    numberImg[i] = allnumber.get(i*10, 0, 10, 10);
  }
}

void draw() {
  // update
  if (!isStart) {
    if (mode.equals("MENU")) menu.update();
    else if (mode.equals("GAME")) game.update();
    else if (mode.equals("RETRY")) retry.update();
  } else {
    if (mode.equals("MENU")) menu = new Menu();
    else if (mode.equals("GAME")) game = new Game();
    else if (mode.equals("RETRY")) retry = new Retry(game);
    else if (mode.equals("TOPSCORE")) topScore = new TopScore();
    isStart = false;
  }
  
  // render
  imageMode(CORNER);
  image(bgImg, 0, 0, width, height);
  if (mode.equals("MENU")) menu.render();
  else if (mode.equals("GAME")) game.render();
  else if (mode.equals("RETRY")) retry.render();
  else if (mode.equals("TOPSCORE")) topScore.render();
}

void mouseClicked() {
  if (mode.equals("MENU")) menu.mouseClicked();
  else if (mode.equals("RETRY")) retry.mouseClicked();
  else if (mode.equals("TOPSCORE")) topScore.mouseClicked();
  else if (mode.equals("GAME")) game.mouseClicked();
}

boolean isMouseOn(double x1, double x2, double y1, double y2) {
  if (mouseX > x1 && mouseX < x2 && mouseY > y1 && mouseY < y2)
    return true;
  return false;
}



void setNumber (String numbers, int x, int y) {
  String[] numberList = new String[numbers.length()];
  for (int i = 0; i < numberList.length; i++) {
    numberList[i] = String.valueOf(numbers.charAt(i));
  }
  int widthPic = 10, heightPic = 10;
  imageMode(CORNER);
  for (int i = 0; i < numberList.length; i++) {
    for (int j = 0; j < 10; j++) {
      if (numberList[i].equals(String.valueOf(j))) {
        image(numberImg[j], x + i * widthPic, y, widthPic, heightPic);
        break;
      } else if (numberList[i].equals(".")) {
        image(numberImg[10], x + i * widthPic, y, widthPic, heightPic);
        break;
      }
    }
  }
}