// Triangles

ArrayList<Triangle> triangle_list;
ArrayList<PVector> vertex_list;

class Triangle extends Primitive {
  PVector v1,v2,v3;  // vertices
  PVector n1,n2,n3;  // normals
  PVector abc;       // a, b, c coefficients of plane equation (also the normal vector)
  float d;           // last plane equation coefficient
  Material refl;
  
  Triangle(PVector p1, PVector p2, PVector p3)
  {
    v1 = p1.get();
    v2 = p2.get();
    v3 = p3.get();
    
    // calculate plane equation coefficients according to f(x,y,z) = ax + by + cz + d = 0
    PVector e1 = PVector.sub(p2, p1);  // vector parallel to one triangle edge
    PVector e2 = PVector.sub(p3, p1);  // vector parallel to another edge
    abc = PVector.cross (e1, e2, abc);      // cross product is normal to both e1 and e2
    abc.normalize();
    d = -1 * PVector.dot (p1, abc);    // plug one of the vertices into f(x,y,z) to find d
  }
  
  // intersect a ray with a triangle
  Hit ray_intersect (Ray ray)
  {
  Hit hit = new Hit();
  hit.was_hit = false;  // start out assuming the triangle was not hit
  
  // intersect ray with plane
  float numer = -1 * (PVector.dot(abc, ray.org) + d);
  float denom = PVector.dot(abc, ray.dir);
  
  // bail if the ray is parallel to the triangle's plane
  if (denom == 0.0)
    return (hit);
  
  // ray parameter for intersection
  float t = numer / denom;
  
  // bail t parameter is too small
  if (t < 0)
    return (hit);
  
  float x,y;
  float x1,y1,x2,y2,x3,y3;
  float dx1,dy1,dx2,dy2;
  float z_cross;
  
  // hit position in 3D
  PVector pos = ray.pos(t);
  
  // we want to see which normal component is larges in absolute value
  float nx = abs(abc.x);
  float ny = abs(abc.y);
  float nz = abs(abc.z);
  
  // project to one of the 2D planes, based on plane normal
  if (nx >= ny && nx >= nz) {
    x = pos.y;
    y = pos.z;
    x1 = v1.y;
    y1 = v1.z;
    x2 = v2.y;
    y2 = v2.z;
    x3 = v3.y;
    y3 = v3.z;
  }
  else if (ny >= nx && ny >= nz) {
    x = pos.x;
    y = pos.z;
    x1 = v1.x;
    y1 = v1.z;
    x2 = v2.x;
    y2 = v2.z;
    x3 = v3.x;
    y3 = v3.z;
  }
  else {
    x = pos.x;
    y = pos.y;
    x1 = v1.x;
    y1 = v1.y;
    x2 = v2.x;
    y2 = v2.y;
    x3 = v3.x;
    y3 = v3.y;
  }
  
  // make sure the projected vertices are oriented in the proper direction
  dx1 = x2 - x1;
  dy1 = y2 - y1;
  dx2 = x3 - x1;
  dy2 = y3 - y1;
  z_cross = dx1 * dy2 - dx2 * dy1;
  float scale = 1;
  
  if (z_cross > 0) {  // if they are the wrong direction, negate the comparisons
    scale = -1;
  }
  
  // determine inside/outside the projected triangle by the
  // z-component of cross-products between edges
  dx1 = x2 - x1;
  dy1 = y2 - y1;
  dx2 = x - x1;
  dy2 = y - y1;
  z_cross = dx1 * dy2 - dx2 * dy1;
  
  if (scale * z_cross > 0)
    return (hit);
  
  dx1 = x3 - x2;
  dy1 = y3 - y2;
  dx2 = x - x2;
  dy2 = y - y2;
  z_cross = dx1 * dy2 - dx2 * dy1;
  
  if (scale * z_cross > 0)
    return (hit);
  
  dx1 = x1 - x3;
  dy1 = y1 - y3;
  dx2 = x - x3;
  dy2 = y - y3;
  z_cross = dx1 * dy2 - dx2 * dy1;
  
  if (scale * z_cross > 0)
    return (hit);
  
  // if we get here, we are inside the triangle,
  // so record that the triangle was hit
  hit.was_hit = true;
  hit.pos = pos;
  hit.t = t;
  hit.refl = refl;
  
  // use the best surface normal
  if (PVector.dot(abc, ray.dir) < 0)
    hit.normal = abc.get();
  else
    hit.normal = PVector.mult(abc, -1.0);
  
  return (hit);
  }
  
} // triangle

// initialize triangle list
void init_triangles()
{
  triangle_list = new ArrayList<Triangle>();
  vertex_list = new ArrayList<PVector>();
}

// add a vertex to the list
void add_vertex(float x, float y, float z)
{
  // create a vector at the new vertex position
  PVector vec = new PVector(x, y, z);

  // grab the current transformation matrix and apply
  // to the vertex
  PMatrix mat = getMatrix(); 
  //printMatrix();
  mat.mult (vec, vec);
  
  // add the transformed vertex to the list of vertices
  vertex_list.add (vec);
}

// add a triangle to the list, using the first three vertices on the vertex list
void add_triangle()
{
  if (vertex_list.size() < 3) {
    println ("too few vertices");
    exit();
  }
  PVector v1 = vertex_list.get(0);
  PVector v2 = vertex_list.get(1);
  PVector v3 = vertex_list.get(2);
  Triangle tri = new Triangle (v1, v2, v3);
  tri.refl = get_current_material();
  triangle_list.add (tri);
  object_list.add (tri);
}