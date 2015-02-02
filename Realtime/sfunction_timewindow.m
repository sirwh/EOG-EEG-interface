%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: This s-function gives an output of reshaped time window
% The output is like [(channel) (length) (data reshaped to 1*n)] which is a vector of 1*(n+2) 
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: P300_directions.slx
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2015/02/02 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sys,x0,str,ts] = sfunction_timewindow(t,x,u,flag,channel,length);

global data;

if flag==0
    
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = channel*length+2;  %
    sizes.NumInputs      = -1;  % dynamically sized
    sizes.DirFeedthrough = 1;   % has direct feedthrough
    sizes.NumSampleTimes = 1;

    sys = simsizes(sizes);
    str = [];
    x0  = [];
    ts  = [-1 0];   % inherited sample time

    data=zeros(channel,length);

elseif flag==3
    if t<10
        return;
    else
       data(:,1)=[];
       data = [data u.*ones(channel,1)];  
       temp = reshape(data, 1, []);
       sys = [channel length temp];
    end
end
    
    
