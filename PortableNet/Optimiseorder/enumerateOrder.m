clear all

netPath = '../../PortableNet/data/resnet/imagenet-resnet-152-dag.mat' ;
cut1 = 'data' ;
cut2 = 'res3a' ;

% Initial order
nextNodes = [] ;
orderSet = cell(1) ;
success = false ;

% Modify the network
net = prepareNet(netPath, cut1, cut2) ;

% All possible order sequences
orderSet = allOrder(net,orderSet, success) ;

% Calculate the memory usage for each
memory = {} ;
for q = 1:numel(orderSet)
    memory{q} = getMemory(net,orderSet{q}) ;
end

% Calculate the maximum memory usage
maximum = zeros(numel(memory),1) ;
for q = 1:numel(memory)
    maximum(q) = max(memory{q}) ;
end

% Calculate the average memory usage
average = zeros(numel(memory),1) ;
for q = 1:numel(memory)
    average(q) = sum(memory{q}) / numel(memory{q});
end

[m, i] = max(average) ;

result = orderSet{i} ;


function orderSet = allOrder(net, orderSet, success)
counter = 0;

if ~success
    % Keeps a copy of current set of order sequence before it gets updated
    for o = 1:numel(orderSet)
        nextOrder{o} = orderSet{o} ;
    end
    
    for a = 1:numel(orderSet)
        % For each of the order sequence, find the next set of output nodes
        nextNodes = searchOut(net,nextOrder{a}) ;
        
        % Raise success flag when there is no output nodes
        if isempty(nextNodes)
            success = true ;
            return
        else
            success = false ;
        end
        
        if (~success)
            for b = 1:numel(nextNodes)
                % Continue with recursive function when the criteria is not met
                counter = counter + 1 ;
                orderSet{counter} = addNodes(nextNodes(b),nextOrder{a}) ;
                
            end
        end
    end
end
orderSet = allOrder(net, orderSet, success) ;
end

function orderSet = testOrder(net, orderSet, success)
counter = 0;

if ~success
    % Keeps a copy of current set of order sequence before it gets updated
    for o = 1:numel(orderSet)
        nextOrder{o} = orderSet{o} ;
    end
    
    for a = 1:numel(orderSet)
        % For each of the order sequence, find the next set of output nodes
        nextNodes{a} = searchOut(net,nextOrder{a}) ;
    end
    
    % Raise success flag when there is no output nodes
    if isempty(nextNodes{1}) && isempty(nextNodes{2})
        success = true ;
        return
    else
        success = false ;
    end
    
    if (~success)
        
        orderSet{1} = addNodes(nextNodes{1,1}(1,1),nextOrder{1}) ;
        orderSet{2} = addNodes(nextNodes{1,2}(1,end),nextOrder{2}) ;
        
    end
end

orderSet = testOrder(net, orderSet, success) ;
end

function nextOrder = addNodes(nextNodes, existingOrder)
% This function adds one output to a specific order sequence

nextOrder = cat(2,nextNodes,existingOrder) ;

end

function outIndex = searchOut(net,order)
% This function searches backward recursively for the output node
% Output node is defined as a node that does not act as an input to another
% node

% Create cells to store inputs and outputs
inputs = cat(1,{net.layers(:).inputs}) ;
outputs = cat(1,{net.layers(:).outputs}) ;

% Delete the inputs and outputs associated with the nodes that we already
% used
if ~isempty(order)
    for orderCounter = 1:numel(order)
        outputs{1, order(orderCounter)} = {'used'} ;
        inputs{1, order(orderCounter)} = {'used'} ;
    end
end

% Initialize array that stores how many forward arrows each node has
depForward = zeros(1,numel(outputs)) ;

% Initialize array that stores nodes that are defined as output nodes
outIndex = zeros(1,numel(outputs));

% Initialize counter
indexCounter = 1 ;

% Unnest the inputs
inputsFlat = [inputs{1,:}] ;

% Search through all outputs
% Find the outputs that does not act as an input to any layer
% Record the index for the output nodes
for j = 1:numel(outputs)
    depForward(j)= not(ismember(outputs{1,j}, inputsFlat)) ;
    if depForward(j) == 1
        outIndex(indexCounter) = j ;
        indexCounter = indexCounter + 1 ;
    end
end

% Clear index array to prepare for next search
outIndex(outIndex == 0) = [] ;

end

function memory = getMemory(obj,order)
counter = 1 ;
memory = zeros(numel(obj.layers) * 2 - 1, 1) ;
fanout = zeros(numel(obj.vars), 1) ;
memory(1) = numel(obj.vars(1).value) ;

for f = 1:numel(obj.vars)
    fanout(f) = obj.vars(f).fanout ;
end


for l = 1:numel(order)
    counter = counter + 1 ;
    
    % After one layer, store the output tensor from this layer
    memory(counter) = memory(counter - 1) + numel(obj.vars(obj.getVarIndex(obj.layers(order(l)).outputs)).value) ;
    
    % Decide whether to delete the input tensor(s)
    % Manually delete data
    if l == 1
        counter = counter + 1 ;
        memory(counter) = memory(counter - 1) - numel(obj.vars(1).value) ;
        
    else
        
        for i = 1:numel(obj.layers(order(l)).inputs)
            
            % Find the tensors who points to the current tensor
            indexIn = obj.getVarIndex((obj.layers(order(l)).inputs{1,i})) - 1 ;
            
            fanout(indexIn+1) = fanout(indexIn+1) - 1 ;
            
            % When the input is no longer needed we release this tensor
            if fanout(indexIn+1) == 0
                counter = counter + 1 ;
                memory(counter) = memory(counter - 1) - numel(obj.vars(indexIn+1).value) ;
            end
            
        end
    end
end
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

function optMemory = findOptMemory()
% Find the output nodes 
% Defined as the set of nodes that does not act as inputs to any other
% nodes
nextNodes = searchOut(net,orders) ;


optMemory = zeros(numel(nextNodes),1) ;

for n = 1:numel(nextNodes)
    optMemory(n) = findOptMemory(nextNodes(n),net) ;
end

order = zeros(numel(net.layers),1) ;





end