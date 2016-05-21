% Save out test results.
function saveresults(test_name,test_params,test_metric_names,test_model_names,...
    mdp_params,mdp_cat_name,mdp_param_names,algorithms,names,colors,order,...
    restarts,series_result,transfer_result)

% Create directory.
timestamp = datestr(now);
% Replace spaces with underscores.
timestamp = regexprep(timestamp,' ','_');
% Replace : with .
timestamp = regexprep(timestamp,':','.');
dir_name = ['Output_' test_name '_' timestamp];
mkdir(dir_name);
mkdir([dir_name '/graphs']);
mkdir([dir_name '/imgs']);
if ~isempty(transfer_result),
    mkdir([dir_name '/xfer_imgs']);
end;

% Save workspace variables to be restored later.
save([dir_name '/result.mat'],'test_name','test_params','test_metric_names',...
    'test_model_names','mdp_params','mdp_cat_name','mdp_param_names',...
    'algorithms','names','colors','order','restarts','series_result',...
    'transfer_result');

% Now sanitize series_result and transfer_result to clear them out.
for i1=1:size(series_result,1),
    for i2=1:size(series_result,2),
        for i3=1:size(series_result,3),
            series_result{i1,i2,i3} = struct('metric_scores',{series_result{i1,i2,i3}.metric_scores});
            for i4=1:size(transfer_result,4),
                transfer_result{i1,i2,i3,i4} = struct('metric_scores',{transfer_result{i1,i2,i3,i4}.metric_scores});
            end;
        end;
    end;
end;

% Save workspace variables to be restored later.
save([dir_name '/result_small.mat'],'test_name','test_params','test_metric_names',...
    'test_model_names','mdp_params','mdp_cat_name','mdp_param_names',...
    'algorithms','names','colors','order','restarts','series_result',...
    'transfer_result');
