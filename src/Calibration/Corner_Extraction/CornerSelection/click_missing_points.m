%% Function to click manual the missing points of the automatic corner detection
%
% written by A. Balbaa and M.Schönbein, 02.Aug 2012


function [cor,cb] = click_missing_points (I,cor,cb,xc,yc)

figure(2);
image(I);
colormap(gray(256));
hold on;
plot(cor.p(:,1),cor.p(:,2),'r*');

index = length(cor.p);

nr=input('How many rows/columns are missing from the chessboard? ');

np=input('How many points are there in each missing row/column? ');

lr=input('Are the missing rows/colummns missing from the left or from the right? ([]=Left) ');

disp('Please select corners row by row starting from the leftmost row and select points inwards. ');
disp('Press ENTER when ready to locate missing corners');
pause;


x=[];y=[];xr=[];yr=[];xp=[];yp=[];
ct12=[];cc12=[];
ct23=[];cc23=[];
ct34=[];cc34=[];
ct41=[];cc41=[];
figure(2); hold on;

for n1=1:nr
    
    for n2=1:np
        [xi,yi] = ginput3(1);
        [xxi] = cornerfinder([xi;yi],I,11,11);
        xi = xxi(1);
        yi = xxi(2);
        figure(2);
        plot(xi,yi,'+','color',[ 1.000 0.314 0.510 ],'linewidth',2);
        x = [x;xi];
        y = [y;yi];
        xp = [xp;xi];
        yp = [yp;yi];
        
        ct12 = [ct12;(index+n2+((n1-1)*np))];
        ct23 = [ct23,(index+n2+((n1-1)*np))];
        ct34 = [(index+n2+((n1-1)*np));ct34];
        ct41 = [(index+n2+((n1-1)*np)),ct41];
        
        drawnow;
    end
    
    xr=[xr x];
    yr=[yr y];
    
    cc12=[cc12,ct12];
    cc23=[ct23;cc23];
    cc34=[ct34,cc34];
    cc41=[cc41;ct41];
    
    x=[];y=[];ct12=[];ct23=[];ct34=[];ct41=[];
end

hold off;


cor.p = [cor.p;[xp yp]];


x=size(cb);
if x(1)==np
    orientation=1;
else
    orientation=2;
end



if isempty(lr)
    if orientation==1
        cb=[cc12,cb];
    else
        cb=[cc12';cb];
    end
else
    if orientation==1
        cb=[cb,cc12];
    else
        cb=[cb;cc12'];
    end
end





end







