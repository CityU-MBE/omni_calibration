%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Config FILE
%  information about the mono and stereo calibration
%  CHANGE BEFORE CALIBRATION
%
%  Author: M. Schönbein 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [calib_info, params] = config()

opts = init();

%% General Calibration
% Save the results in the folder
calib_info.calibration_name = 'Calibration_040914'; 
mkdir ( sprintf( '%s/data/%s', opts.root_dir, calib_info.calibration_name ));
calib_info.filename = sprintf('%s/data/%s', opts.root_dir, calib_info.calibration_name );

% Visualization of the results
calib_info.visualize_error_flag = 1;        % shows the reprojection error
calib_info.visualize_corners = 1;           % 1 - all reprojection errors in one plot; 2 - one plot for every checkerboard

% Calibration Method
calib_info.method = 14;          % 1 - 10 Geometric Model (see load_param or Readme for details), 
                                % 14 Centered Model,
                                % 11 Scaramuzza with new initialization 
                                % 12 Mei Model, 
                                % 16 Geyer Model
                                % 17 Scaramuzza
calib_info.ref_for_14 = 3;      % (method 14 needs a reference calibration; DEFAULT = 3)


% only for the scaramuzza calibration
calib_info.scara_ini = 0;   % Initialization original; Initialization with normalization

% Number of cameras to calibrate
calib_info.number_cameras = 2; %2;                     

%% Image Informations
% Image path
calib_info.image_path = sprintf('%s/data/DemoImages', opts.root_dir);

% Format of the images
calib_info.format_image = 'png';            

% Name of the images (prefix)
calib_info.name_cam1 = 'left_img_';  
calib_info.name_cam2 = 'right_img_'; 
  
% images for calibration (empty = all images, else [1 2 ... n])
calib_info.ima_numbers = [];

%% Infos concerning the corner detection
calib_info.dX = 100;            % Size of square in x-direction
calib_info.dY = 100;            % Size of square in y-direction

calib_info.n_sq_x = 6;          % Number of squares along the X direction
calib_info.n_sq_y = 4;          % Number of squares along the Y direction

calib_info.wintx = 5;           % Size of the window for manual corner detection in x direction
calib_info.winty = 5;			% Size of the window for manual corner detection in y direction

%% Initial Mirror/Camera Parameter 
% Midpoint xc/yc of the image 
calib_info.center = 1;  % (1 = take this valus; 0 = click center/radius)
calib_info.xc{1,1} = 750; ;
calib_info.yc{1,1} = 750; 
calib_info.radius{1} = 750;

calib_info.xc{1,2} = 730;  
calib_info.yc{1,2} = 730; 
calib_info.radius{2} = 730;

% radius of the mirror
calib_info.R = 22.5;       

% Hyperbol parameter (use hyperbolic or spheric parameters)
    calib_info.omni.a = 26.857800;
    calib_info.omni.b = 20.848500;
calib_info.coordinate_system = 2;

% Extrinisics ( R and T between the cameras)
params.cam{1}.ex_T  = [ 0; 0; 0];
params.cam{1}.ex_om = [ 0 0 0];
params.cam{2}.ex_T  = [ 800; 0; 0]; 
params.cam{2}.ex_om = [   0 0 0];

%% Optimization parameteres
% optimization
tolerance = 1e-6; 
max_iter = 5000;
jacobian = 'on';
if calib_info.method <= 10 || calib_info.method == 14
    algo = 'levenberg-marquardt';
else
    algo = 'trust-region-reflective';
end

calib_info.options=optimset('Algorithm',algo, 'Display','iter',...
                 'TolX', tolerance, 'TolFun', tolerance, ...
                 'DerivativeCheck','off', 'Diagnostics','off', ... %'Jacobian',opts.jacobian, 
                 'ScaleProblem', 'Jacobian',...
                 'MaxFunEvals',inf, ...
                 'MaxIter', max_iter); %, ...   'OutputFcn',@outfun);

end


