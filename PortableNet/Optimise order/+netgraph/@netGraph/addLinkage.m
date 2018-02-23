function obj = addLinkage(obj, name, inputs, outputs, varargin)
if ~isempty(varargin)
    
    index = find(strcmp(name, {obj.linkage.name})) ;
    if ~isempty(index), error('There is already a linkage with name ''%s''.', name), end
    index = numel(obj.linkage) + 1 ;
    
    if ischar(inputs), inputs = {inputs} ; end
    if ischar(outputs), outputs = {outputs} ; end
    
    obj.linkage(index) = struct(...
        'name', {name}, ...
        'inputs', {inputs}, ...
        'outputs', {outputs}, ...
        'inputIndexes', {[]}, ...
        'outputIndexes', {[]}, ...
        'block', varargin) ;
   
    for input = obj.linkage(index).inputs
        obj.addNodes(char(input)) ;
    end
  
    for output = obj.linkage(index).outputs
        obj.addNodes(char(output)) ;
    end
    
else
    index = find(strcmp(name, {obj.linkage.name})) ;
    if ~isempty(index), error('There is already a linkage with name ''%s''.', name), end
    index = numel(obj.linkage) + 1 ;
    
    if ischar(inputs), inputs = {inputs} ; end
    if ischar(outputs), outputs = {outputs} ; end
    
    obj.linkage(index) = struct(...
        'name', {name}, ...
        'inputs', {inputs}, ...
        'outputs', {outputs}, ...
        'inputIndexes', {[]}, ...
        'outputIndexes', {[]},...
        'block', {[]}) ;
   
    for input = obj.linkage(index).inputs
        obj.addNodes(char(input)) ;
    end
  
    for output = obj.linkage(index).outputs
        obj.addNodes(char(output)) ;
    end
end
end