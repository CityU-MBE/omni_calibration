function [mirR,ind] = mirror_point_mir (z_mir, A, B, C, CamR, XR)

err_min = 100000;
    
x_mir = zeros (4, length(z_mir));
y_mir = zeros (2, length(z_mir));

for i = 1 : length(z_mir)
    if isreal(z_mir(i))
        if (z_mir(i) > 0) % Für Kamerapositionen unterhalb des Spiegel muss der z-Wert positiv sein.

            indt = 0;
            % calculate the cc parameters for the polynom coefficients

            % (see Apendix)
            %[c1, c2, c3] = calculate_cc_coefficients (A, B, C, CamR, XR, z_mir(i));
            c = calculate_cc_coefficientsMex ([A, B, CamR(2), CamR(3), XR(1), XR(2), XR(3), z_mir(i)]);

            aa2 = c(1)^2+c(2)^2;
            bb2 = 2*c(2)*c(3);
            cc2 = c(3)^2 + c(1)^2*(A*z_mir(i)^2 + B*z_mir(i) - C);

            % calculate the y coordinate of the mirror point
            y_mir(1,i) = (-bb2 + sqrt(bb2^2-4*aa2*cc2)) / (2*aa2);
            y_mir(2,i) = (-bb2 - sqrt(bb2^2-4*aa2*cc2)) / (2*aa2);

            for j = 1 : 2

                % calculate the x coordinate of the mirror point
                x_mir((j-1)*2+1,i) =  sqrt(C - A*z_mir(i)^2 - B*z_mir(i) - y_mir(j,i)^2);
                x_mir((j-1)*2+2,i) = -sqrt(C - A*z_mir(i)^2 - B*z_mir(i) - y_mir(j,i)^2);

                for n = 1 : 2
                    indt = indt + 1;
                    vi =  [x_mir(indt,i); y_mir(j,i); z_mir(i)] - CamR;
                    nr  = [x_mir(indt,i); y_mir(j,i); A*z_mir(i) + B/2];
                    vr = XR - [x_mir(indt,i); y_mir(j,i); z_mir(i)];

                    li = vi'/norm(vi)*nr;
                    lr = vr'/norm(vr)*nr;

                    err = abs(li+lr);

                    if err < err_min
                        err_min = err;

                        z = z_mir(i);
                        y = y_mir(j,i);
                        x = x_mir(indt,i);
                        ind = [j,indt];
                    end
                end
            end
        end
    end
end

% Point on the mirror surface in the rotated coordinate system (mR = (xp, yp, zp) 
mirR = [x; y; z];