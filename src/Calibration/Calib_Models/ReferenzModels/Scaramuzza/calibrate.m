
function [RRfin,ss]=calibrate(Xt, Yt, Xp_abs, Yp_abs, xc, yc, taylor_order_default, ima_proc)
Yp=Yp_abs-yc;
Xp=Xp_abs-xc;

for kk = ima_proc
    
    Ypt=Yp(:,:,kk);
    Xpt=Xp(:,:,kk);
    
    %Building the matrix
    A=[Xt.*Ypt, Yt.*Ypt, -Xt.*Xpt, -Yt.*Xpt, Ypt, -Xpt];
%    [V,D]=eig(A'*A);
    [U,S,V] = svd(A);
    
%     %Solving for computing the scale factor Lambda
    R11=V(1,end);
    R12=V(2,end);
    R21=V(3,end);
    R22=V(4,end);
    T1=V(5,end);
    T2=V(6,end);
    
    AA=( (R11*R12)+(R21*R22) )^2;
    BB=R11^2+R21^2;
    CC=R12^2+R22^2;
    R32_2=roots([ 1 , CC-BB , -AA ]);
    R32_2=R32_2( find(R32_2>=0));
    
    R31=[];
    R32=[];
    sg=[1,-1];
    for i=1:length( R32_2 )
        for j=1:2
            sqrtR32_2= sg(j) * sqrt( R32_2(i) );
            R32=[ R32 ; sqrtR32_2 ];
            if R32_2==0 %<= 0.00000001 * (R12^2+R22^2) %that is like R32==0
                R31=[ R31 ; sqrt(CC-BB) ];
                R31=[ R31 ;-sqrt(CC-BB) ];
                R32=[ R32 ; sqrtR32_2];
            else
                R31=[ R31 ; -sqrtR32_2\(R11*R12+R21*R22) ];
            end
        end
    end

    RR=zeros(3,3,length(R32)*2);
    count=0;
    for i1=1:length(R32)
        for i2=1:2
            count=count+1;
            Lb=sqrt(R11^2+R21^2+R31(i1)^2)\1;
            RR(:,:,count)=sg(i2) * Lb * [ R11     R12     T1;
                                          R21     R22     T2;
                                          R31(i1) R32(i1) 0];
        end
    end
    
    RR1=[];
    count2=0;
    for count=1:size(RR,3)
        if ( sign(RR(1,3,count))==sign(Xpt(1)) && sign(RR(2,3,count))==sign(Ypt(1)) )
            count2=count2+1;
            RR1(:,:,count2)=RR(:,:,count);
        end
    end
    
    if isempty(RR1)
        RRfin=0;
        ss=0;
        return;
    end
    
%    figure(1); imagesc(aa(:,:,:,counter)); set(h,'name',filename);    
    nm=plot_RR(RR1, Xt, Yt, Xpt, Ypt, 0);
    %nm=input('Which of the following is the correct matrix? type < 1 or 2>: ');
    
    RRdef=RR1(:,:,nm);
    RRfin(:,:,kk)=RRdef;    

end

%Run program finding mirror and translation parameters
[RRfin,ss]=omni_find_parameters_fun(Xt, Yt, Xp_abs, Yp_abs, xc, yc, RRfin, taylor_order_default, ima_proc);

function [RRfin,ss]=omni_find_parameters_fun(Xt, Yt, Xp_abs, Yp_abs, xc, yc, RRfin, taylor_order, ima_proc)

Yp=Yp_abs-yc;
Xp=Xp_abs-xc;

PP=[];
QQ=[];
count=0;
for i = ima_proc,
    count=count+1;
    
    RRdef=RRfin(:,:,i);
    
    R11=RRdef(1,1);
    R21=RRdef(2,1);
    R31=RRdef(3,1);
    R12=RRdef(1,2);
    R22=RRdef(2,2);
    R32=RRdef(3,2);
    T1=RRdef(1,3);
    T2=RRdef(2,3);
    
    Xpt=Xp(:,:,i);
    Ypt=Yp(:,:,i);
    
    MA= R21.*Xt + R22.*Yt + T2;
    MB= Ypt.*( R31.*Xt + R32.*Yt );
    MC= R11.*Xt + R12.*Yt + T1;
    MD= Xpt.*( R31.*Xt + R32.*Yt );
    
    rho=[];
    for j=2:taylor_order
        rho(:,:,j)= (sqrt(Xpt.^2 + Ypt.^2)).^j;
    end
    
    PP1=[MA;MC];
    for j=2:taylor_order
        PP1=[ PP1, [MA.*rho(:,:,j);MC.*rho(:,:,j)] ];
    end
     
         
    
    PP=[PP   zeros(size(PP,1),1); 
        PP1, zeros(size(PP1,1),count-1) [-Ypt;-Xpt]];
    QQ=[QQ;
        MB; MD];
end

s=pinv(PP)*QQ;
ss=s(1:taylor_order);
count=0;
for j=ima_proc,
    count=count+1;
    RRfin(3,3,j) = s( length(ss) + count );
end
ss=[ss(1);0;ss(2:end)];

function index=plot_RR(RR, Xt, Yt, Xpt, Ypt, figure_number)

if figure_number>0
    figure(figure_number);
end
for i=1:size(RR,3)
    RRdef=RR(:,:,i);
    R11=RRdef(1,1);
    R21=RRdef(2,1);
    R31=RRdef(3,1);
    R12=RRdef(1,2);
    R22=RRdef(2,2);
    R32=RRdef(3,2);
    T1=RRdef(1,3);
    T2=RRdef(2,3);
    
    MA= R21.*Xt + R22.*Yt + T2;
    MB= Ypt.*( R31.*Xt + R32.*Yt );
    MC= R11.*Xt + R12.*Yt + T1;
    MD= Xpt.*( R31.*Xt + R32.*Yt );
    rho= sqrt(Xpt.^2 + Ypt.^2);
    rho2= (Xpt.^2 + Ypt.^2);
    
    PP1=[MA, MA.*rho, MA.*rho2;
         MC, MC.*rho, MC.*rho2];
    
    PP=[PP1, [-Ypt;-Xpt]];
    
    QQ=[MB; MD];
    
    s=pinv(PP)*QQ;
    ss=s(1:3);
    if figure_number>0
        subplot(1,size(RR,3),i); plot(0:620,polyval([ss(3) ss(2) ss(1)],[0:620])); grid; axis equal;
    end
    if ss(end)>=0
        index=i;
    end
end


