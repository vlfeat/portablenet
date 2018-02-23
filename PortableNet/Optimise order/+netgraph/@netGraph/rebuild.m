function rebuild(obj)
%REBUILD Rebuild the internal data structures of a netGraph object

nodeNumUsage = zeros(1, numel(obj.nodes)) ;

for l = 1:numel(obj.linkage)
  ii = obj.getNodesIndex(obj.linkage(l).inputs) ;
  oi = obj.getNodesIndex(obj.linkage(l).outputs) ;
  obj.linkage(l).inputIndexes = ii ;
  obj.linkage(l).outputIndexes = oi ;
  nodeNumUsage(ii) = nodeNumUsage(ii) + 1 ;

end

[obj.nodes.numUsages] = tolist(num2cell(nodeNumUsage)) ;
[obj.fanout] = [obj.nodes.numUsages] ;

end

% --------------------------------------------------------------------
function varargout = tolist(x)
% --------------------------------------------------------------------
[varargout{1:numel(x)}] = x{:} ;
end
