% Construct the raw features for the highway domain.
function [feature_data,true_feature_map,r] = highwayfeatures(mdp_params,mdp_data)

% mdp_params - definition of MDP domain
% mdp_data - generic definition of domain
% feature_data - generic feature data:
%   splittable - matrix of states to features
%   stateadjacency - sparse state adjacency matrix

% Fill in default parameters.
mdp_params = highwaydefaultparams(mdp_params);

% Construct adjacency table.
stateadjacency = sparse([],[],[],mdp_data.states,mdp_data.states,...
    mdp_data.states*mdp_data.actions);
for s=1:mdp_data.states,
    for a=1:mdp_data.actions,
        stateadjacency(s,mdp_data.sa_s(s,a,1)) = 1;
    end;
end;

% Construct split table.
% Features are the following:
% 1..speeds - indicates current speed.
% 1..lanes - indicates current lane.
% 1..(c1+c2) - closest object of type in front same lane.
% 1..(c1+c2) - closest object of type in back same lane.
% 1..(c1+c2) - closest object of type in front 1 lane left.
% 1..(c1+c2) - closest object of type in back 1 lane left.
% 1..(c1+c2) - closest object of type in front 1 lane right.
% 1..(c1+c2) - closest object of type in back 1 lane right.
% 1..(c1+c2) - closest object of type in front any lane.
% 1..(c1+c2) - closest object of type in back any lane.
tests = mdp_params.speeds+mdp_params.lanes+(mdp_params.c1+mdp_params.c2)*64;
testscont = 2+(mdp_params.c1+mdp_params.c2)*8;
splittable = zeros(mdp_data.states,tests);
splittablecont = zeros(mdp_data.states,testscont);
for s=1:mdp_data.states,
    [x,lane,speed] = highwaystatetocoord(s,mdp_params);
    
    % Write lane and speed features.
    splittable(s,1:mdp_params.speeds) = [ones(1,speed) zeros(1,mdp_params.speeds-speed)];
    splittable(s,mdp_params.speeds+lane) = 1;
    splittablecont(s,1) = speed;
    splittablecont(s,2) = lane;
    
    % Find closest objects in each lane.
    strti = mdp_params.speeds+mdp_params.lanes;
    strtci = 2;
    cnt = (mdp_params.c1+mdp_params.c2)*8;
    ccnt = mdp_params.c1+mdp_params.c2;
    [splittable(s,strti+1:strti+cnt),splittablecont(s,strtci+1:strtci+ccnt)] = ...
        highwayclosestcar(mdp_data,mdp_params,x,lane,1);
    strti = strti+cnt;
    strtci = strtci+ccnt;
    [splittable(s,strti+1:strti+cnt),splittablecont(s,strtci+1:strtci+ccnt)] = ...
        highwayclosestcar(mdp_data,mdp_params,x,lane,-1);
    strti = strti+cnt;
    strtci = strtci+ccnt;
    [splittable(s,strti+1:strti+cnt),splittablecont(s,strtci+1:strtci+ccnt)] = ...
        highwayclosestcar(mdp_data,mdp_params,x,max(1,lane-1),1);
    strti = strti+cnt;
    strtci = strtci+ccnt;
    [splittable(s,strti+1:strti+cnt),splittablecont(s,strtci+1:strtci+ccnt)] = ...
        highwayclosestcar(mdp_data,mdp_params,x,max(1,lane-1),-1);
    strti = strti+cnt;
    strtci = strtci+ccnt;
    [splittable(s,strti+1:strti+cnt),splittablecont(s,strtci+1:strtci+ccnt)] = ...
        highwayclosestcar(mdp_data,mdp_params,x,min(mdp_params.lanes,lane+1),1);
    strti = strti+cnt;
    strtci = strtci+ccnt;
    [splittable(s,strti+1:strti+cnt),splittablecont(s,strtci+1:strtci+ccnt)] = ...
        highwayclosestcar(mdp_data,mdp_params,x,min(mdp_params.lanes,lane+1),-1);
    strti = strti+cnt;
    strtci = strtci+ccnt;
    [splittable(s,strti+1:strti+cnt),splittablecont(s,strtci+1:strtci+ccnt)] = ...
        highwayclosestcar(mdp_data,mdp_params,x,-1,1);
    strti = strti+cnt;
    strtci = strtci+ccnt;
    [splittable(s,strti+1:strti+cnt),splittablecont(s,strtci+1:strtci+ccnt)] = ...
        highwayclosestcar(mdp_data,mdp_params,x,-1,-1);
end;

% Return feature data structure.
feature_data = struct('stateadjacency',stateadjacency,'splittable',splittable);

% Construct true feature map.
true_feature_map = sparse([],[],[],mdp_data.states,...
    mdp_params.r_tree.total_leaves,mdp_data.states);
for s=1:mdp_data.states,
    % Determine which leaf state belongs to.
    [leaf,~] = cartcheckleaf(mdp_params.r_tree,s,feature_data);
    true_feature_map(s,leaf) = 1;
end;

% Fill in the reward function.
R_SCALE = 5;
r = cartaverage(mdp_params.r_tree,feature_data)*R_SCALE;

% Optionally, replace splittable.
if mdp_params.continuous,
    feature_data.splittable = splittablecont;
    feature_data.altsplittable = splittable;
end;
