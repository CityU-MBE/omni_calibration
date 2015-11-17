% check corner extraction

function images_active = check_corner_extraction ( grid, images_active, info )

images = load_images(1,0,1,info);

n = floor(sqrt(size(grid{1,1}.Xp_abs,3)));
m = ceil(sqrt(size(grid{1,1}.Xp_abs,3)));

for j = 1 : size(images,2)
    %title(sprintf('%01d Camera',j));
    h = figure(size(images,2)+j); colormap('gray');
    set(h,'name',sprintf('Camera %01d',j),'numbertitle','off')
    
    for i = 1 : size(grid{1,1}.Xp_abs,3)
        if images_active{j}.active_images(i)
            subplot(m,m,i); hold on;
            imshow(images{1,j}.I{i});

            % show the clicked corners in all images
            plot(grid{1,j}.Xp_abs(:,1,i), grid{1,j}.Yp_abs(:,1,i),'r*','MarkerSize',10,'LineWidth',2); 
            plot(grid{1,j}.Xp_abs(1,1,i), grid{1,j}.Yp_abs(1,1,i),'g*','MarkerSize',15,'LineWidth',4);
            plot(grid{1,j}.Xp_abs(5,1,i), grid{1,j}.Yp_abs(5,1,i),'y*','MarkerSize',15,'LineWidth',4);
            plot(grid{1,j}.Xp_abs(35,1,i),grid{1,j}.Yp_abs(35,1,i),'b*','MarkerSize',15,'LineWidth',4);

            for k = 1 : 35
               text( grid{1,j}.Xp_abs(k,1,i)+15, grid{1,j}.Yp_abs(k,1,i)+25, int2str(k),'color','m','FontSize',20,'FontWeight','bold')
            end
        end
    end
    
end

fprintf('Check the orientation of the checkerboards. \n' );
fprintf('"Green" - upper left corner of the checkerboard, "Red" - upper right, "Blue" - lower right, "Yellow" - lower left. \n');

for j = 1 : size(images,2)
    
    img_false = input(sprintf('Are the orientation of the checkerboards of the %01d camera okay? (Yes, or number of the checkerboards which are false) \n', j));

    if (isempty (img_false ) == 0 )
   
        for k = 1 : size(img_false,2) 
            
            images_active{1,j}.active_images(img_false(k)) = 0;
        
        end
    
    end
    
end


