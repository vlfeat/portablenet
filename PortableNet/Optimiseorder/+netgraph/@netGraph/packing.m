function maxMem = packing(obj, order)
%PACKING gives the optimal address allocation for each of the tensors to
% minimize the maximum total memory usage

% Get a table that shows the coexisting tensors at certain time
table = netgraph.xTable() ;
table = getBlock(obj, order, table) ;

% Import size from netGraph
size = zeros(1,numel(obj.nodes)) ;
size(1) = obj.nodes(1).size ;
for s =2:numel(obj.nodes)
    size(s) = obj.nodes(obj.getNodesIndex(obj.linkage(order(s-1)).outputs)).size ;
end

maxMem = 0 ;

% For each time period get the address for the existing tensors
% Already allocated tensors would not be reallocated during next time
% period
for t = 1:numel(table.Entry)
    size = zeros(1,numel(table.Entry(t).key)) ;
    for s =1:numel(table.Entry(t).key)
        size(s) = obj.nodes(obj.getNodesIndex(table.Entry(t).key{s})).size ;
    end
    
    Memory = getAddress(obj, {table.Entry(t).key}, size) ;  
    
    if Memory > maxMem
        maxMem = Memory ;
    end
end
end

function table = getBlock(obj, order, table)
%GETBLOCK find the block of tensors that co-exist at certain time

frontieer(1) = obj.linkage(order(1)).inputs ;

for i = 1:numel(order)
    frontieer(end+1) = obj.linkage(order(i)).outputs ;
    index = obj.getNodesIndex(obj.linkage(order(i)).outputs) ;
    
    % Record in table
    table.Entry(end+1).key = frontieer ;
    if i >1 && (numel(table.Entry(end-1).key) <= numel(frontieer))
        if isequal(table.Entry(end-1).key, frontieer(1:numel(table.Entry(end-1).key)))
            table.Entry(end-1)= [] ;
        end
    end
    
    % Delete the input tensors that are no longer required
    inputIndex = obj.getInputIndex(index) ;
    for in = 1:numel(inputIndex)
        obj.nodes(inputIndex(in)).numUsages = obj.nodes(inputIndex(in)).numUsages - 1 ;
        if obj.nodes(inputIndex(in)).numUsages == 0
            frontieer(find(ismember(frontieer,obj.nodes(inputIndex(in)).name))) = [] ;
        end
    end
    
end

if isempty(table.Entry(1).key)
    table.Entry(1) = [] ;
end

end

function maxMem = getAddress(obj, entry, size)
entry = entry{1,1} ;

n = numel(entry) ;

prob = optimproblem('Description', 'Minimise the maximum memory used', ...
    'ObjectiveSense', 'minimize') ;

a = optimvar('a', n, 'LowerBound', 0) ;
maxA = optimvar('maxA', 'LowerBound', 0) ;
x = optimvar('x', n, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1) ;

for p = 1:n
    if ~isempty(obj.nodes(obj.getNodesIndex(entry{p})).address)
        a(p).LowerBound = obj.nodes(obj.getNodesIndex(entry{p})).address ;
        a(p).UpperBound = obj.nodes(obj.getNodesIndex(entry{p})).address ;
    end
end

prob.Objective = maxA ;

% Create empty constraint array
constr = optimconstr(n*3) ;
constrCounter = 1 ;

% Introduce auxilliary variable to perform min max operation
for l = 1:n
    constr(constrCounter) = maxA >= a(l) + size(l)  ;
    constrCounter = constrCounter + 1 ;
end

% The tensors do not overlap in memory
M = 1e3 * size(1);
for k = 1:(n-1)
    constr(constrCounter) = M * x(k) - a(k) - size(k) + a(k+1) >= 1;
    constrCounter = constrCounter + 1 ;
    constr(constrCounter) = (1 - x(k)) * M - a(k+1) - size(k+1) + a(k) >= 1 ;
    constrCounter = constrCounter + 1 ;
end

constr(constrCounter) = x(n) * M - a(n) - size(n) + a(1) >= 1 ;
constrCounter = constrCounter + 1 ;
constr(constrCounter) = (1 - x(n)) * M - a(1) - size(1) + a(n) >= 1 ;

prob.Constraints.constr = constr ;

sol = solve(prob) ;

maxMem = sol.maxA ;

for m =1:n
    if isempty(obj.nodes(obj.getNodesIndex(entry{m})).address)
    obj.nodes(obj.getNodesIndex(entry{m})).address = sol.a(m) ;
    end
end

end

