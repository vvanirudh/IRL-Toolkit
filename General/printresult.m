% Print pre-computed IRL test result.
function printresult(test_result)

% Print results.
for o=1:length(test_result),
    if length(test_result) ~= 1,
        if o==1,
            fprintf(1,'Printing results for processed version:\n');
        else
            fprintf(1,'Printing results for non-processed version:\n');
        end;
    end;
    for i=1:length(test_result(o).test_models),
        for j=1:length(test_result(o).test_metrics),
            fprintf(1,'%s on %s, %s %s: ',test_result(o).algorithm,test_result(o).mdp,test_result(o).test_models{i},test_result(o).test_metrics{j});
            metric = test_result(o).metric_scores{i,j};
            if length(metric) == 1,
                fprintf(1,'%f\n',metric);
            elseif length(metric) == 2,
                fprintf(1,'%f (%f)\n',metric(1),metric(2));
            else
                fprintf(1,'%f (%f vs %f)\n',metric(1),metric(2),metric(3));
            end;
        end;
    end;
end;
