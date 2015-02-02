function [xsup,alpha,multiplier,pos,Ksup]=svmoneclass(x,kernel,kerneloption,nu,verbose)

% USAGE
%
% [xsup,alpha,rho,pos]=svmoneclass(x,kernel,kerneloption,nu,verbose)
%
%


[n1,n2]=size(x);

K=normalizekernel(x,kernel,kerneloption);
%K=svmkernel(x,kernel,kerneloption);
c=zeros(n1,1);
A=ones(n1,1);
b=1;
C= 1/nu/n1;
lambda=1e-7;
[alpha, multiplier, pos]=monqp(K,c,A,b,C,lambda,verbose);
xsup=x(pos,:);
Ksup=K(pos,pos);