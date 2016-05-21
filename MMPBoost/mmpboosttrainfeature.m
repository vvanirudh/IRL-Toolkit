function [tree,leaves] = mmpboosttrainfeature(Ex,depth,max_depth,leaves,F)

% Test to use.
test = 1;

% Value of best split.
G = Inf;

if depth > max_depth,
    makeLeaf = 0;
    fMean = mean(Ex(:,2),1);
else
    % Step over all possible splitting moves.
    for tTest=1:size(F,2),
        % Split examples.
        st_splits = F(Ex(:,1),tTest);
        lt_states = Ex(find(1-st_splits),:);
        gt_states = Ex(find(st_splits),:);
        
        if ~isempty(lt_states) && ~isempty(gt_states),
            % Compute means and variances.
            ltMean = mean(lt_states(:,2),1);
            gtMean = mean(gt_states(:,2),1);
            ltVar = sum((lt_states(:,2)-ltMean).^2,1);
            gtVar = sum((gt_states(:,2)-gtMean).^2,1);
            value = ltVar+gtVar;

            if value < G,
                G = value;
                test = tTest;
            end;
        end;
    end;

    % Construct partitions.
    st_splits = F(Ex(:,1),test);
    lt_states = Ex(find(1-st_splits),:);
    gt_states = Ex(find(st_splits),:);
    fMean = mean(Ex(:,2),1);
    makeLeaf = 1;
end;

if makeLeaf == 1 && length(Ex) > 1 && G ~= Inf,
    % Create node with the best split.
    [leftTree,leaves] = mmpboosttrainfeature(lt_states,depth+1,...
        max_depth,leaves,F);
    [rightTree,leaves] = mmpboosttrainfeature(gt_states,depth+1,...
        max_depth,leaves,F);
    
    % Create node.
    tree = struct('type',1,'test',test,...
        'ltTree',leftTree,'gtTree',rightTree,'mean',fMean,'cells',Ex(:,1));
else
    % Create leaf node.
    tree = struct('type',0,'index',leaves+1,'mean',fMean,'cells',Ex(:,1));
    leaves = leaves + 1;
end;
