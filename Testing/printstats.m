% Print scores from a series of tests.
function printstats(fid,test_params,test_metric_names,test_model_names,...
    mdp_params,mdp_cat_name,mdp_param_names,algorithms,names,restarts,...
    series_result,transfer_result)

% Gather statistics.
scores = zeros(length(test_params{1}.test_metrics),...
               length(test_params{1}.test_models),...
               length(mdp_params),...
               length(algorithms),...
               restarts);
if ~isempty(transfer_result),
    tscores = zeros(length(test_params{1}.test_metrics),...
                   length(test_params{1}.test_models),...
                   length(mdp_params),...
                   length(algorithms),...
                   restarts,size(transfer_result,4));
end;
for n=1:length(mdp_params),
    for a=1:length(algorithms),
        for r=1:restarts,
            for m=1:length(test_params{1}.test_models),
                for s=1:length(test_params{1}.test_metrics),
                    scores(s,m,n,a,r) = series_result{n,a,r}.metric_scores{m,s}(1);
                    if ~isempty(transfer_result),
                        for t=1:size(transfer_result,4),
                            tscores(s,m,n,a,r,t) = transfer_result{n,a,r,t}.metric_scores{m,s}(1);
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

% Report results.
fprintf(fid,'IRL RESULTS:\n');
for n=1:length(mdp_params),
    fprintf(fid,'\n%s %s results:',mdp_cat_name,mdp_param_names{n});
    for k=1:length(test_params{1}.test_models),
        fprintf(fid,'\n%s:\n',test_model_names{k});
        for s=1:length(test_params{1}.test_metrics),
            for a=1:length(algorithms),
                fprintf(fid,'%s: %s \t %f\n',test_metric_names{s},names{a},mean(scores(s,k,n,a,:),5));
            end;
        end;
    end;
end;
if ~isempty(transfer_result),
    fprintf(fid,'\nTRANSFER RESULTS:\n');
    for n=1:length(mdp_params),
        fprintf(fid,'\n%s %s results:',mdp_cat_name,mdp_param_names{n});
        for k=1:length(test_params{1}.test_models),
            fprintf(fid,'\n%s:\n',test_model_names{k});
            for s=1:length(test_params{1}.test_metrics),
                for a=1:length(algorithms),
                    fprintf(fid,'%s: %s \t %f\n',test_metric_names{s},names{a},mean(mean(tscores(s,k,n,a,:,:),6),5));
                end;
            end;
        end;
    end;
end;
