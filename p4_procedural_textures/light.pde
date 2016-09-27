// Light sources

ArrayList<Light> light_list;

class Light {
  PVector pos;  // position
  PVector col;  // color
  
  Light(float x, float y, float z, float r, float g, float b) {
    pos = new PVector (x, y, z);
    col = new PVector (r, g, b);
  }
}

// initialize the light list
void init_lights()
{
  light_list = new ArrayList<Light>();
}

// add a new point iight to the list
void add_light (float x, float y, float z, float r, float g, float b)
{
  Light lite = new Light (x, y, z, r, g, b);
  light_list.add (lite);
}