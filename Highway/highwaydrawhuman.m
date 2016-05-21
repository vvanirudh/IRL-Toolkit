% Draw indicator for human agent in interactive highway environment.
function agent = highwaydrawhuman(mdp_params,~,s,a)

[y,lane,speed] = highwaystatetocoord(s,mdp_params);
x = (speed-1)*mdp_params.lanes+lane;
if nargin < 4,
    % Unknown action.
    agent = rectangle('Position',[x-0.8,y-0.8,0.6,0.6],'FaceColor',[0.8 0.8 1]);
else
    % Action is known.
    agent = [];
    actionmap = [ 5 3 4 2 1 ];
    gridworlddrawagent(x,y,actionmap(a),[1 1 1]);
end;
