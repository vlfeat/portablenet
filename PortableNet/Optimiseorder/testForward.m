clear all
% test = netgraph.netGraph() ;
% test.addLinkage(1,'src','x1') ;
% test.addLinkage(2,'src','x7') ;
% test.addLinkage(3,'x1','x2') ;
% test.addLinkage(4,'x1','x3') ;
% test.addLinkage(5,'x2','x4') ;
% test.addLinkage(6,'x3','x5') ;
% test.addLinkage(7,{'x4','x5'},'x6') ;
% test.addLinkage(8,{'x3','x7'},'x8') ;
% test.addLinkage(9,{'x2','x7'},'x9') ;
% test.addLinkage(10,{'x1','x8'},'x10') ;
% test.addLinkage(11,{'x1','x9'},'x11') ;
% test.addLinkage(12,{'x10','x11'},'x12') ;
% 
% test.rebuild() ;
% 
% test.setSize('src', 0);
% test.setSize('x1', 10);
% test.setSize('x2', 20);
% test.setSize('x3', 30);
% test.setSize('x4', 60);
% test.setSize('x5', 200);
% test.setSize('x6', 100);
% test.setSize('x7', 40);
% test.setSize('x8', 10);
% test.setSize('x9', 10);
% test.setSize('x10', 50);
% test.setSize('x11', 30);
% test.setSize('x12', 20);

netPath = '../data/resnet/imagenet-resnet-152-dag.mat' ;
includeBack = false ;
test = netgraph.netGraph.loadobj(netPath,includeBack) ;
tic
% test = netgraph.netGraph() ;
% test.addLinkage(1,'a','b') ;
% test.addLinkage(2,'a','c') ;
% test.addLinkage(3,'b','d') ;
% test.addLinkage(4,'c','e') ;
% test.addLinkage(5,{'d','e'},'f') ;
% test.addLinkage(6,'f','h') ;
% test.addLinkage(7,'f','g') ;
% test.addLinkage(8,'g','i') ;
% test.addLinkage(9,'h','j') ;
% test.addLinkage(10,{'i','j'},'k') ;
% 
% test.rebuild() ;
% 
% test.setSize('a', 10);
% test.setSize('b', 130);
% test.setSize('c', 110);
% test.setSize('d', 10);
% test.setSize('e', 40);
% test.setSize('f', 1);
% test.setSize('g', 110);
% test.setSize('h', 60);
% test.setSize('i', 10);
% test.setSize('j', 80);
% test.setSize('k', 1);

% Represent as a graph
test.getGraph() ;

% Default
% dOrder = test.defaultOrder() ;
% dmemory = test.getMemory(dOrder) ;
% dMax = max(dmemory) ;

% For optimal order
[oOrder, omemoryUsage] = test.optOrder() ;
omemory = test.getMemory(oOrder) ;
oMax = max(omemory) ;
toc
