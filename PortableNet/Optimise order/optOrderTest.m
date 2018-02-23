clear all

% netPath = '../../PortableNet/data/googlenet/imagenet-googlenet-dag.mat' ;
% 
% graph_ = netgraph.netGraph.loadobj(netPath) ;

% Modify the network
% cut1 = '' ;
% cut2 = '' ;

% net = prepareNet(netPath, cut1, cut2) ;

% % Find the optimal order sequence
% optimise(net) ;

function optimise(obj)

% Find frontieer and subgraph for the network
% Frontieer is defined as the set of output nodes
% Subgraph is defined as the residual graph after deleting the output nodes
node = struct('subgraph', [] ,'frontieer', [] ) ;
node = findNodes(obj, node) ;

% Initialise an empty table to store the current optimal order sequence
table = containers.Map('KeyType', 'char', 'ValueType', 'any');

% Optimise recursively
[table, optimal] = xoptimize(obj, node, table) ;



end

function node = findNodes(obj, node)
% This function finds the initial frontineer and subgraph
counter = 1 ;

while counter <= numel(obj.vars)
    if obj.vars(counter).fanout == 0
        node.frontieer(end+1) = counter ;
    end
    
    node.subgraph(end+1) = counter ;
    
    counter = counter + 1 ;
    
end
end

function [table, result] = xoptimize(obj, node, table)
key = keys(table) ;

if ~isempty(key)
lastkey = str2num(key{end}) ;
end

if isKey(table, sprintf('%d ',node.subgraph)) && ~isequal(node.subgraph,lastkey)
    result = table(sprintf('%d ',node.subgraph)) ;
    result = result{1,1} ;
    return
end

if isempty(node.subgraph)
    result = struct('peak', 1, 'frontieerSize', 1, 'node', 1) ;
    result.peak = 0 ;
    result.frontieerSize = 0 ;
    result.node = [] ;
    return
end

% Initialise the optimal
optimal = struct('peak', intmax, 'frontieerSize', 0, 'node', []) ;

for f = 1:numel(node.frontieer)
    
    % Delete each node from frontieer and subgraph and make it the pivot
    pivot = node.frontieer(f) ;
    node.frontieer(find(node.frontieer == pivot)) = [] ;
    node.subgraph(find(node.subgraph == pivot)) = [] ;
    
    % Find the nodes that become frontieer after the deletion of the pivot
    if (pivot - 1) ~= 0
        inputsIndex = getVarIndex(obj, obj.layers(pivot - 1).inputs) ;
        for in = 1:numel(inputsIndex)
            obj.vars(inputsIndex(in)).fanout = obj.vars(inputsIndex(in)).fanout - 1 ;
            if obj.vars(inputsIndex(in)).fanout == 0
                node.frontieer(end+1) = inputsIndex(in) ;
            end
        end
    end
    
    % Recursively optimise the subgraph
    [table, best] = xoptimize(obj, node, table) ;
    
    % Peak memory use is the frontieer size plus the size of pivot
    frontieerSize = best.frontieerSize + numel(obj.vars(pivot).value) ;
    peak = max(best.peak, frontieerSize) ;
    
    % Update the optimal solution when the peak is less than the optimal
    % peak
    if (peak < optimal.peak)
        % Recalculate the frontieer size
        % The actual frontieer size is the memory usage of the frontieer
        % Excluding its input
        if (pivot - 1) ~= 0
            for inn = 1 : numel(inputsIndex)
            if ismember(inputsIndex(inn), node.frontieer) 
                frontieerSize = frontieerSize - numel(obj.vars(inputsIndex(inn)).value) ;
            end
            end
        end
        
        optimal.peak = peak ;
        optimal.frontieerSize = frontieerSize ;
        optimal.node = pivot ;
    end
        
        % Undo the deletion of node so that we can try another sequence
        if (pivot - 1) ~= 0
        for in_ = 1:numel(inputsIndex) 
            if obj.vars(inputsIndex(in)).fanout == 0
                node.frontieer(find(node.frontieer == inputsIndex(in))) = [] ;
            end
            obj.vars(inputsIndex(in)).fanout = obj.vars(inputsIndex(in)).fanout + 1 ;
        end
        end
   
    
    % Put the pivot back in frontieer and subgraph
    node.frontieer = [pivot, node.frontieer] ;
    node.subgraph(end+1) = pivot ;
end

% Update the table
stringSubgraph = sprintf('%d ',node.subgraph) ;
newTable = containers.Map(stringSubgraph,{optimal}) ;
table = [table; newTable] ;

result = optimal ;
return

end


function net = prepareNet(netPath,cut1,cut2)

index1 = 0 ;
index2 = 0;

% Load the model and reconstruct into dag form.
addpath('../../matconvnet/matlab') ;

net = dagnn.DagNN.loadobj(netPath) ;

% Find the index of the variable that defines the start and end of network
if ~isempty(cut1)
    index1 = net.getVarIndex(cut1) ;
end

if ~isempty(cut2)
    index2 = net.getVarIndex(cut2) ;
end

% Set up matconvnet
run(fullfile(fileparts(mfilename('fullpath')), ...
    '..', '..', '..','practical-cnn-2017a', 'matconvnet','matlab', 'vl_setupnn.m')) ;

net.mode = 'test' ;

% load and preprocess an image
im = imread('peppers.png') ;
im_ = single(im) ; % note: 0-255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage) ;

net.conserveMemory = 0 ;

% run the CNN
net.eval({'data', im_}) ;

if index1 ~= 0 && index2 ~= 0
    % Delete some layers to reduce amount of computation
    for i = index2:(numel(net.layers))
        removeLayer(net, net.layers(index2).name) ;
    end
    
    for i = 1:(index1 - 1)
        removeLayer(net, net.layers(1).name) ;
    end
end

end