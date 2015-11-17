%% load_images 
% load all images for the calibration 
% Author: M.Schönbein 2012

function [images, calib_info] = load_images(calib_sort, show_mosaic, load_image, calib_info)

format_image = calib_info.format_image;

for cam = 1 : calib_info.number_cameras

    images{cam}.calib_name = eval(['calib_info.name_cam' sprintf(num2str(cam))]);
        
    l = dir([fullfile(calib_info.image_path, images{cam}.calib_name) '*.png'])
    image_numbers = [];
    if ( isempty(calib_info.ima_numbers) == 1)
        ima_nums = size(l,1);
    else 
        ima_nums = size(calib_info.ima_numbers,2);
    end
    
    fprintf(1,'Loading image ');
    for i = 1:ima_nums
        if ( isempty(calib_info.ima_numbers) == 1)
        	filenamepp =  l(i).name;
            image_numbers = [image_numbers,i];
        else 
        	filenamepp =  l(calib_info.ima_numbers(i)).name;
            image_numbers = [image_numbers,calib_info.ima_numbers(i)];
        end

        ima_name = [calib_info.image_path '/' filenamepp];
    
        
        if exist('ima_name','var')
            fprintf(1,'%d...',i);

            if calib_info.format_image == 'ppm'
                I{i} = double(loadppm(ima_name));
            elseif calib_info.format_image == 'pgm'
                I{i} = double(loadpgm(ima_name));
            else
                I{i} = imread(ima_name);
            end
        else
            fprintf(1,'\nWARNING! Images not exist.\n');
        end
        
     end
    
    % calculate mean Image
    I_mean = I{:};   
    for i = 2 : ima_nums
        I_new = eval(sprintf('I{:,%01d}',i));
        I_mean = min(I_mean, I_new);

    end
    
    fprintf(1,'\n');
    if (load_image == 1)
        images{1,cam}.I = I;
    end
    
    images{1,cam}.active_images = ones(1,ima_nums);

    %%% By default, all the images are active for calibration:
    images{1,cam}.active_images = ones(1,ima_nums);
    images{1,cam}.Imean = I_mean;
    
    images{1,cam}.image_numbers = image_numbers;
    images{1,cam}.path          = calib_info.image_path;
    images{1,cam}.format_image  = format_image;

    images{1,cam}.nx = size(I_mean,2);
    images{1,cam}.ny = size(I_mean,1);
    
	% Show all the calibration images
    if ~isempty(I) && show_mosaic == 1
        mosaic(image{1,cam});
    end
    
end

