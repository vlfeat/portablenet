function setSize(obj, name, size)
% SETSIZE set the size of the nodes manually

index = obj.getNodesIndex(name) ;
obj.nodes(index).size = size ;

end