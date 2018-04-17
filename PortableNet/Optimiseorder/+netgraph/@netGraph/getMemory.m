function memory = getMemory(obj,order)
%GETMEMORY calculates the memory usage for the given execution order

% The size of memory array is twice the number of linkages minus 1
% The last data does not need to be deleted
memory = zeros(1,numel(obj.nodes) * 2 - 1) ;

% Step 1 is to import the data
input = obj.getNodesIndex(obj.getInput()) ;
memory(1) = sum([obj.nodes(input).size]) ;

counter = 2 ;

for i = 1:numel(order)
    % Step 2 is to compute the output node
    n = obj.getNodesIndex(obj.linkage(order(i)).outputs) ;
    memory(counter) = memory(counter - 1) + obj.nodes(n).size ;
    
    % Step 3 is to delete any nodes that are not needed for future use
    memory(counter+1) = memory(counter);
    inputIndex = obj.getInputIndex(n) ;
    for in = 1:numel(inputIndex)
        obj.nodes(inputIndex(in)).numUsages = obj.nodes(inputIndex(in)).numUsages - 1 ;
        if obj.nodes(inputIndex(in)).numUsages == 0
            memory(counter+1) = memory(counter+1) - obj.nodes(inputIndex(in)).size ;
        end
    end
    
    counter = counter + 2 ;
end

obj.rebuild() ; 
end