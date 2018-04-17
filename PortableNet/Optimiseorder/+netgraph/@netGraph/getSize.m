function getSize(obj, inputSize, varargin)
%CALCULATE Calculate the size for each node in the network
% In terms of bytes
obj.nodes(1).shape = inputSize ;
obj.nodes(1).size = inputSize(1) * inputSize(2) * inputSize(3) * inputSize(4) * 4  ;

if ~isempty(varargin)
    obj.nodes(end).shape = inputSize ;
    obj.nodes(end).size = inputSize(1) * inputSize(2) * inputSize(3) * inputSize(4) * 4  ;
end

inputSizes{1} = inputSize ;

if ~isempty(varargin)
    n = (numel(obj.linkage)/2) ;
else
    n = numel(obj.linkage) ;
end

for i = 1:n
    block = obj.linkage(i).block ;
    outputSize = block.getOutputSizes(inputSizes) ;
    while iscell(outputSize)
        outputSize = outputSize{1} ;
    end
    obj.nodes(i+1).shape = outputSize ;
    obj.nodes(i+1).size = outputSize(1) * outputSize(2) * outputSize(3) * outputSize(4) * 4 ;
    
    if ~isempty(varargin)
        % Derivative of a certain node is the same size as itself
        obj.nodes(obj.nodeNames.(obj.nodes(2*n - i +2).name)).shape = outputSize ;
        obj.nodes(obj.nodeNames.(obj.nodes(2*n - i +2).name)).size = outputSize(1) * outputSize(2) * outputSize(3) * outputSize(4) * 4 ;
    end
    
    % For each layer calculate the input size
    if i < n
        inputName = obj.linkage(i+1).inputs ;
        inputSizes{1} = obj.nodes(obj.getNodesIndex(inputName)).shape ;
    end
end


% if ~isempty(varargin)
%     % Set the derivative for all outputs 1
%     out = obj.getFrontieer() ;
%     index = strfind(out,'Der') ;
%     
%     for o = 1:numel(index)
%         if ~isempty(index{o})
%             obj.nodes(numel(obj.nodes) - obj.getNodesIndex(out{o}) + 1).shape = varargin{1} ;
%             obj.nodes(numel(obj.nodes) - obj.getNodesIndex(out{o}) + 1).size = varargin{1} ;
%         end
%     end
% end

end