% Return optimal action given the mdp solution.
function a = linearmdpaction(mdp_data,mdp_solution,s)

samp = rand(1,1);
total = 0;
for a=1:mdp_data.actions,
    total = total+mdp_solution.p(s,a);
    if total >= samp,
        return;
    end;
end;
