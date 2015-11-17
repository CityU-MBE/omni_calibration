% Select corner on the checkerboards
%
% written by A. Balbaa and M.Schönbein, 02.Aug 2012
% Adapted Jonas Eichenberger, 2015

function [images, grid] = corners_selection ( grid_temp, images, info )

    cams    = info.number_cameras;
    boards  = length(images{1,1}.active_images);

    for c= 1 : cams

        nCornerExt = 0;

        dX = info.dX;
        dY = info.dY;

        n_sq_x = info.n_sq_x;
        n_sq_y = info.n_sq_y;

        Xt=[]; Yt=[];
        for i=0:n_sq_x
            for j=0:n_sq_y
                Yt=[Yt;j*dY];
                Xt=[Xt;i*dX];
            end
        end

        grid{c}.Xt=Xt;
        grid{c}.Yt=Yt;

        s_xc = info.xc{1,c};    
        s_yc = info.yc{1,c};    

        fprintf(1,['Revising results of camera ' num2str(c) '.\n']);

        corners=grid_temp{1,c}.corners;
        chessboards=grid_temp{1,c}.chessboards;

        ima_proc = [];

        for b = 1 : boards 
            if isempty(chessboards{1,b})

                grid{1,c}.Xp_abs(:,1,b) = zeros( (info.n_sq_x+1)*(info.n_sq_y+1),1);
                grid{1,c}.Yp_abs(:,1,b) = zeros( (info.n_sq_x+1)*(info.n_sq_y+1),1);

                images{1,c}.active_images(1,b) = 0;
                images{1,c}.corner_found(1,b) = 0;

            else

                if ( ( (size(chessboards{1,b}{1,1},1) == info.n_sq_y + 1) && ...
                        (size(chessboards{1,b}{1,1},2) == info.n_sq_x + 1 ) ) || ...
                     ( (size(chessboards{1,b}{1,1},1) == info.n_sq_x + 1) && ...
                        (size(chessboards{1,b}{1,1},2) == info.n_sq_y + 1 ) ) )

                    [corners{1,b},chessboards{1,b}{1,1}] = sort_corners(corners{1,b},chessboards{1,b}{1,1},s_xc,s_yc);

                    grid{1,c}.Xp_abs(:,1,b) = corners{1,b}.p(:,1);
                    grid{1,c}.Yp_abs(:,1,b) = corners{1,b}.p(:,2);
                    grid{1,c}.ima_proc = [ima_proc, images{1,c}.image_numbers(b)];

                    nCornerExt = nCornerExt + 1;
                    
                else

                    fprintf('Automatic Corner Selection failed for Image %d --- image set inactive \n', b);

                    % TODO: Manual Corner Selection

    %                 figure(2);
    %                 imshow(loaded_images{1,c}.I{b}); colormap(gray(256)); hold on;
    %                 plot(corners{1,b}.p(:,1),corners{1,b}.p(:,2),'r*');
    % 
    %                 answ=input('\nAutomatic corner detection failed for this image. \nDo you want to discard image or enter missing corners manually? ([]=manual input) ');
    % 
    %                 if isempty(answ)
    % 
    %                     [corners{1,b},chessboards{1,b}{1,1}] = click_missing_points(loaded_images{1,c}.I{b},corners{1,b},chessboards{1,b}{1,1},s_xc,s_yc);
    %                     cbtemp{1,1}{1,1}=chessboards{1,b}{1,1};
    %                     cortemp{1,1}=corners{1,b};
    %                     [cortemp, cbtemp] = sort_corners(cortemp,cbtemp,s_xc,s_yc);
    %                     corners{1,b}=cortemp{1,1};
    %                     chessboards{1,b}{1,1}=cbtemp{1,1}{1,1};
    % 
    %                 else
    % 
    %                     images{c}.active_images(b) = 0;
    %                     corners{1,i}.p=zeros(num_points,2);
    % 
    %                 end

                    grid{1,c}.Xp_abs(:,1,b) = zeros( (info.n_sq_x+1)*(info.n_sq_y+1),1);
                    grid{1,c}.Yp_abs(:,1,b) = zeros( (info.n_sq_x+1)*(info.n_sq_y+1),1);

                    images{1,c}.active_images(1,b) = 0;
                    images{1,c}.corner_found(1,b) = 0;

                end
            end
        end
        
        fprintf('Camera %d: Grid extracted in %d/%d images \n', c, nCornerExt, boards);

    end

end


