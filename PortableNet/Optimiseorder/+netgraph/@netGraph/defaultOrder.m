function order = defaultOrder(obj)
%DEFAULTORDER finds the default order of which matconvnet uses

order = zeros(1,numel(obj.linkage)) ;

order_ = sortGraph(obj, order) ;
order = fliplr(order_) ;

orderBack = order + numel(obj.linkage) ;

obj.rebuild() ;

if obj.includeBackPropagation == true
    order = cat(2, order, orderBack) ;
end

% memory = obj.getMemory(order) ;
% memoryUsage = max(memory) ;

end

function order = sortGraph(obj, order)
% Find the frontieer
% Defined as the nodes that do not act as input to any layers
frontieer = obj.getFrontieerIndex() ;

if isempty(frontieer) 
    return
end

% Add to order
for i = numel(frontieer):-1:1
    if frontieer(i) ~= 1
    order(nnz(order)+1) = obj.getOutputLayerIndex(frontieer(i)) ;
    end
    
    % Remove from frontieer
    inputIndex = obj.getInputIndex(frontieer(i)) ;
    if inputIndex == 1
        obj.nodes(inputIndex).numUsages = obj.nodes(inputIndex).numUsages - 1 ;
    end
    
    obj.nodes(frontieer(i)).numUsages = obj.nodes(frontieer(i)).numUsages - 1 ;
    
    for in = 1:numel(inputIndex)
        obj.nodes(inputIndex(in)).numUsages = obj.nodes(inputIndex(in)).numUsages - 1 ;
    end
end

    % Find the next nodes recursively
    order = sortGraph(obj, order) ;

end





% function order = defaultOrder(obj)
% % --------------------------------------------------------------------
% hops = cell(1, numel(obj.nodes)) ;
% for l = 1:numel(obj.linkage)
%   for v = obj.linkage(l).inputIndexes
%     hops{v}(end+1) = l ;
%   end
% end
% order = zeros(1, numel(obj.linkage)) ;
% for l = 1:numel(obj.linkage)
%   if order(l) == 0
%     order = dagSort(obj, hops, order, l) ;
%   end
% end
% if any(order == -1)
%   warning('The network graph contains a cycle') ;
% end
% [~,order] = sort(order, 'descend') ;
% end
% 
% 
% % --------------------------------------------------------------------
% function order = dagSort(obj, hops, order, linkage)
% % --------------------------------------------------------------------
% if order(linkage) > 0, return ; end
% order(linkage) = -1 ; % mark as open
% n = 0 ;
% for o = obj.linkage(linkage).outputIndexes ;
%   for child = hops{o}
%     if order(child) == -1
%       return ;
%     end
%     if order(child) == 0
%       order = dagSort(obj, hops, order, child) ;
%     end
%     n = max(n, order(child)) ;
%   end
% end
% order(linkage) = n + 1 ;
% end
