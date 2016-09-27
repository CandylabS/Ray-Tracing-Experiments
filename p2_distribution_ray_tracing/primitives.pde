// geometric primitives

ArrayList<Primitive> object_list;

abstract class Primitive {
  int value;
  
  abstract Hit ray_intersect(Ray r);
}

// initialize the list of objects in the scene
void init_objects()
{
  object_list = new ArrayList<Primitive>();
}