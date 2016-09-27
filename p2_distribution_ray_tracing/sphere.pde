// Sphere objects

ArrayList<Sphere> sphere_list;
ArrayList<MovingSphere> moving_sphere_list;

class Sphere extends Primitive {
  PVector center;
  float radius;
  Material refl;

  Sphere(){}

  Sphere (float x, float y, float z, float r) {
    center = new PVector (x, y, z);
    radius = r;
    refl = get_current_material();
  }
  
  // see if a ray intersects a sphere
  Hit ray_intersect(Ray ray)
  {
  Hit hit = new Hit();
  hit.t = -1;

  getPos();
  
  float a = ray.dir.magSq();
  float b = 2 * (PVector.dot(ray.org, ray.dir) - PVector.dot(center, ray.dir));
  float c = ray.org.magSq() + center.magSq() - 2 * PVector.dot(ray.org, center) - radius * radius;
  
  if (false) {
    println ("a b c: " + a + " " + b + " " + c);
    println ("sphere radius = " + radius);
    println ("sphere center = " + center.x + " " + center.y + " " + center.z);
  }
  
  float desc = b*b - 4*a*c;
  
  // start by assuming that there is no hit
  hit.was_hit = false;
  
  if (desc >= 0) {
    float t1 = (-b + sqrt (desc)) / (2 * a);
    float t2 = (-b - sqrt (desc)) / (2 * a);
    float min_t = huge;
    if (t1 > 0 && t1 < min_t) { 
      min_t = t1;
      hit.pos = ray.pos(t1);
      hit.was_hit = true;
      hit.normal = PVector.sub(hit.pos, center);
      hit.normal.normalize();
      hit.refl = refl;
    }
    if (t2 > 0 && t2 < min_t) {
      min_t = t2;
      hit.pos = ray.pos(t2);
      hit.was_hit = true;
      hit.normal = PVector.sub(hit.pos, center);
      hit.normal.normalize();
      hit.refl = refl;
    }
    hit.t = min_t; // choose the nearer one
  }
  
  return(hit);
  }

  void getPos(){}

}  // sphere

class MovingSphere extends Sphere {
  PVector start_pos, end_pos;
  float start_rad, end_rad;

  MovingSphere (float[] r, float x1, float y1, float z1, float x2, float y2, float z2) {
    start_pos = new PVector (x1, y1, z1);
    end_pos = new PVector (x2, y2, z2);
    start_rad = r[0];
    end_rad = r[1];
    refl = get_current_material();
  }

  void getPos() {
    // do some random things
    float amp = random(0, 1);
    float ppx = lerp(start_pos.x, end_pos.x, amp);
    float ppy = lerp(start_pos.y, end_pos.y, amp);
    float ppz = lerp(start_pos.z, end_pos.z, amp);
    center =  new PVector(ppx, ppy, ppz);
    radius = lerp(start_rad, end_rad, amp);
  }
}

// initialize the sphere list
void init_spheres()
{
  sphere_list = new ArrayList<Sphere>();
  moving_sphere_list = new ArrayList<MovingSphere>();
}

// add a new sphere to the list of spheres
void add_sphere(float x, float y, float z, float r)
{
  PVector vec1 = new PVector (x, y, z);
  PVector vec2 = new PVector (x + r, y, z);
  
  // grab the current transformation matrix and apply
  // to the sphere center
  PMatrix mat = getMatrix(); 
  //printMatrix();
  mat.mult (vec1, vec1);
  mat.mult (vec2, vec2);
  PVector vec_diff = PVector.sub(vec2, vec1);
  float rad_new = vec_diff.mag();
  
  Sphere s = new Sphere(vec1.x, vec1.y, vec1.z, rad_new);
  sphere_list.add (s);
  object_list.add (s);
}

void add_moving_sphere(float r, float x1, float y1, float z1, float x2, float y2, float z2) 
{
  PVector vec1 = new PVector (x1, y1, z1);
  PVector vec2 = new PVector (x2, y2, z2);
  PVector vec3 = new PVector (x1 + r, y1, z1);
  PVector vec4 = new PVector (x2 + r, y2, z2);
  
  // grab the current transformation matrix and apply
  // to the sphere center
  PMatrix mat = getMatrix(); 
  //printMatrix();
  mat.mult (vec1, vec1);
  mat.mult (vec2, vec2);
  mat.mult (vec3, vec3);
  mat.mult (vec4, vec4);
  PVector[] vec_diff = {PVector.sub(vec3, vec1), PVector.sub(vec4, vec2)};
  float[] rad_new = {vec_diff[0].mag(), vec_diff[1].mag()};

  MovingSphere s = new MovingSphere(rad_new, vec1.x, vec1.y, vec1.z, vec2.x, vec2.y, vec2.z);
  moving_sphere_list.add(s); 
  object_list.add(s);
}