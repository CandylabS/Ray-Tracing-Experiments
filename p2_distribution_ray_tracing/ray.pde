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
  int i,j,k,index;
  
  noStroke();

  for (j = 0; j < height; j++) {
    for (i = 0; i < width; i++) {
      //initialize
      PVector pixel_color = new PVector(0,0,0);

      debug_flag = false;
      // un-comment to print debug info for center pixel
      // if (i == 150 && j == 150)
      // debug_flag = true;
      
      for (k = 0; k < rays_per_pixel; k++){
        Ray ray = eye_ray(i, j); // eye_ray(i,j,k)
        Hit hit = intersect_scene (ray);
      
        if (debug_flag) {
          println ("ray origin   : " + ray.org.x + " " + ray.org.y + " " + ray.org.z);
          println ("ray direction: " + ray.dir.x + " " + ray.dir.y + " " + ray.dir.z);
        }
      
        if (hit.was_hit) {
          PVector col = shade_hit (hit);
          pixel_color.add(col.x, col.y, col.z);
        }
        else
          pixel_color.add(background_color.x, background_color.y, background_color.z);
      }

      pixel_color.mult(1/rays_per_pixel); // average pixel_color by rays_per_pixel
      fill (pixel_color.x, pixel_color.y, pixel_color.z);
      rect(i, height - j, 1, 1);
    }
  }
}

// create an eye ray
Ray eye_ray(int i, int j)
{
  // random position from each pixel(i,j)
  if (rays_per_pixel > 1) {
    delta[0] = random(0, 1);
    delta[1] = random(0, 1);
    // random position on lens
    if (is_lens) {
      PVector v = PVector.random2D();
      x0 = v.x * lens_size;
      y0 = v.y * lens_size;
    } 
  }

  // eye things
  float x = (i + delta[0] - width/2.0) * 2 * k / (float) width;
  float y = (j + delta[1] - height/2.0) * 2 * k / (float) height; 

  PVector org = new PVector(x0, y0, 0); 
  PVector dir = new PVector(x - org.x/lens_dist, y - org.y/lens_dist, -1);

  Ray ray = new Ray (org, dir);
  
  return (ray);
}

void init_eye(){
  // eye things
  theta = fov_degrees * PI / 180;  // want FOV angle in radians
  k = tan(theta/2);
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