% Draw arrow indicating optimal action at specified position.
function gridworlddrawagent(x,y,a,color,overlap)

if nargin < 5,
    overlap = 0;
end;

w = 1+(overlap>=1)*0.5;

if (a == 1),
    rectangle('Position',[x-0.6,y-0.6,0.2,0.2],'FaceColor',color,'Curvature',[1 1],'LineWidth',w);
else
    if a == 5,
        nx = x-1;
        ny = y;
    elseif a == 4,
        nx = x;
        ny = y-1;
    elseif a == 3,
        nx = x+1;
        ny = y;
    elseif a == 2,
        nx = x;
        ny = y+1;
    end;
    vec = [(nx-x)*0.25;(ny-y)*0.25];
    norm1 = [vec(2),-vec(1)];
    norm2 = -norm1;
    xv = [x-0.5+vec(1),x-0.5+norm1(1),x-0.5+norm2(1)];
    yv = [y-0.5+vec(2),y-0.5+norm1(2),y-0.5+norm2(2)];
    if overlap == 1,
    	xv = xv + vec(1)*0.75;
    	yv = yv + vec(2)*0.75;
    end;
    xv = [xv xv(1)];
    yv = [yv yv(1)];
    patch(xv,yv,color,'LineWidth',w); 
end;

