function [theta, phi] = inverse_projection_centered ( centered, q)

par = zeros(1,6);
par(1:length(centered.param)) = centered.param;

u = q - par(1:2)'*ones(1,size(q,2));

theta = atan2( u(2,:), u(1,:));

for j = 1 : size(theta,2)
    
    m = [par(6), par(5), par(4), par(3)+( par(1) - q(1,j))./cos(theta(j))];

    phiTmp=roots(m);
    res = phiTmp ( find(imag(phiTmp)==0));
    if isempty(res) 
        phi(j)=NaN;
    else
        %phi(j)=min(abs(res));
        %fprintf('Achtung geändert das auch negative Winkel\n');
        phi(j) = res;
    end
end
