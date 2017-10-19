function exporter()

run ../Lib/matconvnet/matlab/vl_setupnn

opts.outDir = 'data/alexnet.mcn' ;
mkdir(opts.outDir) ;

% Load AlexNet model in DagNN format.
net_ = load('data/models/imagenet-caffe-alex.mat') ;
net = dagnn.DagNN.fromSimpleNN(net_) ;

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
order = net.getLayerExecutionOrder() ;
op = struct('type','LoadImage',...
  'inputs',{{}},...
  'outputs',{net.layers(order(1)).inputs(1)}, ...
  'reshape',[224 224], ...
  'averageColor',[128 128 128], ...
  'dataType','single') ;
netj.operations{end+1} = op ;
  
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
  end
  netj.operations{end+1} = op ;
end

% Write data out.
json = jsonencode(netj) ;
exportText(fullfile(opts.outDir,'net.json'),json) ;
for i = 1:numel(net.params)
  exportBlob(fullfile(opts.outDir,sprintf('%s.tensor', net.params(i).name)), ...
    net.params(i).value) ;
end

function exportText(fileName,string)
f=fopen(fileName,'w');
fwrite(f,string);
fclose(f) ;

function exportBlob(fileName,blob)
f=fopen(fileName,'wb');
switch class(blob)
  case 'double', precision = 'float64' ;
  case 'single', precision = 'float32' ;
  otherwise, assert(false) ;
end
fwrite(f,blob,precision,'ieee-le');
fclose(f) ;

function s=merge(s1,s2)
s=s1;
for f=fieldnames(s2)'
  s.(char(f)) = s2.(char(f)) ;
end






