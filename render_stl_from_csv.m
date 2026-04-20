function render_stl_from_csv(csv_filename, w)

% ===== ORIGINAL CODE START (UNCHANGED) =====

stl_folder = 'Inverted_sphere';

process_and_save_from_csv(csv_filename, stl_folder, w);

end


function process_and_save_from_csv(csv_filename, stl_folder, w)
    linedata = readmatrix(csv_filename);

    fig = figure;
    ax = axes('Parent', fig);
    hold on;
    xlabel('X-axis'); ylabel('Y-axis'); zlabel('Z-axis');
    title('Rectangles with Varying Angle');
    axis equal;
    grid on;
    view(3);

    if ~exist(stl_folder, 'dir')
        mkdir(stl_folder);
    end

    num_divisions = 60;
    for i = 1:num_divisions
        psi = (i - 1) * (pi/2) / (num_divisions - 1);

        update_plot(ax, linedata, w, psi);
        drawnow;

        stl_filename = fullfile(stl_folder, sprintf('model_psi_%03d.stl', i));

        process_and_export_stl(linedata, w, psi, stl_filename);

        fprintf('Generated STL file %d of %d: %s\n', i, num_divisions, stl_filename);
    end

    fprintf('All STL files generated in: %s\n', stl_folder);
end


function update_plot(ax, linedata, w, psi)
    cla(ax);
    hold(ax, 'on');

    start_points = [
        linedata(:, 1) + (1 - linedata(:, 2)) .* cos(psi), ...
        1 - (1 - linedata(:, 2)) .* sin(psi), ...
        linedata(:, 3)
    ];

    end_points = [
        linedata(:, 4) + (1 - linedata(:, 5)) .* cos(psi), ...
        1 - (1 - linedata(:, 5)) .* sin(psi), ...
        linedata(:, 6)
    ];

    width_indices = linedata(:, 10);
    width_values = w(width_indices)/2;

    width_values1 = nan(size(width_indices));
    for i = 1:length(width_indices)
        idx = width_indices(i);
        if idx >= 3
            sum1 = sum(w(1:idx));
            sum2 = sum(w(1:idx-2));
            term3 = 1.25*w(idx-2);
            term4 = w(idx)/2;
            width_values1(i) = sum1 - sum2 - term3 - term4;
        end
    end

    for i = 1:size(linedata, 1)
        start_point = start_points(i, :);
        end_point = end_points(i, :);
        flag = linedata(i, 11);

        perp_vector = [0, 0, 1];

        if flag == 0
            rect_width = width_values(i);
            V1 = start_point + perp_vector * (rect_width / 2);
            V2 = start_point - perp_vector * (rect_width / 2);
            V3 = end_point + perp_vector * (rect_width / 2);
            V4 = end_point - perp_vector * (rect_width / 2);
        elseif flag == 1
            rect_width = width_values(i);
            rect_width1 = width_values1(i);
            V1 = start_point + perp_vector * (rect_width / 2);
            V2 = start_point - perp_vector * (rect_width1 / 1);
            V3 = end_point + perp_vector * (rect_width / 2);
            V4 = end_point - perp_vector * (rect_width1 / 1);
        else
            continue;
        end

        patch(ax, 'Vertices', [V1; V2; V3; V4], 'Faces', [1 2 3; 3 2 4], ...
            'FaceColor', 'cyan', 'FaceAlpha', 0.5);
    end

    title(ax, sprintf('Angle: %.2f radians', psi));
    hold(ax, 'off');
end


function process_and_export_stl(linedata, w, psi, stl_filename)

    start_points = [
        linedata(:, 1) + (1 - linedata(:, 2)) .* cos(psi), ...
        1 - (1 - linedata(:, 2)) .* sin(psi), ...
        linedata(:, 3)
    ];

    end_points = [
        linedata(:, 4) + (1 - linedata(:, 5)) .* cos(psi), ...
        1 - (1 - linedata(:, 5)) .* sin(psi), ...
        linedata(:, 6)
    ];

    width_indices = linedata(:, 10);
    width_values = w(width_indices)/2;

    width_values1 = nan(size(width_indices));
    for i = 1:length(width_indices)
        idx = width_indices(i);
        if idx >= 3
            sum1 = sum(w(1:idx));
            sum2 = sum(w(1:idx-2));
            term3 = 1.25*w(idx-2);
            term4 = w(idx)/2;
            width_values1(i) = sum1 - sum2 - term3 - term4;
        end
    end

    flags = linedata(:, 11);

    rectangles = [start_points, end_points, width_values(:), width_values1(:), flags(:)];

    triangulate_and_save_rectangles_as_stl(rectangles, stl_filename);
end


function triangulate_and_save_rectangles_as_stl(rectangles, filename)

    all_vertices = [];
    all_faces = [];
    face_offset = 0;

    for i = 1:size(rectangles, 1)

        start_point = rectangles(i, 1:3);
        end_point = rectangles(i, 4:6);
        width = rectangles(i, 7);
        width1 = rectangles(i, 8);
        flag = rectangles(i, 9);

        perp_vector = [0, 0, 1];

        if flag == 0
            V1 = start_point + perp_vector * (width / 2);
            V2 = start_point - perp_vector * (width / 2);
            V3 = end_point + perp_vector * (width / 2);
            V4 = end_point - perp_vector * (width / 2);
        elseif flag == 1
            V1 = start_point + perp_vector * (width / 2);
            V2 = start_point - perp_vector * (width1 / 1);
            V3 = end_point + perp_vector * (width / 2);
            V4 = end_point - perp_vector * (width1 / 1);
        else
            continue;
        end

        vertices = [V1; V2; V3; V4];
        faces = [1 2 3; 3 2 4];

        all_vertices = [all_vertices; vertices];
        all_faces = [all_faces; faces + face_offset];
        face_offset = face_offset + 4;
    end

    write_stl(filename, all_faces, all_vertices);
end


function write_stl(filename, faces, vertices)

    fid = fopen(filename, 'w');
    fprintf(fid, 'solid mesh\n');

    for i = 1:size(faces, 1)
        fprintf(fid, '  facet normal 0 0 0\n');
        fprintf(fid, '    outer loop\n');

        for j = 1:3
            fprintf(fid, '      vertex %f %f %f\n', vertices(faces(i, j), :));
        end

        fprintf(fid, '    endloop\n');
        fprintf(fid, '  endfacet\n');
    end

    fprintf(fid, 'endsolid mesh\n');
    fclose(fid);
end
