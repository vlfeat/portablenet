function exporter()

% Setup MatConvNet.
run(fullfile(fileparts(mfilename('fullpath')), ...
    '..', '..', '..','practical-cnn-2017a', 'matconvnet','matlab', 'vl_setupnn.m')) ;

% Load the model and reconstruct into dag form.
addpath('../../matconvnet/matlab') ;

net = dagnn.DagNN.loadobj('../../PortableNet/data/googleLeNet/imagenet-googlenet-dag.mat') ;

opts.outDir = '../data/googleLeNet' ;
mkdir(opts.outDir) ;

% -------------------------------------------------------------------------
% Decide on order of execution
% -------------------------------------------------------------------------

% Initialisation
order = zeros(1,numel(net.layers)) ;
outIndex = zeros(1,numel(net.layers));
depForward = zeros(1,numel(net.layers)) ;
depForward_Init = zeros(1,numel(net.layers)) ;
% releaseFlag = zeros(1,numel(net.layers)) ;
ordercounter = 0 ;

% Mark the number of dependencies for each node
inputs = cat(1,{net.layers(:).inputs}) ;
% inputs_Init = inputs ;
outputs = cat(1,{net.layers(:).outputs}) ;
outputs_Init_Flat = [outputs{1,:}] ;


% Store the initial dependencies for each node
inputsFlat = [inputs{1,:}] ;
for j = 1:numel(outputs)
    for t = 1:numel(inputsFlat)
        depForward_Init(j)= depForward_Init(j) + (ismember(outputs{1,j}, inputsFlat{1,t})) ;
    end
end

% Search for the output (defined as the node that does not act as any
% inputs)
while ordercounter < numel(net.layers)
    indexCounter = 1;
    
    inputsFlat = [inputs{1,:}] ;
    
    for j = 1:numel(outputs)
        depForward(j)= not(ismember(outputs{1,j}, inputsFlat)) ;
        if depForward(j) == 1
            outIndex(indexCounter) = j ;
            indexCounter = indexCounter + 1 ;
        end
    end
    
    % Start from the output and search backwards
    % Put the node in out node array when the dependencies are all occupied
    % Remove the node
    
    numNodes = nnz(outIndex);
    
    for k = 1:numNodes
        order(numel(net.layers) - ordercounter) = outIndex(numNodes - k + 1) ;
        
        %         % Raise release flag only when the first output node in a set of nodes is
        %         % placed in order array
        %         if numNodes == 1
        %             releaseFlag(outIndex(1)) = 1 ;
        %         else
        %         releaseFlag()
        %         end
        
        outputs(outIndex(numNodes - k + 1)) = {'used'} ;
        inputs(outIndex(numNodes - k + 1)) = {'used'} ;
        
        outIndex(numNodes - k + 1) = 0 ;
        
        ordercounter = ordercounter + 1 ;
    end
end


% -------------------------------------------------------------------------
% Create list of operation
% -------------------------------------------------------------------------

netj.operations = {} ;

% The first operation is to load the parameters.
for i = 1:numel(net.params)
    op.type = 'Load' ;
    op.inputs = {} ;
    op.outputs = {net.params(i).name} ;
    op.shape = size(net.params(i).value) ;
    op.dataType = class(net.params(i).value) ;
    op.endian = 'little' ;
    op.fileName = [net.params(i).name '.tensor'] ;
    netj.operations{end+1} = op ;
end

% The second operation is to load the data to operate on
%order = net.getLayerExecutionOrder() ;
op = struct('type','LoadImage',...
    'inputs',{{}},...
    'outputs',{net.layers(order(1)).inputs(1)}, ...
    'reshape',{net.meta.inputs.size}, ...
    'dataType','single') ;
netj.operations{end+1} = op ;

% % Initialise the counter array for used dependencies
% usedDep = zeros(1,numel(net.layers)) ;

% The other operations come from the neural network
for i = 1:numel(order)
    ly = net.layers(order(i)) ;
    bk = ly.block ;
    op = struct(...
        'type',class(bk), ...
        'name',ly.name,...
        'inputs',{ly.inputs},...
        'outputs',{ly.outputs},...
        'params',{ly.params}) ;
    switch op.type
        case 'dagnn.Conv'
            op = merge(op, struct(...
                'shape',bk.size, ...
                'hasBias',bk.hasBias, ...
                'padding', bk.pad, ...
                'stride',  bk.stride, ...
                'dilate', bk.dilate));
        case 'dagnn.Pooling'
            op = merge(op, struct(...
                'shape', bk.poolSize, ...
                'padding', bk.pad, ...
                'stride',  bk.stride)) ;
        case 'dagnn.LRN'
            op = merge(op, struct(...
                'param', bk.param)) ;
        case 'dagnn.BatchNorm'
            op = merge(op, struct(...
                'channel', bk.numChannels, ...
                'param', bk.epsilon, ...
                'moments', bk.moments)) ;
        case 'dagnn.Sum'
            op = merge(op, struct(...
                'numofInputs', bk.numInputs)) ;
        case 'dagnn.Concat'
            op = merge(op, struct(...
                'dimension', bk.dim)) ;
    end
    netj.operations{end+1} = op ;
    
    % Once an operation is completed one dependancy is consumed
    for u = 1 : numel(ly.inputs)
        [flag, index] = ismember(ly.inputs{1,u},outputs_Init_Flat) ;
        
        % For first operation manually release data
        if flag == 0
            op = struct(...
                'type','release',...
                'name',{ly.inputs}) ;
            netj.operations{end+1} = op ;
        else
            
            depForward_Init(index) = depForward_Init(index) - 1 ;
            %     isIndex = cellfun(@(x) isequal(x,index), )
            %     nnn = find(index) ;
            if depForward_Init(index) == 0
                op = struct(...
                    'type','release',...
                    'name',{net.layers(index).outputs}) ;
                netj.operations{end+1} = op ;
            end
        end
    end
    
    % The reason we can not release the input immediately is because this
    % input is shared for another node
    
end

%netj.operations{end} = {};

% Write data out.
json = jsonencode(netj) ;
exportText(fullfile(opts.outDir,'net.json'),json) ;
exportDescription(fullfile(opts.outDir,'description.txt'),net.meta.classes.description) ;
for m = 1:numel(net.params)
    exportBlob(fullfile(opts.outDir,sprintf('%s.tensor', net.params(m).name)), ...
        net.params(m).value) ;
end

exportBlob(fullfile(opts.outDir,sprintf('averageColour.tensor')),single(net.meta.normalization.averageImage));

    function exportText(fileName,string)
        f=fopen(fileName,'w');
        fwrite(f,string);
        fclose(f) ;
    end

    function exportDescription(fileName,cell)
        f=fopen(fileName,'w');
        for n = 1:1000
            fwrite(f,cell{n});
            fwrite(f,"|");
        end
        fclose(f) ;
    end

    function exportBlob(fileName,blob)
        f=fopen(fileName,'wb');
        switch class(blob)
            case 'double', precision = 'float64' ;
            case 'single', precision = 'float32' ;
            otherwise, assert(false) ;
        end
        fwrite(f,blob,precision,'ieee-le');
        fclose(f) ;
    end

    function s=merge(s1,s2)
        s=s1;
        for f=fieldnames(s2)'
            s.(char(f)) = s2.(char(f)) ;
        end
    end

%     function order = getNextOrder(inputs, outputs, outIndex)
%         % Initialise the forward dependency array that stores the forward
%         % dependencies for each node
%         depForward = zeros(1,numel(net.layers)) ;
%
%         % Unnest the input array to show all inputs
%         inputsFlat = [inputs{1,:}] ;
%
%         % Search for output nodes (defined as the nodes that do not act as inputs)
%         for i = 1:numel(outputs)
%
%             % 0 suggests the output node act as an input at least one time
%             % 1 suggests the output node does not act as an input
%             depForward(numel(net.layers) - i + 1)= not(ismember(outputs{1,numel(net.layers) - i + 1}, inputsFlat)) ;
%
%             % Store the output nodes
%             if depForward(i) == 1
%                 outIndex{end+1} = i ;
%             end
%         end
%
%         % Start from the output and search backwards
%         % Put the node in out node array when the dependencies are all occupied
%         % Remove the node
%         order = outIndex{1} ;
%
%         outputs(outIndex{1}) = {'used'} ;
%         inputs(outIndex{1}) = {'used'} ;
%
%         outIndex{1} = [] ;
%
%     end

end

