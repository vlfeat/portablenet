function [linkageOrder, memoryUsage] = optOrder(obj)
%OPTORDER find the optimal execution order sequence given a network


% Find frontieer and subgraph for the network
% Frontieer is defined as the set of output nodes
% Subgraph is defined as the residual graph after deleting the output nodes
% Both frontieer and subgraph stores the index of nodes
subSet = struct(...
    'frontieer', {[]}, ...
    'subgraph', {[]}) ;

% Initialise the frontieer and subgraph by going through the netGraph
subSet = findInitialSubset(obj, subSet) ;

% Initialise an empty table to store the current optimal order sequence
table = netgraph.xTable() ;

% Optimise recursively
result = xoptimize(obj, subSet, table) ;

% Generate the order
order = zeros(1,numel(obj.nodes)) ;
linkageOrder = {} ;

counter = numel(obj.nodes) ;
while ~isempty(subSet.subgraph)
    value = table.findValue(subSet.subgraph) ;
    order(counter) = value.node ;
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
% This function finds the initial frontineer and subgraph
for index = 1:numel(obj.nodes)
    
    if obj.nodes(index).numUsages == 0
        subSet.frontieer(end+1) = index ;
    end
    
    subSet.subgraph(end+1) = index ;
    
end
end

function result = xoptimize(obj, subSet, table)
value = table.findValue(subSet.subgraph) ;
if ~isempty(value)
    result = value ;
    return
end

% Stop the recursive function when all of the nodes in subgraph has been
% gone through
if isempty(subSet.subgraph)
    result = struct(...
        'peakMemory', 0, ...
        'frontieerSize', 0, ...
        'node', {[]}) ;
    return
end


% Initialise a structure to store optimal solution
optimal = struct(...
    'peakMemory', intmax, ...
    'frontieerSize', 0, ...
    'node', {[]}) ;

for counter = 1:numel(subSet.frontieer)
    % Take one node from frontieer and make it the pivot
    % Delete the pivot from frontieer and subgraph
    pivot = subSet.frontieer(counter) ;
    subSet.frontieer(counter) = [] ;
    subSet.subgraph(find(ismember(subSet.subgraph,pivot))) = [] ;
    
    % Find the next set of nodes that become the frontieer after the
    % deletion of pivot
    % Add to the end of frontieer
    inputIndex = obj.getInputIndex(pivot) ;
    for in = 1:numel(inputIndex)
        obj.nodes(inputIndex(in)).numUsages = obj.nodes(inputIndex(in)).numUsages - 1 ;
        if obj.nodes(inputIndex(in)).numUsages == 0
            subSet.frontieer(end+1) = inputIndex(in) ;
        end
    end
    
    % Recursively optimise the subgraph
    % Best stores what happened previously
    best = xoptimize(obj, subSet, table) ;
    
    % Update the optimal
    % 1. check the peak memory usage
    % Peak memory usage is the previous frontieer size plus the pivot
    frontieerSize = best.frontieerSize + obj.nodes(pivot).size ;
    peakMemory = max(best.peakMemory, frontieerSize) ;
    
    % 2. Only update the optimal solution when the peak is lower than optimal
    if (peakMemory < optimal.peakMemory)
        
        % 3. Update the new frontieer size
        % The new frontieer size is calculated by adding the pivot and minus
        % its input as long as the input is not needed for another calculation
        
        for inn = 1:numel(inputIndex)
            if obj.nodes(inputIndex(inn)).numUsages == 0
                frontieerSize = frontieerSize - obj.nodes(inputIndex(inn)).size ;
            end
        end
        
        % 4. Update the optimal solution
        optimal.peakMemory = peakMemory ;
        optimal.frontieerSize = frontieerSize ;
        optimal.node = pivot ;
    end
    
    % Undo the following so that we can try another node in the frontieer
    % 1. Undo the deletion of pivot
    % 2. Undo the adding to new frontieer
    % 3. Undo the change to numUsages
    for innn = 1:numel(inputIndex)
        if obj.nodes(inputIndex(innn)).numUsages == 0
            subSet.frontieer(find(ismember(subSet.frontieer,inputIndex(innn)))) = [] ;
        end
        obj.nodes(inputIndex(innn)).numUsages = obj.nodes(inputIndex(innn)).numUsages + 1 ;
    end
    subSet.frontieer = [pivot, subSet.frontieer] ;
    subSet.subgraph(end+1) = pivot ;
    
end

table.addEntry(subSet.subgraph, optimal) ;

result = optimal ;

return

end
