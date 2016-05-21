% Run the optimization phase to compute a reward function that is close to
% the current feature hypothesis.
function [R,MARGIN] = firloptimization(Eo,Rold,ProjToLeaf,LeafToProj,...
        FeatureMatch,mdp_data,verbosity)

% Weight of smoothing term (relative to reward objective).
SMOOTH_WEIGHT = 0.02;

% Total size.
states = mdp_data.states;
actions = mdp_data.actions;
msize = states*actions;
results = size(mdp_data.sa_s,3);

% Construct constraints.
cols = find(Eo);
examples = length(cols);

sN = zeros(msize-examples*actions,1);       % Start state indices.
rN = zeros(msize-examples*actions,1);       % State-action indices.
eN = zeros(msize-examples*actions,results); % Resultant state indices.
pN = zeros(msize-examples*actions,results); % Resultant state coefficients (discount & probability).

sM = zeros(examples*(actions-1),1);         % Start state indices.
rM = zeros(examples*(actions-1),1);         % State-action indices.
eM = zeros(examples*(actions-1),results);   % Resultant state indices.
pM = zeros(examples*(actions-1),results);   % Resultant state coefficients (discount & probability).

sE = zeros(examples,1);                     % Start state indices.
rE = zeros(examples,1);                     % State-action indices.
eE = zeros(examples,results);               % Resultant state indices.
pE = zeros(examples,results);               % Resultant state coefficients (discount & probability).

Nrow = 1;
Mrow = 1;
Erow = 1;
for startstate=1:states,
    if Eo(startstate,1) ~= 0,
        % Generate destination state and reward under optimal action.
        optaction = Eo(startstate,1);
        reward = actions*(startstate-1)+optaction;

        sE(Erow,1) = startstate;
        rE(Erow,1) = reward;
        eE(Erow,:) = mdp_data.sa_s(startstate,optaction,:);
        pE(Erow,:) = mdp_data.sa_p(startstate,optaction,:)*mdp_data.discount;
        Erow = Erow+1;

        % Step over actions.
        for action=1:actions,
            if action ~= optaction,
                % Generate destination state and reward indices.
                reward = actions*(startstate-1)+action;
                
                sM(Mrow,1) = startstate;
                rM(Mrow,1) = reward;
                eM(Mrow,:) = mdp_data.sa_s(startstate,action,:);
                pM(Mrow,:) = mdp_data.sa_p(startstate,action,:)*mdp_data.discount;
                Mrow = Mrow+1;
            end;
        end;
    else
        for action=1:actions,
            % Generate destination state and reward indices.
            reward = actions*(startstate-1)+action;

            sN(Nrow,1) = startstate;
            rN(Nrow,1) = reward;
            eN(Nrow,:) = mdp_data.sa_s(startstate,action,:);
            pN(Nrow,:) = mdp_data.sa_p(startstate,action,:)*mdp_data.discount;
            Nrow = Nrow+1;
        end;
    end;
end;

% Determine number of leaves.
[~,msize] = size(ProjToLeaf);
[leafEntries,leaves] = size(FeatureMatch);

% Margin by which examples should be optimal.
MARGIN = 0.01;

margins = ones(examples*(actions-1),1)*MARGIN;

EPSILON = 2.22*10^(-16);
cvx_begin
    if verbosity ~= 0,
        cvx_quiet(false);
    else
        cvx_quiet(true);
    end;

    cvx_precision([EPSILON^(0.5),EPSILON^(0.25),EPSILON^(0.125)]);
    variable r(msize);
    variable v(states);
    variable f(leaves);
    
    % Objective function.
    minimize( sum_square(LeafToProj*f-r)*(1/msize) +...
              sum(abs(FeatureMatch*f))*(SMOOTH_WEIGHT/(leafEntries*500)) );
              
    subject to
        % Leaf average.
        f == ProjToLeaf*r;
        % Value function constraints.
        v(sN) >= r(rN) + sum(v(eN).*pN,2);
        v(sM) >= r(rM) + sum(v(eM).*pM,2) + margins;
        v(sE) == r(rE) + sum(v(eE).*pE,2);
cvx_end

% Check for failure.
if (size(Rold,1) > 1) && (isnan(cvx_optval) == 1),
    if verbosity ~= 0,
        fprintf(1,'WARNING: Failed to obtain solution, reverting to old reward!\n');
    end;
    R = Rold;
else
    % Recover reward function.
    R = reshape(r,actions,states)';
end;
