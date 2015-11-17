function [x,y] = omni3d2pixel(ss, xx, width, height, normalization_const)

uMax = normalization_const;

%convert 3D coordinates vector into 2D pixel coordinates
m=xx(3,:)./sqrt(xx(1,:).^2+xx(2,:).^2);

rho=[];
poly_coef=ss(end:-1:1);
poly_coef_tmp=poly_coef;
for j=1:length(m)
    poly_coef_tmp(end-1)=poly_coef(end-1)-m(j);
    rhoTmp=roots(poly_coef_tmp)*uMax;
    res=rhoTmp(find(imag(rhoTmp)==0 & rhoTmp>0 & rhoTmp<height ));
    if isempty(res) %| length(res)>1
       % fprintf('No valid image point: in "omni3d2pixel.m"\n')
        rho(j)=10000;
    else
        rho(j)=min(res);
    end
end
x = xx(1,:)./sqrt(xx(1,:).^2+xx(2,:).^2).*rho ;
y = xx(2,:)./sqrt(xx(1,:).^2+xx(2,:).^2).*rho ;