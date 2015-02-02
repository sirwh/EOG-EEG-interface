function [ypred,maxi]=svmmultival(x,xsup,w,b,nbsv,kernel,kerneloption)

% USAGE ypred=svmmultival(x,xsup,w,b,nbsv,kernel,kerneloption)
% 
% Process the class of a new point x of a one-against-all 
% or a all data at once MultiClass SVM
% 
% This function should be used in conjuction with the output of
% svmmulticlass.
%
%
% See also svmmulticlass, svmval
%

% 29/07/2000 Alain Rakotomamonjy


[n1,n2]=size(x);
nbclass=length(nbsv);
y=zeros(n1,nbclass);
nbsv=[0 nbsv];
aux=cumsum(nbsv);
for i=1:nbclass
    if ~isstruct(xsup)
         xsupaux=xsup(aux(i)+1:aux(i)+nbsv(i+1),:);
        waux=w(aux(i)+1:aux(i)+nbsv(i+1));
        baux=b(i);
    else
        xsupaux=xsup;
        xsupaux.indice=xsup.indice(aux(i)+1:aux(i)+nbsv(i+1));
        waux=w(aux(i)+1:aux(i)+nbsv(i+1));
        baux=b(i);
    end;
   ypred(:,i)= svmval(x,xsupaux,waux,baux,kernel,kerneloption);
end;
[maxi,ypred]=max(ypred');
