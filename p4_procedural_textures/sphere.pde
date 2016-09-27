// Sphere objects

ArrayList<Sphere> sphere_list;

class Sphere extends Primitive {
  PVector center;
  float radius;
  Material refl;
  float noise_scale;
  
  Sphere (float x, float y, float z, float r) {
    center = new PVector (x, y, z);
    radius = r;
    refl = get_current_material();
    noise_scale = noise;
    init_stone(center, radius);
  }
  
  // see if a ray intersects a sphere
  Hit ray_intersect(Ray ray)
  {
  Hit hit = new Hit();
  hit.t = -1;
  
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

  // calculate hit noise diffuse
  if (hit.was_hit) {
    if (noise > 0) noiseTexture(hit, noise_scale);
    else if (is_wood) woodTexture(hit);
    else if (is_marble) marbleTexture(hit);
    else if (is_stone) stoneTexture(hit);
  }
  
  return(hit);
  }

}  // sphere

// initialize the sphere list
void init_spheres()
{
  sphere_list = new ArrayList<Sphere>();
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