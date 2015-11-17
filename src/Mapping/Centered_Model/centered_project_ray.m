function [q, dq] = centered_project_ray(param,a)

if nargin >= 1

    par = zeros(1,6);
    par(1:length(param)) = param;
    
    r = par(3)+par(4)*a(1,:)+par(5)*a(1,:).^2+par(6)*a(1,:).^3;
    q = par(1:2)'*ones(1,size(a,2)) + [r.*cos(a(2,:));r.*sin(a(2,:))];

    drda1 = par(4) + 2*par(5)*a(1,:) + 3*par(6)*a(1,:).^2;
    
    for i = 1 : size(a,2)
        dq{1,i}(1,:) = [ drda1(:,i).*cos(a(2,i))];
        dq{1,i}(2,:) = - r(:,i).*sin(a(2,i));

        dq{2,i}(1,:) = drda1(:,i).*sin(a(2,i));
        dq{2,i}(2,:) = r(:,i).*cos(a(2,i));
    end
    
else
        
    % test derivatives
    param = 1.0e+02 * [ 6.711071357634459, 7.275922086378131, 5.244395950538145, 5.773487216067772, 3.336883634746558, 1.403245865693434];
    a = [0.1,0.1;1.3,1.3];
    
    test_derivatives(@centered_project_ray,1e-8,param,a)
    
end