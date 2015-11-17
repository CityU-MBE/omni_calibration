function [Y,dYdom,dYdT] = rigid_motion2(X,om,T)

if nargout > 1

  [R,dRdom] = rodrigues(om);

  [m,n] = size(X);

  Y = R* ( X - repmat(T,[1 n]));

  dYdT = repmat(-R,[1,1,n]); 
  
  dYdR = zeros(3,9,n);
  dYdR(1,1:3:end,:) = (X-T*ones(1,n));
  dYdR(2,2:3:end,:) = (X-T*ones(1,n));
  dYdR(3,3:3:end,:) = (X-T*ones(1,n));

  for i=1:n
    dYdom(:,:,i) = dYdR(:,:,i) * dRdom;
  end

else

  R = rodrigues(om);

  [m,n] = size(X);

  Y = R* ( X - repmat(T,[1 n]));

end
