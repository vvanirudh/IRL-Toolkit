% Draw single gridworld with specified reward function.
function gridworlddraw(r,p,g,mdp_params,~,feature_data,model)

% Set up the axes.
n = mdp_params.n;

maxr = max(max(r));
minr = min(min(r));
rngr = maxr-minr;

if iscell(g),
    % This means p is crop.
    crop = p;
else
    crop = [1 n; 1 n];
end;

axis([0  crop(1,2)-crop(1,1)+1  0  crop(2,2)-crop(2,1)+1]);
if ~iscell(g),
    set(gca,'xtick',0:(crop(1,2)-crop(1,1)+1));
    set(gca,'ytick',0:(crop(2,2)-crop(2,1)+1));
else
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
end;
daspect([1 1 1]);

% Draw the reward function.
for y=crop(2,1):crop(2,2),
    for x=crop(1,1):crop(1,2),
        if rngr == 0
            v = 0.0;
        else
            v = (mean(r((y-1)*n+x,:),2)-minr)/rngr;
        end;
        %color = [max(0.0,2.0*(v-0.5)) 1.0-2.0*abs(v-0.5) max(0.0,-2.0*(v-0.5))];
        color = [v v v];
        color = min(ones(1,3),max(zeros(1,3),color));
        rectangle('Position',[x-crop(1,1),y-crop(2,1),1,1],'FaceColor',color);
    end;
end;

if iscell(g),
    % g contains example traces - just draw those.
    for i=1:size(g,1),
        for t=1:size(g,2),
            s = g{i,t}(1);
            a = g{i,t}(2);
            y = floor((s-1)/n)+1;
            x = s-(y-1)*n;
            if x < crop(1,1) || x > crop(1,2) || y < crop(2,1) || y > crop(2,2),
                continue;
            end;
            gridworlddrawagent(x-crop(1,1)+1,y-crop(2,1)+1,a,[1,1,1],1);
        end;
    end;
else
    % Convert p to action mode.
    if size(p,2) ~= 1,
        [~,p] = max(p,[],2);
    end;

    % Draw paths.
    for y=1:n,
        for x=1:n,
            s = (y-1)*n+x;
            a = p(s);
            gridworlddrawagent(x,y,a,[g(s),g(s),g(s)]);
        end;
    end;
end;
