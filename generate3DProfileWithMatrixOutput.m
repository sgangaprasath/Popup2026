function [alpha_matrix, beta_matrix] = generate3DProfileWithMatrixOutput(n, w, starting_points, r_array, f_handle)
%function [alpha_matrix, beta_matrix] = generate3DProfileWithMatrixOutput(n, w, starting_points, r_array, f_handle)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This function generates alpha and beta matrices using optimization
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Initialize output matrices
    alpha_matrix = zeros(n,n);
    beta_matrix  = zeros(n,n);

    % Initialize arrays for plotting
    x_coords = [];
    y_coords = [];
    z_coords = [];
    neg_z_coords = [];

    % Loop over all layers
    for i = 1:(7*n-1)

        % Current radius
        current_r = r_array(i);

        % Solve optimization
        [optimal_alpha, optimal_beta] = optimizeCylinder(n, current_r, f_handle);

        % Store results
        alpha_matrix(:, i) = optimal_alpha;
        beta_matrix(:, i)  = optimal_beta;

        % Store for visualization
        z_coords = [z_coords, starting_points(i) * ones(1,n)];
        x_coords = [x_coords, optimal_alpha];
        y_coords = [y_coords, optimal_beta];

        %neg_z_coords = [neg_z_coords, -starting_points(i) * ones(1,n)];
    end

    % Display matrices
    disp('Alpha Matrix:');
    disp(alpha_matrix);

    disp('Beta Matrix:');
    disp(beta_matrix);

    % Plot 3D profile
    figure;
    scatter3(x_coords, y_coords, z_coords, 50, z_coords, 'filled'); hold on;
    %scatter3(x_coords,y_coords,neg_z_coords,50,neg_z_coords,'filled');
    colormap('parula'); colorbar;

    xlabel('Alpha (X)');
    ylabel('Beta (Y)');
    zlabel('Starting Points (Z)');
    title('3D Profile');

    grid on;

end
