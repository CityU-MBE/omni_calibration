clear all; close all; dbstop error;
disp('==========================');

opts = init();
lw = 2;
fs = 14;

load(sprintf('%s/images.mat',info.filename)); 
load(sprintf('%s/calib_%04d.mat',info.filename, info.method)); 


width = images{1}.nx;
height = images{1}.ny;
cam = param.cam{1};

dist_range = logspace(1,5,30);
radius_range = 100:100:700;

figure('Position',[300 300 800 500],'Color','w');

for i=1:length(radius_range)
  r = radius_range(i);
  e = [];
  for dist = dist_range
    [m w] = compute_reflected_ray([width/2+r height/2]',cam);
    p  = m+dist*w;
    %pc = p - cam.centered.vp;
    q1 = projection_centered(cam.centered,p);
    q2 = projection_geometric ([0,0,0], [0;0;0], cam.T, cam.mir(1), cam.mir(2), cam.mir(3), cam.om, cam.k, cam.alpha, cam.f, cam.c, p);
    q3 = centered_map_observations(cam.centered,q2);
    %q4 = projection_geometric ([0,0,0], [0;0;0], tt.param.cam{1}.T, tt.param.cam{1}.mir(1), tt.param.cam{1}.mir(2), ...
    %   tt.param.cam{1}.mir(3), tt.param.cam{1}.om, tt.param.cam{1}.k, tt.param.cam{1}.alpha, tt.param.cam{1}.f, tt.param.cam{1}.c, pc);
    e  = [e; norm(q1-q2) norm(q1-q3)];
  end
  c = color_from_index(i-1);
  loglog(dist_range,e(:,1),'--','Color',c,'LineWidth',lw); hold on;
  loglog(dist_range,e(:,2),'-','Color',c,'LineWidth',lw);
  %loglog(dist_range,e(:,3),'-.','Color',c,'LineWidth',lw);
end

legend('r = 100 (unwarped)','r = 100 (warped)',...
       'r = 200 (unwarped)','r = 200 (warped)',...
       'r = 300 (unwarped)','r = 300 (warped)',...
       'r = 400 (unwarped)','r = 400 (warped)',...
       'r = 500 (unwarped)','r = 500 (warped)',...
       'r = 600 (unwarped)','r = 600 (warped)',...
       'r = 700 (unwarped)','r = 700 (warped)',...
       'Location','NorthEastOutside');
set(gca,'FontSize',fs);
xlabel('Distance [mm]','FontSize',fs);
ylabel('Error [px]','FontSize',fs);

