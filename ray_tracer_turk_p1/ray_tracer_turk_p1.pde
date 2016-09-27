//////////////////////////////////////
//
//  Ray Tracer
//
//  Greg Turk, January 2014
//
/////////////////////////////////////

int screen_width = 300;
int screen_height = 300;

boolean debug_flag = false;

PMatrix3D global_mat;
float[] gmat = new float[16];  // global matrix values

float fov_degrees = 60;    // field of view, in degrees
PVector background_color;  // color of scene background

// Some initializations for the scene.

void setup() {
  size (300, 300, P3D);  
  noStroke();
  colorMode (RGB, 1.0);
  background (0, 0, 0);
  
  // grab the global matrix values (to use later)
  PMatrix3D global_mat = (PMatrix3D) getMatrix();
  global_mat.get(gmat);
  //println (gmat[11]);
  
  //printMatrix();
  // reset the matrix
  resetMatrix();
  
//  interpreter("rect_test.cli");
  
  // initilize the scene
  init_scene();
}

// initialize the scene
void init_scene()
{
  init_spheres();
  init_triangles();
  init_objects();
  init_materials();
  init_lights();
  background_color = new PVector (0, 0, 0);
}

// Press key 1 to 9 and 0 to run different test cases.

void keyPressed() {
  init_scene();
  switch(key) {
    case '1':  interpreter("t01.cli"); break;
    case '2':  interpreter("t02.cli"); break;
    case '3':  interpreter("t03.cli"); break;
    case '4':  interpreter("t04.cli"); break;
    case '5':  interpreter("t05.cli"); break;
    case '6':  interpreter("t06.cli"); break;
    case '7':  interpreter("t07.cli"); break;
    case '8':  interpreter("t08.cli"); break;
    case '9':  interpreter("t09.cli"); break;
    case '0':  interpreter("t10.cli"); break;
    case 'q':  exit(); break;
  }
}

//  Parser core. It parses the CLI file and processes it based on each 
//  token. Only "color", "rect", and "write" tokens are implemented. 
//  You should start from here and add more functionalities for your
//  ray tracer.
//
//  Note: Function "splitToken()" is only available in processing 1.25 or higher.

void interpreter(String filename) {
  
  String str[] = loadStrings(filename);
  if (str == null) println("Error! Failed to read the file.");
  for (int i=0; i<str.length; i++) {
    
    String[] token = splitTokens(str[i], " "); // Get a line and parse tokens.
    if (token.length == 0) continue; // Skip blank line.
    
    if (token[0].equals("fov")) {
      fov_degrees = float(token[1]);
    }
    else if (token[0].equals("background")) {
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      background_color = new PVector (r, g, b);
    }
    else if (token[0].equals("point_light")) {
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      float r = float(token[4]);
      float g = float(token[5]);
      float b = float(token[6]);
      add_light (x, y, z, r, g, b);
    }
    else if (token[0].equals("begin")) {
      vertex_list.clear();
    }
    else if (token[0].equals("end")) {
      add_triangle();
    }
    else if (token[0].equals("vertex")) {
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      add_vertex (x, y, z);
    }
    else if (token[0].equals("diffuse")) {
      float dr = float(token[1]);
      float dg = float(token[2]);
      float db = float(token[3]);
      float ar = float(token[4]);
      float ag = float(token[5]);
      float ab = float(token[6]);
      add_diffuse (dr, dg, db, ar, ag, ab);
    }    
    else if (token[0].equals("sphere")) {
      float r = float(token[1]);
      float x = float(token[2]);
      float y = float(token[3]);
      float z = float(token[4]);
      add_sphere (x, y, z, r);
    }
    else if (token[0].equals("push")) {
      pushMatrix();
    }
    else if (token[0].equals("pop")) {
      popMatrix();
    }
    else if (token[0].equals("translate")) {
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      translate (x, y, z);
    }
    else if (token[0].equals("scale")) {
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      scale (x, y, z);
    }
    else if (token[0].equals("rotate")) {
      float theta = float(token[1]);
      float x = float(token[2]);
      float y = float(token[3]);
      float z = float(token[4]);
      theta *= PI / 180.0;
      rotate (theta, x, y, z);
    }
    else if (token[0].equals("color")) {
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      fill(r, g, b);
    }
    else if (token[0].equals("rect")) {
      float x0 = float(token[1]);
      float y0 = float(token[2]);
      float x1 = float(token[3]);
      float y1 = float(token[4]);
      rect(x0, screen_height-y1, x1-x0, y1-y0);
    }
    else if (token[0].equals("read")) {
      interpreter (token[1]);
    }
    else if (token[0].equals("write")) {
      // render the scene
      pushMatrix();
      translate (gmat[3], gmat[7], gmat[11]);
      render_scene();
      popMatrix();
      // save the current image to a .png file
      save(token[1]);  
    }
  }
}

//  Draw frames.  Should be left empty.
void draw() {
}

// when mouse is pressed, print the cursor location
void mousePressed() {
  println ("mouse: " + mouseX + " " + mouseY);
}