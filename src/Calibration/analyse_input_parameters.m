function analyse_input_parameters ( info)

fprintf('\n******************************************************************************\n');
fprintf('********************** Calibration parameters ********************************\n');
fprintf('Calibration Method: %s \n',  func_name (info.method));
fprintf('Number of Cameras: %d \n', info.number_cameras);
fprintf('Image folder: %s \n', info.image_path);
fprintf('Results folder: %s \n', info.filename);
fprintf('******************************************************************************\n');
fprintf('******************************************************************************\n\n');

end