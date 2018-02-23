function getSize(obj, inputSize)
%CALCULATE Calculate the size for each node in the network
% In terms of bytes
obj.nodes(1).shape = inputSize ;
obj.nodes(1).size = inputSize(1) * inputSize(2) * inputSize(3) * inputSize(4) * 4  ;

inputSizes{1} = inputSize ;

for i = 1:numel(obj.linkage)
    block = obj.linkage(i).block ;
    outputSize = block.getOutputSizes(inputSizes) ;
    while iscell(outputSize)
        outputSize = outputSize{1} ;
    end
    obj.nodes(i+1).shape = outputSize ;
    obj.nodes(i+1).size = outputSize(1) * outputSize(2) * outputSize(3) * outputSize(4) * 4 ;
    
    if i < numel(obj.linkage)
    inputName = obj.linkage(i+1).inputs ;
    inputSizes{1} = obj.nodes(obj.getNodesIndex(inputName)).shape ;
    end
end
end