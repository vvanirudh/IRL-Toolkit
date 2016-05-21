% Construction decision subtree.
function [tree,leaves,Rout,Vout] = firlregressiontree(st_states,depth,...
    leavesIn,Eo,R,V,split_thresh,max_depth,mdp_data,feature_data)

% Set leaves.
leaves = leavesIn;

% Test to use.
test = 1;

% Value of best split.
G = Inf;

if depth > max_depth,
    makeLeaf = 0;
    fMean = mean(R(st_states,:),1);
else
    % Step over all possible splitting moves.
    for tTest=1:size(feature_data.splittable,2),
        % Split examples.
        st_splits = feature_data.splittable(st_states,tTest);
        lt_states = st_states(find(1-st_splits));
        gt_states = st_states(find(st_splits));
        
        % Compute mean.
        ltMean = mean(mean(R(lt_states,:),1),2);
        gtMean = mean(mean(R(gt_states,:),1),2);
        ltVar = sum(sum((R(lt_states,:)-ltMean).^2,1),2);
        gtVar = sum(sum((R(gt_states,:)-gtMean).^2,1),2);
        value = ltVar+gtVar;

        if ~isempty(lt_states) && ~isempty(gt_states) && value < G,
            G = value;
            test = tTest;
        end;
    end;

    % Construct partitions.
    st_splits = feature_data.splittable(st_states,test);
    lt_states = st_states(find(1-st_splits));
    gt_states = st_states(find(st_splits));
    fMean = mean(R(st_states,:),1);
    fullMean = mean(fMean,2);
    maxDeviation = max(max((R(st_states,:)-fullMean).^2,[],1),[],2);

    if maxDeviation > split_thresh^2 && length(st_states) > 1,
        % Test if this node should be prunable.
        Rnew = R;
        Rnew(st_states,:) = repmat(fMean,length(st_states),1);
        Vnew = stdvalueiteration(mdp_data,Rnew,V);
        [~,P] = stdpolicy(mdp_data,Rnew,Vnew);
        
        % Test if P matches all non-zero values of Eo.
        mismatches = Eo.*(P ~= Eo);
        if isempty(find(mismatches,1)),
            % Do not make leaf (unnecessary).
            makeLeaf = 0;
            R = Rnew;
            V = Vnew;
        else
            makeLeaf = 1;
        end;
    else
        makeLeaf = 0;
    end;
end;

if makeLeaf == 1 && length(st_states) > 1 && G ~= Inf,
    % Create node with the best split.
    [rightTree,leaves,R,V] = firlregressiontree(gt_states,depth+1,...
        leaves,Eo,R,V,split_thresh,max_depth,mdp_data,feature_data);
    [leftTree,leaves,R,V] = firlregressiontree(lt_states,depth+1,...
        leaves,Eo,R,V,split_thresh,max_depth,mdp_data,feature_data);
    Rout = R;
    Vout = V;
    
    % Create node.
    tree = struct('type',1,'test',test,...
        'ltTree',leftTree,'gtTree',rightTree,'mean',fMean,'cells',st_states);
else
    % Create leaf node.
    tree = struct('type',0,'index',leaves+1,'mean',fMean,'cells',st_states);
    leaves = leaves + 1;
    Rout = R;
    Vout = V;
end;
