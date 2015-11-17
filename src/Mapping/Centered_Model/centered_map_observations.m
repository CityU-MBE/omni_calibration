function q_centered = centered_map_observations(centered,q_obs)

width  = size(centered.Qu,2);
height = size(centered.Qu,1);

u = (q_obs(1,:)+width)/4+1;
v = (q_obs(2,:)+height)/4+1;

q_centered(1,:) = interp2(centered.Qu,u,v,'cubic');
q_centered(2,:) = interp2(centered.Qv,u,v,'cubic');
