%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: To mark the detected eye movements upon the EOG and differentiated EOG.
%--------------------------------------------------------------------------------------------------------------------------------
% Used in: analyzetrain.m
%--------------------------------------------------------------------------------------------------------------------------------
% Update : 2014/12/26 by Jiaxin MA @Kyoto Univ.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawblinkline(data, result)

figure;
y=max(abs(data));
z=min(abs(data));
subplot(2,1,1); plot(data);
hold on
for i=1:4:length(result) % before differentiating
    if(mod(i,4)==2 || mod(i,4)==3)
        continue;
    end
    x1=result(i);
    x2=result(i+3);
    plot([x1,x1],[z,y],'r');
    plot([x2,x2],[z,y],'g');
end

ndata = diff(data);
y=max(abs(ndata));
subplot(2,1,2); plot(ndata);
hold on
for i=1:4:length(result) % after differentiating
    if(mod(i,4)==2 || mod(i,4)==3)
        continue;
    end
    x1=result(i);
    x2=result(i+3);
    plot([x1,x1],[-y,y],'r');
    plot([x2,x2],[-y,y],'g');
end

hold off

end

