% Graph results for a single model and metric.
function graphresult(test_metric_name,test_model_name,step_name,step_names,...
            algorithms,names,colors,order,values,options)

if nargin < 10,
    options = [];
end;
        
% Compute means and standard errors.
if length(size(values)) == 4,
    means = mean(mean(values,4),3);
    errs = sqrt((1/(size(values,3)*size(values,4)))*...
        sum(sum(bsxfun(@minus,values,means).^2,4),3))/...
        sqrt(size(values,3)*size(values,4));
else
    means = mean(values,3);
    errs = std(values,[],3)/sqrt(size(values,3));
end;

%w = 256;h = 320;
w = 512; h = 640;
algs = order;
showleg = 1;
maxy = [];
miny = 0;
% Parse options structure.
if ~isempty(options),
    % Adjust width and height.
    w = w*options.size;
    h = h*options.size;
    % Choose which algorithms to show.
    algs = [];
    for a=1:length(algorithms),
        if a > 1 && strcmp(algorithms{a},algorithms{a-1}),
            cnt = cnt+1;
        else
            cnt = 1;
        end;
        for i=1:length(options.algorithms),
            algnum = strcat(algorithms{a},num2str(cnt));
            if strcmp(algorithms{a},options.algorithms{i}) || ...
               strcmp(algnum,options.algorithms{i}),
                algs = [algs a];
                break;
            end;
        end;
    end;
    % Choose if we want to show the legend.
    showleg = options.legend;
    % Choose maximum value on y axis.
    for i=1:length(options.scale_key),
        if strcmp(options.scale_key{i},test_metric_name),
            maxy = options.scales(1,i);
            if size(options.scales,1) == 2,
                miny = options.scales(2,i);
            end;
        end;
    end;
end;

% Create figure.
figure('Position',[20 200 w h]);

% Write title and labels.
clf;
axes('position',[.16 .12 .8 .8]);
set(gca,'FontSize',13);
title(lower(test_model_name));
set(get(gca,'title'),'units','normalized');
set(get(gca,'title'),'position',[0.45 1.04]);
xlabel(lower(step_name));
ylabel(lower(test_metric_name));
xly = -0.07;
ylx = -0.12;
set(get(gca,'xlabel'),'units','normalized');
set(get(gca,'xlabel'),'position',[0.5 xly]);
set(get(gca,'ylabel'),'units','normalized');
set(get(gca,'ylabel'),'position',[ylx 0.5]);

% Set X-axis labels.
grid on;
set(gca,'xcolor',[0.8,0.8,0.8],'ycolor',[0.8,0.8,0.8]);
set(gca,'FontSize',9);
set(gca,'XTick',1:length(step_names));
set(gca,'XTickLabel',step_names);

% Set axes size.
if isempty(maxy),
    maxy = max(max(means+errs));
end;
axis([1  length(step_names)  miny  maxy]);

% Plot error area.
for a=algs,
    % Interpolate means and variances.
    %xi = 1:1:length(step_names);
    xi = 1:0.1:length(step_names);
    tavg = interp1(1:length(step_names),means(a,:),xi,'pchip');
    tvar = interp1(1:length(step_names),errs(a,:),xi,'pchip');
    
    % Compute top and bottom edges.
    bottom = tavg-tvar;
    top = tavg+tvar;
    xs = xi;
    
    % Draw the patch.
    patch([xs,fliplr(xs)],[bottom,fliplr(top)],...
            colors{a}*0.6+ones(1,3)*0.4,'EdgeColor','none','FaceAlpha',0.33);
end;

% Plot result.
hold on;
leg = zeros(length(algs),1);
i = 1;
for a=algs,
    % Interpolate result.
    %xi = 1:1:length(step_names);
    xi = 1:0.1:length(step_names);
    tavg = interp1(1:length(step_names),means(a,:),xi,'pchip');
    tavgm = interp1(1:length(step_names),means(a,:),1:length(step_names),'pchip');
    xs = xi;
    
    % Choose line width.
    alg = algorithms{a};
    if strcmp(alg,'optimal'),
        lw = 1.5;
    elseif strcmp(alg,'gpirl'),
        lw = 2;
    else
        lw = 1;
    end;
    
    % Plot.
    leg(i,1) = plot(xs,tavg,'Color',colors{a},'LineWidth',lw,'MarkerSize',2);
    plot(1:length(step_names),tavgm,'s','Color',colors{a},'MarkerFaceColor',colors{a},'LineWidth',lw,'MarkerSize',2);
    i = i+1;
end;

% Create the legend.
if showleg,
    h = legend(leg,names(algs));
    set(h,'FontSize',8);
    set(h, 'Location', 'NorthEast');
    set(h, 'Box', 'off');
    set(h, 'Color', 'none');
end;

% Create black axes without grid.
c_axes = copyobj(gca,gcf);
set(c_axes, 'color', 'none', 'xcolor', 'k', 'xgrid', 'off', 'ycolor','k', 'ygrid','off');
title(c_axes,'');
set(get(c_axes,'xlabel'),'units','normalized');
set(get(c_axes,'xlabel'),'position',[0.5 xly]);
set(get(c_axes,'ylabel'),'units','normalized');
set(get(c_axes,'ylabel'),'position',[ylx 0.5]);

% Clean up.
hold off;
