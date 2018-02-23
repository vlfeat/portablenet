classdef xTable < handle
    properties (Access = {?netgraph.netGraph, ?netgraph.table})
        Entry
    end
    
    methods
        function obj = xTable()
            obj.Entry = struct(...,
                'key', {[]},...
                'value', {[]}) ;
        end
        
        function addEntry(obj, newKey, newValue)
            if isempty(obj.Entry(1).key)
                obj.Entry(1).key = newKey ;
                obj.Entry(1).value = newValue ;
            else
                
                index = numel(obj.Entry) + 1 ;
                obj.Entry(index).key = newKey ;
                obj.Entry(index).value = newValue ;
            end
        end
        
        
        
        
        function value = findValue(obj, key)
            repFlag = false ;
            if ~iscell(key)
                key = {key} ;
            end
            
            i = numel(obj.Entry) ;
            
            while i >= 1
                if (isempty(setdiff(key{:},obj.Entry(i).key)) &&...
                        ~isempty(obj.Entry(i).key) &&...
                        isempty(setdiff(obj.Entry(i).key,key{:})))
                    repFlag = true ;
                    value = obj.Entry(i).value ;
                    break
                else
                    i = i - 1 ;
                end
            end
            
            if repFlag == false
                value = [] ;
            end
        end
        
    end
end
