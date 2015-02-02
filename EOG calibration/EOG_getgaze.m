%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: The threshold algorithm for gaze detection. For gaze,
% because the interval between postive peak and negative peak is too long,
% we only find the positive peak.
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: analyzetrain.m
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2014/12/26 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function blkc = EOG_getgaze(data, fs, Vcl, Amin, Amax, durmin, durmax)

ndata = diff(data); 
thdiff=10; 

len=length(ndata); % Step 0: remove all the small peaks (differentiated value < 10)
for i=1:len
    if abs(ndata(i))<thdiff;
        ndata(i)=0;
    end
end
flag=zeros(1,len);


for i=2:len-1 % Step 1: roughly find and mark all the postive peaks ([1,-1])
    if ndata(i)>0 && ndata(i-1)<=0 && ndata(i+1)>0
        flag(i)=1;
    elseif ndata(i)>0 && ndata(i+1)<=0 && ndata(i-1)>0
        flag(i)=-1;
    end
end
blka = find(flag);

for i=2:length(blka) % Step 2: compare peak velocities with threshold (Vcl), only retain the peaks larger than threshold.
    if blka(i-1) ~= 0;
        if flag(blka(i-1))==1 && flag(blka(i))==-1 && max(ndata(blka(i-1):blka(i)))<Vcl;
            blka(i-1:i)=0;
        end
    end
end
blka=blka(find(blka));

blkb = flag(blka);
blkc = [];

len2=length(blka);
j=1;
for i=1:len2-1 % Step 3: find the consecutive positive peak and negative peak
    if blkb(i)==1 && blkb(i+1)==-1
        blkc(j:j+1)=blka(i:i+1);
        j=j+2;
    end
end


len4=length(blkc);
for i=1:2:len4  % Step 4: compare amplitude with threshold (Amin & Amax), and compare duration with threshold (durmin & durmax)
   % amp = sum(ndata(blkc(i):blkc(i+1)));
    amp = max(data(blkc(i):blkc(i+1)))-data(blkc(i));
    if amp<Amin || amp>Amax 
        blkc(i:i+1)=0;
    end
    
    dur = blkc(i+1)-blkc(i);
    if dur<durmin*fs || dur>durmax*fs
        blkc(i:i+1)=0;
    end
    
end
blkc=blkc(find(blkc));


end

