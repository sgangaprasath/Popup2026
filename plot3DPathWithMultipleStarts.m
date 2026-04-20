function line_data_optimized = plot3DPathWithMultipleStarts(alpha_matrix, beta_matrix, n,w,csv_filename)
    % Initialize figure
    figure;
    hold on;
    grid on;
    xlabel('X-axis (Alpha)');
    ylabel('Y-axis (Beta)');
    zlabel('Z-axis');
    title('3D Path with Alternate Starting Points (Positive and Negative Z)');
    
    % Set 3D view
    view(3);
   
    
    % Ensure 1:1:1 aspect ratio
    axis equal;
    
    %w = 1 / n; % Step size in the z-direction
    %w=sum_difference/n;
    % Initialize matrix to store line data
    line_data_optimized = []; % Each row will store [start_x, start_y, start_z, end_x, end_y, end_z, length, color, iteration]
    % Initialize array to store endpoints of last lines
    endpoints = []; % Each row will store [x_end, y_end, z_end]

    % Loop over alternate starting points (step=2)
    for start_col = 1:2:(7*n-1) % Iterate with step=2 (1, 3, 5, ...)
        % Initialize starting point for this path in positive Z direction
        x_pos = alpha_matrix(1, start_col); % Starting x-coordinate
        y_pos = beta_matrix(1, start_col); % Starting y-coordinate
        z_pos = sum(w(:, 1:start_col), 2);       % Starting z-coordinate

        
        % Check if branching should occur based on z_pos
        if z_pos >= 0.9%|| z_pos <= 0.3 %%z_pos >= 15
            fprintf('Skipping branching for start_col=%d as z_pos=%.2f >= 0.75\n', start_col, z_pos);
            continue; % Skip to the next starting column
        end
        
        % Draw the path for this starting point in both directions
        for i = 1:(n-1)/2 
            if mod(i, 2) == 1 %&& 2*i+1 <= n % Odd iteration
                % Odd iteration logic: Use columns (start_col, start_col+1)
                delta_y = beta_matrix(2*i+1, start_col+1) - beta_matrix(2*i-1, start_col);
                if start_col~=1
                    delta_y1 = beta_matrix(2*i+1, start_col-1) - beta_matrix(2*i-1, start_col);
                end
                delta_z = w(start_col); % Positive Z direction
                delta_x = alpha_matrix(2*i+1, start_col+1) - alpha_matrix(2*i-1, start_col);
                
            else %2*i+1 <= n % Even iteration
                % Even iteration logic: Use columns (start_col, start_col+1)
                delta_y = beta_matrix(2*i+1, start_col) - beta_matrix(2*i-1, start_col+1);
                delta_z = -w(start_col); % Negative Z direction
                delta_x = alpha_matrix(2*i+1, start_col) - alpha_matrix(2*i-1, start_col+1);
            end
            
            %% Positive Z Direction Plotting
                   % Check if green line is moving toward negative X direction
                if delta_x < 0
                    endpoints = [endpoints; x_pos y_pos z_pos];
                   
                    fprintf('Skipping green line for positive Z direction at iteration %d as delta_x=%.2f < 0\n', i, delta_x);
                    break; % Stop processing this branch
                end
                

             % Draw line parallel to X-axis

            new_x_pos = x_pos + delta_x;
                        % Check if green line is moving toward negative X direction
            
            plot3([x_pos new_x_pos], [y_pos y_pos], [z_pos z_pos], 'g', 'LineWidth', 2); % Line in X direction
            
            plot3([x_pos new_x_pos], [y_pos y_pos], [z_pos+(delta_z/2) z_pos+(delta_z/2)], 'b', 'LineWidth', 2); % Line in X direction
            
            
            length_g = abs(new_x_pos - x_pos); % Calculate length of green line
            if start_col== (7*n-2) && mod(i, 2) == 0
                line_data_optimized = [line_data_optimized; x_pos, y_pos, z_pos, new_x_pos, y_pos, z_pos, length_g, 8, i,start_col,0,w(start_col)]; % Store data
            else
                line_data_optimized = [line_data_optimized; x_pos, y_pos, z_pos, new_x_pos, y_pos, z_pos, length_g, 7, i,start_col,0,w(start_col)]; % Store data
            end
            if mod(i, 2) == 1
                line_data_optimized = [line_data_optimized; x_pos, y_pos, z_pos+(delta_z/2), new_x_pos, y_pos, z_pos+(delta_z/2), length_g, 8, i,start_col,0,w(start_col)]; % Store data
                
            else
                line_data_optimized = [line_data_optimized; x_pos, y_pos, z_pos+(delta_z/2), new_x_pos, y_pos, z_pos+(delta_z/2), length_g, 6, i,start_col,0,w(start_col)]; % Store data
               

            end
            
            
             
            % % Draw line parallel to Y-axis (vertical line)
            
            new_y_pos = y_pos + delta_y;
            plot3([new_x_pos new_x_pos], [y_pos new_y_pos], [z_pos z_pos], 'b', 'LineWidth', 2); % Vertical line in Y-axis
             plot3([new_x_pos new_x_pos], [y_pos new_y_pos], [z_pos+(delta_z/2) z_pos+(delta_z/2)], 'g', 'LineWidth', 2); % Vertical line in Y-axis
             
            
            length_b = abs(new_y_pos - y_pos); % Calculate length of blue line
            if start_col== (7*n-2) && mod(i, 2) == 0
                line_data_optimized = [line_data_optimized; new_x_pos, y_pos, z_pos, new_x_pos, new_y_pos, z_pos, length_b, 8, i,start_col,0,w(start_col)]; % Store data
            else
                line_data_optimized = [line_data_optimized; new_x_pos, y_pos, z_pos, new_x_pos, new_y_pos, z_pos, length_b, 7, i,start_col,0,w(start_col)]; % Store data
            end
            if mod(i, 2) == 1
                line_data_optimized = [line_data_optimized; new_x_pos, y_pos, z_pos+(delta_z/2), new_x_pos, new_y_pos, z_pos+(delta_z/2), length_b, 8, i,start_col,0,w(start_col)]; % Store data
                
            else
                line_data_optimized = [line_data_optimized; new_x_pos, y_pos, z_pos+(delta_z/2), new_x_pos, new_y_pos, z_pos+(delta_z/2), length_b, 6, i,start_col,0,w(start_col)]; % Store data
                
            end
            if start_col~=1 && mod(i, 2) == 1 && new_x_pos-(alpha_matrix(2*i-1, start_col-2))>0  && delta_y1>0 
                plot3([alpha_matrix(2*i-1, start_col-2) new_x_pos], [y_pos y_pos], [z_pos-(delta_z/2) z_pos-(delta_z/2)], 'b', 'LineWidth', 2); % Line in X direction
               
                line_data_optimized = [line_data_optimized; alpha_matrix(2*i-1, start_col-2), y_pos, z_pos-(delta_z/2), new_x_pos, y_pos, z_pos-(delta_z/2), abs(new_x_pos-(alpha_matrix(2*i-1, start_col-2))), 6, i,start_col,1,w(start_col)]; % Store data
               
                plot3([new_x_pos new_x_pos], [y_pos y_pos+delta_y1], [z_pos-(delta_z/2) z_pos-(delta_z/2)], 'g', 'LineWidth', 2); % Vertical line in Y-axis
               
                line_data_optimized = [line_data_optimized; new_x_pos, y_pos, z_pos-(delta_z/2), new_x_pos, y_pos+delta_y1, z_pos-(delta_z/2), abs(delta_y1), 6, i,start_col,1,w(start_col)]; % Store data
               
                if i <= floor((n-1)/4 + 1) && (alpha_matrix(4*((i+1)/2)+1, start_col-2))-new_x_pos>0 && (beta_matrix(4*((i+1)/2)+1, start_col))-y_pos+delta_y1>0 
                    plot3([new_x_pos alpha_matrix(4*((i+1)/2)+1, start_col-2)], [y_pos+delta_y1 y_pos+delta_y1], [z_pos-(delta_z/2) z_pos-(delta_z/2)], 'b', 'LineWidth', 2); % Line in X direction
                   
                    line_data_optimized = [line_data_optimized; new_x_pos, y_pos+delta_y1, z_pos-(delta_z/2), alpha_matrix(4*((i+1)/2)+1, start_col-2), y_pos+delta_y1, z_pos-(delta_z/2), abs((alpha_matrix(4*((i+1)/2)+1, start_col-2))-new_x_pos), 8, i,start_col,1,w(start_col)]; % Store data
                   
                    plot3([alpha_matrix(4*((i+1)/2)+1, start_col-2) alpha_matrix(4*((i+1)/2)+1, start_col-2)], [y_pos+delta_y1 beta_matrix(4*((i+1)/2)+1, start_col)], [z_pos-(delta_z/2) z_pos-(delta_z/2)], 'g', 'LineWidth', 2); % Vertical line in Y-axis
                   
                    line_data_optimized = [line_data_optimized; alpha_matrix(4*((i+1)/2)+1, start_col-2), y_pos+delta_y1, z_pos-(delta_z/2), alpha_matrix(4*((i+1)/2)+1, start_col-2), beta_matrix(4*((i+1)/2)+1, start_col), z_pos-(delta_z/2), abs((beta_matrix(4*((i+1)/2)+1, start_col))-(y_pos+delta_y1)), 8, i,start_col,1,w(start_col)]; % Store data
                   
                
                                  
                end
            
            elseif start_col~=1 && mod(i, 2) == 1 && new_x_pos-(alpha_matrix(2*i-1, start_col-2))<0  
                %plot3([alpha_matrix(4*((i-1)/2)+1, start_col-2) alpha_matrix(4*((i-1)/2)+1, start_col-2)], [beta_matrix(4*((i-1)/2)+1, start_col) 1], [z_pos-(delta_z/2) z_pos-(delta_z/2)], 'g', 'LineWidth', 2); % Vertical line in Y-axis
                %plot3([alpha_matrix(4*((i-1)/2)+1, start_col-2) alpha_matrix(4*((i-1)/2)+1, start_col-2)], [beta_matrix(4*((i-1)/2)+1, start_col) 1], [-(z_pos-(delta_z/2)) -(z_pos-(delta_z/2))], 'g', 'LineWidth', 2); % Vertical line in Y-axis
                %line_data_optimized = [line_data_optimized; alpha_matrix(4*((i-1)/2)+1, start_col-2),(beta_matrix(4*((i-1)/2)+1, start_col)), z_pos-(delta_z/2), alpha_matrix(4*((i-1)/2)+1, start_col-2), 1, z_pos-(delta_z/2), abs(1-(beta_matrix(4*((i-1)/2)+1, start_col))), 8, i]; % Store data
                    %line_data_optimized = [line_data_optimized; alpha_matrix(4*((i-1)/2)+1, start_col-2), (beta_matrix(4*((i-1)/2)+1, start_col)), -(z_pos-(delta_z/2)), alpha_matrix(4*((i-1)/2)+1, start_col-2), 1, -(z_pos-(delta_z/2)), abs(1-(beta_matrix(4*((i-1)/2)+1, start_col))), 6, i]; % Store data
            end
            y_pos = new_y_pos; % Update y-coordinate
           
            %% Draw Yellow Lines from Endpoint of Blue Line
        if i <= (7*n-1)/2   % Ensure yellow lines are not drawn for the last iteration
            % Determine which column to use based on whether the iteration is odd or even
            if mod(i, 2) == 1 % Odd iteration
                    % Check if green line is moving toward negative X direction
                if delta_x < 0
                    
                    fprintf('Skipping green line for positive Z direction at iteration %d as delta_x=%.2f < 0\n', i, delta_x);
                    break; % Stop processing this branch
                end

                col_to_use = start_col+1; % Use start_col+1 for odd iterations
                % Calculate the length of the next blue line based on the selected column
                %next_length_b = abs(beta_matrix(2*i+3, start_col) - beta_matrix(2*i+1, start_col+1)); % Length of next blue line

                %% First Yellow Line Parallel to Y-axis
               
                    yellow_y_end_1 = new_y_pos ; 

                if i ~= 1   
                    plot3([x_pos x_pos], [new_y_pos-delta_y yellow_y_end_1], [z_pos+w(start_col) z_pos+w(start_col)], 'y', 'LineWidth', 2); % Yellow line parallel to Y-axis
                    
                    length_yellow = abs(yellow_y_end_1-(new_y_pos-delta_y));
                     line_data_optimized= [line_data_optimized; x_pos, new_y_pos-delta_y, z_pos+w(start_col), x_pos, yellow_y_end_1, z_pos+w(start_col), length_yellow, 7, i,start_col,0,w(start_col)]; % Store data
                     
                end
                %% Second Yellow Line Parallel to X-axis
                yellow_x_end_2 = x_pos + abs(delta_x); 
                if i ~= (n-1)/2
                    plot3([x_pos yellow_x_end_2], [yellow_y_end_1 yellow_y_end_1], [z_pos+w(start_col) z_pos+w(start_col)], 'y', 'LineWidth', 2); % Yellow line parallel to X-axis
                    %plot3([x_pos yellow_x_end_2], [yellow_y_end_1 yellow_y_end_1], [-(z_pos+w) -(z_pos+w)], 'y', 'LineWidth', 2); % Yellow line parallel to X-axis
                    
                 
                    length_yellow_1 = abs(yellow_x_end_2 - x_pos); % Calculate length of first yellow line
                     line_data_optimized= [line_data_optimized; x_pos, yellow_y_end_1, z_pos+w(start_col), yellow_x_end_2, yellow_y_end_1, z_pos+w(start_col), length_yellow_1, 7, i,start_col,0,w(start_col)]; % Store data 
                    %line_data_optimized= [line_data_optimized; x_pos, yellow_y_end_1, -(z_pos+w), yellow_x_end_2, yellow_y_end_1, -(z_pos+w), length_yellow_1, 7, i,start_col,0]; % Store data 
                end
            
            else % Even iteration
                   % Check if green line is moving toward negative X direction
                if delta_x < 0
                    
                    fprintf('Skipping green line for positive Z direction at iteration %d as delta_x=%.2f < 0\n', i, delta_x);
                    break; % Stop processing this branch
                end
                
                 % Calculate the length of the next blue line based on the selected column
           % next_length_b = abs(beta_matrix(2*i+3, col_to_use) - beta_matrix(2*i+1, col_to_use)); % Length of next blue line

            %% First Yellow Line Parallel to Y-axis
            yellow_y_end_1 = new_y_pos ; 
            plot3([x_pos x_pos], [new_y_pos-delta_y yellow_y_end_1], [z_pos-w(start_col) z_pos-w(start_col)], 'y', 'LineWidth', 2); % Yellow line parallel to Y-axis
            

            length_yellow_1 = abs(yellow_y_end_1 - (new_y_pos-delta_y)); % Calculate length of first yellow line
             line_data_optimized = [line_data_optimized; x_pos, new_y_pos-delta_y, z_pos-w(start_col), x_pos, yellow_y_end_1, z_pos-w(start_col), length_yellow_1, 7, i,start_col,0,w(start_col)]; % Store data (positive Z)
            

            %% Second Yellow Line Parallel to X-axis
            yellow_x_end_2 = x_pos + abs(delta_x); 
            if i ~= (7*n-1)/2
                plot3([x_pos yellow_x_end_2], [yellow_y_end_1 yellow_y_end_1], [z_pos-w(start_col) z_pos-w(start_col)], 'y', 'LineWidth', 2); % Yellow line parallel to X-axis
                
    
                length_yellow_2 = abs(yellow_x_end_2 - x_pos); % Calculate length of second yellow line
                 line_data_optimized = [line_data_optimized; x_pos, yellow_y_end_1, z_pos-w(start_col), yellow_x_end_2, yellow_y_end_1, z_pos-w(start_col), length_yellow_2 ,7,i,start_col,0,w(start_col)]; % Store data (positive Z)
                 
            end
            
            end
                       
        end

                

            
            
            % Draw line parallel to Z-axis
            new_z_pos = z_pos + delta_z;
             
            plot3([new_x_pos new_x_pos], [y_pos y_pos], [z_pos new_z_pos], 'r', 'LineWidth', 2); % Line in Z direction
            
            z_pos = new_z_pos; % Update z-coordinate
            
            

                        
           
            x_pos = new_x_pos; % Update x-coordinate
            %% Check if this is the last iteration for this branch
            if i == (7*n-1)/2 || delta_x<=0 
                endpoints = [endpoints; new_x_pos y_pos new_z_pos]; % Store positive Z endpoint
                
                endpoints = [endpoints; x_neg y_neg z_neg]; % Store negative Z endpoint
                break;
            end
                       
        end
    end
    

        %% Find the maximum Y-coordinate among all endpoints
        %max_y_coord = max(endpoints(:, 2)); 
        %disp(max_y_coord);
        %disp(endpoints)
    
        %% Draw lines from each endpoint to max Y-coordinate parallel to Y-axis
        for j = 1:size(endpoints, 1)
            endpoint_x = endpoints(j, 1);
            endpoint_y = endpoints(j, 2);
            endpoint_z = endpoints(j, 3);
    
            %plot3([endpoint_x endpoint_x], [endpoint_y max_y_coord], [endpoint_z endpoint_z], 'm--', 'LineWidth', 2); 
            %plot3([endpoint_x endpoint_x], [endpoint_y max_y_coord], [endpoint_z+w/2 endpoint_z+w/2], 'm--', 'LineWidth', 2); 
            %plot3([endpoint_x endpoint_x], [endpoint_y max_y_coord], [endpoint_z+w endpoint_z+w], 'm--', 'LineWidth', 2); 
            %plot3([endpoint_x endpoint_x], [endpoint_y max_y_coord], [-endpoint_z -endpoint_z], 'm--', 'LineWidth', 2);
            %plot3([endpoint_x endpoint_x], [endpoint_y max_y_coord], [-endpoint_z-w/2 -endpoint_z-w/2], 'm--', 'LineWidth', 2); 
            %plot3([endpoint_x endpoint_x], [endpoint_y max_y_coord], [-endpoint_z-w -endpoint_z-w], 'm--', 'LineWidth', 2); 

            %length_m_line = abs(max_y_coord - endpoint_y); 
            %line_data_optimized = [line_data_optimized; endpoint_x endpoint_y endpoint_z endpoint_x max_y_coord endpoint_z length_m_line 6 NaN];
            %line_data_optimized = [line_data_optimized; endpoint_x endpoint_y -endpoint_z endpoint_x max_y_coord -endpoint_z length_m_line 8 NaN];

            %line_data_optimized = [line_data_optimized; endpoint_x endpoint_y endpoint_z+w/2 endpoint_x max_y_coord endpoint_z+w/2 length_m_line 7 NaN];
            %line_data_optimized = [line_data_optimized; endpoint_x endpoint_y -endpoint_z-w/2 endpoint_x max_y_coord -endpoint_z-w/2 length_m_line 7 NaN];

            %line_data_optimized = [line_data_optimized; endpoint_x endpoint_y endpoint_z+w endpoint_x max_y_coord endpoint_z+w length_m_line 8 NaN];
            %line_data_optimized = [line_data_optimized; endpoint_x endpoint_y -endpoint_z-w endpoint_x max_y_coord -endpoint_z-w length_m_line 6 NaN];
        end




    %% Save the data to a CSV file
    writematrix(line_data_optimized,csv_filename);
    
    
    hold off;
end


