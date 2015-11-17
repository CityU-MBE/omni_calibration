function weight_mask = weightMask(radius)

weight_mask = [];
for r=radius
  weight_mask{r} = zeros(r*2+1,r*2+1);
  for u=1:r*2+1
    for v=1:r*2+1
      dist = sqrt((u-r-1)*(u-r-1)+(v-r-1)*(v-r-1))/r;
      dist = min(max(dist,0.7),1.3);
      weight_mask{r}(v,u) = (1.3-dist)/0.6;
    end
  end
end
