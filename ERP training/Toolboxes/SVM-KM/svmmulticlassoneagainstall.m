function [xsup,w,b,nbsv,pos]=svmmulticlass(x,y,nbclass,c,epsilon,kernel,kerneloption,verbose);

% USAGE [xsup,w,b,nbsv,pos]=svmmulticlass(x,y,nbclass,c,epsilon,kernel,kerneloption,verbose);
%
%
% SVM Multi Classes Classification One against Others algorithm
%
% y is the target vector which contains integer from 1 to nbclass.
% 
% This subroutine use the svmclass function
% 
% the differences lies in the output nbsv which is a vector
% containing the number of support vector for each machine
% learning.
% For xsup, w, b, the output of each ML are concatenated
% in line.
% 
% 
% See svmclass, svmmultival
%
%
% 29/07/2000 Alain Rakotomamonjy

xsup=[];  % 3D matrices can not be used as numebr of SV changes
w=[];
b=[];
pos=[];
nbsv=zeros(1,nbclass);
nbsuppvector=zeros(1,nbclass);
if isstruct(x)
    xsup=x;
end;
for i=1:nbclass
    
    yone=(y==i)+(y~=i)*-1;
    

    [xsupaux,waux,baux,posaux]=svmclassls(x,yone,c,epsilon,kernel,kerneloption,verbose);
    
    
    if ~isstruct(x)  % data is stored in matrix
        [n1,n2]=size(xsupaux);
        nbsv(i)=n1;
        xsup=[xsup;xsupaux];
        w=[w;waux];
        b=[b;baux];
        pos=[pos;posaux];
    else % data is stored in file
        w=[w;waux];
        b=[b;baux];
        pos=[pos;posaux];
        nbsv(i)=length(posaux);
        
        xsup.indice=x.indice(pos);
    end;
end;


