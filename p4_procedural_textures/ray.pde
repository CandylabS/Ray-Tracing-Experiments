// Rays and Hit Records

class Ray {
  PVector org;   // origin
  PVector dir;    // direction
  
  Ray (PVector o, PVector d) {
    org = o.get();
    dir = d.get();
  }
  
  // given a t value, return the corresponding 3D position on the ray
  PVector pos(float t) {
    PVector dir_scaled = PVector.mult(dir, t);
    return (PVector.add(dir_scaled, org));
  }
}

// a record of what was hit by a ray
class Hit {
  PVector pos;      // 3D position of hit
  float t;          // ray parameter of hit
  boolean was_hit;  // was there in fact a hit?
  PVector normal;   // surface normal at hit
  Material refl;    // surface material reflectance
}

// render the scene by casting rays from the eye
void render_scene()
{
  int i,j;
  
  noStroke();
  
  for (j = 0; j < height; j++) {
    for (i = 0; i < width; i++) {
      
      debug_flag = false;
      // un-comment to print debug info for center pixel
//      if (i == 150 && j == 150)
//        debug_flag = true;
      
      Ray ray = eye_ray(i, j);
      Hit hit = intersect_scene (ray);
      
      if (debug_flag) {
        println ("ray origin   : " + ray.org.x + " " + ray.org.y + " " + ray.org.z);
        println ("ray direction: " + ray.dir.x + " " + ray.dir.y + " " + ray.dir.z);
      }
      
      if (hit.was_hit) {
        PVector col = shade_hit (hit);
        fill (col.x, col.y, col.z);
      }
      else
        fill (background_color.x, background_color.y, background_color.z);
      
      rect(i, height - j, 1, 1);
    }
  }
}

// create an eye ray
Ray eye_ray(int i, int j)
{
  PVector org = new PVector (0, 0, 0);
  
  float theta = fov_degrees * PI / 180;  // want FOV angle in radians
  float k = tan(theta/2);

  float x = (i - width/2.0) * 2 * k / (float) width;
  float y = (j - height/2.0) * 2 * k / (float) height;
  PVector dir = new PVector (x, y, -1);
  
  Ray ray = new Ray (org, dir);
  
  return (ray);
}

// see what a given ray hits in the scene
Hit intersect_scene(Ray ray)
{
  int k;
  float epsilon = 1e-5;
  Hit hit_near = new Hit();
  hit_near.t = huge;
  
//  println ("sphere count = " + sphere_list.size());
  
  // go thru all the objects in the scene,
  // testing each to find the closest intersection along the ray
  for (k = 0; k < object_list.size(); k++) {
    Primitive prim = object_list.get(k);
    Hit h = prim.ray_intersect (ray);
    if (h.was_hit && h.t > epsilon && h.t < hit_near.t) {
      hit_near = h;
    }
  }
  
  return (hit_near);
}