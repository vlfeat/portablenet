classdef netGraph < matlab.mixin.Copyable
    
    properties
        nodes
        linkage
    end
    
    properties (Transient, Access = private, Hidden = true)
        modifed = false
        nodeNames = struct()
        layerNames = struct()
        layerIndexes = {}
    end
    
    properties (Transient, Access = public, Hidden = true)
        fanout = {[]}
    end
    
    methods
        function obj = netGraph()
            % Initialise a graph representation
            obj.linkage = struct(...
                'name', {}, ...
                'inputs', {}, ...
                'outputs', {}, ...
                'inputIndexes', {}, ...
                'outputIndexes', {}, ...
                'block', {}) ;
            
            obj.nodes = struct(...
                'name', {}, ...
                'size', {}, ...
                'shape', {}, ...
                'numUsages', {}) ;
        end
        
        % Manipulate the netGraph
        setSize(obj, name, size)
        addLinkage(obj, name, inputs, outputs, varargin)
        rebuild(obj)
        
        % Get size of the nodes
        getSize(obj, inputSizes)
        
        % Get execution order
        [order, memoryUsage] = optOrder(obj)
        
        function outputs = getFrontieer(obj)
            n = find([obj.nodes.numUsages] == 0) ;
            outputs = {obj.nodes(n).name} ;
        end
        
        function l = getLinkageIndex(obj, name)
            if iscell(name)
                l = zeros(1, numel(name)) ;
                for k = 1:numel(name)
                    l(k) = obj.getLinkageIndex(name{k}) ;
                end
            else
                if isfield(obj.linkageNames, name)
                    l = obj.linkageNames.(name) ;
                else
                    l = NaN ;
                end
            end
        end
        
        function inputIndex = getInputIndex(obj, output)
            % Given an output node, this function finds the index for its
            % inputs
            while iscell(output)
                output = output{1,1} ;
            end
            
            if isnumeric(output)
                index = [] ;
                inputIndex = [] ;
                
                for counter = 1 : numel(obj.linkage)
                    if isequal(cell2mat(obj.linkage(counter).outputs),obj.nodes(output).name)
                        index(end+1) = counter ;
                    end
                end
                
                for counter2 = 1 : numel(index)
                    input = obj.linkage(index(counter2)).inputs ;
                    for counter3 = 1 : numel(input)
                        if ~ischar(input{counter3})
                            input{counter3} = num2str(input{counter3}) ;
                        end
                        inputIndex(end+1) = getNodesIndex(obj,{input{counter3}}) ;
                    end
                end
                
            else
                warning('The input is not an index') ;
            end      
        end
        
        function outputLayerIndex = getOutputLayerIndex(obj, output)
            % Given an output node's index, this function finds the associated
            % layer's index
            while iscell(output)
                output = output{1,1} ;
            end
            
            if isnumeric(output)
                outputLayerIndex = [] ;
                
                for counter = 1 : numel(obj.linkage)
                    if isequal(cell2mat(obj.linkage(counter).outputs),obj.nodes(output).name)
                        outputLayerIndex(end+1) = counter ;
                    end
                end
             
            else
                warning('The node is not an index') ;
            end      
        end
        
        function n = getNodesIndex(obj, name)
            if iscell(name)
                n = zeros(1, numel(name)) ;
                for k = 1:numel(name)
                    n(k) = obj.getNodesIndex(name{k}) ;
                end
            else
                if isfield(obj.nodeNames, name)
                    n = obj.nodeNames.(name) ;
                else
                    n = NaN ;
                end
            end
        end
    end
    
    methods (Static)
        obj = loadobj(s)
    end
    
    methods (Access = {?netGraph.netGraph})
        function n = addNodes(obj, name)
            n = numel(obj.nodes) + 1 ;
            obj.nodes(n) = struct(...
                'name', {name}, ...
                'size', {[]}, ...
                'shape', {[]}, ...
                'numUsages', {[]}) ;
            
            if n > 1
                for i = 1:(numel(obj.nodes)-1)
                    if isequal(name,obj.nodes(i).name)
                        obj.nodes(n) = [] ;
                        n = i ;
                    end
                end
            end
            
            obj.nodeNames.(name) = n ;
        end
        
    end
    
end
