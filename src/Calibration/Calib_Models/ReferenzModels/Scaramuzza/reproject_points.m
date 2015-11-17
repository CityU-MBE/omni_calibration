function [m, err, stderr, MSE] = reproject_points ( ocam_model, grids, cam, show_output, plot_error , normalization, normalization_const);

M=[grids{1,cam}.Xt, grids{1,cam}.Yt, zeros(size(grids{1,cam}.Xt))]; 
M(:,3)=1;
%Mc=[]; Xpp=[]; Ypp=[];
count=0; MSE=0;  %u=[];

if (plot_error == 1)
    figure(cam+4);
    set(cam+4,'Name','Analyse error','NumberTitle','off');
    hold on; 
    grid on;
    xlabel('u [pixel]');
    ylabel('v [pixel]');
    title('Reprojection Error in Pixel');
    %zoom on;
    colors = 'brgkcm';
end

for i = grids{1,cam}.ima_proc
%    if (images{1,cam}.active_images(i) ~= 0)
        count = count+1;
        Mc = ocam_model{1,cam}.RRfin(:,:,i)*M';

        [xp1,yp1] = omni3d2pixel(ocam_model{1,cam}.ss, Mc, ocam_model{1,cam}.width, ocam_model{1,cam}.height, normalization_const);
        xp = xp1*ocam_model{1,cam}.c + yp1*ocam_model{1,cam}.d + ocam_model{1,cam}.xc;
        yp = xp1*ocam_model{1,cam}.e + yp1                     + ocam_model{1,cam}.yc; 

        m(:,:,count)= [xp; yp];

        if xp == NaN
            MSE = NaN;
            return;
        end  

        sqerr= ( grids{1,cam}.Xp_abs(:,:,i)-xp' ).^2 + ( grids{1,cam}.Yp_abs(:,:,i)-yp' ).^2;

        err(count)=mean(sqrt(sqerr));
        stderr(count)=std(sqrt(sqerr));
        MSE=MSE+sum(sqerr);

%         figure(cam+4); hold on; axis equal; 
%         grid on; xlim([-5,5]); ylim([-5,5])
%         if (plot_error == 1)
%             plot ( grids{1,cam}.Xp_abs(:,:,i)-xp', grids{1,cam}.Yp_abs(:,:,i)-yp',[num2str(colors(rem(i-1,6)+1)) '+']); hold on;
%         end
        
%         figure(cam+5);
%         subplot(5,5,i); hold on; axis equal; 
%         grid on; xlim([-5,5]); ylim([-5,5])
%         plot ( grids{1,cam}.Xp_abs(:,:,i)-xp',grids{1,cam}.Yp_abs(:,:,i)-yp',[num2str(colors(rem(i-1,6)+1)) '+']); hold on;
%    end
end

hold off; %grid on;

if (show_output == 1)
    fprintf(1,'\n Average reprojection error computed for each chessboard [pixels]:\n\n');
    for i=1:length(err)
        fprintf(' %3.2f � %3.2f\n',err(i),stderr(i));
    end

    fprintf(1,'\n Average error [pixels]\n\n %f\n',mean(err));
    fprintf(1,'\n Sum of squared errors\n\n %f\n',MSE);
end
