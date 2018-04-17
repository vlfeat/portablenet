function obj = loadobj(s,includeBack)
% LOADOBJ(s) initialize a graphical representation structure
% If S is a string, initializes the structure with data from a mat-file s

addpath('../../matconvnet/matlab') ;

% Check the input to see
if ischar(s)
    s = load(s);
else
    warning('The input is not a string. Could not read. ');
    return;
end

if isstruct(s)
    assert(isfield(s, 'layers'), 'Invalid model.');
    
    % Initialise a netGraph representation
    obj = netgraph.netGraph() ;
    
    obj.includeBackPropagation = includeBack ;
    
    % Add the forward linkages
    for l = 1:numel(s.layers)
        constr = str2func(s.layers(l).type) ;
        block = constr() ;
        block.load(struct(s.layers(l).block)) ;
        obj.addLinkage(...
            s.layers(l).name, ...
            s.layers(l).inputs, ...
            s.layers(l).outputs, ...
            block, ...
            s.layers(l).type) ;
    end
    
    if obj.includeBackPropagation == true
        % Add backward linkages
        obj.addBack() ;
    end
    
    obj.rebuild() ;
    
    inputSize = s.meta.inputs.size ;
    
    if obj.includeBackPropagation == false
        obj.getSize(inputSize) ;
    else
        outputDer = 1 ;
        obj.getSize(inputSize, outputDer) ;
    end
  
else
    error('Unknown data type %s for `import(s)`.', class(s));
end

end

