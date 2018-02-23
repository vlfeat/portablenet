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

clear all

netPath = '../data/googlenet/imagenet-googlenet-dag.mat';

test = netgraph.netGraph.loadobj(netPath) ;

[order, memoryUsage] = test.optOrder() ;
