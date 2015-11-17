% check corner extraction
% ADAPTED Jonas Eichenberger, Oct. 2015

function [images, grid] = check_corner_extraction ( grid, images, info )

    images_loaded = load_images(1,0,1,info);
    opts = init();

    n = floor(sqrt(size(grid{1,1}.Xp_abs,3)));
    m = ceil(sqrt(size(grid{1,1}.Xp_abs,3)));

    for c = 1 : size(images,2) % iterate over cameras
         %
        for i = 1 : size(grid{1,1}.Xp_abs,3) % iterate over images

            if images{c}.active_images(i)

                plot_grid(images_loaded, grid, i, c, info);

            end

        end

    end

    fprintf('Check the orientation of the checkerboards. \n' );
    fprintf('"Green" - upper left corner of the checkerboard, "Cyan" - upper right, "Blue" - lower right, "Yellow" - lower left. \n');

    for c = 1 : size(images,2)

        img_false = input(sprintf('Are the orientation of the checkerboards of the %01d camera okay? (yes=[], or vector with wrong images e.g. [3 7]) \n', c));

        close all

        if (~isempty (img_false))

            for k = 1 : length(img_false) 
                ind = img_false(k);

                [x, y] = rearrange_corners(grid{1,c}.Xp_abs(:,1,ind), grid{1,c}.Yp_abs(:,1,ind), info);
                grid{1,c}.Xp_abs(:,1,ind) = x;
                grid{1,c}.Yp_abs(:,1,ind) = y;

                plot_grid(images_loaded, grid, ind, c, info);

            end
            
            img_false = input(sprintf('Better? (yes=[], or vector with wrong images e.g. [3 7]) \n'));

            if (~isempty(img_false))

                for k = 1 : length(img_false)

                    ind = img_false(k);

                    images{1,c}.active_images(ind) = 0;
                    fprintf('Discard image: %d\n', ind);

                end

            end

        end

    end
    
    close all

end

function [] = plot_grid(images, grid, indexImage, indexCamera, info)

    for cam = length(indexCamera)
        for im = length(indexImage)
        
            c = indexCamera(cam);
            i = indexImage(im);

            h = figure(i*c);
            set(h,'name',sprintf('Camera %01d - Image %d',c,i),'numbertitle','off')

            imshow(images{1,c}.I{i});
            hold on;

            % show the corners in all images
            plot(grid{1,c}.Xp_abs(:,1,i), grid{1,c}.Yp_abs(:,1,i),'r*','MarkerSize',10,'LineWidth',2);
            plot(grid{1,c}.Xp_abs(1,1,i), grid{1,c}.Yp_abs(1,1,i),'g*','MarkerSize',15,'LineWidth',4);
            plot(grid{1,c}.Xp_abs(info.n_sq_y+1,1,i), grid{1,c}.Yp_abs(info.n_sq_y+1,1,i),'y*','MarkerSize',15,'LineWidth',4);
            plot(grid{1,c}.Xp_abs(end-info.n_sq_y,1,i), grid{1,c}.Yp_abs(end-info.n_sq_y,1,i),'c*','MarkerSize',15,'LineWidth',4);
            plot(grid{1,c}.Xp_abs(end,1,i),grid{1,c}.Yp_abs(end,1,i),'b*','MarkerSize',15,'LineWidth',4);

            for k = 1 : size(grid{1,1}.Xp_abs,1)
               text( grid{1,c}.Xp_abs(k,1,i)+6, grid{1,c}.Yp_abs(k,1,i)+6, int2str(k),'color','m','FontSize',11,'FontWeight','bold')
            end
            
            pause(0.1) % wait so plots don't go to wrong figure -> strange
    
        end
    end

end


