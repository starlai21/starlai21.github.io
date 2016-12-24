Spaceship ship;

void setup() {
  size(620, 360);
  ship = new Spaceship();
}

void draw() {
  background(255); 
  
  // Update position
  ship.update();
  // Wrape edges
  ship.wrapEdges();
  // Draw ship
  ship.display();
   

  fill(0);
  //text("left right arrows to turn, z to thrust",10,height-5);

  // Turn or thrust the ship depending on what key is pressed
  if (keyPressed) {
    if (key == CODED && keyCode == LEFT) {
      ship.turn(-0.03);
    } else if (key == CODED && keyCode == RIGHT) {
      ship.turn(0.03);
    } else if (key == 'z' || key == 'Z') {
      ship.thrust(); 
    }
  }
}


class Spaceship { 
  // All of our regular motion stuff
  PVector position;
  PVector velocity;
  PVector acceleration;
  
  ParticleSystem ps;

  // Arbitrary damping to slow down ship
  float damping = 0.995;
  float topspeed = 6;

  // Variable for heading!
  float heading = 0;

  // Size
  float r = 16;

  // Are we thrusting (to color boosters)
  boolean thrusting = false;

  Spaceship() {
    position = new PVector(width/2,height/2);
    velocity = new PVector();
    acceleration = new PVector();
    
    ps = new ParticleSystem();
  } 

  // Standard Euler integration
  void update() { 
    velocity.add(acceleration);
    velocity.mult(damping);
    velocity.limit(topspeed);
    position.add(velocity);
    acceleration.mult(0);
    
    ps.run();
  }

  // Newton's law: F = M * A
  void applyForce(PVector force) {
    PVector f = force.get();
    //f.div(mass); // ignoring mass right now
    acceleration.add(f);
  }

  // Turn changes angle
  void turn(float a) {
    heading += a;
  }
  
  // Apply a thrust force
  void thrust() {
    // Offset the angle since we drew the ship vertically
    float angle = heading - PI/2;
    // Polar to cartesian for force vector!
    PVector force = PVector.fromAngle(angle);
    force.mult(0.1);
    applyForce(force); 
    
    force.mult(-2);
    ps.addParticle(position.x,position.y+r,force);
    
    
    // To draw booster
    thrusting = true;
  }

  void wrapEdges() {
    float buffer = r*2;
    if (position.x > width +  buffer) position.x = -buffer;
    else if (position.x <    -buffer) position.x = width+buffer;
    if (position.y > height + buffer) position.y = -buffer;
    else if (position.y <    -buffer) position.y = height+buffer;
  }


  // Draw the ship
  void display() { 
    stroke(0);
    strokeWeight(2);
    pushMatrix();
    translate(position.x,position.y+r);
    rotate(heading);
    fill(175);
    if (thrusting) fill(255,0,0);
    // Booster rockets
    rect(-r/2,r,r/3,r/2);
    rect(r/2,r,r/3,r/2);
    fill(175);
    // A triangle
    beginShape();
    vertex(-r,r);
    vertex(0,-r);
    vertex(r,r);
    endShape(CLOSE);
    rectMode(CENTER);
    popMatrix();
    
    thrusting = false;
  }
}

// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Using Generics now!  comment and annotate, etc.

class ParticleSystem {
  ArrayList<Particle> particles;

  ParticleSystem() {
    particles = new ArrayList<Particle>();
  }

  void addParticle(float x, float y, PVector force) {
    particles.add(new Particle(new PVector(x, y),force));
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}
class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;

  Particle(PVector l,PVector dir) {
    acceleration = dir.get();
    velocity = PVector.random2D();
    position = l.get();
    lifespan = 255.0;
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 2.0;
  }

  // Method to display
  void display() {
    noStroke();
    fill(127,0,0,lifespan);
    ellipse(position.x,position.y,12,12);
  }
  
  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}