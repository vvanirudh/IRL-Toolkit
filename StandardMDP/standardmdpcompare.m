% Compare two policies, return number of discrepancies.
function diff = standardmdpcompare(p1,p2)

diff = length(find(p1 ~= p2 & p1 ~= 0 & p2 ~= 0));
