% Construct the Highway MDP structures.
function [mdp_data,r,feature_data,true_feature_map] = highwaybuild(mdp_params)

% mdp_params - parameters of the objectworld:
%       seed (0) - initialization for random seed
%       length (32) - length of the highway
%       lanes (3) - number of lanes
%       speeds (4) - number of possible speeds
%       num_cars (14,6) - total number of cars of each c1 type
%       c1 (2) - number of primary car types
%       c2 (2) - number of secondary car types
%       determinism (1.0) - probability of correct transition
%       discount (0.9) - temporal discount factor to use
% mdp_data - standard MDP definition structure with object-world details:
%       states - total number of states in the MDP
%       actions - total number of actions in the MDP
%       discount - temporal discount factor to use
%       sa_s - mapping from state-action pairs to states
%       sa_p - mapping from state-action pairs to transition probabilities
%       map1 - mapping from states to c1 colors
%       map2 - mapping from states to c2 colors
%       c1array - array of locations by c1 colors
%       c2array - array of locations by c2 colors
% r - mapping from state-action pairs to rewards

% Fill in default parameters.
mdp_params = highwaydefaultparams(mdp_params);

% Set random seed.
rand('seed',mdp_params.seed);

% Constants.
states = mdp_params.length*mdp_params.lanes*mdp_params.speeds;

% Construct map.
map1 = zeros(mdp_params.length,mdp_params.lanes);
map2 = zeros(mdp_params.length,mdp_params.lanes);
c1array = cell(mdp_params.c1,1);
c2array = cell(mdp_params.c2,1);
carsplaced = 0;
attempt = 0;
while carsplaced < sum(mdp_params.num_cars),
    attempt = attempt+1;
    if attempt > sum(mdp_params.num_cars)*400,
        break;
    end;
    % Determine c1 category of car to place.
    carsum = 0;
    for c1=1:mdp_params.c1,
        carsum = carsum + mdp_params.num_cars(c1);
        if carsplaced < carsum,
            break;
        end;
    end;
    
    % Randomly determine c2 category.
    c2 = ceil(rand(1,1)*mdp_params.c2);

    % Select placement location.
    x = ceil(rand(1,1)*mdp_params.length);
    l = ceil(rand(1,1)*mdp_params.lanes);

    % Check rules.
    carsinlane = 0;
    for cl=1:mdp_params.lanes,
        if map1(x,cl) ~= 0,
            carsinlane = carsinlane + 1;
        end;
    end;
    xb = mod(x - 1 - 1,mdp_params.length)+1;
    xf = mod(x + 1 - 1,mdp_params.length)+1;
    xbb = mod(x - 2 - 1,mdp_params.length)+1;
    xff = mod(x + 2 - 1,mdp_params.length)+1;
    carsb = 0;
    carsf = 0;
    carsbb = 0;
    carsff = 0;
    for cl=1:mdp_params.lanes,
        if map1(xb,cl) ~= 0,
            carsb = carsb + 1;
        end;
        if map1(xbb,cl) ~= 0,
            carsbb = carsbb + 1;
        end;
        if map1(xf,cl) ~= 0,
            carsf = carsf + 1;
        end;
        if map1(xff,cl) ~= 0,
            carsff = carsff + 1;
        end;
    end;

    %fprintf(1,'Trying to place car...\n');
    if map1(x,l) == 0,
        if (carsinlane == 0 && carsb+carsf <= 1 && (carsff == 0 || carsf == 0) && (carsbb == 0 || carsb == 0)) ||...
           (carsinlane == 1 && carsb == 0 && carsf == 0),
            % Add the car here.
            map1(x,l) = c1;
            map2(x,l) = c2;
            c1array{c1} = [c1array{c1};x,l];
            c2array{c2} = [c2array{c2};x,l];
            carsplaced = carsplaced + 1;
            %fprintf(1,'Placed car %i of %i\n',carsplaced,sum(mdp_params.num_cars));
        end;
    end;
end;

% Build action mapping.
sa_s = zeros(states,5,5);
sa_p = zeros(states,5,5);
for x=1:mdp_params.length,
    for lane=1:mdp_params.lanes,
        for spd=1:mdp_params.speeds,
            successors = zeros(1,1,5);
            for action=1:5,
                % Decide on desired new lane and new speed.
                ns = spd;
                nl = lane;
                if action == 1, % Move left.
                    nl = max(1,lane-1);
                elseif action == 2, % Move right.
                    nl = min(mdp_params.lanes,lane+1);
                elseif action == 3, % Slow down.
                    ns = max(1,spd-1);
                elseif action == 4, % Speed up.
                    ns = min(mdp_params.speeds,spd+1);
                else % No action.
                    nl = lane;
                end;
                
                % Check for lane collisions.
                if map1(x,nl) ~= 0,
                    nl = lane;
                end;
                
                % Check for vertical collisions.
                as = ns;
                ax = x;
                for i=2:ns,
                    nx = mod(x+i-1-1,mdp_params.length)+1;
                    if map1(nx,nl) ~= 0,
                        as = i-1;
                        break;
                    end;
                    ax = nx;
                end;
                
                % Construct final coordinate.
                successors(1,1,action) = highwaycoordtostate(ax,nl,as,mdp_params);
            end;
            s = highwaycoordtostate(x,lane,spd,mdp_params);
            sa_s(s,:,:) = repmat(successors,[1,5,1]);
            sa_p(s,:,:) = reshape(eye(5,5)*mdp_params.determinism + ...
                (ones(5,5)-eye(5,5))*((1.0-mdp_params.determinism)/4.0),...
                1,5,5);
        end;
    end;
end;

% Create MDP data structure.
mdp_data = struct(...
    'states',states,...
    'actions',5,...
    'discount',mdp_params.discount,...
    'determinism',mdp_params.determinism,...
    'sa_s',sa_s,...
    'sa_p',sa_p,...
    'map1',map1,...
    'map2',map2,...
    'c1array',{c1array},...
    'c2array',{c2array});

% Construct feature map.
[feature_data,true_feature_map,r] = highwayfeatures(mdp_params,mdp_data);
