%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: The threshold algorithm for eye movement detection.
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: analyzetrain.m, sfunction_2blinkcheck.m, sfunction_3blinkcheck.m, sfunction_frowncheck.m, sfunction_winkcheck.m
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2014/12/26 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function blkc = EOG_getpeak(data, fs, Vcl, Vop, Amin, durmin, durmax, ext_head, ext_tail)
% data -- input EOG data
% fs -- sample rate (Hz)
% Vcl -- threshold for positive peak
% Vop -- threshold for negative peak
% Amin -- threshold for amplitude
% durmin -- threshold for min duration
% durmin -- threshold for max duration
% ext_head -- extension forward (properly equal to 10, in order to get correct amplitude)
% ext_tail -- extension backward (can be -10, or be 0 to avoid too long result) 

ndata = diff(data);
len=length(ndata);
flag=zeros(1,len);

if ext_tail==0
    ext_tail = Vop; Vop=0;
end
if ext_head==0
    ext_head = Vcl; Vcl=0;
end

for i=2:len-1 % Step 1: roughly find and mark all the postive peaks ([1,2]) and negative peaks ([3,4])
    if ndata(i)>=ext_head && ndata(i-1)<ext_head && ndata(i+1)>=ext_head
        flag(i)=1;
    elseif ndata(i)>=ext_head && ndata(i+1)<ext_head && ndata(i-1)>=ext_head
        flag(i)=2;
    elseif ndata(i)<=ext_tail && ndata(i-1)>ext_tail && ndata(i+1)<=ext_tail
        flag(i)=3;
    elseif ndata(i)<=ext_tail && ndata(i+1)>ext_tail && ndata(i-1)<=ext_tail
        flag(i)=4;
    end
end
blka = find(flag);

if Vop~=0 || Vcl~=0
    for i=2:length(blka) % Step 2: compare peak velocities with thresholds (Vcl, Vop), only retain the peaks larger than threshold.
        if blka(i-1) ~= 0;
            if Vcl~=0 && flag(blka(i-1))==1 && flag(blka(i))==2 && max(ndata(blka(i-1):blka(i)))<Vcl
                blka(i-1:i)=0; 
            elseif Vop~=0 && flag(blka(i-1))==3 && flag(blka(i))==4 && min(ndata(blka(i-1):blka(i)))>Vop
                blka(i-1:i)=0; 
            end
        end
    end
end
blka=blka(find(blka));

blkb = flag(blka);
blkc = [];

len2=length(blka);
j=1;
for i=1:len2-3 % Step 3: find the consecutive positive peak and negative peak
    if blkb(i)==1 && blkb(i+1)==2 && blkb(i+2)==3 && blkb(i+3)==4
        blkc(j:j+3)=blka(i:i+3); 
        j=j+4;
    end
end

len4=length(blkc);
for i=1:4:len4 % Step 4: compare amplitude with threshold (Amin), and compare duration with threshold (durmin & durmax)
    amp = max(data(blkc(i):blkc(i+3)))-data(blkc(i));
    if amp < Amin
        blkc(i:i+3)=0;
    end
    
    if blkc(i+3)-blkc(i)<durmin*fs || blkc(i+3)-blkc(i)>durmax*fs
        blkc(i:i+3)=0;
    end
end

blkc=blkc(find(blkc));

end

