%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: The s-function to detect gaze (left/right) in real time
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: P300_directions.slx
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2015/02/02 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sys,x0,str,ts] = sfunction_gazecheck(t,x,u,flag,windowlength,THL,THR)

DelayBegin=20;

if flag==0
    
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 2;
    sizes.NumOutputs     = 1;  % dynamically sized
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
        
        re = data(1,:)-data(2,:);
        blkgl=EOG_getgaze(re,32, THL(1),THL(2),THL(3),0.05,0.5);
        dis = zeros(1,length(blkgl)/2);
        for i=1:2:length(blkgl)
            dis((i+1)/2) = corr(data(1, blkgl(i):blkgl(i+1))', data(2, blkgl(i):blkgl(i+1))');
            if dis((i+1)/2)>-0.8
                blkgl(i:i+1)=0;
            end
        end
        blkgl=blkgl(find(blkgl));
        
        blkgr=EOG_getgaze(-re,32,THR(1),THR(2),THR(3),0.05,0.5);
        dis = zeros(1,length(blkgr)/2);
        for i=1:2:length(blkgr)
            dis((i+1)/2) = corr(data(1, blkgr(i):blkgr(i+1))', data(2, blkgr(i):blkgr(i+1))');
            if dis((i+1)/2)>-0.8
                blkgr(i:i+1)=0;
            end
        end
        blkgr=blkgr(find(blkgr));
                
        if ~isempty(blkgl)
            sys = [11 windowlength];
        elseif ~isempty(blkgr)
            sys = [12 windowlength];
        else
            sys = [0 0];
        end
           
    end
   
elseif flag==3
    sys = x(1);
end
    
    
