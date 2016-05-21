% This is an alternative function for drawing the highway environment.
% Instead of rendering the entire environment, with different speeds shown
% side-by-side, this function renders a specified portion of the highway
% (with the top wrapped to the bottom), using higher-quality symbols to
% represent the different types of vehicles. The function can also render
% the agent at a specified position, render transition frames, and render
% with either horizontal or vertical orientation.
function highwayrenderframe(r,mdp_params,mdp_data,hlength,orientation,...
    s1,s2,trans_frac,draw_agent,quality)
% r - the reward function of this environment.
% mdp_params - highway parameters.
% mdp_data - data for this MDP.
% length - how much of the highway to draw.
% orientation - 1 for vertical, 2 for horizontal.
% s1 - first state for agent.
% s2 - second state for agent.
% trans_frac - how far the agent is between s1 and s2

% Get state positions.
[x1,lane1,speed1] = highwaystatetocoord(s1,mdp_params);
[x2,lane2,speed2] = highwaystatetocoord(s2,mdp_params);
% Adjust x for boundary.
if x2 < x1,
    x1 = x1 - mdp_params.length;
end;
ax = x1*(1-trans_frac)+x2*trans_frac;
lf = (1-trans_frac)^(speed2);
al = lane1*lf+lane2*(1-lf);
startx = ax-max(1,draw_agent);

% Set up the coordinates.
lanes = mdp_params.lanes;
axis([0 lanes startx startx+hlength]);
set(gca,'xtick',[]);
set(gca,'ytick',[]);
daspect([1 1 1]);
set(gca,'visible','off');
if orientation == 2,
    view(90,-90);
end;

% Colors.
curb_color = [0.35 0.5 0.25];
road_color = [0.35 0.37 0.4];
divider_color = [0.8 0.7 0.6];

% Lengths.
curb = 0.15;
divider = 0.04;
dsp = 0.1;
full_length = [startx-0.1 startx+hlength+0.1 startx+hlength+0.1 startx-0.1];

if ~isempty(r),
    % Draw reward.
    maxr = max(max(r));
    minr = min(min(r));
    rngr = maxr-minr;
    for y=floor(startx-0.01):ceil(startx+hlength+0.01),
        for l=1:lanes,
            % Get state.
            yy = mod(y,mdp_params.length);
            if yy==0,
                yy = mdp_params.length;
            end;
            s = highwaycoordtostate(yy,l,speed1,mdp_params);
            % Draw reward.
            if rngr == 0,
                v = 0.0;
            else
                v = (mean(r(s,:),2)-minr)/rngr;
            end;
            color = [v v v];
            color = min(ones(1,3),max(zeros(1,3),color));
            patch([l-1 l-1 l l],[y-1 y y y-1],color,'EdgeColor','none');
        end;
    end;
else
    % Draw the road.
    patch([0 0 lanes lanes],full_length,road_color,'EdgeColor','none');
end;

% Draw curbs.
patch([0 0 curb curb],full_length,curb_color,'EdgeColor','none');
patch([lanes-curb lanes-curb lanes lanes],full_length,curb_color,'EdgeColor','none');

% Draw the dividers.
for k=1:lanes-1,
    ls = k-divider*0.5;
    le = k+divider*0.5;
    for step=floor(startx):ceil(startx+hlength)+1,
        patch([ls ls le le],[step+dsp-trans_frac step+0.5-dsp-trans_frac step+0.5-dsp-trans_frac step+dsp-trans_frac],divider_color,'EdgeColor','none');
        patch([ls ls le le],[step+0.5+dsp-trans_frac step+1.0-dsp-trans_frac step+1.0-dsp-trans_frac step+0.5+dsp-trans_frac],divider_color,'EdgeColor','none');
    end;
end;

% Draw the cars.
for i=1:size(mdp_data.c1array,1),
    for j=1:size(mdp_data.c1array{i},1),
        % Get colors and position of object.
        y = mdp_data.c1array{i}(j,1);
        y2 = y-mdp_params.length;
        y3 = y+mdp_params.length;
        lane = mdp_data.c1array{i}(j,2);
        c1 = i;
        c2 = mdp_data.map2(y,lane);
        
        if y > startx && y-1 < startx+hlength,
            % Draw the car.
            highwayrenderobject(lane,y,c1,c2,quality);
        end;
        if y2 > startx && y2-1 < startx+hlength,
            % Draw the car.
            highwayrenderobject(lane,y2,c1,c2,quality);
        end;
        if y3 > startx && y3-1 < startx+hlength,
            % Draw the car.
            highwayrenderobject(lane,y3,c1,c2,quality);
        end;
    end;
end;

% Draw the agent.
if draw_agent,
    highwayrenderobject(al,ax,3,1,quality);
end;
