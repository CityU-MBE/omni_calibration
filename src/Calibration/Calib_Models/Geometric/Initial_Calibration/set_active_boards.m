function active = set_active_boards ( images, params )

ind = 1;
active.numberboards = zeros(1,size(images{1,1}.active_images,2));
active.sumboards = 0;
for t = 1 : size(images{1,1}.active_images,2)
    if (images{1,1}.active_images(t) == 1) 
       
        active.board{ind}.om = [1 1 1];
        active.board{ind}.T  = [1 1 1];   
        ind = ind + 1;
        
        active.numberboards(t) = 1;  
        active.sumboards = active.sumboards + 1;
        
    elseif params.calib == 2 && images{1,2}.active_images(t) == 1
       
        active.board{ind}.om = [1 1 1];
        active.board{ind}.T  = [1 1 1];   
        ind = ind + 1;
        
        active.numberboards(t) = 1;  
        active.sumboards = active.sumboards + 1;
    else
        
        active.board{ind}.om = [0 0 0];
        active.board{ind}.T  = [0 0 0];   
        ind = ind + 1;
        
    end
end