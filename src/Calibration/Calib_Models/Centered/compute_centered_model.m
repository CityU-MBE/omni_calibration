%% Compute the parameters of the centered model
% M. Schönbein 2013

function [cam,resnorm] = compute_centered_model ( param, images, M, grid)

resnorm = [];
dims = [images{1}.nx images{1}.ny];

for c = 1:length(param.cam)   
  cam{c} = centered_camera(param.cam{c},dims);
  for b = 1:size(param.board,2)
    if images{1,c}.active_images(b) == 1
        
       % move boards to vp (param.board{b}.T - vp)
       param.board{b}.T = param.board{b}.T - cam{c}.centered.vp;
        
      [om,T] = compose_motion(param.board{b}.om, param.board{b}.T, param.cam{c}.ex_om, param.cam{c}.ex_T);
      p = rodrigues(om)*M' + repmat(T,1,size(M,1));
      q_obs = centered_map_observations(cam{c}.centered, [grid{1,c}.Xp_abs(:,:,b), grid{1,c}.Yp_abs(:,:,b)]');
      q_est = projection_centered(cam{c}.centered,p);
      q_diff = q_obs-q_est;
      resnorm = [resnorm; q_diff(:).^2];
    end
  end
end

resnorm = sum(resnorm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cam = centered_camera(cam,dims)

width  = dims(1)+mod(dims(1),2);
height = dims(2)+mod(dims(2),2);
num_rays = 50;
radius = min(width,height)/2;

% pre-compute rotation matrix
cam.R = rodrigues(cam.om);

% init H and b (linear system to estimate v)
H = zeros(3,3);
b = zeros(3,1);
q = [];
a = [];

% compute H and b (linear system to estimate v)
for u=round(linspace(1,width-2,num_rays))
  for v=round(linspace(1,height-2,num_rays))
    du = u-width/2;
    dv = v-height/2;
    if du*du+dv*dv<=radius*radius && du*du+dv*dv>=0.3*0.3*radius*radius
      [m w] = compute_reflected_ray([u v]',cam);
      H = H + [1-w(1)*w(1)  -w(1)*w(2)  -w(1)*w(3); ...
                -w(2)*w(1) 1-w(2)*w(2)  -w(2)*w(3); ...
                -w(3)*w(1)  -w(3)*w(2) 1-w(3)*w(3)];
      b = b + m - w*(m'*w);
      q = [q [u;v]];
      a = [a centered_ray_as_angle(w)];
    end
  end
end

% compute viewpoint
cam.centered.vp = H\b;

% compute model parameters
centered_param0 = [width/2 height/2 zeros(1,4)];
f = @(x) reproj_error(x,q,a);
[cam.centered.param,resnorm] = lsqnonlin(f,centered_param0);

if 0
  diff = centered_project_ray(cam.centered.param,a)-q;
  figure,hold on;
  quiver(q(1,:),q(2,:),diff(1,:),diff(2,:),0,'Color','b','LineWidth',1);
  set(gca,'ydir','reverse');
  xlim([0 width]); ylim([0 height]);
  keyboard;
end

% init Q
cam.centered.Qu = zeros(height/2,width/2);
cam.centered.Qv = zeros(height/2,width/2);

% compute mirror points M and reflected rays W
for i=1:height/2
  fprintf('Observation map: %d/%d\n',i,height/2)
  for j=1:width/2
    u = (j-1)*4-width/2;
    v = (i-1)*4-height/2;
    [m w] = compute_reflected_ray([u v]',cam);          % with non SVP model
    a = centered_ray_as_angle(w);
    q = centered_project_ray(cam.centered.param,a);
    cam.centered.Qu(i,j) = q(1);
    cam.centered.Qv(i,j) = q(2);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function err = reproj_error(param,q,a)

err = centered_project_ray(param,a)-q;
err = err(:);
