$fn = 128;

/* [Peg Parameters] */

peg_body_length = 40;
peg_body_diameter = 20;

// To remove the cap entirely, set its length to 0
peg_cap_length = 2;
peg_cap_diameter = 24;

/* [Snap Parameters] */

// openGrid snap type for connecting to base plates
snap_type = "Full"; // [Lite, Full, Directional]

// The fitment affects the tightness of the snap when mounted (ease of removing the peg)
// Use a value between 0.0 and 1.0, with 0.5 meaning a standard fit.
// A value between 0.66-0.75 would be a tight fit, and a value of 1.0 would be very difficult to insert and remove.
snap_fitment = 0.5;

/* [Hidden] */

/*/////////////////////////
    PARAMETRIC PEG
*//////////////////////////

module torus(main_radius, tube_radius) {
    rotate_extrude() {
        translate([main_radius, 0, 0]) {
            circle(r = tube_radius);
        };
    };
};

module filleted_flange(inner_diameter, outer_diameter) {
    fillet_radius = outer_diameter - inner_diameter;
    torus_radius = min(inner_diameter/2 + fillet_radius, 20);

    difference() {
        cylinder(h = fillet_radius, r = torus_radius);
        
        translate([0, 0, fillet_radius]) {
            torus(main_radius = torus_radius, 
                  tube_radius = fillet_radius - 0.01);
        };
    };
};

module peg_cap(length, diameter) {
    // Peg cap of 0 means no cap, just round off the end
    if (length == 0) {
        sphere_radius = diameter * 0.2;
        adjusted_length = 0.001;
        adjusted_diameter = diameter - sphere_radius*3;
        
        translate([0, 0, 0]) {
            minkowski() {
                // peg cap
                cylinder(h = adjusted_length, d = adjusted_diameter);
                // filleting sphere, sized to make the cap edge round
                sphere(r = sphere_radius);
            };
        };

    } else {
        sphere_radius = length/2;
        adjusted_length = length - sphere_radius;
        adjusted_diameter = diameter - sphere_radius*2;
    
        translate([0, 0, sphere_radius]) {
            minkowski() {
                // peg cap
                cylinder(h = adjusted_length, d = adjusted_diameter);
                // filleting sphere, sized to make the cap edge round
                sphere(r = sphere_radius);
            };
        };
    }
};

module peg(body_length, body_diameter, cap_length, cap_diameter) {   
    union() {

        // peg body
        cylinder(h = body_length, d = body_diameter);
        
        // peg cap (at top of peg body)
        translate([0, 0, body_length]) {
            peg_cap(length = cap_length, diameter = cap_diameter);
        };
        
        // peg cap chamfer
        if (cap_length > 0) {
            chamfer_depth = (cap_diameter - body_diameter)/2;
            translate([0, 0, body_length - chamfer_depth]) {
                cylinder(h = chamfer_depth + cap_length/2 , 
                         d1 = body_diameter, 
                         d2 = body_diameter + chamfer_depth*2);
            };
        };
    };
};

///////////////////////////////////////////////////
//
//  Opengrid ParaSnap
//
///////////////////////////////////////////////////

/* [Configuration Parameters] */

// openGrid snap type for connecting to base plates.
SNAP_TYPE = "Lite"; // [Lite, Full, Directional]

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

/*/////////////////////////
    ASSEMBLE THE SNAP PEG
*//////////////////////////


union() {
    // Bare openGrid Snap
    render()
        para_snap(type = SNAP_TYPE);
    
    translate([12.5, 12.5, 0]) {
        // Fillet at base of peg
        filleted_flange(inner_diameter = peg_body_diameter, 
                        outer_diameter = min(peg_body_diameter*1.33, 22));
        
        // Completed peg with cap
        peg(body_length = peg_body_length, 
            body_diameter = peg_body_diameter,
            cap_length = peg_cap_length,
            cap_diameter = peg_cap_diameter);
    };
};

