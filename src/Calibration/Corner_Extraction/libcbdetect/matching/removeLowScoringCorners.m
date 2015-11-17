function corners = removeLowScoringCorners(corners,tau)

idx = corners.score<tau;
corners.p(idx,:)   = [];
corners.r(idx,:)   = [];
corners.v1(idx,:)  = [];
corners.v2(idx,:)  = [];
corners.score(idx) = [];