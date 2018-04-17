function memory = worstmem(obj)
n = numel(obj.nodes);
memory = 0 ;

for i = 1:n
    memory = memory + obj.nodes(i).size ;
end
end