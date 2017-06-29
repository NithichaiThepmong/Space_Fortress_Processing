 public class GameObject {
  
  protected double x, y;
  protected double size;

  public GameObject(double x, double y, double size) {
    this.x = x;
    this.y = y;
    this.size= size;
  }
  
  public boolean isTimeUp(double timeDelay, double timeNow) {
    return (frameCount - timeNow) > (timeDelay / 1000 * frameRate);
  }

  public void update() {
  }

  public void render() {
  }
  
  public double getX() { 
    return x;
  }
  
  public double getY() {
    return y;
  }
  
  public double getSize() {
    return size;
  }
  
}


public class Fortress extends GameObject {

  private int powerID;
  private double degreeFortress;
  private double score;
  
  private double rapidDelay;
  private long rapidTime;
  private ArrayList<Bullet> bullets;
  private double v;
  private double firePower;
  private long ultimatePowerTime;
  private double ultimatePowerDelay;
  private double normalBulletDelay;
  private double ultimateBulletDelay;
  
  private ArrayList<Alien> aliens;
  private long aliensStopTime;
  private double aliensStopDelay;
  private boolean aliensStop;
  
  private PImage fortressImg;

  public Fortress(double x, double y, double size, ArrayList<Alien> aliens) {
    super(x, y, size);
    normalBulletDelay = 500;
    ultimateBulletDelay = 10;
    rapidDelay = normalBulletDelay;
    rapidTime = frameCount;
    v = 5;
    firePower = 1;
    ultimatePowerDelay = 2000;
    score = 0;
    
    this.aliens = aliens;
    aliensStopDelay = 3000;
    
    bullets = new ArrayList<Bullet>();
    
    fortressImg = loadImage("fortress.png");
  }

  private void move() {
    degreeFortress = atan2(mouseY- height/2, mouseX-width/2);
  }

  private void shoot() {
    // speed of shoot
    if (isTimeUp(rapidDelay, rapidTime)) {
      bullets.add(new Bullet(super.x, super.y, 10, degreeFortress, v));
      rapidTime = frameCount;
    }
    // ultimate shoot time up
    if (isTimeUp(ultimatePowerDelay, ultimatePowerTime)) {
      rapidDelay = normalBulletDelay;
      specialPower(0);
    }
  }

  public void specialPower(int powerID) {
    this.powerID = powerID;
    if (powerID == 0) {
      rapidDelay = normalBulletDelay;
    } else if (powerID == 1) {
      if (normalBulletDelay > 50) {
        normalBulletDelay -= 10;
        rapidDelay = normalBulletDelay;
      }
      powerID = 0;
    } else if (powerID == 2) {
      firePower += 1;
      powerID = 0;
    } else if (powerID == 3) { 
      for (int i = 0; i < aliens.size(); i++) {
        aliens.get(i).setV(0);
      }
      aliensStopTime = frameCount;
      aliensStop = true;
    } else if (powerID == 4) { 
      rapidDelay = ultimateBulletDelay;
      ultimatePowerTime = frameCount;
    }
  }
  
  public void aliensStopping() {
    if (isTimeUp(aliensStopDelay, aliensStopTime)) {
      for (int i = 0; i < aliens.size(); i++) {
        aliens.get(i).setV(aliens.get(i).getVMove());
      }
      aliensStop = false;
      specialPower(0);
    }
  }
  
  public void addScore(double score) {
    this.score += score;
  }
  
  public boolean isAliensStop() {
    return aliensStop;
  }

  public void update() {
    move();
    shoot();
    for (int i = 0; i < bullets.size(); i++) {
      Bullet b = bullets.get(i);
      if (b.getX() < 0 || b.getX() > width || b.getY() < 0 || b.getY() > height) {
        bullets.remove(i);
      }
      b.update();
    }
    if (aliensStop) aliensStopping();
  }

  public void render() {
    for (int i = 0; i < bullets.size(); i++) {
      Bullet b = bullets.get(i);
      b.render();
    }
    noFill();
    stroke(0);
    pushMatrix();
    translate((float)super.x, (float)super.y);
    rotate((float)degreeFortress);
    imageMode(CENTER);
    image(fortressImg, 0, 0, (float)size, (float)size);
    popMatrix();
  }
  
  public ArrayList<Bullet> getBullets() {
    return bullets;
  }
  
  public double getFirePower() {
    return firePower;
  }
  
  public int getPowerID() {
    return powerID;
  }
  
  public double getScore() {
    return score;
  }
  
}


public class Alien extends GameObject{
  
  private int HP;
  private double v;
  private double degree;
  private double vMove;
  private int type;
  
  private PImage alienImg;
  private PImage alienSpeedImg;
  
  public Alien(double x, double y, double size, int type, int HP) {
    super(x, y, size);
    this.type = type;
    if (type == 0) {
      this.HP = HP;
      vMove = 0.5;
    } else if (type == 1) {
      this.HP = HP;
      vMove = 2;
    } else if (type == 2) {
      this.HP = HP * 3;
      vMove = 0.5;
    }
    v = vMove;
    
    alienImg = loadImage("alien.png");
    alienSpeedImg = loadImage("alien_speed.png");
  }
  
  public int getHP() {
    return HP;
  }
  
  public void getDamage(int damage) {
    HP -= damage;
  }
  
  public void update() {
    x += v * cos((float)degree);
    y += v * sin((float)degree);
  }
  
  public void render() {
    fill(0);
    textSize(10);
    textAlign(CENTER, CENTER);
    text(HP, (float)super.x, (float)super.y);
    noFill();
    stroke(0);
    imageMode(CENTER);
    if (type == 0) {
      image(alienImg, (float)super.x, (float)super.y, (float)size, (float)size);
    } else if (type == 1) {
      image(alienSpeedImg, (float)super.x, (float)super.y, (float)size, (float)size);
    } else if (type == 2) {
      image(alienImg, (float)super.x, (float)super.y, (float)size * 1.5, (float)size * 1.5);
    }
    
  }
  
  public double getV() {
    return v;
  }
  
  public double getDegree() {
    return degree;
  }
  
  public double getVMove() {
    return vMove;
  }
  
  public void setV(double v) {
    this.v = v;
  }
  
  public void setDegree(double degree) {
    this.degree = degree;
  }
  
} 


public class Bonus extends GameObject{

  private int type;
  private boolean isUsed;
  
  private PImage bonusImg;
  
  public Bonus(double x, double y, double size, int type) {
    super(x, y, size);
    this.type = type;
    isUsed = false;
    
    bonusImg = loadImage("bonus.png");
  }
  
  public void render() {
    imageMode(CENTER);
    image(bonusImg, (float)super.x, (float)super.y, (float)28, (float)30);
  }
  
  public int getType() {
    return type;
  }
  
  public boolean isUsed() {
    return isUsed;
  }
  
  public void setUsed(boolean isUsed) {
    this.isUsed = isUsed;
  }
  
}


public class Bullet extends GameObject {
  
  private double degree;
  private double v;
  
  private PImage bulletImg;

  public Bullet(double x, double y, double size, double degree, double v) {
    super(x, y, size);
    this.degree = degree;
    this.v = v;                // velocity
    
    bulletImg = loadImage("bullet.png");
  }
  
  public void move () {
    super.x += v * cos((float)degree);
    super.y += v * sin((float)degree);
  }
  
  public void update() {
    move();
  }
  
  public void render() {
    noFill();
    stroke(0);
    imageMode(CENTER);
    image(bulletImg, (float)super.x, (float)super.y, (float)super.size, (float)super.size);
  }
  
  public double getV() {
    return v;
  }
  
  public void setV(double v) {
    this.v = v;
  }
  
}

public class HUD {
  
  private Fortress fortress;
  
  public HUD( Fortress fortress) {
    this.fortress = fortress;
  }
  
  public void render() {
    String scoreText = String.valueOf((int)fortress.getScore());
    setNumber(scoreText, width/2 - 10 * scoreText.length() / 2, 20);
  }
  
}