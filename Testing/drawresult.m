% Draw specified policy and overlay evaluation results on top of the plot.
function drawresult(test_result,test_metric_names,test_model_names,...
    mdp_cat_name,mdp_param_name,algorithm,name)

% Draw the test result.
visualize(test_result,1);

% Move visualization over.
sp1 = subplot(1,2,1);
sp2 = subplot(1,2,2);
set(sp1,'position',[0.26,0.0,0.32,1.0]);
set(sp2,'position',[0.64,0.0,0.32,1.0]);

% Overlay metric results.
ax = axes('Position', [0.0, 0.0, 0.2, 1.0]);
set(ax,'visible','off');
xStart = 0.05;
curY = 0.95;
yStep = 0.04;
textcolor = [0.9 0.3 0.3];

% Print title.
text(xStart,curY,[name ' ' mdp_cat_name ' ' mdp_param_name],'color',textcolor,'FontWeight','bold');
curY = curY - yStep;

% Print statistics.
for n=1:length(test_model_names),
    curY = curY - yStep;
    text(xStart,curY,[test_model_names{n} ':'],'color',textcolor,'FontWeight','bold');
    curY = curY - yStep;
    for m=1:length(test_metric_names),
        text(xStart,curY,[test_metric_names{m} ': ' num2str(test_result.metric_scores{n,m}(1))],'color',textcolor,'FontWeight','bold');
        curY = curY - yStep;
    end;
end;
