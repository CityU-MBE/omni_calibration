% 
function m = projection_scaramuzza ( ss, width, height, c, d, e, xc, yc, M, normalization_const)

[xp1,yp1] = omni3d2pixel(ss, M, width, height, normalization_const);
        
xp = xp1*c + yp1*d + xc;
yp = xp1*e + yp1   + yc; 
        
m = [xp; yp];