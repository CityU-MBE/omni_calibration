function T = computeExtrinsics(H)

lambda  = 1/norm(H(:,1));
R(:,1)  = lambda*H(:,1);
R(:,2)  = lambda*H(:,2);
R(:,3)  = cross(R(:,1),R(:,2));
t       = lambda*H(:,3);
[U,S,V] = svd(R);
T   = [U*V' t];
