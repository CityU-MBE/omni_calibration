%% compute Homography between points on the mirror surface and a checkerboard plane
% M. Schönbein

function [r_resu, T1, H] = compute_omni_Homography (u, M, omni, f, xc, yc)

% compute points on the mirror surface from the image points
for i = 1 : size(u,2)
	Xmir(:,i) = calculate_3d_mirrorpoints (u(:,i), omni.a, omni.b,  f(1), xc, yc, 2*omni.e);
end

M_n(:,1:2) = M(:,1:2);
M_n(:,3) = ones(size(M,1),1);

H = homography2d(M_n', Xmir);

tt = H*M_n(1,:)';
if ( sign(tt(1)) ~= sign(Xmir(1,1)) )
    H = -H;
end
    

Tt = computeExtrinsics(H);
r_resu = rodrigues(Tt(:,1:3));
T1 = Tt(:,4);
R1 = Tt(:,1:3);

