# Geometry and design of popup structures

This project builds a 3D popup-structure using optimization, converts it into line geometry, and finally generates STL files for different deployment angles.

## Reference

For theoretical details, please refer to the following article. If you use these codes to generate popup design, please cite:

> Chavda, J. J. & Prasath, S. G. (2026). *Geometry and design of popup structures*. arXiv:2603.07067

---

# 🔁 COMPLETE EXECUTION FLOW

main.m  
→ parameters.m  
→ generate3DProfileWithMatrixOutput.m  
→ optimizeCylinder.m  
→ plot3DPathWithMultipleStarts.m  
→ CSV file  
→ render_stl_from_csv.m  
→ STL files  

---

# 1. main.m

This is the main driver.

Steps:
1. Calls `parameters()` → loads all inputs
2. Calls geometry generator → gets alpha & beta matrices (described below)
3. Calls plotting function → builds full popup-structure
4. Calls rendering → converts to STL

Key idea:
This file **does not compute anything itself**, it just connects all modules.

---

# 2. parameters.m

This file defines ALL inputs used in the system.

## Variables

### n
Number of layers (controls resolution of structure)

---

### w (width vector)
Defines spacing between layers.

Used in:
- Z-direction increments
- STL thickness

---

### starting_points
Computed as:
starting_points = [0, cumsum(w(1:end-1))]

Meaning:
Each layer starts at cumulative height.

---

### r (radius profile)

Defines shape of surface.

Example:
r = sqrt(abs(5 + starting_points.^2))

This controls how the structure bends.

---

### f (constraint function)

Defines relationship between alpha and beta.

Example:
f(x, r) → gives allowed beta for given alpha

Used inside optimization as nonlinear constraint.

---

### csv_filename

File where geometry is stored after plotting.

---

# 3. generate3DProfileWithMatrixOutput.m

This builds the core geometry.

## Goal:
Compute alpha and beta values for each layer.

---

## Important Interpretation:

alpha → x-coordinate of fold vertex  
beta → y-coordinate of fold vertex  

So each pair (alpha, beta) represents the **2D position of a fold vertex** in the cut-fold pattern.

---

## Process:

Loop:
for i = 1:(7*n - 1)

For each layer:
1. Get radius r(i)
2. Call optimization
3. Store results

---

## Output:

alpha_matrix (n × layers)  
beta_matrix (n × layers)

Each column = one vertical slice of structure  
Each row = a fold vertex position (x = alpha, y = beta)

---

## Visualization:

Also creates scatter plot:
(x = alpha, y = beta, z = starting_points)

---

# 4. optimizeCylinder.m

This is the **most important part (optimization)**.

Uses:
fmincon()

---

## Variables:

vars = [alpha(1:n), beta(1:n)]

Here:
- alpha → x-coordinates of fold vertices  
- beta → y-coordinates of fold vertices  

---

## Objective Function:

Minimizes:

1. Uniform spacing

2. Smoothness:
second differences small

3. Optional geometry constraints:
- First fundamental form
- Second fundamental form

---

## Constraints:

### Linear:
- continuity constraints
- monotonicity

---

### Boundary:
alpha(1) = 0  
beta(1) = 1 - r  
alpha(n) = r  
beta(n) = 1  

---

### Nonlinear:
f(alpha, r) = beta

This enforces geometric shape.

---

## Output:

optimal_alpha  
optimal_beta  

---

# 5. plot3DPathWithMultipleStarts.m

This builds the **actual popup structure**.

---

## Core Idea:

Instead of simple lines,
it builds a **zig-zag branching structure**

---

## Loop Structure:

Outer loop:
for start_col = 1:2:(7*n-1)

→ starts from alternating columns

---

Inner loop:
for i = 1:(n-1)/2

→ builds path step-by-step

---

## At each step:

### Compute:
delta_x  
delta_y  
delta_z  

These define movement in 3D using:
- alpha differences → x-direction  
- beta differences → y-direction  
- layer spacing → z-direction  

---

## Draw lines:

### Green (X-direction)
(x → x + delta_x)

---

### Blue (Y-direction)
(y → y + delta_y)

---

### Red (Z-direction)
(z → z + delta_z)

---

### Yellow (auxiliary structure)
connects branches

---

## Stop condition:

if delta_x < 0:
→ stop branch

This prevents invalid geometry.

---

## Data storage:

Each segment stored as:

[x1, y1, z1, x2, y2, z2, length, color, iteration, column, flag, width]

---

## Output:

CSV file containing all segments.

---

# 6. render_stl_from_csv.m

This converts line data into surfaces.

---

## Step 1: Read CSV

Each row = one line segment

---

## Step 2: Convert to rectangles

Each line becomes a strip:

Start → End  
Width → from w  

---

## Step 3: Apply deformation

Uses angle psi:

x' = x + (1 - y)*cos(psi)  
y' = 1 - (1 - y)*sin(psi)  

This simulates deployment.

---

## Step 4: Generate STL

For psi ∈ [0, π/2]:

Loop:
60 steps

Each step:
- update geometry
- triangulate
- export STL

---

## Output:

Folder:
Inverted_sphere/

Files:
model_psi_001.stl  
...  
model_psi_060.stl  

---

# 7. Geometry Representation

Each rectangle → 4 vertices:

V1, V2, V3, V4

Converted into 2 triangles:
[1 2 3]  
[3 2 4]

---

# 8. Summary

This code:

1. Generates fold vertex positions (x = alpha, y = beta)
2. Optimizes shape
3. Builds branching structure
4. Converts lines → surfaces
5. Exports deployable models

---
