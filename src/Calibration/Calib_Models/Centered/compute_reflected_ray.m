function [m2 wr] = compute_reflected_ray(p,cam)

% pixel -> point on image plane 
x = inverse_projection(p,cam.f,cam.c);

% compute intersection point on the mirror surface (TODO: right one?)
[m1, m2, v, c] = inverse_mirror_point(x,cam.R,cam.T,cam.mir);

% normal vector
n = [ m2(1); m2(2); cam.mir(1)*m2(3) + cam.mir(2) / 2 ];
n = n/norm(n);

% camera ray
wi = [ m2(1) - c(1); m2(2)-c(2); m2(3)-c(3)];
wi = wi/norm(wi);

% reflected ray
wr = wi - 2*n * (transpose(wi)*n) / (transpose(n)*n);
