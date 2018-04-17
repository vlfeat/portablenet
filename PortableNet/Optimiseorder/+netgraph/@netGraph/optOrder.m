function [linkageOrder, memoryUsage] = optOrder(obj)
%OPTORDER find the optimal execution order sequence given a network

% Find open nodes and subgraph for the network
% Open nodes are defined as the set of output nodes that do not act as
% inputs to any other nodes
% Subgraph is defined as the residual graph after deleting the output nodes
% Both open nodes and subgraph stores the index of nodes
subSet = struct(...
    'open', {[]}, ...
    'subgraph', {[]}) ;

% Initialise the open nodes and subgraph by going through the netGraph
subSet = findInitialSubset(obj, subSet) ;

% Initialise a fake sink to get a single output
sinkName = 'sink' ;
outSet = {} ;
for ou = 1:numel(subSet.open)
    outSet{end+1} = obj.nodes(subSet.open(ou)).name ;
end
obj.addLinkage(sinkName, outSet, sinkName) ;
obj.setSize(sinkName, 0) ;
obj.rebuild() ;
subSet.open = obj.getNodesIndex(sinkName) ;
subSet.subgraph(end+1) = obj.getNodesIndex(sinkName) ;

% Initialise an empty table to store the current optimal order sequence
table = netgraph.xTable() ;

% Optimise recursively
frontieerSize = 0 ;
pivotIndex = 1 ;
result = xoptimize(obj, subSet, table, frontieerSize, pivotIndex) ;

% Manually add the sink node
table.Entry(end+1) = table.Entry(end) ;
table.Entry(end).key = subSet.subgraph ;
table.Entry(end).value.peakMemory = table.Entry(end).value.peakMemory ;
table.Entry(end).value.node = subSet.open ;

% Generate the order
order = zeros(1,numel(obj.nodes)) ;
mem = zeros(1,numel(obj.nodes)) ;
linkageOrder = {} ;

counter = numel(obj.nodes) ;
while ~isempty(subSet.subgraph)
    value = table.findValue(subSet.subgraph) ;
    order(counter) = value.node ;
    mem(counter) = value.peakMemory ;
    counter = counter - 1 ;
    subSet.subgraph(find(subSet.subgraph == value.node)) = [] ;
end

for orderCounter = numel(order):-1:2
    linkageOrder{orderCounter -1} = obj.getOutputLayerIndex(order(orderCounter)) ;
end

linkageOrder = [linkageOrder{:}] ;

memoryUsage = result.peakMemory ;

end

function subSet = findInitialSubset(obj, subSet)
% This function finds the initial open nodes and subgraph
for index = 1:numel(obj.nodes)
    
    if obj.nodes(index).numUsages == 0
        subSet.open(end+1) = index ;
    end
    
    subSet.subgraph(end+1) = index ;
    
end
end

function optimal = xoptimize(obj, subSet, table, frontieerSize, pivotIndex)
table.numCalls = table.numCalls + 1 ;

% Take one node from frontieer and make it the pivot
% Delete the pivot from frontieer and subgraph
pivot = subSet.open(pivotIndex) ;
subSet.open(find(ismember(subSet.open,pivot))) = [] ;
subSet.subgraph(find(ismember(subSet.subgraph,pivot))) = [] ;

% Adjust the frontieer size if the pivot we just removed is part of the
% frontieer
% The frontieer is defined as the set of nodes that is necessary to
% calculate the next node while all nodes prior to the frontieer could be
% deleted
if obj.nodes(pivot).numUsages < obj.nodes(pivot).numOutputs
    frontieerSize = frontieerSize - obj.nodes(pivot).size ;
end

% Find the next set of nodes that become the frontieer after the
% deletion of pivot
% Add to the end of open nodes
% Adjust the size of frontieer when the input nodes are all used during
% forward path
inputIndex = obj.getInputIndex(pivot) ;
for in = 1:numel(inputIndex)
    if obj.nodes(inputIndex(in)).numUsages == obj.nodes(inputIndex(in)).numOutputs
        frontieerSize = frontieerSize + obj.nodes(inputIndex(in)).size ;
    end
    
    obj.nodes(inputIndex(in)).numUsages = obj.nodes(inputIndex(in)).numUsages - 1 ;
    
    if obj.nodes(inputIndex(in)).numUsages == 0
        subSet.open(end+1) = inputIndex(in) ;
    end
end

% Initialise optimal solution 
optimal = struct(...
    'peakMemory', 0, ...
    'node', {[]}) ;

% Define memorization
value = table.findValue(subSet.subgraph) ;
if ~isempty(value)
    optimal = value ;
else
    if ~isempty(subSet.open)
        optimal.peakMemory = intmax ;
        for i = 1:numel(subSet.open)
            % Recursively optimise the subgraph
            % Best stores what happened previously
            best = xoptimize(obj, subSet, table, frontieerSize, i) ;
            
            % Compare the peak memory usage for different order after
            % taking different node in open nodes and keep the smaller one
            if optimal.peakMemory > best.peakMemory
                optimal.peakMemory = best.peakMemory ;
                optimal.node = subSet.open(i) ;
            end
        end
        
        % Record the optimal solution, using the current order solution as
        % key
        table.addEntry(subSet.subgraph, optimal) ;
    end
end

% The peak memory is taken as the larger value of previous peak memory and
% the frontieer size plus the current pivot
optimal.peakMemory = max(optimal.peakMemory, (frontieerSize + obj.nodes(pivot).size));

% Restore the open nodes set and number of usages to try another
for inn = 1:numel(inputIndex)
    if obj.nodes(inputIndex(inn)).numUsages == 0
        subSet.open(end) = [] ;
    end
    obj.nodes(inputIndex(inn)).numUsages = obj.nodes(inputIndex(inn)).numUsages + 1 ;
end

% Restore the open nodes set and subgraph
newSize = zeros(1,(numel(subSet.open) + 1)) ;
newSize(pivotIndex) = pivot ;
if pivotIndex ~= 1
    newSize(1:(pivotIndex-1)) = subSet.open(1:(pivotIndex-1)) ;
end
newSize((pivotIndex+1):numel(newSize)) = subSet.open(pivotIndex:numel(subSet.open)) ;
subSet.open = newSize ;

subSet.subgraph(end+1) = pivot ;

% Return the optimal solution
result = optimal ;

end


