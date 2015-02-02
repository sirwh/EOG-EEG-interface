%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: The s-function to detect wink (left/right) in real time
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: P300_directions.slx
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2015/02/02 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sys,x0,str,ts] = sfunction_winkcheck(t,x,u,flag,windowlength,THL,THR)
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
        channel_used = [3 4];
        data=reshape(u(3:length(u)), u(1), u(2));
        data=data(channel_used, u(2)-windowlength+1:u(2));
       
        blkd = EOG_getpeak(data(1,:), 32, THL(1),THL(2),THL(3), 0.2, 0.5, 10, 0);
        dis = zeros(1,length(blkd)/4);
        for i=1:4:length(blkd)
            dis((i+3)/4) = corr(data(1, blkd(i):blkd(i+3))', data(2, blkd(i):blkd(i+3))');
            if dis((i+3)/4)<-0.8
                blkd(i:i+3)=0;
            end
        end
        blkd=blkd(find(blkd));
        
        blke = EOG_getpeak(data(2,:), 32, THR(1),THR(2),THR(3), 0.2, 0.5, 10, 0);
        dis = zeros(1,length(blke)/4);
        for i=1:4:length(blke)
            dis((i+3)/4) = corr(data(1, blke(i):blke(i+3))', data(2, blke(i):blke(i+3))');
            if dis((i+3)/4)<-0.8
                blke(i:i+3)=0;
            end
        end
        blke=blke(find(blke));
           
        if ~isempty(blkd) && isempty(blke)
            sys = [31 windowlength];
        elseif ~isempty(blke) && isempty(blkd)
            sys = [32 windowlength];
        else
            sys = [0 0];
       end
    end
   
elseif flag==3
    sys = x(1);
end
    
    
