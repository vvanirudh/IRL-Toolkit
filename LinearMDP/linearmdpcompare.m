% Compare two policies, return number of discrepancies.
function diff = linearmdpcompare(p1,p2)

% For each state, calculate the probability of taking different actions.
diff = 0;
for s=1:size(p1,1),
    if size(p1,2) == 1,
        % p1 is deterministic.
        if size(p2,2) == 1,
            % p2 is deterministic.
            if p1(s) ~= 0 && p2(s) ~= 0,
                diff = diff + (p1(s) ~= p2(s));
            end;
        else
            % p2 is probabilistic.
            if p1(s) ~= 0,
                diff = diff + (1-p2(s,p1(s)));
            end;
        end;
    else
        % p1 is probabilistic.
        if size(p2,2) == 1,
            % p2 is deterministic.
            if p2(s) ~= 0,
                diff = diff + (1-p1(s,p2(s)));
            end;
        else
            % p2 is probabilistic.
            prod = 0;
            for a=1:size(p1,2),
                prod = prod + p1(s,a)*p2(s,a);
            end;
            diff = diff + (1-prod);
        end;
    end;
end;
