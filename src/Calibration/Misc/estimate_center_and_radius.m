% Estimate center and radius 
function info = estimate_center_and_radius ( images, info )

    if info.center == 0
        for i = 1 : size(images,2)
            figure(i);
            imshow(images{1,i}.Imean);

            d = ginput(2);

            info.xc{1,i} = d(1,1);
            info.yc{1,i} = d(1,2);
            
            info.radius{i} = sqrt( (d(2,1)-d(1,1))^2 + (d(2,2)-d(1,2))^2 );
            
            figure(i); hold on;
            line( [d(1,1)-50,d(1,1)+50], [d(1,2)-50,d(1,2)+50],'Color','y');
            line( [d(1,1)-50,d(1,1)+50], [d(1,2)+50,d(1,2)-50],'Color','y');
            
            t = 0 : pi/100 : 2*pi;
            
            plot(d(1,1)+info.radius{i} *cos(t),d(1,2)+info.radius{i} *sin(t),'r-','LineWidth',3)
            
        end
    end