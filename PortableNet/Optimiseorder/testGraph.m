clear all

% For optimal order
netPath = '../data/googleNet/imagenet-googlenet-dag.mat';
includeBack = false ;
test = netgraph.netGraph.loadobj(netPath,includeBack) ;

mygraph = test.getGraph() ;
plot(mygraph, 'Layout', 'force') ;

[oOrder, omemoryUsage] = test.optOrder() ;
omemory = test.getMemory(oOrder) ;
oMax = max(omemory) ;

% % For default order
% netPath = '../data/resnet/imagenet-resnet-152-dag.mat';
% includeBack = false ;
% test = netgraph.netGraph.loadobj(netPath,includeBack) ;
% 
% test.includeBackPropagation = true ;
% dOrder = test.defaultOrder() ;
% 
% includeBack = true ;
% test = netgraph.netGraph.loadobj(netPath,includeBack) ;
% 
% dmemory = test.getMemory(dOrder) ;
% dMax = max(dmemory) ;

