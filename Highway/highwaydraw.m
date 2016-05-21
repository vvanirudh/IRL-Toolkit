% Draw single highway with specified reward function.
function highwaydraw(r,p,g,mdp_params,mdp_data,feature_data,model)

% Set up the axes.
lanes = mdp_params.lanes;
speeds = mdp_params.speeds;
length = mdp_params.length;
axis([0  lanes*speeds  0  length]);
set(gca,'xtick',0:lanes*speeds);
set(gca,'ytick',0:length);
daspect([1 1 1]);

maxr = max(max(r));
minr = min(min(r));
rngr = maxr-minr;

% Draw the reward function.
for x=1:length,
    for lane=1:lanes,
        for spd=1:speeds,
            xpos = (spd-1)*lanes+lane;
            ypos = x;
            s = highwaycoordtostate(x,lane,spd,mdp_params);
            if rngr == 0,
                v = 0.0;
            else
                v = (mean(r(s,:),2)-minr)/rngr;
            end;
            %color = [max(0.0,2.0*(v-0.5)) 1.0-2.0*abs(v-0.5) max(0.0,-2.0*(v-0.5))];
            color = [v v v];
            color = min(ones(1,3),max(zeros(1,3),color));
            rectangle('Position',[xpos-1,ypos-1,1,1],'FaceColor',color);
        end;
    end;
end;

% Convert p to action mode.
if size(p,2) ~= 1,
    [~,p] = max(p,[],2);
end;

% Draw delimiting markers for speeds.
for spd=0:speeds,
    line([spd*mdp_params.lanes spd*mdp_params.lanes],[0 length],'linewidth',2,'color','b');
end;

% Action highway to gridworld conversion table.
actionmap = [ 5 3 4 2 1 ];

if ~isempty(p),
    % Draw paths.
    for x=1:length,
        for lane=1:lanes,
            for spd=1:speeds,
                xpos = (spd-1)*lanes+lane;
                ypos = x;
                s = highwaycoordtostate(x,lane,spd,mdp_params);
                a = p(s);
                % Convert a from highway action to gridworld action.
                a = actionmap(a);
                gridworlddrawagent(xpos,ypos,a,[g(s),g(s),g(s)]);
            end;
        end;
    end;
end;

% Initialize colors.
shapeColors = colormap(lines(mdp_params.c1+mdp_params.c2));

% Draw objects.
for i=1:size(mdp_data.c1array,1),
    for j=1:size(mdp_data.c1array{i},1),
        % Get colors and position of object.
        y = mdp_data.c1array{i}(j,1);
        lane = mdp_data.c1array{i}(j,2);
        c1 = i;
        c2 = mdp_data.map2(y,lane);
        
        for spd=1:speeds,
            x = (spd-1)*lanes+lane;

            % Draw the object.
            rectangle('Position',[x-0.65,y-0.65,0.3,0.3],'Curvature',[1,1],...
                'FaceColor',shapeColors(mdp_params.c1+c2,:),...
                'EdgeColor',shapeColors(c1,:),'LineWidth',1);
        end;
    end;
end;
