public class Scene {

  private int FPS = 60;

  public Scene() {
    frameRate(FPS);
  }

  public void update() {
  }

  public void render() {
  }
  
}

public class Game extends Scene {

  private Fortress fortress;
  
  private ArrayList<Alien> aliens;
  private long alienRespawnTime;
  private double alienRespawnDelay;
  private int alienHP;
  private int alienNumber;
  private int alienDead;
  
  private ArrayList<Bonus> bonuses;
  private long bonusTime;
  private double bonusDelay;
  
  private HUD hud;
  
  private boolean isPause;
  
  private PImage pauseImg;
  private PImage resumeImg;
  private PImage exitImg;

  public Game() {
    
    // Alien
    aliens = new ArrayList<Alien>();
    alienHP = 1;
    alienNumber = 3;
    alienRespawnDelay = 3000;
    alienRespawnTime = frameCount;
    alienDead = 0;
    
    // Fortress
    fortress = new Fortress(width/2, height/2, 50, aliens);
    
    // Bonuses
    bonuses = new ArrayList<Bonus>();
    bonusTime = frameCount;
    bonusDelay = 10000;
    
    // HUD
    hud = new HUD(fortress);
    
    pauseImg = loadImage("pause.png");
    resumeImg = loadImage("resume.png");
    exitImg = loadImage("exit.png");
  }

  public void update() {
    
    if (!isPause) {
      // fortress
      fortress.update();
      
      // alien
      alienRespawn(fortress);
      ArrayList<Bullet> bullets = fortress.getBullets();
      for (int i = 0; i < aliens.size(); i++) {
        
        // alien vs fortress
        if(collision(fortress, aliens.get(i))) {
          saveTopScore();
          mode = "RETRY";
          isStart = true;
          break;
        }
        alienVCalculate(fortress, aliens.get(i));
        
        // alien vs bullets
        for (int j = 0; j < bullets.size(); j++) {
          if (collision(bullets.get(j), aliens.get(i))) {
            bullets.get(j).setV(bullets.get(j).getV() - 1);
            aliens.get(i).getDamage((int)fortress.getFirePower());
            if (bullets.get(j).getV() <= 0) {
              bullets.remove(j);
            }
          }
        }
        
        // aliens vs aliens
        aliens.get(i).update();
        if (aliens.get(i).getHP() <= 0) {
          aliens.remove(i);
          alienDead++;
          fortress.addScore(1);
          if (alienDead % 3 == 0) alienHP++;
        }
      }
      
      // bonuses
      bonusRespawn();
      for (int i = 0; i < bonuses.size(); i++) {
        for (int j = 0; j < bullets.size(); j++) {
          if (collision(bullets.get(j), bonuses.get(i))) {
            fortress.specialPower(bonuses.get(i).getType()+1);
            bullets.remove(j); 
            bonuses.get(i).setUsed(true);
            break;
          }
        }
        bonuses.get(i).update();
        if (bonuses.get(i).isUsed()) 
          bonuses.remove(i);
      }
    } else {
      noLoop();
    }
    
  }
  
  public void saveTopScore() {
    String[] topScores = loadStrings("top_score.txt");
    double[] scores = new double[10];
    if (topScores.length <= 0) {
      for (int i = 0; i < 10; i++)
        scores[i] = 0;
    } else {
      for (int i = 0; i < 10; i++) {
        if (i >= topScores.length) scores[i] = 0;
        else scores[i] = Double.parseDouble(topScores[i]);
      }
    }
    for (int i = 0; i < scores.length; i++) {
      if (fortress.getScore() >= scores[i]) {
        for (int j = 8; j >= i; j--) {
          scores[j+1] = scores[j];
        }
        scores[i] = fortress.getScore();
        break;
      }
    }
    String[] data = new String[10];
    for (int i = 0; i < scores.length; i++) {
      data[i] = String.valueOf((int)scores[i]);
    }
    saveStrings("top_score.txt", data);
  }
  
  public void bonusRespawn() {
    if (isTimeUp(bonusDelay, bonusTime)) {
      float x = random(width * 0.2, width * 0.8);
      float y = random(height * 0.2, height * 0.8);
      bonuses.add(new Bonus(x, y, 30, (int)random(4)));
      bonusTime = frameCount;
    }
  }

  public void render() {
    fortress.render();
    for (int i = 0; i < aliens.size(); i++)
      aliens.get(i).render();
    for (int i = 0; i < bonuses.size(); i++)
      bonuses.get(i).render();
    hud.render();
    // pause
    imageMode(CENTER);
    image(pauseImg, width * 0.95, height * 0.05, 30, 30);
    
    if (isPause) {
      noStroke();
      fill(0, 100);
      rectMode(CENTER);
      rect(width/2, height/2, width, height);
      image(resumeImg, width * 0.25, height/2, 150, 50);
      image(exitImg, width * 0.75, height/2, 150, 50);
    }
  }
  
  public void mouseClicked() {
    if (!isPause && isMouseOn(width * 0.95 - 15, width * 0.95 + 15, height * 0.05 - 15, height * 0.05 + 15))
      isPause = true;
    else if (isPause) {
      if (isMouseOn(width * 0.25 - 75, width * 0.25 + 75, height/2 - 25, height/2 + 25)) {
        isPause = false;
        loop();
      }
      else if (isMouseOn(width * 0.75 - 75, width * 0.75 + 75, height/2 - 25, height/2 + 25)) {
        mode = "MENU";
        isStart = true;
        loop();
      }
    } 
  }
  
  public boolean collision(GameObject me, GameObject enemy) {
    if (dist((float)me.getX(), (float)me.getY(), (float)enemy.getX(), (float)enemy.getY()) < enemy.getSize()) 
      return true;
    return false;
  }

  public void alienRespawn(Fortress fortress) {
    if (isTimeUp(alienRespawnDelay, alienRespawnTime) && !fortress.isAliensStop()) {
       for (int i = 0; i < alienNumber; i++) {
         double code = random(4);
         double[] xy = getRandomXY(code);
         aliens.add(new Alien(xy[0], xy[1], 30, 0, alienHP));
       }
       if (alienDead % 7 == 0 && alienDead != 0) {
         double code = random(4);
         double[] xy = getRandomXY(code);
         aliens.add(new Alien(xy[0], xy[1], 30, 1, alienHP));
       }
       if (alienDead % 11 == 0 && alienDead != 0) {
         double code = random(4);
         double[] xy = getRandomXY(code);
         aliens.add(new Alien(xy[0], xy[1], 30, 2, alienHP));
       }
       alienRespawnTime = frameCount;
    }
  }
  
  public double[] getRandomXY(double respawnCode) {
    double x = 0;
    double y = 0;
    if (respawnCode >= 3) {
      x = random(-width * 0.25, 0);
      y = random(-height * 0.25, 1.25 * height);
    } else if (respawnCode >= 2) {
      x = random(-width * 0.25, 1.25 * width);
      y = random(-height * 0.25, 0);
    } else if (respawnCode >= 1) {
      x = random(width, 1.25 * width);
      y = random(-height * 0.25, 1.25 * height);
    } else {
      x = random(-width * 0.25, 1.25 * width);
      y = random(height, 1.25 * height);
    }
    double[] xy = {x, y};
    return xy;
  }
  
  private boolean isTimeUp(double timeDelay, double timeNow) {
    return (frameCount - timeNow) > (timeDelay / 1000 * frameRate);
  }
  
  private void alienVCalculate(Fortress f, Alien a) {
    double degree = atan2((float)(f.getY()-a.getY()), (float)(f.getX()-a.getX()));
    a.setDegree(degree);
  }
  
  public Fortress getFortress() {
    return fortress;
  }
  
}

public class Menu extends Scene {
  
  private PImage startImg;
  private PImage topScoreImg;
  private PImage exitImg;
  private PImage logoImg;
  
  public Menu() {
    startImg = loadImage("start.png");
    topScoreImg = loadImage("top_score.png");
    exitImg = loadImage("exit.png");
    logoImg = loadImage("logo.png");
  }
  
  public void update() {
  }
  
  public void render() {
    imageMode(CENTER);
    image(logoImg, width/2, height * 0.15, 390, 80);
    image(startImg, width/2, height * 0.4, 150, 50);
    image(topScoreImg, width/2, height * 0.6, 150, 50);
    image(exitImg, width/2, height * 0.8, 150, 50);
  }
  
  public void mouseClicked() {
    if (isMouseOn(width/2 - 75, width/2 + 75, height * 0.4 - 25, height * 0.4 + 25)) {
      isStart = true;
      mode = "GAME";
    } else if (isMouseOn(width/2 - 75, width/2 + 75, height * 0.6 - 25, height * 0.6 + 25)) {
      isStart = true;
      mode = "TOPSCORE";
    } else if (isMouseOn(width/2 - 75, width/2 + 75, height * 0.8 - 25, height * 0.8 + 25)) {
      exit();
    } 
  }
  
}

public class Retry extends Scene {
  
  private Fortress fortress;
  
  private PImage retryImg, newGameImg;
  
  public Retry(Game game) {
    this.fortress = game.getFortress();
    
    retryImg = loadImage("retry.png");
    newGameImg = loadImage("new_game.png");
  }
  
  public void render() {
    fill(255);
    textSize(25);
    textAlign(CENTER,CENTER);
    text("SCORE : " + (int)fortress.getScore(), width/2, 0.3 * height);
    imageMode(CENTER);
    image(retryImg, width/2, 0.5 * height, 150, 50);
    image(newGameImg, width/2, 0.7 * height, 150, 50);
  }
  
  public void mouseClicked() {
    if (isMouseOn(width/2 - 75, width/2 + 75, 0.5 * height - 25, 0.5 * height + 25)) {
        mode = "GAME";
        isStart = true;
    } else if (isMouseOn(width/2 - 75, width/2 + 75, 0.7 * height - 25, 0.7 * height + 25)) {
        mode = "MENU";
        isStart = true;
    } 
  }
  
}

public class TopScore {
  
  private String[] topScores;
  private PImage menuImg;
  private PImage scoreImg;
  
  public TopScore() {
    topScores = loadStrings("top_score.txt");
    menuImg = loadImage("menu.png");
    scoreImg = loadImage("score.png");
  }
  
  public void render() {
    imageMode(CENTER);
    image(scoreImg, width/2, 0.2 * height, 50, 10);
    image(menuImg, width/2, 0.9 * height, 150, 50);
    if (topScores.length <= 0) {
      for (int i = 0; i < 10; i++) {
        String showData = i + 1 + " . " + 0;
        setNumber(showData, width/2 - 10 * showData.length() / 2, (int)(height * 0.3 + height * 0.05 * i));
      }
    } else {
      for (int i = 0; i < topScores.length; i++) {
        String showData = i + 1 + " . " + topScores[i];
        setNumber(showData, width/2 - 10 * showData.length() / 2, (int)(height * 0.3 + height * 0.05 * i));
      }
    }
  }
  
  public void mouseClicked() {
    if(isMouseOn(width/2 - 75, width/2 + 75, 0.9 * height - 25, 0.9 * height + 25)) {
        isStart = true;
        mode = "MENU";
      }
  }
}