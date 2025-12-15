$fn = 128;

/* [Bin Parameters] */

bin_width = 100;
bin_depth = 40;
bin_height = 40;

wall_thickness = 2;
floor_thickness = 2;

// You can subdivide the bin into sub-bins along its width and depth.
width_sub_bins = 1;
depth_sub_bins = 1;
sub_bin_wall_thickness = 2;

/* [Snap Parameters] */

// openGrid snap type for connecting to base plates.
snap_type = "Directional"; // [Lite, Full, Directional]

// The number of snaps to position along the connecting face of the bin.
// The snaps will be evenly spaced with one openGrid cell between them, grouped in the center of the connecting face.
// A value of `-1` means that the maximum number of snaps will be used.
preferred_snap_count = 10;

// The fitment affects the tightness of the snap when mounted (ease of removing the peg)
// Use a value between 0.0 and 1.0, with 0.5 meaning a standard fit.
// A value between 0.66-0.75 would be a tight fit, and a value of 1.0 would be very difficult to insert and remove.
snap_fitment = 0.5;

// The standoff distance between the snap and the bin wall.
// The default is 0.5mm, but if your bin has trouble snapping to your board,
// (especially for lite snaps), consider adding 0.5mm-1.0mm of standoff.
snap_standoff = 0.5;

/* [Hidden] */

/*///////////////////////////
    BIN
*////////////////////////////

wall_chamfer_outer = wall_thickness * 1.5;
wall_chamfer_inner = wall_thickness;
lip_chamfer = wall_thickness/2;

module bin() {
	polyhedron(
		points = [
			/* SW Corner */ 
		
			// SW bottom outer corner
				/* 00 */ [wall_chamfer_outer, wall_chamfer_outer, 0], // bottom
				/* 01 */ [wall_chamfer_outer, 0, wall_chamfer_outer], // S
				/* 02 */ [0, wall_chamfer_outer, wall_chamfer_outer], // W
			
			// SW top/lip corner, S seam
				/* 03 */ [wall_chamfer_outer, 0, bin_height - lip_chamfer], // outer
				/* 04 */ [wall_chamfer_outer + wall_thickness/4, wall_thickness/2, bin_height], // top
				/* 05 */ [wall_chamfer_outer + wall_thickness/2, wall_thickness, bin_height - lip_chamfer], // inner
			
			// SW top/lip corner, W seam
				/* 06 */ [0, wall_chamfer_outer, bin_height - lip_chamfer], // outer
				/* 07 */ [wall_thickness/2, wall_chamfer_outer + wall_thickness/4, bin_height], // top
				/* 08 */ [wall_thickness, wall_chamfer_outer + wall_thickness/2, bin_height - lip_chamfer], // inner
			
			// SW bottom inner corner
				/* 09 */ [wall_chamfer_outer + wall_thickness/2, wall_thickness, floor_thickness + wall_chamfer_inner], // S
				/* 10 */ [wall_thickness, wall_chamfer_outer + wall_thickness/2, floor_thickness + wall_chamfer_inner], // W
				/* 11 */ [wall_thickness + wall_chamfer_inner, wall_thickness + wall_chamfer_inner, floor_thickness], // bottom
			
			/* NW Corner */
			
			// NW bottom outer corner
				/* 12 */ [wall_chamfer_outer, bin_depth - wall_chamfer_outer, 0], // bottom
				/* 13 */ [0, bin_depth - wall_chamfer_outer, wall_chamfer_outer], // W
				/* 14 */ [wall_chamfer_outer, bin_depth, wall_chamfer_outer], // N
			
			// NW top/lip corner, W seam
				/* 15 */ [0, bin_depth - wall_chamfer_outer, bin_height - lip_chamfer], // outer
				/* 16 */ [wall_thickness/2, bin_depth - (wall_chamfer_outer + wall_thickness/4), bin_height], // top
				/* 17 */ [wall_thickness, bin_depth - (wall_chamfer_outer + wall_thickness/2), bin_height - lip_chamfer], // inner
			
			// NW top/lip corner, N seam
				/* 18 */ [wall_chamfer_outer, bin_depth, bin_height - lip_chamfer], // outer
				/* 19 */ [wall_chamfer_outer + wall_thickness/4, bin_depth - wall_thickness/2, bin_height], // top
				/* 20 */ [wall_chamfer_outer + wall_thickness/2, bin_depth - wall_thickness, bin_height - lip_chamfer], // inner
			
			// NW bottom inner corner
				/* 21 */ [wall_thickness, bin_depth - (wall_chamfer_outer + wall_thickness/2), floor_thickness + wall_chamfer_inner], // W
				/* 22 */ [wall_thickness + wall_chamfer_inner, bin_depth - wall_thickness, floor_thickness + wall_chamfer_inner], // N
				/* 23 */ [wall_thickness + wall_chamfer_inner, bin_depth - (wall_thickness + wall_chamfer_inner), floor_thickness], // bottom
			
			/* NE Corner */
			
			// NE bottom outer corner
				/* 24 */ [bin_width - wall_chamfer_outer, bin_depth - wall_chamfer_outer, 0], // bottom
				/* 25 */ [bin_width, bin_depth - wall_chamfer_outer, wall_chamfer_outer], // E
				/* 26 */ [bin_width - wall_chamfer_outer, bin_depth, wall_chamfer_outer], // N
			
			// NE top/lip corner, E seam 
				/* 27 */ [bin_width, bin_depth - wall_chamfer_outer, bin_height - lip_chamfer], // outer
				/* 28 */ [bin_width - wall_thickness/2, bin_depth - (wall_chamfer_outer + wall_thickness/4), bin_height], // top
				/* 29 */ [bin_width - wall_thickness, bin_depth - (wall_chamfer_outer + wall_thickness/2), bin_height - lip_chamfer], // inner
			
			// NE top/lip corner, N seam
				/* 30 */ [bin_width - wall_chamfer_outer, bin_depth, bin_height - lip_chamfer], // outer
				/* 31 */ [bin_width - (wall_chamfer_outer + wall_thickness/4), bin_depth - wall_thickness/2, bin_height], // top
				/* 32 */ [bin_width - (wall_chamfer_outer + wall_thickness/2), bin_depth - wall_thickness, bin_height - lip_chamfer], // inner
			
			// NE bottom inner corner
				/* 33 */ [bin_width - wall_thickness, bin_depth - (wall_chamfer_outer + wall_thickness/2), floor_thickness + wall_chamfer_inner], // E
				/* 34 */ [bin_width - (wall_chamfer_outer + wall_thickness/2), bin_depth - wall_thickness, floor_thickness + wall_chamfer_inner], // N
				/* 35 */ [bin_width - (wall_thickness + wall_chamfer_inner), bin_depth - (wall_thickness + wall_chamfer_inner), floor_thickness], // bottom
			
			/* SE Corner */
			
			// SE bottom outer corner
				/* 36 */ [bin_width - wall_chamfer_outer, wall_chamfer_outer, 0], // bottom
				/* 37 */ [bin_width - wall_chamfer_outer, 0, wall_chamfer_outer], // S
				/* 38 */ [bin_width, wall_chamfer_outer, wall_chamfer_outer], // E
			
			// SE top/lip corner, S seam
				/* 39 */ [bin_width - wall_chamfer_outer, 0, bin_height - lip_chamfer], // outer
				/* 40 */ [bin_width - (wall_chamfer_outer + wall_thickness/4), wall_thickness/2, bin_height], // top
				/* 41 */ [bin_width - (wall_chamfer_outer + wall_thickness/2), wall_thickness, bin_height - lip_chamfer], // inner
			
			// SE top/lip corner, E seam
				/* 42 */ [bin_width, wall_chamfer_outer, bin_height - lip_chamfer], // outer
				/* 43 */ [bin_width - wall_thickness/2, wall_chamfer_outer + wall_thickness/4, bin_height], // top
				/* 44 */ [bin_width - wall_thickness, wall_chamfer_outer + wall_thickness/2, bin_height - lip_chamfer], // inner
			
			// SE bottom inner corner
				/* 45 */ [bin_width - (wall_chamfer_outer + wall_thickness/2), wall_thickness, floor_thickness + wall_chamfer_inner], // S
				/* 46 */ [bin_width - wall_thickness, wall_chamfer_outer + wall_thickness/2, floor_thickness + wall_chamfer_inner], // E
				/* 47 */ [bin_width - (wall_thickness + wall_chamfer_inner), wall_thickness + wall_chamfer_inner, floor_thickness], // bottom
		],
		faces = [
			// SW Corner
			[0, 1, 2],	        // outer bottom face 
			[1, 3, 6, 2],       // outer face
			[3, 4, 7, 6],       // outer lip
			[4, 5, 8, 7],       // inner lip
			[5, 9, 10, 8],      // inner face
			[9, 11, 10],        // inner bottom face
			
			// W Wall
            [0, 2, 13, 12],     // outer bottom face
            [2, 6, 15, 13],     // outer face
            [6, 7, 16, 15],     // outer lip
            [7, 8, 17, 16],     // inner lip
            [8, 10, 21, 17],    // inner face
            [10, 11, 23, 21],   // inner bottom face 
			
			// NW Corner
			[12, 13, 14],       // outer bottom face
			[13, 15, 18, 14],   // outer face
			[15, 16, 19, 18],   // outer lip
			[16, 17, 20, 19],   // inner lip
			[17, 21, 22, 20],   // inner face
			[23, 22, 21],       // inner bottom face
			
			// N Face
            [14, 26, 24, 12],   // outer bottom face
			[18, 30, 26, 14],   // outer face
			[18, 19, 31, 30],   // outer lip
			[19, 20, 32, 31],   // inner lip
			[20, 22, 34, 32],   // inner face
			[22, 23, 35, 34],   // inner bottom face
			
			// NE Corner
            [26, 25, 24],       // outer bottom face
			[25, 26, 30, 27],   // outer face
			[30, 31, 28, 27],   // outer lip
			[31, 32, 29, 28],   // inner lip
			[32, 34, 33, 29],   // inner face
			[33, 34, 35],       // inner bottom face
			
			// E Face
            [24, 25, 38, 36],   // outer bottom face
			[25, 27, 42, 38],   // outer face
			[27, 28, 43, 42],   // outer lip
			[28, 29, 44, 43],   // inner lip
			[29, 33, 46, 44],   // inner face
			[33, 35, 47, 46],   // inner bottom face
			
			// SE Corner
            [38, 37, 36],       // outer bottom face
			[38, 42, 39, 37],   // outer face
			[42, 43, 40, 39],   // outer lip
			[43, 44, 41, 40],   // inner lip
			[46, 45, 41, 44],   // inner face
			[45, 46, 47],       // inner bottom face
			
			// S Face
            [0, 36, 37, 1],    // outer bottom face
			[1, 37, 39, 3],     // outer face
			[4, 3, 39, 40],     // outer lip
			[5, 4, 40, 41],     // inner lip
			[9, 5, 41, 45],     // inner face
			[11, 9, 45, 47],    // inner bottom face
            
            // Bottom/outer face
            [0, 12, 24, 36],
            
            // Top/inner face
			[11, 47, 35, 23]
		]
	);
};

module bin_divider(length) {
    inset = wall_thickness/2;
    adjusted_length = length - wall_thickness;
    sub_bin_lip_chamfer = sub_bin_wall_thickness/2;
    height = min(bin_height, bin_height - (lip_chamfer - sub_bin_wall_thickness/2));
    
    polyhedron(
        points = [
            [inset, sub_bin_wall_thickness/2, height], // lip W
            [inset, 0, height - sub_bin_lip_chamfer], // front NW
            [inset, 0, wall_chamfer_inner], // front WSW
            [inset + wall_chamfer_inner, 0, 0], // front SSW
            [length - wall_chamfer_inner, 0, 0], // front SSE
            [length, 0, wall_chamfer_inner], // front ESE
            [length, 0, height - sub_bin_lip_chamfer], // front NE
            [length, sub_bin_wall_thickness/2, height], // lip E
            [length, sub_bin_wall_thickness, height - sub_bin_lip_chamfer], // rear NE
            [length, sub_bin_wall_thickness, wall_chamfer_inner], // rear ESE
            [length - wall_chamfer_inner, sub_bin_wall_thickness, 0], // rear SSE
            [inset + wall_chamfer_inner, sub_bin_wall_thickness, 0], // rear SSW
            [inset, sub_bin_wall_thickness, wall_chamfer_inner], // rear WSW
            [inset, sub_bin_wall_thickness, height - sub_bin_lip_chamfer], // rear NW
        ],
        
        faces = [
            [0, 1, 6, 7], // front lip
            [1, 2, 3, 4, 5, 6], // front face
            [7, 8, 13, 0], // rear lip
            [8, 9, 10, 11, 12, 13], // rear face
            [0, 1, 2, 12, 13], // W edge
            [5, 6, 7, 8, 9], // E edge
            [2, 3, 11, 12], // W bottom chamfer
            [4, 5, 9, 10], // E bottom chamfer
            [3, 4, 10, 11], // bottom edge
        ]
    );
};

///////////////////////////////////////////////////
//
//  Opengrid ParaSnap
//
///////////////////////////////////////////////////

/* [Configuration Parameters] */

// openGrid snap type for connecting to base plates.
SNAP_TYPE = "Full"; // [Lite, Full, Directional]

TOL = 0.1; // Tolerance; general tolerance for fitting parts together
EPS = 0.01; // Epsilon; used for ensuring manifold geometry during boolean operations

// Hides the rest of the file from MakerWorld Parametric Model Maker main parameter view
/* [Hidden] */

/* [Internal Parameters] */

CELL_WIDTH = 28;
SNAP_WIDTH = 25;
SNAP_MARGIN = (CELL_WIDTH - SNAP_WIDTH) / 2; // thickness of one cell's portion of the wall
SNAP_HEIGHT_FULL = 6.8;
SNAP_HEIGHT_LITE = 3.4;
SNAP_HEIGHT = SNAP_TYPE == "Lite" ? SNAP_HEIGHT_LITE : SNAP_HEIGHT_FULL;
CORNER_CHAMFER = 4.8184; // adjacent edge length for chamfered corners
CORNER_OVERHANG_INSET = 3.2627; // distance from snap edge to edge of chamfer overhang
CORNER_OVERHANG_ROOF_HEIGHT = 0.4; // thickness of the chamfer overhang roof
CORNER_OVERHANG_SLOPE_HEIGHT = 1.1; // height of the chamfer overhang's sloping face
CORNER_OVERHANG_HEIGHT = CORNER_OVERHANG_ROOF_HEIGHT + CORNER_OVERHANG_SLOPE_HEIGHT;
CHAMFERED_EDGE_LENGTH = 6.8142; // length (hypotenuse) of chamfered corner edge
EDGE_LENGTH = 15.1632; // length of N/S/W/E edges after corner chamfer
NUB_THICKNESS = 0.4; // thickness of the snap nubs (thicker = tighter fit)

// For strength (at a sacrifice of printability) the rings can be embedded in the snap body
SNAP_RING_EMBED = true;

SNAP_RING_MAJOR_RADIUS = 6;
SNAP_RING_MINOR_RADIUS = 0.75;
SNAP_RING_SECTION_RADIUS = 0.5;
SNAP_RING_SECTION_SIDES = 8;
SNAP_RING_SECTION_ROTATION = 0;

// Scale factor for snap ring, computed based on embed mode and snap type
SNAP_RING_SCALE_FACTOR = 
  (SNAP_RING_EMBED && SNAP_TYPE == "Lite") ? [1, 1, 2] :           // Embedded Lite: nub height 1.6mm
  (!SNAP_RING_EMBED && SNAP_TYPE == "Lite") ? [1, 1, 1.73183] :    // Insert Lite: nub height 2.0mm
  (SNAP_RING_EMBED && SNAP_TYPE != "Lite") ? [1, 1, 4.5] :         // Embedded Full: 
  [1, 1, 3.5];                                                     // Insert Full: 

SNAP_RING_SEGMENTS = 100;

/* [Helper Functions] */

// Computes the height of a regular polygon cross-section
// For even sides: flat-to-flat = 2 * r * cos(180/n)
// For odd sides: flat-to-vertex = r * (1 + cos(180/n))
function section_height(r, n) = 
  (n % 2 == 0) 
    ? 2 * r * cos(180 / n)      // even: flat-to-flat
    : r * (1 + cos(180 / n));   // odd: flat-to-vertex

// Computes the bounding box of an elliptical torus as [width, depth, height]
function elliptical_torus_bounds(major_radius, minor_radius, section_radius, section_sides, scale_factor = [1, 1, 1]) = 
  [
    2 * (major_radius + section_radius) * scale_factor[0],          // width (X)
    2 * (minor_radius + section_radius) * scale_factor[1],          // depth (Y)
    section_height(section_radius, section_sides) * scale_factor[2] // height (Z)
  ];

/* [Modules] */

// Snap Octagonal Profile - Generates a 2D octagonal profile for the snap body, used in extrusion
//
// Parameters:
//   width - overall width of the octagon
//   chamfer - adjacent (x, y) length of chamfered corner edges

module snap_octagonal_profile(width, chamfer) {
  polygon(
    points = [
      [chamfer, 0],
      [width - chamfer, 0],
      [width, chamfer],
      [width, width - chamfer],
      [width - chamfer, width],
      [chamfer, width],
      [0, width - chamfer],
      [0, chamfer]
    ],
    paths = [[0,1,2,3,4,5,6,7]]
  );
}

// Snap Body - Generates the main octagonal solid body of an openGrid snap
//
// Parameters:
//   type - snap type: "Lite", "Full", or "Directional"

module snap_body(type = SNAP_TYPE) {
  offset = (SNAP_WIDTH - (SNAP_WIDTH)) / 2;

  hull() {
    translate([0, 0, -EPS])
      linear_extrude(height = EPS)
        snap_octagonal_profile(width = SNAP_WIDTH, chamfer = CORNER_CHAMFER);
    translate([offset, offset, -SNAP_HEIGHT])
      linear_extrude(height = EPS)
        snap_octagonal_profile(width = SNAP_WIDTH, chamfer = CORNER_CHAMFER);
  }
}

// Snap Overhang - Generates the chamfered overhang from the corners of an openGrid snap
// Parameters:
//   none

module snap_overhang() {
  // === Overhang Roof ===
  translate([0, 0, CORNER_OVERHANG_SLOPE_HEIGHT])
    linear_extrude(height = CORNER_OVERHANG_ROOF_HEIGHT)
      snap_octagonal_profile(width = SNAP_WIDTH, chamfer = CORNER_OVERHANG_INSET);
  // === Overhang Slope ===
  hull() {
    translate([0, 0, 0])
      linear_extrude(height = EPS)
        snap_octagonal_profile(width = SNAP_WIDTH, chamfer = CORNER_CHAMFER);
    translate([0, 0, CORNER_OVERHANG_SLOPE_HEIGHT])
      linear_extrude(height = EPS)
        snap_octagonal_profile(width = SNAP_WIDTH, chamfer = CORNER_OVERHANG_INSET);
  }
}

// Octagonal Elliptical Torus
// A torus-like shape with:
//   - Elliptical sweep path (cat's eye / squished donut)
//   - Octagonal cross-section with flat face on build plate
//
// Parameters:
//   major_radius - ellipse radius along X axis (the "wide" direction)
//   minor_radius - ellipse radius along Y axis (the "narrow" direction)
//   section_sides - number of sides for the cross-sectional shape (default: 8 for octagon)
//   section_radius - circumradius of the cross-sectional shape
//   section_rotation - rotate the cross-section around the sweep axis (0 = flat on bottom
//   segments - smoothness of the elliptical path

module elliptical_torus(
  major_radius = 30,
  minor_radius = 20,
  section_sides = 8,
  section_radius = 5,
  section_rotation = 0,
  segments = 200,
  scale_factor = [1, 1, 1],
  fill = false
) {
  step = 360 / segments;

  // Debug: echo the bounding box
  _bounds = elliptical_torus_bounds(major_radius, minor_radius, section_radius, 
                                    section_sides, scale_factor = scale_factor);
  echo(str("elliptical_torus bounding box - width (X): ", _bounds[0],
           ", depth (Y): ", _bounds[1], ", height (Z): ", _bounds[2]));

  // Helper module: creates a thin slice of the cross-section polygon
  // positioned at angle 'a' on the ellipse, oriented perpendicular to the path
  module slice(a) {
    // Position on ellipse
    px = major_radius * cos(a);
    py = minor_radius * sin(a);
    
    // Tangent direction (derivative of ellipse parametric form)
    tx = -major_radius * sin(a);
    ty = minor_radius * cos(a);
    
    // Angle of tangent in XY plane
    tangent_angle = atan2(ty, tx);
    
    translate([px, py, 0])
      rotate([0, 0, tangent_angle])
      rotate([0, 90, 0])
      rotate([0, 0, section_rotation + 180/section_sides]) // flat face on bottom
      linear_extrude(height = EPS, center = true)
        circle(r = section_radius, $fn = section_sides);
  }

  scale(scale_factor)
    // Union of hulled pairs of adjacent slices
    if (fill) {
      // Hull all slices together to fill the center
      hull() {
        for (i = [0 : segments - 1]) {
          slice(i * step);
        }
      }
    } else {
      // Hull only adjacent pairs for hollow torus
      union() {
        for (i = [0 : segments - 1]) {
          a1 = i * step;
          a2 = (i + 1) * step;
          hull() {
            slice(a1);
            slice(a2);
          }
        }
      }
    }
}

// Smear - Creates a hull between two copies of the child geometry
// Used for making elongated shapes by "smearing" along the Y axis
// Parameters:
//   y_distance - distance to move the second copy along the Y axis
//   scale_factor - scaling to apply to both copies (default: [1, 1, 1])

module smear(y_distance, scale_factor = [1, 1, 1]) {
  hull() {
    translate([0, 0, 0])
      scale(scale_factor)
        children();
    translate([0, y_distance, 0])
      scale(scale_factor)
        children();
  }
}

// Snap Ring - Generates the octagonal elliptical torus used for snap nubs
// Parameters:
//   none

module snap_ring() {
  elliptical_torus(
    major_radius = SNAP_RING_MAJOR_RADIUS,
    minor_radius = SNAP_RING_MINOR_RADIUS,
    section_sides = SNAP_RING_SECTION_SIDES,
    section_radius = SNAP_RING_SECTION_RADIUS,
    section_rotation = SNAP_RING_SECTION_ROTATION,
    segments = SNAP_RING_SEGMENTS,
    scale_factor = SNAP_RING_SCALE_FACTOR,
    fill = false
  );
}

// Snap Ring Cutter - Generates a cutter shape for creating the snap ring cutouts
// Parameters:
//   none

module snap_ring_cutter() {
  smear(y_distance = -3, scale_factor = [1, 1, 1])
    snap_ring();
}

// Grid Support Tower - Replacement for slicer-generated support tower
// 
// Parameters:
//   length, width, height - outer dimensions of the support tower
//   outer_wall_thickness - perimeter wall thickness (default: 0.4mm, typical nozzle width)
//   grid_spacing - distance between grid lines (default: 2.5mm)
//   inner_wall_thickness - thickness of internal grid lines (default: 0.4mm)
//   interface_thickness - height of denser top interface (default: 0.6mm, ~3 layers)
//   interface_density - spacing for top interface grid (default: 0.8mm)

module grid_support_tower(
    length,
    width,
    height,
    outer_wall_thickness = 0.4,
    grid_spacing = 2.5,
    inner_wall_thickness = 1,
    interface_thickness = 0.6
) {
    // Main body height (excluding interface)
    body_height = max(0, height - interface_thickness);
    
    // Internal dimensions
    inner_length = length - 2 * outer_wall_thickness;
    inner_width = width - 2 * outer_wall_thickness;
    
    union() {
        // === MAIN SUPPORT BODY ===
        if (body_height > 0) {
            // Outer perimeter walls (hollow box)
            difference() {
                cube([length, width, body_height]);
                translate([outer_wall_thickness, outer_wall_thickness, -0.01])
                    cube([inner_length, inner_width, body_height + 0.02]);
            }
            
            // Internal grid - X direction lines
            if (inner_length > 0 && inner_width > 0) {
                translate([outer_wall_thickness, outer_wall_thickness, 0]) {
                    // Lines parallel to X axis
                    for (y = [grid_spacing : grid_spacing : inner_width - inner_wall_thickness]) {
                        translate([0, y - inner_wall_thickness/2, 0])
                            cube([inner_length, inner_wall_thickness, body_height]);
                    }
                    
                    // Lines parallel to Y axis
                    for (x = [grid_spacing : grid_spacing : inner_length - inner_wall_thickness]) {
                        translate([x - inner_wall_thickness/2, 0, 0])
                            cube([inner_wall_thickness, inner_width, body_height]);
                    }
                }
            }
        }
        
        // === TOP INTERFACE LAYER ===
        // Denser grid for better part support at the top
        if (interface_thickness > 0) {
            translate([0, 0, body_height]) {
                // Solid top layer
                cube([length, width, interface_thickness]);
            }
        }
    }
}

/* [Assembly] */

module positioned_rings() {

  ring_bounds = elliptical_torus_bounds(
    major_radius = SNAP_RING_MAJOR_RADIUS,
    minor_radius = SNAP_RING_MINOR_RADIUS,
    section_radius = SNAP_RING_SECTION_RADIUS,
    section_sides = SNAP_RING_SECTION_SIDES,
    scale_factor = SNAP_RING_SCALE_FACTOR
  );

  cutter_inset = ring_bounds[1]/2 - NUB_THICKNESS;
  cutter_nudge_z = -ring_bounds[2]/2 - CORNER_OVERHANG_HEIGHT;

  // Bottom cutter for snap ring
  translate([SNAP_WIDTH/2, cutter_inset, cutter_nudge_z])
    if (SNAP_RING_EMBED) snap_ring(); else snap_ring_cutter();
  // Top cutter for snap ring
  translate([SNAP_WIDTH/2, SNAP_WIDTH - cutter_inset, cutter_nudge_z])
    rotate([0, 0, 180])
      if (SNAP_RING_EMBED) snap_ring(); else snap_ring_cutter();
  // Left cutter for snap ring
  translate([cutter_inset, SNAP_WIDTH/2, cutter_nudge_z])
    rotate([0, 0, -90])
      if (SNAP_RING_EMBED) snap_ring(); else snap_ring_cutter();
  // Right cutter for snap ring
  translate([SNAP_WIDTH - cutter_inset, SNAP_WIDTH/2, cutter_nudge_z])
    rotate([0, 0, 90])
      if (SNAP_RING_EMBED) snap_ring(); else snap_ring_cutter();
}

// ParaSnap - Complete openGrid ParaSnap module
// Parameters:
//   type - snap type: "Lite", "Full", or "Directional"

module para_snap(type = SNAP_TYPE) {
  render()
    union() {
      difference() {
        #union() {
          translate([0, 0, -CORNER_OVERHANG_HEIGHT])
            snap_overhang();
          snap_body(type = SNAP_TYPE);
        }
        if (!SNAP_RING_EMBED) {
          positioned_rings();
        }
      }
      if (SNAP_RING_EMBED) {
        positioned_rings();
      }
    }
}

/*///////////////////////////
    ASSEMBLY MODULES
*////////////////////////////

module positioned_snaps() {

    // Figure out how many snaps to place, and their spacing
    snap_surface_width = bin_width - (wall_chamfer_outer * 2);
    cell_count = floor(snap_surface_width / CELL_WIDTH);
    cell_count_is_even = cell_count % 2 == 0 ? true : false;
    max_snap_count = cell_count_is_even ? floor(cell_count/2) : floor(cell_count/2) + 1; // max number of snaps that we could fit with gaps between
    user_snap_count = preferred_snap_count == -1 ? max_snap_count : preferred_snap_count; // user's preferred snap count (max if -1)
    snap_count = min(max_snap_count, user_snap_count); // resolved actual number of snaps to use
    snap_count_is_even = snap_count % 2 == 0 ? true : false;

    // echo(str("Snap surface width: ", snap_surface_width));
    // echo(str("Cell count: ", cell_count));
    // echo(str("Max snap count: ", max_snap_count));
    // echo(str("User snap count: ", user_snap_count));
    // echo(str("Snap count: ", snap_count));
    // echo(str("Snap count is even: ", snap_count_is_even));

    snap_object_overlap = 0.1; // to ensure manifold geometry during boolean operations

    snap_group_width = snap_count_is_even ? (CELL_WIDTH * snap_count * 2) - CELL_WIDTH : (CELL_WIDTH * snap_count * 2);
    snap_group_offset = snap_count_is_even ? (snap_surface_width - snap_group_width) / 2 + wall_chamfer_outer : (snap_surface_width - snap_group_width) / 2 + wall_chamfer_outer + CELL_WIDTH/2;
    
    translate([snap_group_offset, -EPS, bin_height - CELL_WIDTH])
        for (i = [0 : snap_count - 1]) {
            translate([(CELL_WIDTH)*2*i + SNAP_MARGIN, 0, 0])
                rotate([90, 0 , 0])
                    para_snap(type = SNAP_TYPE);
        }
};

module positioned_bin() {
    translate([0, -bin_depth, 0])
        bin();
};

module positioned_dividers() {
    inner_width = bin_width - sub_bin_wall_thickness*(width_sub_bins+1);
    width_gap = inner_width / width_sub_bins;
    inner_depth = bin_depth - sub_bin_wall_thickness*2;
    depth_gap = inner_depth / depth_sub_bins;

    if (width_sub_bins > 1) {
        for (i = [1 : width_sub_bins - 1]) {
            translate([wall_thickness + width_gap*i + sub_bin_wall_thickness*(i-1), 0, 0])
                rotate([0, 0, -90])
                    bin_divider(length = bin_depth - wall_thickness/2);
        }
    }
    
    if (depth_sub_bins > 1) {
        for (i = [1 : depth_sub_bins - 1]) {
            translate([0, -wall_thickness - depth_gap*i - sub_bin_wall_thickness*(i-1), 0])
                bin_divider(length = bin_width - wall_thickness/2);
        }
    }
};

// Final Product
union() {
    render(convexity = 10) positioned_snaps();
    render(convexity = 10) positioned_bin();
    positioned_dividers();
};
