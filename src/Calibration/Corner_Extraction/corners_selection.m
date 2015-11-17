% Select corner on the checkerboards
%
% written by A. Balbaa and M.Schönbein, 02.Aug 2012

function [images, grid] = corners_selection ( grid_temp, images, calib_info )

opts = init();

cams    = calib_info.number_cameras;
boards  = length(images{1,1}.active_images)

for c= 1 : cams
    
    dX = calib_info.dX;
    dY = calib_info.dY;
        
    n_sq_x = calib_info.n_sq_x;
    n_sq_y = calib_info.n_sq_y;
    
    Xt=[]; Yt=[];
    for i=0:n_sq_x
        for j=0:n_sq_y
            Yt=[Yt;j*dY];
            Xt=[Xt;i*dX];
        end
    end

    grid{c}.Xt=Xt;
    grid{c}.Yt=Yt;

    s_xc = calib_info.xc{1,c};    
    s_yc = calib_info.yc{1,c};    
    
    fprintf(1,['Revising results of camera ' num2str(c) '.\n']);
    
    corners=grid_temp{1,c}.corners;
    chessboards=grid_temp{1,c}.chessboards;
    
    ima_proc = [];
    
    for b = 1 : boards 
        if isempty(chessboards{1,b})
            
            grid{1,c}.Xp_abs(:,1,b) = zeros( (calib_info.n_sq_x+1)*(calib_info.n_sq_y+1),1);
            grid{1,c}.Yp_abs(:,1,b) = zeros( (calib_info.n_sq_x+1)*(calib_info.n_sq_y+1),1);

            images{1,c}.active_images(1,b) = 0;
            
        else
            if ( ( (size(chessboards{1,b}{1,1},1) == calib_info.n_sq_y + 1) && ...
                    (size(chessboards{1,b}{1,1},2) == calib_info.n_sq_x + 1 ) ) || ...
                 ( (size(chessboards{1,b}{1,1},1) == calib_info.n_sq_x + 1) && ...
                    (size(chessboards{1,b}{1,1},2) == calib_info.n_sq_y + 1 ) ) )

                [corners{1,b},chessboards{1,b}{1,1}] = sort_corners(corners{1,b},chessboards{1,b}{1,1},s_xc,s_yc);

                num_points=(calib_info.n_sq_x+1)*(calib_info.n_sq_y+1);

                if ( num_points ~= numel(chessboards{1,b}{1,1}))

                    if (calib_info.auto_cornerdetection == 1)

                        images{c}.active_images(i) = 0;
                        corners{1,i}.p=zeros(num_points,2);

                    else

                        figure(2);
                        image(cb{1,i}); colormap(gray(256)); hold on;
                        plot(corners{1,i}.p(:,1),corners{1,i}.p(:,2),'r*');

                        answ=input('\nAutomatic corner detection failed for this image. \nDo you want to discard image or enter missing corners manually? ([]=manual input) ');

                        if isempty(answ)

                            [corners{1,i},chessboards{1,i}{1,1}] = click_missing_points(cb{1,i},corners{1,i},chessboards{1,i}{1,1},s_xc,s_yc);
                            cbtemp{1,1}{1,1}=chessboards{1,i}{1,1};
                            cortemp{1,1}=corners{1,i};
                            [cortemp cbtemp] = sort_corners(cortemp,cbtemp,s_xc,s_yc);
                            corners{1,i}=cortemp{1,1};
                            chessboards{1,i}{1,1}=cbtemp{1,1}{1,1};

                        else

                            images{c}.active_images(i) = 0;
                            corners{1,i}.p=zeros(num_points,2);

                        end
                    end
                end

                grid{1,c}.Xp_abs(:,1,b) = corners{1,b}.p(:,1);
                grid{1,c}.Yp_abs(:,1,b) = corners{1,b}.p(:,2);
                grid{1,c}.ima_proc = [ima_proc, images{1,c}.image_numbers(b)];
                
                images{1,c}.active_images(1,b) = 1;
            else
            
                grid{1,c}.Xp_abs(:,1,b) = zeros( (calib_info.n_sq_x+1)*(calib_info.n_sq_y+1),1);
                grid{1,c}.Yp_abs(:,1,b) = zeros( (calib_info.n_sq_x+1)*(calib_info.n_sq_y+1),1);

                images{1,c}.active_images(1,b) = 0;

            end
        end
    end

    
end

save ( sprintf('%s/data/%s/grid.mat', opts.root_dir, calib_info.calibration_name), 'grid');
save ( sprintf('%s/data/%s/images.mat', opts.root_dir, calib_info.calibration_name), 'images');

end


