// Surface Materials

ArrayList<Material> material_list;

class Material {
  PVector diffuse;
  PVector ambient;
  float k_refl;
  
  Material(float dr, float dg, float db, float ar, float ag, float ab, float _k_refl)
  {
    diffuse = new PVector (dr, dg, db);
    ambient = new PVector (ar, ag, ab);
    k_refl = _k_refl;
  }
 
}

// initialize the materials list
void init_materials()
{
  material_list = new ArrayList<Material>();
}

// return a reference to the most recently defined material
Material get_current_material()
{
  int index = material_list.size() - 1;
  return (material_list.get(index));
}

// add a new diffuse material to the materials list
void add_diffuse(float dr, float dg, float db, float ar, float ag, float ab)
{
  Material m = new Material(dr, dg, db, ar, ag, ab, 0);
  material_list.add(m);
}

// add a new reflective material to the materials list
void add_reflective(float dr, float dg, float db, float ar, float ag, float ab, float k_refl)
{
  Material m = new Material(dr, dg, db, ar, ag, ab, k_refl);
  material_list.add(m);
}

// calculate sharding for a surface hit
PVector shade_hit(Hit hit)
{
  int i;
  PVector full_color = new PVector(0, 0, 0);
  PVector col = new PVector();
  float epsilon = 1e-6;
    
  // loop through all the lights to account for their contributions
  for (i = 0; i < light_list.size(); i++) {
    
    // see if this light is blocked
    Light light = light_list.get(i);
    PVector light_dir = PVector.sub(light.pos, hit.pos);
    
    // first check for attached shadows [if it is inner or back of a surface]
    if (PVector.dot(hit.normal, light_dir) < 0) {
      continue;
    }
    
    // now check for cast shadows by shooting a shadow ray [if it is blocked by other objects]
    Ray light_ray = new Ray (hit.pos, light_dir);
    Hit light_hit = intersect_scene (light_ray);
    if (light_hit.was_hit == true && light_hit.t < 1) {
      continue;
    }
    
    // calculate N dot L
    PVector L = PVector.sub (light.pos, hit.pos);
    L.normalize();
    float diff = PVector.dot (L, hit.normal);
    // clamp to zero
    if (diff < 0)
      diff = 0;

    // calculate reflection ray
    if (hit.refl.k_refl > 0) {
      PVector refl_col = reflection(hit);
      refl_col.mult(hit.refl.k_refl);
      full_color.add (refl_col);
    }
    
    // determine color, which is diffuse color times light color
    col.x =  hit.refl.diffuse.x * light.col.x;
    col.y =  hit.refl.diffuse.y * light.col.y;
    col.z =  hit.refl.diffuse.z * light.col.z;
    
    if (debug_flag) {
      print_vec ("normal:", hit.normal);
      print_vec ("light: ", L);
      print_vec ("color product:", col);
      println ("N dot L = " + diff);
    }

    // combine color and N dot L
    col.mult(diff);
    // accumulate color
    full_color.add (col);
  } 
  // for loop over
  
  // add in ambient term
  full_color.add (hit.refl.ambient);
 
  if (debug_flag)
    print_vec ("color:", full_color);
  
  return (full_color);
}

// color component relate to reflection
PVector reflection(Hit hit) {
  PVector refl_col = new PVector(0, 0, 0);  // no color relate to reflection

  PVector org = new PVector(0, 0, 0);   // hardcode, this is not recursive, suppose there are no other reflections
  PVector E = PVector.sub (org, hit.pos);
  E.normalize();
  float diff_2 = PVector.dot(E, hit.normal);

  // if there is reflection on hit.pos
  if (diff_2 > 0) {
    // create new reflection ray from hit.pos
    PVector v = hit.normal.copy();
    v.setMag(diff_2 * 2);
    PVector refl_dir = PVector.sub(v, E);
    Ray refl_ray = new Ray(hit.pos, refl_dir);
    // if reflection ray hits some object
    Hit h = intersect_scene (refl_ray);
    if (h.was_hit) {
      refl_col = shade_hit (h);
    }
  }

  return refl_col;
}