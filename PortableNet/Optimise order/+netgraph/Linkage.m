classdef Linkage < handle
    %LINKAGE Base class for a linkage in netGraph
    
    properties (Access = {?netgraph.netGraph, ?netgraph.Linkage}, Transient) 
    netGraph
    layerIndex
    end
    
    methods 
        
        function add_(obj, netGraph, index)
            %ATTACH Attach the linkage to a netGraph
            obj.netGraph = netGraph ;
            obj.linkageIndex = index ;
            for input = net.linkage(index).inputs
                netGraph.addNodes(char(input)) ;
            end
            for input = net.linkage(index).outputs
                netGraph.addNodes(char(output)) ;
            end
        end
    end
end