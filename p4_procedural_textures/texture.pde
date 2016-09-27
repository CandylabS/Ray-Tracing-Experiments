void noiseTexture(Hit hit, float scale) {
	float shift = noise_3d(hit.pos.x * scale, hit.pos.y * scale, hit.pos.z * scale);
	hit.refl.diffuse = new PVector(shift, shift, shift);
}

void woodTexture(Hit hit) {
	// wood initialization
	PVector wood_diffuse = new PVector(0.353, 0.2, 0);
	PVector wood_ambient = new PVector(0.510, 0.357, 0.122);
	// texture formula
	float shift = sin(noise_3d(hit.pos.x, hit.pos.y, hit.pos.z) * PI * 12) * 0.05;
	hit.refl.diffuse = new PVector(wood_diffuse.x + shift, wood_diffuse.y + shift, wood_diffuse.z + shift);
	hit.refl.ambient = new PVector(wood_ambient.x + shift, wood_ambient.y + shift, wood_ambient.z + shift);
}

void marbleTexture(Hit hit) {
	float freq = PI;
	float peak = 5;
	float a = 25;
	float b = 8;
	float c = 2;
	float shift = sin(freq * ( hit.pos.x + peak * turb(hit, a, b, c)))/5 + 0.25;
  	hit.refl.diffuse = new PVector(shift, shift, shift);
	hit.refl.ambient = new PVector(shift, shift, shift);
}

float turb(Hit hit, float a, float b, float c) {
	float shift1 = noise_3d(hit.pos.x * a, hit.pos.y * a, hit.pos.z * a);
	float shift2 = noise_3d(hit.pos.x * b, hit.pos.y * b, hit.pos.z * b);
	float shift3 = noise_3d(hit.pos.x * c, hit.pos.y * c, hit.pos.z * c);
	float shift = (shift1/a + shift2/b + shift3/c) / (1/a + 1/b + 1/c);
	return shift;
}

void stoneTexture(Hit hit) {
	// crack color
	float delta = 0.05;
	float min_dist = 100;
	PVector base_col = new PVector(0.3, 0.3, 0.3);
	PVector clr = base_col.copy();
	for (int i=0; i<pts.size(); i++) {
		PVector pt = pts.get(i);
		float _dist = dist(hit.pos.x, hit.pos.y, hit.pos.z, pt.x, pt.y, pt.z);
		if (_dist < min_dist) {
      		if ((min_dist - _dist) < delta)
        		clr = new PVector(0.3, 0.3, 0.3);
      		else clr = clrs.get(i);
			min_dist = _dist;
		}
	}

	// between the crack
	float scale = 100;
	float shift = noise_3d(hit.pos.x * scale, hit.pos.y * scale, hit.pos.z * scale) * 0.1;
	hit.refl.diffuse = new PVector(shift + clr.x, shift + clr.y, shift + clr.z);
}

// stone initialization
ArrayList<PVector> pts, clrs;

void init_stone(PVector center, float r){
	// initialize
	pts = new ArrayList<PVector>();
	clrs = new ArrayList<PVector>();
	// crack texture
	int scatter = 100;
	PVector col = new PVector(0.612, 0.741, 0.420);
	for (int i=0; i<scatter; i++) {
		PVector pt = PVector.random3D();
		pt.setMag(r);
		pt.add(center);
		pts.add(pt);
		println(pt);
		float col_noise = noise_3d(pt.x, pt.y, pt.z) / 2;
		PVector clr = new PVector(col.x + col_noise, col.y + col_noise, col.z + col_noise);
		clrs.add(clr);
		println(clr);
	}
}