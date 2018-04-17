
% test = netgraph.netGraph() ;
% test.addLinkage(1,'a','b') ;
% test.addLinkage(2,'a','c') ;
% test.addLinkage(3,'b','d') ;
% test.addLinkage(4,'c','e') ;
% test.addLinkage(5,{'d','e'},'f') ;
% % test.addLinkage(6,'f','h') ;
% % test.addLinkage(7,'f','g') ;
% % test.addLinkage(8,'g','i') ;
% % test.addLinkage(9,'h','j') ;
% % test.addLinkage(10,{'i','j'},'k') ;
% 
% test.rebuild() ;
% 
% test.setSize('a', 10);
% test.setSize('b', 130);
% test.setSize('c', 110);
% test.setSize('d', 10);
% test.setSize('e', 40);
% test.setSize('f', 1);
% % test.setSize('g', 110);
% % test.setSize('h', 60);
% % test.setSize('i', 10);
% % test.setSize('j', 80);
% % test.setSize('k', 1);
% 
% % 
% % For optimal order
% includeBack = true ;
% test.includeBackPropagation = includeBack ;
% 
% test.addBack() ;
% test.rebuild() ;
% 
% n = numel(test.linkage)/2 ;
% for i = 1:n
%         % Derivative of a certain node is the same size as itself
%         test.nodes(2*n - i +2).shape = test.nodes(i+1).shape ;
%         test.nodes(2*n - i +2).size = test.nodes(i+1).size;
% end
% test.setSize('Da', 10);
% 
% mygraph = test.getGraph() ;
% plot(mygraph, 'Layout', 'force') ;
% 
% [oOrder, omemoryUsage] = test.optOrder() ;
% omemory = test.getMemory(oOrder) ;
% oMax = max(omemory) ;

% 
% netPath = '../data/resnet/imagenet-resnet-152-dag.mat';
% % dOrder = test.defaultOrder() ;
% 
% includeBack = true ;
% test = netgraph.netGraph.loadobj(netPath,includeBack) ;
% 
% [oOrder, omemoryUsage] = test.optOrder() ;
% omemory = test.getMemory(oOrder) ;
% oMax = max(omemory) ;


% % For default order
% test.includeBackPropagation = true ;
% dOrder = test.defaultOrder() ;
% 
% test.addBack() ;
% test.rebuild() ;
% 
% n = numel(test.linkage)/2 ;
% for i = 1:n
%         % Derivative of a certain node is the same size as itself
%         test.nodes(2*n - i +2).shape = test.nodes(i+1).shape ;
%         test.nodes(2*n - i +2).size = test.nodes(i+1).size;
% end
% test.setSize('Da', 10);
% 
% dmemory = test.getMemory(dOrder) ;
% dMax = max(dmemory) ;
% 


% netPath = '../data/resnet/imagenet-resnet-152-dag.mat';
% 
% includeBack = false ;
% test = netgraph.netGraph.loadobj(netPath,includeBack) ;
% test.includeBackPropagation = true ;
% dOrder = test.defaultOrder() ;
% 
% includeBack = true ;
% test = netgraph.netGraph.loadobj(netPath,includeBack) ;
% 
% dmemory = test.getMemory(dOrder) ;
% dMax = max(dmemory) ;
