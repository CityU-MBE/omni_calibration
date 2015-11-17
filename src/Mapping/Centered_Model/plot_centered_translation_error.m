clear all; close all; dbstop error;
disp('==========================');

opts = init();
info = config();
lw = 2;
fs = 14;

load(sprintf('%s/images.mat',info.filename)); 
load(sprintf('%s/calib_%04d.mat',info.filename, info.method)); 


width = images{1}.nx;
height = images{1}.ny;
cam = param.cam{1};

dist_range = logspace(1,5,30);
radius_range = 1:5:700;

e = [];
a = [];
for i=1:length(radius_range)
  r = radius_range(i);
  [m w] = compute_reflected_ray([width/2+r height/2]',cam);
  a(:,i) = centered_ray_as_angle(w);
  H = [1-w(1)*w(1)  -w(1)*w(2)  -w(1)*w(3); ...
        -w(2)*w(1) 1-w(2)*w(2)  -w(2)*w(3); ...
        -w(3)*w(1)  -w(3)*w(2) 1-w(3)*w(3)];
  b = m - w*(m'*w);
  m = [0 0 0]';
  w = [0 0 1]';
  H = H + [1-w(1)*w(1)  -w(1)*w(2)  -w(1)*w(3); ...
            -w(2)*w(1) 1-w(2)*w(2)  -w(2)*w(3); ...
            -w(3)*w(1)  -w(3)*w(2) 1-w(3)*w(3)];
  b = b + m - w*(m'*w);
  e(i) = norm(cam.centered.vp-H\b);
end

figure('Position',[300 300 640 480],'Color','w');
plot(radius_range,e,'-b','LineWidth',lw);
%plot(a(,:),e,'-b','LineWidth',lw);

set(gca,'FontSize',fs);
xlabel('Radius [px]','FontSize',fs);
ylabel('Error [mm]','FontSize',fs);

