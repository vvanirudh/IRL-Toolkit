% Save out test results.
function renderresults(dir_name,graph_only)

SAVED_TRANSFERS = 1;

% Load the results.
if graph_only,
    filename = '/result_small.mat';
else
    filename = '/result.mat';
end;
if iscell(dir_name),
    % Load and concatenate results from multiple directories.
    for i=1:length(dir_name),
        if i > 1,
            prev_mdp_params = mdp_params;
            prev_mdp_param_names = mdp_param_names;
            prev_series_result = series_result;
            prev_transfer_result = transfer_result;
        end;
        load([dir_name{i} filename]);
        if i > 1,
            mdp_params = [prev_mdp_params mdp_params];
            mdp_param_names = [prev_mdp_param_names mdp_param_names];
            series_result = vertcat(prev_series_result,series_result);
            transfer_result = vertcat(prev_transfer_result,transfer_result);
        end;
    end;
    dir_name = dir_name{end};
else
    % Load a single directory.
    load([dir_name filename]);
end;

% Store text dump of the results.
fid = fopen([dir_name '/summary.txt'],'w');
printstats(fid,test_params,test_metric_names,test_model_names,...
    mdp_params,mdp_cat_name,mdp_param_names,algorithms,names,restarts,...
    series_result,transfer_result);
fclose(fid);

% Graph each metric for each model.
for m=1:length(test_params{1}.test_models),
    for s=1:length(test_params{1}.test_metrics),
        % Assemble matrix of values for this model and metric.
        values = zeros(length(algorithms),length(mdp_params),restarts);
        for a=1:length(algorithms),
            for n=1:length(mdp_params),
                for r=1:restarts,
                    values(a,n,r) = series_result{n,a,r}.metric_scores{m,s}(1);
                end;
            end;
        end;
        % Graph the result.
        graphresult(test_metric_names{s},test_model_names{m},mdp_cat_name,...
            mdp_param_names,algorithms,names,colors,order,values);
        % Save the graph.
        set(gcf, 'PaperPositionMode', 'auto');
        plot2svg([dir_name '/graphs/' test_params{1}.test_models{m} '_' test_params{1}.test_metrics{s} '.svg'],1);
        pause(1.0); % This is necessary in order for the save to succeed.
        % Close window.
        close all;
        if ~isempty(transfer_result),
            % Assemble matrix of transfer values.
            tvalues = zeros(length(algorithms),length(mdp_params),restarts,size(transfer_result,4));
            for a=1:length(algorithms),
                for n=1:length(mdp_params),
                    for r=1:restarts,
                        for t=1:size(transfer_result,4),
                            tvalues(a,n,r,t) = transfer_result{n,a,r,t}.metric_scores{m,s}(1);
                        end;
                    end;
                end;
            end;
            % Graph the result.
            graphresult(test_metric_names{s},[test_model_names{m} ' Transfer'],mdp_cat_name,...
                mdp_param_names,algorithms,names,colors,order,tvalues);
            % Save the graph.
            set(gcf, 'PaperPositionMode', 'auto');
            plot2svg([dir_name '/graphs/' test_params{1}.test_models{m} '_xfer_' test_params{1}.test_metrics{s} '.svg'],1);
            pause(1.0); % This is necessary in order for the save to succeed.
            % Close window.
            close all;
        end;
    end;
end;

if ~graph_only,
    % Store image of each policy, with results printed on the figure.
    for n=1:length(mdp_params),
        for a=1:length(algorithms),
            for r=1:restarts,
                % Plot image of policy.
                drawresult(series_result{n,a,r},test_metric_names,...
                    test_model_names,mdp_cat_name,mdp_param_names{n},...
                    algorithms{a},names{a});
                % Save the image.
                set(gcf, 'PaperPositionMode', 'auto');
                plot2svg([dir_name '/imgs/' algorithms{a} '.' num2str(a) '_' num2str(r) '_' mdp_cat_name mdp_param_names{n} '.svg'],1);
                pause(1.0); % This is necessary in order for the save to succeed.
                % Close window.
                close all;

                % Store images of transferred rewards.
                if ~isempty(transfer_result),
                    for t=1:min(SAVED_TRANSFERS,size(transfer_result,4)),
                        % Plot image of policy.
                        drawresult(transfer_result{n,a,r,t},test_metric_names,...
                            test_model_names,mdp_cat_name,mdp_param_names{n},...
                            algorithms{a},names{a});
                        % Save the image.
                        set(gcf, 'PaperPositionMode', 'auto');
                        plot2svg([dir_name '/xfer_imgs/' algorithms{a} '.' num2str(a) '_xfer_' num2str(r) 'to' num2str(t) '_' mdp_cat_name mdp_param_names{n} '.svg'],1);
                        pause(1.0); % This is necessary in order for the save to succeed.
                        % Close window.
                        close all;
                    end;
                end;
            end;
        end;
    end;
end;
