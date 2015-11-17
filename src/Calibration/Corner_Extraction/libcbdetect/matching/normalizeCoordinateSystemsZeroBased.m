function corners = normalizeCoordinateSystemsZeroBased(corners)

% make v1(:,1)+v1(:,2) positive (=> comparable to c++ code)
idx = corners.v1(:,1)+corners.v1(:,2)<0;
corners.v1(idx,:) = -corners.v1(idx,:);

% make all coordinate systems right-handed (reduces matching ambiguities from 8 to 4)
corners_n1 = [corners.v1(:,2) -corners.v1(:,1)];
flip       = -sign(corners_n1(:,1).*corners.v2(:,1)+corners_n1(:,2).*corners.v2(:,2));
corners.v2 = corners.v2.*(flip*ones(1,2));

% convert to 0-based index (standard pixel coordinates, 0-based)
corners.p = corners.p-1;
