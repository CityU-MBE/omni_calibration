function [ocam_model] = find_center_calibration(param, grid, c)
    
    s_xc = param.cam{c}.xc;
    s_yc = param.cam{c}.yc;
    
    ocam_model{1,c}.c = param.cam{c}.c;
    ocam_model{1,c}.d = param.cam{c}.d;
    ocam_model{1,c}.e = param.cam{c}.e;
    ocam_model{1,c}.width = param.cam{c}.width;
    ocam_model{1,c}.height = param.cam{c}.height;

    regwidth    = (ocam_model{1,c}.width/2);
    regheight   = (ocam_model{1,c}.height/2);
    yceil = 5;
    xceil = 5;

    xregstart   = s_xc - (regheight/2);
    xregstop    = s_xc + (regheight/2);
    yregstart   = s_yc - (regwidth/2);
    yregstop    = s_yc + (regwidth/2);

    M = [ grid{1,c}.Xt, grid{1,c}.Yt, zeros(size(grid{1,c}.Xt))]; 

    fprintf(1,'Iteration ');
    for glc=1:9
        [yreg,xreg] = meshgrid ( yregstart:(yregstop-yregstart)/yceil:yregstop+1/yceil, ...
            xregstart:(xregstop-xregstart)/xceil:xregstop+1/xceil);
        ic_proc = [ 1:size(xreg,1) ];
        jc_proc = [ 1:size(xreg,2) ];    
        MSEA=inf*ones(size(xreg));
        for ic=ic_proc
            for jc=jc_proc
                s_xc = xreg(ic,jc);
                s_yc = yreg(ic,jc);
                ocam_model{1,c}.xc = s_xc;
                ocam_model{1,c}.yc = s_yc;
 
                [RRfin,ss] = calibrate ( grid{1,c}.Xt, grid{1,c}.Yt, grid{1,c}.Xp_abs, grid{1,c}.Yp_abs, ...
                    s_xc, s_yc, param.cam{c}.taylor_order, grid{1,c}.ima_proc);
                if RRfin==0
                    MSEA(ic,jc)=inf;
                    continue;
                end
                ocam_model{1,c}.RRfin = RRfin;
                ocam_model{1,c}.ss    = ss;
            
                [m, err, stderr, MSE] = reproject_points ( ocam_model, grid, c, 0, 0, 0, 0);
                
                if ic>1 & jc>1
                    if MSE>MSEA(ic-1,jc)
                        jc_proc(find(jc_proc==jc))=inf;
                        jc_proc=sort(jc_proc);
                        jc_proc=jc_proc(1:end-1);
                        continue;
                    elseif MSE>MSEA(ic,jc-1)
                        break;
                    elseif MSE==NaN
                        break;
                    end
                end
                MSEA(ic,jc)=MSE;
            end
        end
    %    drawnow;
        indMSE=find(min(MSEA(:))==MSEA);
        s_xc = xreg(indMSE(1));
        s_yc = yreg(indMSE(1));
        dx_reg=abs((xregstop-xregstart)/xceil);
        dy_reg=abs((yregstop-yregstart)/yceil);
        xregstart   = s_xc - dx_reg;
        xregstop    = s_xc + dx_reg;
        yregstart   = s_yc - dy_reg;
        yregstop    = s_yc + dy_reg;
        fprintf(1,'%d...',glc);
    end

    fprintf(1,'\n');
    [RRfin,ss] = calibrate ( grid{1,c}.Xt, grid{1,c}.Yt, grid{1,c}.Xp_abs, grid{1,c}.Yp_abs, ...
        s_xc, s_yc, param.cam{c}.taylor_order, grid{1,c}.ima_proc);

    ocam_model{1,c}.RRfin = RRfin;
    ocam_model{1,c}.ss=ss;
    ocam_model{1,c}.xc=s_xc;
    ocam_model{1,c}.yc=s_yc;


