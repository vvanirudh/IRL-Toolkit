% Run a series of tests with the specified parameter sets.
function series_result = runtestseries(algorithms,algorithm_params,...
    mdp_model,test_params,mdp,mdp_params,restarts)

% series_result - cell array containing test result for each test.

N = length(mdp_params);
K = length(algorithms);
R = restarts;
temp_result = cell(R,1);
series_result = cell(N,K,R);
matlabpool;
parfor r=1:R,
    temp_result{r} = cell(N,K);
    for a=1:length(algorithms),
        for n=1:length(mdp_params),
            fprintf(1,'Starting test %i for %s, run %i\n',n,algorithms{a},r);
            if iscell(test_params),
                if size(test_params,1) == R,
                    tp = test_params{r,n};
                else
                    tp = test_params{1,n};
                end;
            else
                tp = test_params;
            end;
            mdpp = mdp_params{n};
            mdpp.seed = mdpp.seed+r-1;
            test_result = runtest(algorithms{a},algorithm_params{a},...
                mdp_model,mdp,mdpp,tp);
            % Remove all but the last entry in each array.
            if length(test_result) == 1,
                rem = length(test_result.irl_result.model_itr)-1;
                if rem > 0 && isfield(test_result.irl_result,'model_itr'),
                    test_result.irl_result.model_itr(1:rem) = [];
                end;
                if rem > 0 && isfield(test_result.irl_result,'r_itr'),
                    test_result.irl_result.r_itr(1:rem) = [];
                end;
                if rem > 0 && isfield(test_result.irl_result,'model_r_itr'),
                    test_result.irl_result.model_r_itr(1:rem) = [];
                end;
                if rem > 0 && isfield(test_result.irl_result,'p_itr'),
                    test_result.irl_result.p_itr(1:rem) = [];
                end;
                if rem > 0 && isfield(test_result.irl_result,'model_p_itr'),
                    test_result.irl_result.model_p_itr(1:rem) = [];
                end;
            end;
            temp_result{r}{n,a} = test_result;
        end;
    end;
end;
matlabpool close;

% Put results into a single cell array.
for r=1:R,
    series_result(:,:,r) = temp_result{r};
end;
