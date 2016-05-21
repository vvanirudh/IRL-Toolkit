% Run a series of transfer tests with the specified parameter sets.
function transfer_result = runtransferseries(algorithms,series_result,...
    mdp_model,test_params,mdp,mdp_params,restarts,transfers)

% series_result - cell array containing test result for each test.

SAVED_TRANSFERS = 1;
N = length(mdp_params);
K = length(algorithms);
R = restarts;
T = transfers;
irl_results = cell(N,1);
% Split series_result.
for n=1:length(mdp_params),
    irl_results{n} = cell(K,R);
    irl_results{n} = series_result(n,:,:);
end;
temp_result = cell(N,1);
transfer_result = cell(N,K,R,T);
matlabpool;
parfor n=1:length(mdp_params),
    temp_result{n} = cell(K,R,T);
    for a=1:length(algorithms),
        for r=1:R,
            fprintf(1,'Starting transfer test %i for %s, run %i\n',n,algorithms{a},r);
            if iscell(test_params),
                tp = test_params{1,n};
            else
                tp = test_params;
            end;
            for t=1:1:T,
                mdpp = mdp_params{n};
                mdpp.seed = mdpp.seed+r*1000+t;
                test_result = runtransfertest(irl_results{n}{1,a,r}.irl_result,algorithms{a},...
                    mdp_model,mdp,mdpp,tp);
                temp_result{n}{a,r,t} = test_result;
                if t > SAVED_TRANSFERS,
                    % Clear out heavyweight data that we can't afford to
                    % save.
                    temp_result{n}{a,r,t} = rmfield(temp_result{n}{a,r,t},'irl_result');
                    temp_result{n}{a,r,t} = rmfield(temp_result{n}{a,r,t},'true_r');
                    temp_result{n}{a,r,t} = rmfield(temp_result{n}{a,r,t},'example_samples');
                    temp_result{n}{a,r,t} = rmfield(temp_result{n}{a,r,t},'test_models');
                    temp_result{n}{a,r,t} = rmfield(temp_result{n}{a,r,t},'test_metrics');
                    temp_result{n}{a,r,t} = rmfield(temp_result{n}{a,r,t},'mdp_data');
                    temp_result{n}{a,r,t} = rmfield(temp_result{n}{a,r,t},'mdp_params');
                    temp_result{n}{a,r,t} = rmfield(temp_result{n}{a,r,t},'mdp_solution');
                    temp_result{n}{a,r,t} = rmfield(temp_result{n}{a,r,t},'feature_data');
                    temp_result{n}{a,r,t} = rmfield(temp_result{n}{a,r,t},'mdp');
                    temp_result{n}{a,r,t} = rmfield(temp_result{n}{a,r,t},'algorithm');
                end;
            end;
        end;
    end;
end;
matlabpool close;

% Put results into a single cell array.
for n=1:length(mdp_params),
    transfer_result(n,:,:,:) = temp_result{n};
end;
