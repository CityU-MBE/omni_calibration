function [img,img_du,img_dv,img_angle,img_weight] = imageNormalizationAndGradients(img)

% normalize image
img = img-boxFilterMex(img,100);
img = 2.5*(max(min(img,+0.2),-0.2)+0.2);

% sobel masks
du = [-1 0 1; -2 0 2; -1 0 1]; % sobel (better than scharr)
dv = du';

% compute image derivatives (for principal axes estimation)
img_du     = conv2(double(img),du,'same');
img_dv     = conv2(double(img),dv,'same');
img_angle  = atan2(img_dv,img_du);
img_weight = sqrt(img_du.^2+img_dv.^2);

% correct angle to lie in between [0,pi]
img_angle(img_angle<0)  = img_angle(img_angle<0)+pi;
img_angle(img_angle>pi) = img_angle(img_angle>pi)-pi;

% scale input image
img     = double(img);
img_min = min(img(:));
img_max = max(img(:));
img     = (img-img_min)/(img_max-img_min);
