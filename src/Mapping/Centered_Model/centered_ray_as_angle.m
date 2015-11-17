function [a, dadw] = centered_ray_as_angle(w)

if nargin >= 1
    
    a = [atan(w(3,:)./sqrt(w(1,:).*w(1,:)+w(2,:).*w(2,:))); atan2(w(2,:),w(1,:))];

    for i = 1 : size(w,2)
        dadw{1,i}(1,:) = -w(3,i).*w(1,i) ./( (w(1,i).*w(1,i)+w(2,i).*w(2,i)).^(3/2) .*(1+w(3,i).*w(3,i) ./(w(1,i).*w(1,i)+w(2,i).*w(2,i))));
        dadw{1,i}(2,:) = -w(3,i).*w(2,i) ./( (w(1,i).*w(1,i)+w(2,i).*w(2,i)).^(3/2) .*(1+w(3,i).*w(3,i) ./(w(1,i).*w(1,i)+w(2,i).*w(2,i))));
        dadw{1,i}(3,:) = 1./ (sqrt(w(1,i).*w(1,i)+w(2,i).*w(2,i)).*(1+w(3,i).*w(3,i) ./(w(1,i).*w(1,i)+w(2,i).*w(2,i))));
    
        dadw{2,i}(1,:) = -w(2,i)./( w(1,i).*w(1,i).*(1+w(2,i).*w(2,i)./(w(1,i).*w(1,i))));
        dadw{2,i}(2,:) = 1      ./( w(1,i)        .*(1+w(2,i).*w(2,i)./(w(1,i).*w(1,i))));
        dadw{2,i}(3,:) = 0;
    end

else

  % test derivatives
    w = [1013,1013;2220,2220;3150,3150]
    
    test_derivatives(@centered_ray_as_angle,1e-8,w)
    
end