% Initial and Final  calibration for all methods

function calibration ( grid, images, paramsMan, info )

opts = init();

paramsMan.calib = info.number_cameras;

fprintf(' Start Calibration with Method %s - can take some time!\n', func_name (info.method));

% checkerboard in the checherboard coordinate system
M = [grid{1,1}.Xt, grid{1,1}.Yt, zeros(size(grid{1,1}.Xt))]; 

%% Initialisation for all calibration types
% set active boards
active = set_active_boards ( images, paramsMan );

%% Initialize extrinsic and intrinsic camera parameters
if info.method <= 10
    %%%%%%%%%%%%%%%% Geometric CALIBRATION Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % load all active camera parameters
    [active, J] = set_active_geometric_param (images, info.method, paramsMan, active, info);
    
	% initial calibration ( with geometric homography)
    params = paramsMan;
    params = initial_ex_calibration (grid, images, active, paramsMan, M );
 
elseif (info.method == 11) || (info.method == 15) 
    %%%%%%%%%%%%%%%%%%% Scaramuzza CALIBRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%% with modified initial intrinisic camera calibration %%%%%%%%%%%%%%
    %%%%%%%% and extrinsics from geometric calibration %%%%%%%%%%%%%%%%%%%%%%%%  
    params = paramsMan;
    
    if  info.method == 11   % with normalization
        params.const = 512;
    else                    % without normalization
        params.const = 1;
    end
    
    % initial extrinsic calibration ( with geometric homography)
    params = initial_ex_calibration (grid, images, active, params, M );
    
    % new intrinsic initiallization
    [params.cam, active] = initial_scara_calibration_new ( grid, images, params, active );
    J = 0;
    
elseif (info.method == 18) || (info.method == 17)
    %%%%%%%%%%%%%%%%%%% Scaramuzza CALIBRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% with original initial calibration %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [params, active, J] = initial_scara_calibration ( grid, images, paramsMan, active, info );
    params.const = 1;

elseif (info.method == 12) || (info.method == 16)
    %%%%%%%%%%%%%%%%%%%%% MEI CALIBRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%% with extrinsics from geometric calibration %%%%%%%%%%%%%%%%%%%%%%%
    
    if info.method == 12    % with distortion parameters (Mei)
        without_k = 0;
    else 
        without_k = 1;      % without distortion parameters (Geyer)
    end
      
    % initial calibration ( with geometric homography)
        params = initial_ex_calibration (grid, images, active, paramsMan, M );
        [params.cam, active, J] = initial_ini_mei_calibration ( images, params, active, without_k, info.omni, info);  
        
 
elseif info.method == 14 
    %%%%%%%%%%%%%%%%%%%% CENTERED CALIBRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if ( exist(sprintf('%s/calib_%04d.mat', info.filename, info.ref_for_14)) ~= 0 )
  
        load(sprintf('%s/calib_%04d.mat', info.filename, info.ref_for_14), 'params','param','resnorm','active' ); 
       
    else 
        
        info.method = info.ref_for_14;
        calibration ( grid, images, paramsMan, info );
        visualize_reprojection_error_calibation ( opts, grid, images, info );
        info.method = 14;
        load(sprintf('%s/calib_%04d.mat', info.filename, info.ref_for_14), 'params','param','resnorm','active' );
    end
    
    param.cam = compute_centered_model (param, images, M, grid);
    
    save ( sprintf ('%s/calib_0014.mat', info.filename ), 'params','param','resnorm','active' );
    return;   
end


u_ini = []; 
for c = 1 : params.calib
    for b = 1 : size(params.board,2)
        if (images{1,c}.active_images(b) == 1)
            for j = 1 : size(grid{1,c}.Xp_abs,1)
                u_ini = [ u_ini; grid{1,c}.Xp_abs(j,:,b); grid{1,c}.Yp_abs(j,:,b)]; 
            end
        end
    end
end  

info.options.JacobPattern = J;

%% Main calibration
if info.method <= 10
    %%%%%%%%%%%%%%%%%%%% GEOMETRIC CALIBRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [x0, resnorm] = optimization_projection (params, M', u_ini, active, images, info.options);
    
    param = unpack_params (x0, params, active);
    
elseif (info.method == 11) || (info.method == 17)
    %%%%%%%%%%%% Scaramuzza CALIBRATION normalization %%%%%%%%%%%%%%%%%%%%%
    [x0, resnorm] = optimization_projection_scara (params, M', u_ini, active, images, info.options, info);
    
    for c = 1 : params.calib 
        active.cam{c}.c = 1;
        active.cam{c}.d = 1;
        active.cam{c}.e = 1;
    end
    
    param = unpack_params_scara (x0, params, active);
    param.calib = params.calib;
    param.const = params.const;



elseif (info.method == 12) || (info.method == 16)
    
    %%%%%%%%%%%%%%%%%%%% MEI CALIBRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%% (with and without distortions) %%%%%%%%%%%%%%%%%%%%%%%%
    [x0, resnorm] = optimization_projection_mei (params, M', u_ini, active, images, info.options);
    
    param = unpack_params_mei (x0, params, active);
    
    % display result
    fprintf('\n******************************************************************************\n');
    fprintf('**************************** Results   ******************************\n');
    
    time = datestr(now, 'dd-mm-HH-MM');
    fileName = sprintf('Result_Mei_%s.txt', time);
    filePath = sprintf('%s/%s', info.filename, fileName);
    fileID = fopen(filePath, 'w');
    
    for c = params.calib
    
        fprintf('\n\n-- Camera %d --\n\n', c);
        
        fprintf('xi: [ %s]\n', sprintf('%f ', param.cam{c}.xi));
        fprintf('gammac: [ %s]\n', sprintf('%f ', param.cam{c}.gammac));
        fprintf('cc: [ %s]\n', sprintf('%f ', param.cam{c}.cc));
        fprintf('kc: [ %s]\n', sprintf('%f ', param.cam{c}.kc));
        fprintf('alphac: [ %s]\n', sprintf('%f ', param.cam{c}.alphac));
        fprintf('ex_T: [ %s]\n', sprintf('%f ', param.cam{c}.ex_T));
        fprintf('ex_om: [ %s]\n', sprintf('%f ', param.cam{c}.ex_om));
        
        % save to file
        fprintf(fileID, '-- Camera %d --\n\n', c);
        
        fprintf(fileID, 'xi: [ %s]\n', sprintf('%f ', param.cam{c}.xi));
        fprintf(fileID, 'gammac: [ %s]\n', sprintf('%f ', param.cam{c}.gammac));
        fprintf(fileID, 'cc: [ %s]\n', sprintf('%f ', param.cam{c}.cc));
        fprintf(fileID, 'kc: [ %s]\n', sprintf('%f ', param.cam{c}.kc));
        fprintf(fileID, 'alphac: [ %s]\n', sprintf('%f ', param.cam{c}.alphac));
        fprintf(fileID, 'ex_T: [ %s]\n', sprintf('%f ', param.cam{c}.ex_T));
        fprintf(fileID, 'ex_om: [ %s]\n', sprintf('%f ', param.cam{c}.ex_om));
        
        fprintf('\nResults saved to file: %s \n', fileName)
    
    end
          
end
  
save( sprintf('%s/calib_%04d.mat', info.filename, info.method), 'params','param','resnorm','active' );
fprintf('\n******************************************************************************\n');
fprintf('**************************** Calibration Done   ******************************\n');
fprintf('*************************saved as calib_%04d.mat *****************************\n', info.method);
fprintf('\n******************************************************************************\n');

end

