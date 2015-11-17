function test_derivatives(func,delta,varargin)

% number of derivatives
num = nargout(func);
num = size(varargin,2);

% compute analytical derivatives
%[foo,d_ana{1:num}] = func(varargin{:});
[foo,d_ana{1}] = func(varargin{:});

% output
fprintf('\nDerivative Check for: %s \n', func2str(func));

% for all parameters
for i=1%:num
  
  % for all elements
  for m=1:size(varargin{i+1},1)
    for n=1:size(varargin{i+1},2)
      
      % compute numerical derivative (uncomment to toggle versions)
      %d_num = numerical_derivative_simple(func,delta,varargin,i+1,m,n);
      d_num = numerical_derivative_higher_order(func,delta,varargin,i+1,m,n);

      % print derivative errors
      for m2=1:size(d_num,1)
        for n2=1:size(d_num,2)
          diff_abs = abs(d_num(m2,n2)-d_ana{i}{m2,n2}(m,n));
          diff_rel = diff_abs/max(abs(d_num(m2,n2)),abs(d_ana{i}{m2,n2}(m,n)));
          fprintf('f(%d,%d) d%i (%d,%d) -> num: %+.3e, ana: %+.3e, diff (abs): %+.3e, diff (rel): %+.3e \n', ...
                  m2,n2,i,m,n,d_num(m2,n2),d_ana{i}{m2,n2}(m,n),diff_abs,diff_rel);
        end
      end
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d_num = numerical_derivative_simple (func,delta,parameters,i,m,n)

% create test parameter sets
p1 = parameters;
p2 = parameters;

p1{i}(m,n) = p1{i}(m,n) - delta/2;
p2{i}(m,n) = p2{i}(m,n) + delta/2;

% compute numerical derivatives
d_num = (func(p2{:})-func(p1{:}))/delta;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d_num = numerical_derivative_higher_order (func,delta,parameters,i,m,n)

% create test parameter sets
k=1;
for d=[+2,+1,-1,-2]
  p = parameters;
  p{i}(m,n) = p{i}(m,n) + d*delta;
  f{k} = func(p{:});
  k=k+1;
end

d_num = (-f{1}+8*f{2}-8*f{3}+f{4})/(12*delta);
