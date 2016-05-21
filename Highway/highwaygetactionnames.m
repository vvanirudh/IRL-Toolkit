% Get names of all actions for human control.
function [names,keys,order] = highwaygetactionnames(~)

names = {'left','right','slower','faster','none'};
keys = {'a','d','x','w','s'};
order = 1:5;
