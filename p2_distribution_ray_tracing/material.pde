// Surface Materials

ArrayList<Material> material_list;

class Material {
  PVector diffuse;
  PVector ambient;
  
  Material(float dr, float dg, float db, float ar, float ag, float ab)
  {
    diffuse = new PVector (dr, dg, db);
    ambient = new PVector (ar, ag, ab);
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
  Material m = new Material(dr, dg, db, ar, ag, ab);
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
    Light light = light_list.get(i);

    PVector light_pos;  // set to light.pos if point light, set to random_pos if disk light
    light_pos = light.randomPos();

    PVector light_dir = PVector.sub(light_pos, hit.pos);
    
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
    PVector L = PVector.sub (light_pos, hit.pos);
    L.normalize();
    float diff = PVector.dot (L, hit.normal);
    // clamp to zero
    if (diff < 0)
      diff = 0;
    
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