function [xsup,w,b,nbsv,classifier,pos,SigmaOut]=svmmulticlassoneagainstone(x,y,nbclass,c,epsilon,kernel,kerneloption,verbose,tag,sigma,pow,method);

%[xsup,w,b,nbsv,classifier,posSigma]=svmmulticlassoneagainstone(x,y,nbclass,c,epsilon,kernel,kerneloption,verbose,tag,sigma,pow,method);
%
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
% classifier gives which class against which one
% 
% An adaptive scaling feature selection can be used by setting
% tag to 0. Other parameters must then be chosen 
% default value : sigma=1, pow=2, method='lupdate'; 
% 
%
% See svmclass, svmmultival
%
%


% Modifications - 05/03/2003   Gaelle Loosli
% input:    verbose (0-3) : level of comments
%           tag 1 : for normal classification
%               0 : for selection of variables
%           sigma : initial weight of variables (scalar value)
%           pow : 
%           method : 'wfixed' 'wbfixed' 'bfixed' 'lfixed' 'lupdate'
% output:   Sigma : updated weighs for each variables
%
% 29/07/2000 Alain Rakotomamonjy

if nargin <12
    method='lupdate';
end;

if nargin <11
    pow=2;
end;

if nargin <10
    sigma=1;
end;

if nargin < 9
    tag=1;
end;
if nargin < 8
    verbose=0;
end;


xsup=[];  % 3D matrices can not be used as numebr of SV changes
w=[];
b=[];
pos=[];
SigmaOut=[];
classifier=[];
nbsv=zeros(1,nbclass);
nbsuppvector=zeros(1,nbclass);
k=1;        
if isempty(x) & strcmp(kernel,'numerical') & isfield(kerneloption,'matrix')
    Kaux=kerneloption.matrix;
    kernelparam=1;
    xapp=[];
else
    kernelparam=0;
end;
for i=1:nbclass-1
    for j=i+1:nbclass
        indi=find(y==i);
        indj=find(y==j);
        yone=[ones(length(indi),1);-ones(length(indj),1)];
        if ~isempty(x)
            xapp=[x(indi,:); x(indj,:)];
        end;    
        
        if kernelparam==1;
            kerneloption.matrix=Kaux([indi indj],[indi indj]);    
        end;
        if tag==1
            [xsupaux,waux,baux,posaux]=svmclass(xapp,yone,c,epsilon,kernel,kerneloption,verbose);
        else
            Sigma = sigma*ones(1,size(x,2));
            [SigmaOutaux,xsupaux,waux,baux,posaux,nflops,crit,SigmaH] = svmfit(xapp,yone,Sigma,c,method,pow,verbose);
            SigmaOut=[SigmaOut;SigmaOutaux];
        end
%        [n1,n2]=size(xsupaux);
        [n1,n2]=size(waux);
        nbsv(k)=n1;
        classifier(k,:)=[i j];
        xsup=[xsup;xsupaux];
        w=[w;waux];
        b=[b;baux];
        aux=[indi;indj];
        pos=[pos;aux(posaux)];
        
        k=k+1;
    end;
end;

