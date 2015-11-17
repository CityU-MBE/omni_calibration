%% Compute the Rotation Matrix for the Mapping function
% compute R and dRR'

function [RR, dRR] = compute_RR_new( Cam )

if nargin == 1

RR = [  Cam(2)/sqrt( Cam(1)^2 + Cam(2)^2 ), -Cam(1)/sqrt( Cam(1)^2 + Cam(2)^2 ), 0;
        Cam(1)/sqrt( Cam(1)^2 + Cam(2)^2 ),  Cam(2)/sqrt( Cam(1)^2 + Cam(2)^2 ), 0;
        0,         0,        1 ];

if (Cam(1) == 0 && Cam(2) == 0) 
    RR = eye(3,3); 
end

    dRR{1,1} = [ -Cam(2)*Cam(1) / (Cam(1)^2 + Cam(2)^2)^(3/2);                      1/sqrt(Cam(1)^2+Cam(2)^2) - Cam(2)^2/(Cam(1)^2+Cam(2)^2)^(3/2); 0];
    dRR{1,2} = [ -1/sqrt(Cam(1)^2+Cam(2)^2) + Cam(1)^2/(Cam(1)^2+Cam(2)^2)^(3/2);   Cam(2)*Cam(1)/(Cam(1)^2+Cam(2)^2)^(3/2);                        0];
    dRR{1,3} = [ 0; 0; 0];
    dRR{2,1} = [  1/sqrt(Cam(1)^2+Cam(2)^2) - Cam(1)^2/(Cam(1)^2+Cam(2)^2)^(3/2);   -Cam(2)*Cam(1)/(Cam(1)^2+Cam(2)^2)^(3/2);                       0];
    dRR{2,2} = [ -Cam(2)*Cam(1) / (Cam(1)^2 + Cam(2)^2)^(3/2);                      1/sqrt(Cam(1)^2+Cam(2)^2) - Cam(2)^2/(Cam(1)^2+Cam(2)^2)^(3/2); 0];
    dRR{2,3} = [ 0; 0; 0];
    dRR{3,1} = [ 0; 0; 0];
    dRR{3,2} = [ 0; 0; 0];
    dRR{3,3} = [ 0; 0; 0];
    

   

else 

    e = 34;
    Cam = [1; 2; -e];
    test_derivatives(@compute_RR_new,1e-8,Cam);

end