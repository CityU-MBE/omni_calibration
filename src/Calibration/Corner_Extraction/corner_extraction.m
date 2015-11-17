%% corner_extraction
% Description: Extract the corners of all images
% Last Change: 11.01.13 M.Schönbein 
%
%%
function [images, grid_temp] = corner_extraction(images, calib_info)

opts = init();

dX = calib_info.dX;
dY = calib_info.dY;
n_sq_x = calib_info.n_sq_x;
n_sq_y = calib_info.n_sq_y;

for c=1:calib_info.number_cameras
    
    fprintf(1,['Gathering information of camera ' num2str(c) '.\n']);  
    
    s_images=images{1,c};

    if ~exist(['s_images.I(' num2str(1) ')']),
        if isempty(s_images.image_numbers),
            disp('Cannot extract corners without images');
            return;
        end;
    end;
    
    Xt=[]; Yt=[];
    for i=0:n_sq_x
        for j=0:n_sq_y
            Yt=[Yt;j*dY];
            Xt=[Xt;i*dX];
        end
    end

    grid{c}.Xt=Xt;
    grid{c}.Yt=Yt;

    fprintf(1,'Load Images and extract the grid corners on the images\n');

    for i = 1 : size(images{1,c}.image_numbers,2)
        
        l = dir([fullfile(images{1,c}.path, images{1,c}.calib_name) strcat('*.',calib_info.format_image)]);
        img_name = [images{1,c}.path '/' l(images{1,c}.image_numbers(i)).name];
        
        if exist(img_name)
            fprintf(1,'%d \n',i);
            if calib_info.format_image == 'ppm'
                I = double(loadppm(img_name));
            elseif calib_info.format_image == 'pgm'
                I = double(loadpgm(img_name));
            else
                I = rgb2gray(imread(img_name));
            end
        else
            fprintf(1,'\nWARNING! Images not exist.\n');
        end
        
        corners{1,i} = findCorners(I,0.05,1);
        chessboards{1,i} = chessboardsFromCorners(corners{1,i});
        
    end

    grid_temp{1,c}.corners = corners;
    grid_temp{1,c}.chessboards = chessboards;

end

save ( sprintf('%s/data/%s/grid_temp.mat', opts.root_dir, calib_info.calibration_name), 'grid_temp' );




