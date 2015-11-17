%% CALCULATE_3D_MIRRORPOINT: Calculates the 3d point on the mirror corresponding to the image points
%   Description:
%    - u: Korresponding Image Point (u;v)
%    - a, b, f, xc, yc, M: intrinic camera calibration
%
%    - Xmir: 3d point on the mirror surface (X,Y,Z)
%   
%   Miriam Schönbein,
%%

function Xmir = calculate_3d_mirrorpoints (u, a, b,  f, xc, yc, M)

e=sqrt(a^2+b^2);

radius	= sqrt ( (u(1) - xc)^2 + (-u(2) + yc)^2 );

%calculate the lambda for the backprojection of the image point to the mirror point
lambdaBack =  M - ((( -e*a*radius^2 + a*M*radius^2 + sqrt (-a^2*radius^2*b^2*f^2 + b^4*f^4 + ... 
		b^2*f^2*radius^2*M^2 + b^2*f^2*radius^2*e^2 - 2*b^2*f^2*radius^2*M*e )) *a) / ... 
		(a^2*radius*radius - b^2*f^2)) - e;
    
R = lambdaBack * radius / f;
Z = sqrt ( 1 + (R^2)/(b^2)) * a - e;            % calculate the corresponding Z coordinate on the mirror	

x = (u(1) - xc);
y = (u(2) - yc);

theta = sign(y) * acos(x/sqrt(x^2+y^2));

X = cos(theta)*R;
Y = sin(theta)*R;

Xmir = [X, Y, Z];