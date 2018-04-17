
x0 = [10,110,3] ;

options = optimset('Diagnostics','on','Display','iter-detailed','MaxIter',5000, 'MaxFun') ;
% options = optimset('Diagnostics','on','Display','iter-detailed','MaxIter', 1) ;
[x,fval] = fminimax(@myfun,x0,[],[],[],[],[10,20,0],[10,20,inf],@const,options);

function f = myfun(x)
size = [10,110,40] ;
f(1) = x(1) + size(1) - 1  ;
f(2) = x(2) + size(2) - 1 ;
f(3) = x(3) + size(3) - 1 ;
% f(3) = x(3) + size(3) - 1 ;
% f(4) = x(4) + size(4) - 1 ;
% f(5) = x(5) + size(5) - 1 ;
end

function [c, ceq] = const(x)
size = [10,110,40] ;
c(1) = min((x(1) + size(1) - x(2) + 1e-5) , (x(2) + size(2) - x(1) + 1e-5))  ;
c(2) = min((x(2) + size(2) - x(3) + 1e-5) , (x(3) + size(3) - x(2) + 1e-5)) ;
c(3) = min((x(3) + size(3) - x(1) + 1e-5) , (x(1) + size(1) - x(3) + 1e-5)) ;

ceq = [] ;
end