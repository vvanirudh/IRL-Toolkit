% Draw single objectworld with specified reward function.
function objectworlddraw(r,p,g,mdp_params,mdp_data,feature_data,model)

% Use gridworld drawing function to draw paths and reward function.
if nargin == 5,
    gridworlddraw(r,p,g,mdp_params,mdp_data);
elseif nargin == 6,
    gridworlddraw(r,p,g,mdp_params,mdp_data,feature_data);
elseif nargin == 7,
    gridworlddraw(r,p,g,mdp_params,mdp_data,feature_data,model);
end;

% Initialize colors.
shapeColors = colormap(lines(mdp_params.c1+mdp_params.c2));

if iscell(g),
    % This means p is crop.
    crop = p;
else
    crop = [1 mdp_params.n; 1 mdp_params.n];
end;

% Draw objects.
for i=1:length(mdp_data.c1array),
    for j=1:length(mdp_data.c1array{i}),
        % Get colors and position of object.
        s = mdp_data.c1array{i}(j);
        c1 = i;
        c2 = mdp_data.map2(s);
        y = ceil(s/mdp_params.n);
        x = s-(y-1)*mdp_params.n;
        if x < crop(1,1) || x > crop(1,2) || y < crop(2,1) || y > crop(2,2),
            continue;
        end;
        x = x-crop(1,1)+1;
        y = y-crop(2,1)+1;
        
        % Draw the object.
        rectangle('Position',[x-0.65,y-0.65,0.3,0.3],'Curvature',[1,1],...
            'FaceColor',shapeColors(mdp_params.c1+c2,:),...
            'EdgeColor',shapeColors(c1,:),'LineWidth',2);
    end;
end;
