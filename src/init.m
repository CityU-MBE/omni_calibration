function opts = init()
% returns root_dir, adds path if no output specified

% ADAPT PATH TO TOOLBOX
opts.root_dir = '/home/jonas/git/thesis-jonas/Camera_Calibration/CalibrationToolbox';

opts.opencv_lib_dir = '/usr/local/lib';
opts.opencv_inc_dir = '';
opts.opencv_version = '';

% To calculate deviations = 1 (only possible with Linux) else 0
opts.deviations = 0;                  
            
% only applied once at the beginning
if nargout==0
  %mkdir(opts.filename);   
  addpath(genpath(sprintf('%s/src',opts.root_dir)));
end 
