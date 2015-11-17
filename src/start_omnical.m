%% START Omnicalibration Toolbox

% Adapted Jonas Eichenberger, 2015

function start_omnical()

    warning off
    close all
    clc

    fprintf('\n Start Omni Calibration Toolbox. \n \n');

    opts = init();

    [info, params] = config();
    analyse_input_parameters ( info);
    reply = input('Check if the calibration parameters are okay,\n --> if the they are okay press enter to continue,\n --> if not press [N], change the parameters in config.m and restart the calibration. \n','s');
    if ((reply == 'N') | (reply == 'n') )
        return
    end

    if (exist( sprintf( '%s/data/%s/images.mat', opts.root_dir, info.calibration_name)) ~= 0)
        
        imagesCoordinates = load( sprintf( '%s/data/%s/images.mat', opts.root_dir, info.calibration_name));
        images = imagesCoordinates.images;
        gridCoordinates = load( sprintf( '%s/data/%s/grid.mat', opts.root_dir, info.calibration_name));
        grid = gridCoordinates.grid;
        
        %%% Load Intrinsic parameters
        % Estimate center
        info = estimate_center_and_radius ( images, info );
    
        % Estimate Intrinsics
        for i = 1 : size(images,2)
            params.cam{i} = mirror_sphere_params ( params.cam{i}, info.omni, info.coordinate_system, info.R, info.radius{1}, info.xc{1,i}, info.yc{1,i});
        end
        
        %%% Check if Corner Extraction was okay
        [images, grid] = check_corner_extraction ( grid, images, info );
        
        save ( sprintf('%s/data/%s/grid.mat', opts.root_dir, info.calibration_name), 'grid');
        save ( sprintf('%s/data/%s/images.mat', opts.root_dir, info.calibration_name), 'images');
      
    else
        %%% load Images
        [ images ] = load_images (1, 0, 0, info);

        %%% Load Intrinsic parameters
        % Estimate center
        info = estimate_center_and_radius ( images, info );

        % Estimate Intrinsics
        for i = 1 : size(images,2)
            params.cam{i} = mirror_sphere_params ( params.cam{i}, info.omni, info.coordinate_system, info.R, info.radius{1}, info.xc{1,i}, info.yc{1,i});
        end

        %%% Corner Extraction
        [images, grid_temp] = corner_extraction(images, info);
        [images, grid] = corners_selection ( grid_temp, images, info );

        %%% Check if Corner Extraction was okay
        [images, grid] = check_corner_extraction ( grid, images, info );
        
        save ( sprintf('%s/data/%s/grid.mat', opts.root_dir, info.calibration_name), 'grid');
        save ( sprintf('%s/data/%s/images.mat', opts.root_dir, info.calibration_name), 'images');

    end

    if(sum(images{1}.active_images)>2) % ensure 'enough' active images

        %%% calibration
        calibration ( grid, images, params, info );

        %%% Visulize Results
        visualize_reprojection_error_calibation ( opts, grid, images, info );

    else

        fprintf('\n Not enough images with checkboard found. \n Aborting Calibration \n');

    end


end