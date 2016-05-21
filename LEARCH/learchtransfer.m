% Transfer learned reward function to a new state space.
function irl_result = learchtransfer(prev_result,mdp_data,mdp_model,...
    feature_data,true_feature_map,verbosity)

% Get latest model.
model = prev_result.model_itr{end};

% Compute reward function.
s = zeros(mdp_data.states,1);
F = feature_data.splittable';
if isfield(model,'trees'),
    for i=1:length(model.trees),
        newCol = zeros(mdp_data.states,1);
        mat = F'>0;
        for s=1:mdp_data.states,
            newCol(s,1) = mmpboostevaltree(model.trees{i},s,mat);
        end;
        F = vertcat(F,newCol');
    end;
end;
if isfield(model,'logistics'),
    for i=1:length(model.logistics),
        newCol = learchevallogistic(model.logistics{i},F');
        F = vertcat(F,newCol');
    end;
end;
if isfield(model,'linweights'),
    s = s+F'*model.linweights;
end;

% Compute reward.
r = repmat(-exp(s-max(s)+log(10)),1,mdp_data.actions);

% Solve MDP.
soln = feval([mdp_model 'solve'],mdp_data,r);
v = soln.v;
q = soln.q;
p = soln.p;

% Build IRL result.
irl_result = struct('r',r,'v',v,'p',p,'q',q,'model_itr',{{prev_result.model_itr{end}}},...
    'r_itr',{{r}},'model_r_itr',{{r}},'p_itr',{{p}},'model_p_itr',{{p}},...
    'time',0,'score',0);
