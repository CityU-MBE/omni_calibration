function opts = init()
% returns root_dir, adds path if no output specified

opts.root_dir = '<change_path_to_toolbox_folder>';

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
