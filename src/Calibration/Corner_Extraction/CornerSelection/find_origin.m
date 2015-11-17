function sel = find_origin (p,cb,max_x,max_y,xc,yc) 


p1 = p(cb(1,1),:);
p2 = p(cb(1,max_x),:);
p3 = p(cb(max_y,max_x),:);
p4 = p(cb(max_y,1),:);
o = [yc xc];

v1 = p1-o;
v2 = p2-o;
v3 = p3-o;
v4 = p4-o;

r1 = norm(v1);
r2 = norm(v2);
r3 = norm(v3);
r4 = norm(v4);
rr = sort([r1 r2 r3 r4]);
rs = rr(end:-1:1);
ri = [0,0,0,0];

for i=1:4
    if(rs(i)==r1)
        ri(i)=1;
    else
        if(rs(i)==r2)
            ri(i)=2;
        else
            if(rs(i)==r3)
                ri(i)=3;
            else
                ri(i)=4;
            end
        end
    end
end

quads = [];
aa = [];

a1 = atan(v1(2)/v1(1));
if(v1(1)>=0 && v1(2)>=0)
    quads = [quads,1];
    aa = [aa,a1];
else if(v1(1)<=0 && v1(2)>=0)
        a1=a1+pi;
        quads = [quads,2];
        aa = [aa,a1];
    else if(v1(1)<=0 && v1(2)<=0)
            a1=a1+pi;
            quads = [quads,3];
            aa = [aa,a1];
        else
            a1=a1+(2*pi);
            quads = [quads,4];
            aa = [aa,a1];
        end
    end
end    

a2 = atan(v2(2)/v2(1));
if(v2(1)>=0 && v2(2)>=0)
    quads = [quads,1];
    aa = [aa,a2];
else if(v2(1)<=0 && v2(2)>=0)
        a2=a2+pi;
        quads = [quads,2];
        aa = [aa,a2];
    else if(v2(1)<=0 && v2(2)<=0)
            a2=a2+pi;
            quads = [quads,3];
            aa = [aa,a2];
        else
            a2=a2+(2*pi);
            quads = [quads,4];
            aa = [aa,a2];
        end
    end
end

a3 = atan(v3(2)/v3(1));
if(v3(1)>=0 && v3(2)>=0)
    quads = [quads,1];
    aa = [aa,a3];
else if(v3(1)<=0 && v3(2)>=0)
        a3=a3+pi;
        quads = [quads,2];
        aa = [aa,a3];
    else if(v3(1)<=0 && v3(2)<=0)
            a3=a3+pi;
            quads = [quads,3];
            aa = [aa,a3];
        else
            a3=a3+(2*pi);
            quads = [quads,4];
            aa = [aa,a3];
        end
    end
end

a4 = atan(v4(2)/v4(1));
if(v4(1)>=0 && v4(2)>=0)
    quads = [quads,1];
    aa = [aa,a4];
else if(v4(1)<=0 && v4(2)>=0)
        a4=a4+pi;
        quads = [quads,2];
        aa = [aa,a4];
    else if(v4(1)<=0 && v4(2)<=0)
            a4=a4+pi;
            quads = [quads,3];
            aa = [aa,a4];
        else
            a4=a4+(2*pi);
            quads = [quads,4];
            aa = [aa,a4];
        end
    end
end

if(ismember([1 4],quads)==[1 1]) %#ok
    for i=1:4
        if(quads(i)==4)
            aa(i)=aa(i)-(2*pi);
            eval(['a' num2str(i) '=aa(i)']);
        end
    end
end

as=sort(aa);
ai=[0,0,0,0];

for i=1:4
    if(as(i)==a1)
        ai(i)=1;
    else
        if(as(i)==a2)
            ai(i)=2;
        else
            if(as(i)==a3)
                ai(i)=3;
            else
                ai(i)=4;
            end
        end
    end
end

sel=ri(1);

for i=1:2
    for j=1:2
        if (ri(i)==ai(j))
            sel=ri(i);
            return;
        end
    end
end

return
    
    
