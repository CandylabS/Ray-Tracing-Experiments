// Light sources

ArrayList<Light> light_list;
ArrayList<DiskLight> disk_light_list;

class Light {
  PVector pos;  // position
  PVector col;  // color

  Light (){}
  Light(float x, float y, float z, float r, float g, float b) {
    pos = new PVector (x, y, z);
    col = new PVector (r, g, b);
  }

  PVector randomPos() {
    return pos;
  }
}

class DiskLight extends Light {
	PVector norm;	// norm vector of disk
  PVector v1, v2; // parallel to disk
  float rad;
  
	DiskLight(float _x, float _y, float _z, float _rad, float _dx, float _dy, float _dz, float _r, float _g, float _b) {
		  pos = new PVector (_x, _y, _z);
    	col = new PVector (_r, _g, _b);
    	norm = new PVector (_dx, _dy, _dz);
    	rad = _rad;
      // 1st vector parallel to disk
      if (norm.z == 0) v1 = new PVector (0, 0, 1);
      else v1 = new PVector (0, 1, -norm.y/norm.z);
      // 2nd vector parallel to disk
      v2 = norm.cross(v1);
      v1.normalize();
      v2.normalize();
	}

  // return a random position on disk light
  PVector randomPos(){
    PVector v, random_pos;
    PVector r = PVector.random2D();
    v1.setMag(r.x * rad);
    v2.setMag(r.y * rad);
    v = PVector.add(v1, v2);
    random_pos = PVector.add(pos, v);
    // set back to 1 for later use
    v1.normalize();
    v2.normalize();
    return random_pos;
  }
}


// initialize the light list
void init_lights()
{
  light_list = new ArrayList<Light>();
  disk_light_list = new ArrayList<DiskLight>();
}

// add a new point iight to the list
void add_light (float x, float y, float z, float r, float g, float b)
{
  Light lite = new Light (x, y, z, r, g, b);
  light_list.add(lite);
}

// add a new disk iight to the list
void add_disk_light (float x, float y, float z, float rad, float dx, float dy, float dz, float r, float g, float b)
{
	DiskLight diskLite = new DiskLight (x, y, z, rad, dx, dy, dz, r, g, b);
	disk_light_list.add(diskLite);
  light_list.add(diskLite);
}