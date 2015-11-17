% Copyright 2012. All rights reserved.
% Author: Andreas Geiger
%         Institute of Measurement and Control Systems (MRT)
%         Karlsruhe Institute of Technology (KIT), Germany

% This is free software; you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or any later version.

% This software is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
% PARTICULAR PURPOSE. See the GNU General Public License for more details.

% You should have received a copy of the GNU General Public License along with
% this software; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA 02110-1301, USA 

function idx = nonMaximumSuppressionSparse(p,s,n,img_size)

p = round(p);
w = img_size(2);
h = img_size(1);

% add noise to make maximum unique
s = s + 1e-10*randn(size(s));

S = zeros(img_size);
for i=1:size(p,1)
  S(p(i,2),p(i,1)) = max(S(p(i,2),p(i,1)),s(i));
end

idx = [];
for i=1:size(p,1)
  u = p(i,1);
  v = p(i,2);
  if s(i)<max(max(S(max(v-n,1):min(v+n,h),max(u-n,1):min(u+n,w))))
    idx = [idx i];
  end
end
