% Visualize the reprojection error for the calibration method
function visualize_reprojection_error_calibation ( opts, grid, images, info )

    fprintf('\n Visualize Calibration Results. \n');

    % Compute the image points for all images out of the 3D points
    M = [grid{1,1}.Xt, grid{1,1}.Yt, zeros(size(grid{1,1}.Xt))];

    result_folder = sprintf( '%s/Method_%02d/', info.filename, info.method);
    mkdir(result_folder);

    calibname = sprintf('%s/calib_%04d.mat', info.filename, info.method);
    if (exist(calibname) == 2)
        load(calibname);
    else 
        fprintf('Error: Calibration Result was not saved. \n');
    end

    colors = 'rbgykcm';
    num = size(param.board,2);

    for c = 1 : info.number_cameras

        ind = 1;
        close all;
        figure(1); h1 = axes();

        for i = 1 : size(param.board,2)

            if (images{1,c}.active_images(i) == 1)

                if info.visualize_error_flag == 1
                    l = dir( [fullfile( info.image_path, eval(sprintf('info.name_cam%1d',c))) strcat('*.',info.format_image)]);
                    I = imread ( sprintf('%s/%s', info.image_path, l(i).name )); 
                    figure('Visible','off')
                    imshow(I); hold on; title('Reprojected (magenta) and extracted (green) corners.','FontSize',12);
                end

                u(:,:,ind) = [ grid{1,c}.Xp_abs(:,:,i)'; grid{1,c}.Yp_abs(:,:,i)' ];

                % compute the image points with the optimized parameters
                X = rodrigues(param.board{i}.om)*M' + repmat(param.board{i}.T,1,size(M,1));

                if info.method == 14
                    X = X - repmat(param.cam{c}.centered.vp,1,size(M,1));
                end

                utest = reprojection (param, X, info.method, c); 
                uopt(:,:,ind) = reshape(utest,2,size(M,1));

                err_sqrt_mi(:,ind) = sqrt( ( u(1,:,ind)' - uopt(1,:,ind)' ).^2 + ( u(2,:,ind)' - uopt(2,:,ind)' ).^2 );

                if info.visualize_error_flag == 1
                    plot(grid{1,c}.Xp_abs(:,:,i), grid{1,c}.Yp_abs(:,:,i),'g*')
                    t=plot(uopt(1,:,ind),uopt(2,:,ind),'m*');
                    %export_fig( sprintf('%s/Result_Img_%04d_%02d.pdf', result_folder, i, c)  );
                    saveas(t, sprintf('%s/Result_Img_%04d_%02d.png', result_folder, i, c)  );

                   if info.visualize_corners == 2 && info.method ~= 14
                        suptitle(sprintf('Reprojection Error Cam %1d', c),'FontSize',12);
                        subplot(h1,ceil(num/5),5,ind); hold on; axis equal;%grid on;
                        xlabel(num2str(mean(err_sqrt_mi(:,ind))))
                   end

                   if info.method ~= 14
                        xlim(h1,[-3,3]); ylim(h1,[-3,3]);  hold(h1,'on');
                        plot ( h1, u(1,:,ind)' - uopt(1,:,ind)', ...
                            u(2,:,ind)' - uopt(2,:,ind)', '+', 'Color', colors(rem(ind,7)+1));
                   end

                end

                ind = ind + 1;

            end

        end

        err(:,c) = mean(mean(err_sqrt_mi));
        if info.visualize_corners == 1 && info.method ~= 14
            xlabel(h1, sprintf('Error [px] \n Mean Error %s', num2str(err(:,c))),'FontSize',12);
            ylabel(h1, 'Error [px]','FontSize',12);
            title(h1,sprintf('Reprojection Error Cam %1d', c),'FontSize',12);
            set(gca,'FontSize',12);

            %export_fig ( h1, sprintf( '%s/Repro_Error_Cam%02d.pdf', result_folder, c) );
            saveas( h1, sprintf( '%s/Repro_Error_Cam%02d.png', result_folder, c) );
        end

    end

    save(sprintf('%s/Repro_Error.mat', result_folder ), 'err');

    % Save 3D Plot of the checkerboards
    if info.visualize_error_flag == 1
        figure('Name', 'Test', 'Color','w');
        h=axes('FontSize',12);
        for n = 1 : size(param.board,2)
            if images{1,1}.active_images(n) == 1
                M_3d = rigid_motion( M', param.board{n}.om, param.board{n}.T); hold on; 

                nx = info.n_sq_x+1;
                ny = info.n_sq_y+1;

                YYx=reshape(M_3d(1,:),ny,nx);
                YYy=reshape(M_3d(2,:),ny,nx);
                YYz=reshape(M_3d(3,:),ny,nx);

                hhh= mesh(YYx,YYy,YYz); axis equal;
                set(hhh,'edgecolor',colors(rem(n-1,6)+1),'linewidth',1);

            end
        end

        plot3(h,0,0,0,'ko','MarkerFaceColor','k','MarkerSize',8);
        plot3(h,-param.cam{1}.ex_T(1), -param.cam{1}.ex_T(2), -param.cam{1}.ex_T(3),'ko','MarkerFaceColor','k','MarkerSize',8);

        xlabel('x [mm]','FontSize',12);
        ylabel('y [mm]','FontSize',12);
        zlabel('z [mm]','FontSize',12);
        set(gca,'FontSize',12);

        saveas( h, sprintf( '%s/3D_Checkerboards.png', result_folder ) );

    end


    fprintf('Saved in: %s \n', result_folder);

end