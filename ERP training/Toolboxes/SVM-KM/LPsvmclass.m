function    [xsup,w,b,pos]=LPsvmclass(xapp,yapp,C,lambda,kernel,kerneloption,verbose)

%  USAGE
%
%   [xsup,w,b,pos]=LPsvmclass(xapp,yapp,C,lambda,kernel,kerneloption,verbose)
%
%   Linear Programming SVM  (see Mangasarian 1998)
%
%   min C sum nu_j  + sum s_j 
%
%   st  y_i ( sum_j w_j y_j K(x_i,x_j) -b ) + nu_i >= 1
%       nu >=0
%       -s_j <= w_j <= s_j
%
%
%   
%   f(x)= sum_ w_j K(x,x_j) +b 
%
%  this function returns xsup, w and b
%


optimopt=optimset('MaxIter',10000,'Display','off', 'TolCon',1e-3,'TolFun',1e-5,'LargeScale','on');

Napp=size(xapp,1);

U=zeros(Napp+Napp+Napp+1,1); % w,s,nu et b  In the non linear case w has the same length as x
f=zeros(Napp+Napp+Napp+1,1);
f(Napp+1:2*Napp)=1;            %  penalizing s
f(2*Napp+1:2*Napp+Napp)=C;    %  penalizing nu

K=svmkernel(xapp,kernel,kerneloption);

% Classification constraint
A= -[K.*(yapp*yapp') zeros(Napp,Napp) eye(Napp) -yapp]; 
% s constraints
A=[A; eye(Napp,Napp) -eye(Napp,Napp) zeros(Napp,Napp) zeros(Napp,1)];  
A=[A; -eye(Napp,Napp) -eye(Napp,Napp) zeros(Napp,Napp) zeros(Napp,1)];  
b=[-ones(Napp,1); zeros(2*Napp,1)];
% upper bound constraints
lb=[-inf*ones(2*Napp,1);zeros(Napp,1);-inf];
tic
x=linprog(f,A,b,[],[],lb,[]);

w=x(1:Napp,1);
pos=find(abs(w) > 1e-10);
xsup=xapp(pos,:);
w=w(pos).*yapp(pos);
b=-x(end);   % The minus is is for compatibility with svmval function and in not 
             % in agreement with Mangasarian original paper   
