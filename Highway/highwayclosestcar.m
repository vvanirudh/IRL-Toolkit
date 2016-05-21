% Utility function to find the nearest cars of all types in specific lane
% and in a specific direction.
function [tablerow,tablerowcont] = highwayclosestcar(mdp_data,mdp_params,x,lane,dir)

% Determine distances to each type of object.
c1dsq = mdp_params.length*ones(mdp_params.c1,1);
c2dsq = mdp_params.length*ones(mdp_params.c2,1);
for i=1:mdp_params.c1,
    for j=1:length(mdp_data.c1array{i}),
        if lane == -1 || mdp_data.c1array{i}(j,2) == lane,
            % Compute distance in desired direction.
            d = mdp_data.c1array{i}(j,1)-x;
            if sign(d) ~= dir && d ~= 0,
                d = mdp_params.length*dir+d;
            end;
            d = abs(d);
            c1dsq(i) = min(c1dsq(i),d);
        end;
    end;
end;
for i=1:mdp_params.c2,
    for j=1:length(mdp_data.c2array{i}),
        if lane == -1 || mdp_data.c2array{i}(j,2) == lane,
            % Compute distance in desired direction.
            d = mdp_data.c2array{i}(j,1)-x;
            if sign(d) ~= dir && d ~= 0,
                d = mdp_params.length*dir+d;
            end;
            d = abs(d);
            c2dsq(i) = min(c2dsq(i),d);
        end;
    end;
end;
    
% Build corresponding feature table.
tablerowcont = zeros(1,mdp_params.c1+mdp_params.c2);
tablerow = zeros(1,(mdp_params.c1+mdp_params.c2)*8);
for d=1:8,
    strt = (d-1)*(mdp_params.c1+mdp_params.c2);
    for i=1:mdp_params.c1,
        tablerow(1,strt+i) = c1dsq(i) < d;
    end;
    strt = (d-1)*(mdp_params.c1+mdp_params.c2)+mdp_params.c1;
    for i=1:mdp_params.c2,
        tablerow(1,strt+i) = c2dsq(i) < d;
    end;
end;
for i=1:mdp_params.c1,
    tablerowcont(1,i) = c1dsq(i);
end;
for i=1:mdp_params.c2,
    tablerowcont(1,i+mdp_params.c1) = c2dsq(i);
end;
