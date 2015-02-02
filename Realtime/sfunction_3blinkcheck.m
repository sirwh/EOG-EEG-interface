%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: The s-function to detect triple blink in real time
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: P300_directions.slx
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2015/02/02 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sys,x0,str,ts] = sfunction_3blinkcheck(t,x,u,flag,windowlength,Vcl,Vop,Amin)
DelayBegin=20;

if flag==0
    
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 2;
    sizes.NumOutputs     = 1;
    sizes.NumInputs      = -1;  % dynamically sized
    sizes.DirFeedthrough = 0;   % has direct feedthrough
    sizes.NumSampleTimes = 1;

    sys = simsizes(sizes);
    str = [];
    x0  = [0 0];   % [state time_skip time_wait2decide]
    ts  = [-1 0];   % inherited sample time
 
elseif flag==2
    
    if t < DelayBegin,return,end
    if x(2) ~= 0
        sys = [x(1) x(2)-1];
    else        
        channel_used = 1;
        data=reshape(u(3:length(u)), u(1), u(2)); 
        data=data(channel_used, u(2)-windowlength+1:u(2)); 
        
        blkc = EOG_getpeak(data, 32, Vcl,Vop,Amin, 0.01, 0.5, 10, -10);
        if length(blkc)>=12
           sys = [3 windowlength];
       else
           sys = [0 0];
       end
    end
   
elseif flag==3
    sys = x(1);
end
    
    
