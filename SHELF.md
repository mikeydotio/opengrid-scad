# OpenGrid Shelf - Architecture Documentation

This document describes the architecture and design of `opengrid-shelf.scad`, which generates shelf components that snap onto openGrid base plates.

## File Organization

The file is organized into four main sections:

```
1. Configuration Parameters (lines 1-18)
2. Hidden/Derived Parameters (lines 19-34)
3. SHELF Module (lines 36-101)
4. OPENGRID SNAP Modules (lines 103-424)
5. FINAL ASSEMBLY (lines 426-469)
```

---

## 1. Configuration Parameters

### Shelf Parameters (lines 3-7)
| Parameter | Default | Description |
|-----------|---------|-------------|
| `shelf_width` | 84mm | Total width. Best as odd multiples of 28mm (112, 196) for side-by-side placement |
| `shelf_depth` | 170mm | Front-to-back depth of shelf tray |

### Snap Parameters (lines 9-17)
| Parameter | Default | Description |
|-----------|---------|-------------|
| `snap_type` | "Directional" | Connection type: "Lite", "Full", or "Directional" |
| `snap_fitment` | 0.66 | Grip tightness 0.0-1.0 (0.5=standard, 0.66-0.75=tight, 1.0=very tight) |

---

## 2. Hidden/Derived Parameters (lines 25-34)

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `shelf_thickness` | 5mm | Thickness of shelf tray floor |
| `shelf_lip_height` | 5mm | Height of lip around tray edge |
| `outer_face_outset` | 3mm | How far outer face extends past tray edge |
| `outer_face_bottom` | 3mm | Z-height where outer face begins |
| `outer_face_top` | 5mm | Z-height where outer face ends |
| `lip_top_height` | 8mm | Total height of lip top |
| `lip_top_thickness` | 2mm | Thickness of lip top rim |
| `tray_edge_inset` | 5mm | Inner tray edge inset (outer_face_outset + lip_top_thickness) |

---

## 3. SHELF Module Architecture

### `shelf_blank()` (lines 36-101)

Creates the shelf tray as a single polyhedron with 24 vertices (6 per corner).

**Vertex Layout (per corner):**
```
Point 0: Bottom face corner
Point 1: Outer face bottom (chamfer start)
Point 2: Outer face top (chamfer end)
Point 3: Lip top outer corner
Point 4: Lip top inner corner
Point 5: Tray surface corner
```

**Corner Order:** SW (0-5) → NW (6-11) → NE (12-17) → SE (18-23)

**Cross-Section Profile:**
```
        ┌─ Lip top (pt 3-4)
        │
   ┌────┘  Inner chamfer (pt 4-5)
   │
   │       Tray surface (pt 5)
   │
   └───────┐  Outer face (pt 1-2)
           │
           └─ Bottom chamfer (pt 0-1)
```

**Face Definitions (lines 73-99):**
- Bottom face: connects all point-0s
- Side faces: W, N, E, S each with outer chamfer, face, top chamfer, lip, inner chamfer
- Top face: connects all point-5s (tray surface)

---

## 4. OPENGRID SNAP Architecture

### Core Dimensions (lines 107-121)
| Parameter | Value | Purpose |
|-----------|-------|---------|
| `cell_width` | 28mm | OpenGrid cell size |
| `snap_width` | 25mm | Snap connector width |
| `snap_wall` | 3mm | Wall between adjacent snaps |
| `snap_margin` | 1.5mm | Half wall (one cell's portion) |
| `long_side_length` | 18.2745mm | Primary box edge length |
| `short_side_length` | 15.1632mm | Corner cutout reference |
| `full_snap_thickness` | 6.8mm | Full snap height |
| `lite_snap_thickness` | 3.4mm | Lite snap height |

### Module Hierarchy

```
opengrid_snap()
├── primary_box()              # Main octagonal body
├── SUBTRACTIVE (difference):
│   ├── large_corner_cutouts() # Corner trimming
│   ├── corner_overhang_cutouts()
│   │   └── corner_overhang_cutout_template() x4
│   ├── bottom_slot_cutouts()
│   │   └── bottom_slot_cutout_template()
│   ├── side_slot_cutouts()
│   ├── triangle_directional_cutout() [Directional only]
│   │   └── triangle_directional_cutout_template()
│   ├── bottom_half_snapfit_cutouts() [Directional only]
│   │   └── bottom_half_snapfit_cutter() x3
│   └── lite_snap_cutout() [Lite only]
└── ADDITIVE (union):
    ├── top_tab()
    │   └── snap_tab_large() or snap_tab_small()
    ├── bottom_tab() → snap_tab_small()
    ├── left_tab() → snap_tab_small()
    └── right_tab() → snap_tab_small()
        └── snap_tab()  # Base parametric tab
```

### Snap Types

| Type | Description | Features |
|------|-------------|----------|
| **Full** | Standard 4-way connection | Full thickness, lite tabs on all 4 sides |
| **Lite** | Reduced height snap | 3.4mm thick, lite tabs on all sides |
| **Directional** | Front-loading snap | Full tab on top, triangle indicator, angled bottom slot, bottom half cutouts |

### Key Submodules

**`primary_box()` (lines 383-397)**
- Creates octagonal base shape via linear extrusion
- 8 vertices forming clipped-corner square

**`snap_tab()` (lines 268-303)**
- Parametric frustum (truncated pyramid)
- Parameters: x_scale, y_scale, z_scale
- Base: 14×4mm, Top: 9.5×2.2mm, Height: 0.8mm (before scaling)

**`snap_tab_large()` / `snap_tab_small()` (lines 305-311)**
- Large: 1.0× scale (used for Directional top)
- Small: 0.8×0.5× scale (used for all other tabs)

**Slot Cutouts (lines 174-266)**
- `bottom_slot_cutouts()`: 4 hull-based rounded slots on bottom face
- `side_slot_cutouts()`: 4 rectangular slots near top edge
- Directional type omits top slots, adds angled bottom slot

---

## 5. Final Assembly (lines 426-469)

### Snap Placement Logic

```
cell_count = floor(shelf_width / 28)
snap_count = alternating placement (every other cell)
gap_count = cells between snaps

For 84mm width:
  cell_count = 3
  snap_count = 2 (cells 0 and 2)
  gap_count = 1 (cell 1)
```

**Placement Formula:**
- Even cell count: snaps at positions 0, 2, 4... offset by `(remainder + 28)/2`
- Odd cell count: snaps at positions 0, 2, 4... offset by `remainder/2`

### Assembly Module

**`snap_chamfer()` (lines 430-442)**
- Creates angled transition between snap and shelf
- Triangular profile extruded across snap width

**Final Union (lines 457-468)**
```
union() {
    shelf_blank()  # Rotated -90° on X, positioned relative to snaps

    for each snap position:
        snap_chamfer()
        opengrid_snap()
}
```

**Shelf Positioning:**
- Translated by `(-outer_snap_offset - snap_margin, snap_width/6, shelf_depth + full_snap_thickness)`
- Rotated -90° on X-axis (shelf stands upright behind snaps)

---

## Design Patterns

### Boolean Operations
The file uses CSG (Constructive Solid Geometry):
- `union()` for combining parts
- `difference()` for cutting holes/slots
- `hull()` for creating rounded slot shapes

### Polyhedron Construction
Both shelf and snap tabs use explicit vertex/face definitions for precise control over geometry, avoiding artifacts from boolean operations on complex shapes.

### Parametric Scaling
The `snap_tab()` module demonstrates parametric design - a single base shape scaled for different uses (large vs small tabs).

---

## Coordinate System

```
        Z (up)
        │
        │   Y (depth/back)
        │  /
        │ /
        └────── X (width/right)

Shelf sits in XY plane, extends in +Y direction
Snaps attach at Y=0 (front edge)
```

---

## Future Enhancement Areas

1. **Bin/Divider Integration** - Internal compartmentalization
2. **Variable Snap Spacing** - Non-uniform snap placement
3. **Parametric Lip Profile** - Customizable edge shapes
4. **Multi-tier Assembly** - Stacking shelf configurations
