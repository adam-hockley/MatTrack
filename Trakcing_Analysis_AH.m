%% Analyse movement data from Tracking_AH 
% Calculates X and Y coordinates or marker centroids

movethresh = 2; % here set the threshold for movement (tested and 2 works well)

%% VideoTrackAnalysis
close all
clear all
load('C:\Users\ANL\Documents\CristianVids\etiquetados\14 oddball3.mat')

find(isempty(gTruth.LabelData.headstage))
% temploc = [0 0 0 0];
for i = 1:length(gTruth.LabelData.headstage)
    temploc = gTruth.LabelData.headstage{i};
    if length(temploc) > 0
        loc(i,:) = temploc(end,:);
    else
        loc(i,1:4) = nan;
    end

end

%% interpolate gaps in tracking (to do)
X = loc(:,1);
Y = loc(:,2);

%% Analyse for movement
Xchange = movmean(abs(diff(X)),5);
Ychange = smooth(abs(diff(Y)),5);

if length(Xchange) < length(X)
    Xchange(end+1:length(X)) = nan;
    Ychange(end+1:length(Y)) = nan;
end

move(1) = 0;
for i = 2:length(gTruth.LabelData.headstage)
    if isnan(X(i)) || isnan(Y(i))
        move(i) = 1;
    elseif Xchange(i) > movethresh || Ychange(i) > movethresh % here setting the threshold for movement
        move(i) = 1;
    else
        move(i) = 0;
    end
end


%% plotting
plot(loc(:,1)/480) % normalising to video frame sizes 
hold on
plot(loc(:,2)/640)

% Movement bars 
sigparts = find(move==1);
B = diff(sigparts);
gaps = find(B>1);
for i = 1:length(gaps)
    sigparts = [sigparts(1:gaps(i)+i-1), nan, sigparts(gaps(i)+i:end)];
end
plot(sigparts, ones(1,length(sigparts))*1,'r','linewidth', 2)

% NO movement bars
sigparts = find(move==0);
B = diff(sigparts);
gaps = find(B>1);
for i = 1:length(gaps)
    sigparts = [sigparts(1:gaps(i)+i-1), nan, sigparts(gaps(i)+i:end)];
end
plot(sigparts, ones(1,length(sigparts))*1,'k','linewidth', 2)

% plot((move+1)/2,'k')
legend({'X','Y','Move','NoMove'})
beautify
print(gcf,'-vector','-depsc','C:\Users\ANL\Documents\CristianVids\etiquetados\14 oddball3.eps')
print(gcf,'-dpng','-r150','C:\Users\ANL\Documents\CristianVids\etiquetados\14 oddball3.png')
% add horizontal bar to signify movement

save('C:\Users\ANL\Documents\CristianVids\etiquetados\14 oddball3_move.mat','move') % save binary movement data

