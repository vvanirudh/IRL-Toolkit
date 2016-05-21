% Return optimal action given the mdp solution.
function a = standardmdpaction(~,mdp_solution,s)

a = mdp_solution.p(s);
