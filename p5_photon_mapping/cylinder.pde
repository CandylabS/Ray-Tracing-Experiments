ArrayList<Cylinder> cylinder_list;

class Cylinder extends Primitive {
	float radius;
	PVector bottom, top;
	Material refl;

	Cylinder(float r, float x, float z, float ymin, float ymax) {
		radius = r;
		bottom = new PVector(x, ymin, z);
		top = new PVector(x, ymax, z);
		refl = get_current_material();
	}

	// see if a ray intersects a sphere
  	Hit ray_intersect(Ray ray)
  	{
  		Hit hit = new Hit();
  		hit.t = -1;

      float a = sq(ray.dir.x) + sq(ray.dir.z);
      float b = ((ray.org.x - top.x) * ray.dir.x + (ray.org.z - top.z) * ray.dir.z) * 2;
      float c = sq(ray.org.x - top.x) + sq(ray.org.z - top.z) - sq(radius);

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
          if (hit.pos.y > bottom.y && hit.pos.y < top.y) {
            hit.was_hit = true;
            PVector center = new PVector(top.x, hit.pos.y, top.z);
            hit.normal = PVector.sub(hit.pos, center);
            hit.normal.normalize();
            hit.refl = refl;
          }
        }
        if (t2 > 0 && t2 < min_t) {
          min_t = t2;
          hit.pos = ray.pos(t2);
          if (hit.pos.y > bottom.y && hit.pos.y < top.y)  {
            hit.was_hit = true;
            PVector center = new PVector(top.x, hit.pos.y, top.z);
            hit.normal = PVector.sub(hit.pos, center);
            hit.normal.normalize();
            hit.refl = refl;
          }
        }
        hit.t = min_t; // choose the nearer one
      }

  		return(hit);
  	}

} //cylinder

// initialize the cylinder list
void init_cylinder()
{
  cylinder_list = new ArrayList<Cylinder>();
}

// add a new cylinder to the list of cylinders
void add_cylinder(float r, float x, float z, float ymin, float ymax)
{	
	PVector vec1 = new PVector (x, ymin, z);
  	PVector vec2 = new PVector (x + r, ymin, z);
  	PVector vec3 = new PVector (x, ymax, z);
  
  	// grab the current transformation matrix and apply
  	// to the cylinder bottom/top center
  	PMatrix mat = getMatrix(); 
  	//printMatrix();
  	mat.mult (vec1, vec1);
  	mat.mult (vec2, vec2);
  	mat.mult (vec3, vec3);
  	PVector vec_diff = PVector.sub(vec2, vec1);
  	float rad_new = vec_diff.mag();

	Cylinder cyl = new Cylinder(rad_new, vec1.x, vec1.z, vec1.y, vec3.y);
	cylinder_list.add(cyl);
	object_list.add(cyl);
}