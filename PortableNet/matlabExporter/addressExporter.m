function addressExporter()
netPath = '../data/resnet/imagenet-resnet-152-dag.mat';
includeBack = false ;
addpath('../Optimiseorder')
test = netgraph.netGraph.loadobj(netPath,includeBack) ;


[order memory] = test.optOrder();
blockMem = test.packing(order) ;
test.rebuild() ;
% Setup MatConvNet.
run(fullfile(fileparts(mfilename('fullpath')), ...
    '..', '..', '..','practical-cnn-2017a', 'matconvnet','matlab', 'vl_setupnn.m')) ;

% Load the model and reconstruct into dag form.
addpath('../../matconvnet/matlab') ;

net = dagnn.DagNN.loadobj('../../PortableNet/data/resnet/imagenet-resnet-152-dag.mat') ;

opts.outDir = '../data/resnet' ;
mkdir(opts.outDir) ;

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
for i = 1:(numel(order)-1)
    ly = net.layers(order(i)) ;
    ad = test.nodes(order(i)+1) ;
    bk = ly.block ;
    op = struct(...
        'type',class(bk), ...
        'name',ly.name,...
        'inputs',{ly.inputs},...
        'outputs',{ly.outputs},...
        'params',{ly.params},...
        'address',{ad.address}) ;
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
    end
    netj.operations{end+1} = op ;
    
    % Once an operation is completed one dependancy is consumed
    index = zeros(1,numel(ly.inputs));
    for in = 1:numel(ly.inputs)
        index(in) = test.getNodesIndex(ly.inputs(in));
        if isempty(index)
            break
        end
        test.nodes(index(in)).numUsages = test.nodes(index(in)).numUsages - 1;
        if test.nodes(index(in)).numUsages == 0
            op = struct(...
                'type','release',...
                'name',{test.nodes(index(in)).name}) ;
            netj.operations{end+1} = op ;
        end
    end
end


% The reason we can not release the input immediately is because this
% input is shared for another node



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



end