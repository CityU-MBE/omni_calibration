% Inverse Projection Cam, A, B, C, omm, k, alpha, f, c, M)
function xx = inverse_projection ( u, f, c)

% Pixel coordinates:
xx(1,:) = 1 / f(1) * (u(1,:) - c(1));
xx(2,:) = 1 / f(2) * (u(2,:) - c(2));
    
end
