function P = projection_mei ( xi, kc, alpha_c, gammac, cc, V)

%V = [1 0 0; 0 -1 0; 0 0 -1]*V;
V = -V;

% changed this line ...
XI = [ xi; kc'; alpha_c; gammac(1); gammac(2); 0; 0];
% ... to this one
%XI = [ xi; kc'; alpha_c; gammac(1); gammac(2); cc(1); cc(2)];

%V = rigid_motion_quat (M, Qw, Tw)
% changed this line ...
%P = spaceToNPlane(-V,XI(1));
P = spaceToNPlane(V,XI(1));

P = distortion(P, XI(2:6));
P = NPlaneToImgPlane(P, XI(7:11));

%P(1,:) = cc(1)+P(1,:);
%P(2,:) = cc(2)-P(2,:);

P(1,:) = cc(1)-P(1,:);
P(2,:) = cc(2)-P(2,:);