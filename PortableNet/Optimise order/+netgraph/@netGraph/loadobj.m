function obj = loadobj(s)
% IMPORT(s) initialize a graphical representation structure
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
    
    for l = 1:numel(s.layers)
        constr = str2func(s.layers(l).type) ;
        block = constr() ;
        block.load(struct(s.layers(l).block)) ;
        obj.addLinkage(...
            s.layers(l).name, ...
            s.layers(l).inputs, ...
            s.layers(l).outputs, ...
            block) ;
    end
    
    obj.rebuild() ;
    
    inputSize = s.meta.inputs.size ;
    obj.getSize(inputSize) ;
    
else
    error('Unknown data type %s for `import(s)`.', class(s));
end

end

