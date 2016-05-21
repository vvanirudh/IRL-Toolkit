% Utility function for coverting state indices to coordinates.
function [x,lane,speed] = highwaystatetocoord(s,mdp_params)

x = ceil(s/(mdp_params.lanes*mdp_params.speeds));
s = s-(x-1)*(mdp_params.lanes*mdp_params.speeds);
lane = ceil(s/mdp_params.speeds);
s = s-(lane-1)*mdp_params.speeds;
speed = s;
