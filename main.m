clear; clc; close all;

params = parameters();

[alpha_matrix, beta_matrix] = generate3DProfileWithMatrixOutput( ...
    params.n, params.w, params.starting_points, params.r, params.f);

plot3DPathWithMultipleStarts(alpha_matrix, beta_matrix, ...
    params.n, params.w, params.csv_filename);
    
render_stl_from_csv(params.csv_filename, params.w);
