function jacPat = calc_JacobianPattern(numCams,num_intrinsics,images,num_cb_params, nM)

    cb_active = images{1}.active_images;
    if numCams==2
        cb_active = cb_active | images{2}.active_images;
    end
    cb_idx = find(cb_active);
    num_cb = length(cb_idx);

    if numCams==1
        jacPat = zeros(num_cb*2*nM,num_intrinsics+num_cb_params*num_cb);
        jacPat(:,1:num_intrinsics) = 1;
        for cb=1:num_cb
            jacPat((1:2*nM)+(cb-1)*2*nM,num_intrinsics+(cb-1)*num_cb_params+(1:num_cb_params)) = 1;
        end
    else
        jacPat = [];
        for i_cam=1:numCams
            cb_active_temp = images{1,i_cam}.active_images;
            cb_idx_temp = find(cb_active_temp);
            num_cb_temp = length(cb_idx_temp);

            % get board world points
            jacPatTemp = zeros(num_cb_temp*2*nM,2*num_intrinsics+6+num_cb_params*num_cb);
            for cb_temp=1:num_cb_temp
                cb = find(cb_idx==cb_idx_temp(cb_temp));
                jacPatTemp((1:2*nM)+(cb_temp-1)*2*nM,2*num_intrinsics+6+(cb-1)*num_cb_params+(1:num_cb_params)) = 1;
            end
            if i_cam==1
                jacPatTemp(:,1:num_intrinsics) = 1;
            else
                jacPatTemp(:,num_intrinsics+(1:(num_intrinsics+6))) = 1;
            end
            jacPat = [jacPat;jacPatTemp];           
       end
    end

end