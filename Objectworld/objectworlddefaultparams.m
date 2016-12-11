% Fill in default parameters for the objectworld example.
function mdp_params = objectworlddefaultparams(mdp_params)

% Create default parameters.
default_params = struct(...
    'seed',0,...
    'n',32,...
    'placement_prob',0.05,...
    'c1',2,...
    'c2',2,...
    'continuous',0,...
    'determinism',1.0,...
    'discount',0.9);

% Set parameters.
mdp_params = filldefaultparams(mdp_params,default_params);

% Construct default reward tree.
c1 = mdp_params.c1;
c2 = mdp_params.c2;
step = c1+c2;
%{
r_tree = struct('type',1,'test',1+step*2,'total_leaves',3,...       % Test distance to c1 1 shape
    'gtTree',struct('type',0,'index',1,'mean',[-2,-2,-2,-2,-2]),... % Penalty for beeing close to c1 1 shape
    'ltTree',struct('type',1,'test',2+step*1,'total_leaves',2,...   % Test distance to c1 2 shape
        'gtTree',struct('type',0,'index',2,'mean',[1 1 1 1 1]),...  % Reward for being close
        'ltTree',struct('type',0,'index',3,'mean',[0 0 0 0 0])));   % Neutral reward for any other state.
%}
%{
r_tree = struct('type',1,'test',1+step*2,'total_leaves',3,...       % Test distance to c1 1 shape
    'ltTree',struct('type',0,'index',1,'mean',[0,0,0,0,0]),... % Neutral reward for being elsewhere
    'gtTree',struct('type',1,'test',2+step*1,'total_leaves',2,...   % Test distance to c1 2 shape
        'gtTree',struct('type',0,'index',2,'mean',[1 1 1 1 1]),...  % Reward for being close
        'ltTree',struct('type',0,'index',3,'mean',[-2 -2 -2 -2 -2])));   % Penalty otherwise
%}

r_tree = struct('type',1,'test',1+step*2,'total_leaves',3,...       % Test distance to c1 1 shape
    'ltTree',struct('type',0,'index',1,'mean',[0,0,0,0,0]),... % Neutral reward for being elsewhere
    'gtTree',struct('type',1,'test',2+step*1,'total_leaves',2,...   % Test distance to c1 2 shape
        'gtTree',struct('type',0,'index',2,'mean',[1 1 1 1 1]),...  % Reward for being close
        'ltTree',struct('type',0,'index',3,'mean',[2 2 2 2 2])));   % Penalty otherwise
    
% Create default parameters.
default_params = struct(...
    'r_tree',r_tree);

% Set parameters.
mdp_params = filldefaultparams(mdp_params,default_params);
