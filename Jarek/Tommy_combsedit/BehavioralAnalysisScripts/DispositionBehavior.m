%% Load bwhavioral data for all subjects
[Subject Period Stage Condition Event Onset Duration ...
    Up	Down Bet1 Bet2 Bet3 Winout1 Winout2 Winout3] = ...
    textread('/Users/Dalton/Documents/MATLAB/neuroeconlab/Jarek/Tommy_combsedit/BehavioralAnalysisScripts/dcj_dynamic_for_matlab.txt', ...
    '%d %d %d %d %s %d %d %d %d %d %d %d %d %d %d', ...
    'headerlines', 1);
%%
eventSelect = strcmpi(Event,'evaluation_1');

diff = Bet2 - Bet1;
offsetSubject = Subject + ((.25)*(Winout1));

green = (abs(Up)-min(Up)+1)/max(abs(Up));
red = (abs(Down)-min(abs(Down))+1)/max(abs(Down));
color = [red,green,zeros(length(Up),1)];
% scatter(offsetSubject(eventSelect), diff(eventSelect), Bet1(eventSelect)+1,color(eventSelect,:));

%%
eventSelect = strcmpi(Event,'evaluation_1');

diff = Bet3 - Bet2;
offsetSubject = Subject + ((.25)*(Winout2));

green = (abs(Up)-min(Up)+1)/max(abs(Up));
red = (abs(Down)-min(abs(Down))+1)/max(abs(Down));
color = [red,green,zeros(length(Up),1)];
% scatter(offsetSubject(eventSelect), diff(eventSelect), Bet1(eventSelect)+1,color(eventSelect,:));

%%
eventSelect = strcmpi(Event,'evaluation_1');

win1 = logical(Winout1);
Loose1 = not(logical(Winout1));

mungWin = (win1 & eventSelect);
mungLose =(Loose1 & eventSelect);

winDiff1 = Bet2(mungWin) - Bet1(mungWin);
loseDiff1=Bet2(mungLose) - Bet1(mungLose);
size = Bet1;
green = (abs(Up)-min(Up)+1)/max(abs(Up));
red = (abs(Down)-min(abs(Down))+1)/max(abs(Down));
color = [red,green,zeros(length(Up),1)];
% scatter(Subject(mungWin), winDiff1, Bet1(mungWin)+1,color(mungWin,:));
% scatter(Subject(mungLose), loseDiff1, (Bet1(mungLose)+1), color(mungLose,:));

%%

eventSelect = strcmpi(Event,'evaluation_1');

diff = Bet2(eventSelect) - Bet1(eventSelect);
color = [Winout1, abs(Winout1-1),zeros(length(Up),1)];

% scatter(Subject(eventSelect), diff, Bet1(eventSelect)+1, color(eventSelect,:));

%%

for i=1:16;
Event1Select = (strcmpi(Event,'evaluation_1') & Subject==i);
Event2Select = (strcmpi(Event,'evaluation_1') & Subject==i);

diff1 = Bet2 - Bet1;
diff2 = Bet3 - Bet2;
expval1= (Up + Down);
expval2= (Up + Down);
realVal1 = Bet1.*Up.*Winout1+Bet1.*Down.*not(Winout1);
realVal2 = Bet2.*Up.*Winout2+Bet2.*Down.*not(Winout2);

realVal1WithFictive = Bet1.*(Up-Down).*Winout1+Bet1.*(Down-Up).*not(Winout1);
realVal2WithFictive = Bet2.*(Up-Down).*Winout2+Bet2.*(Down-Up).*not(Winout2);

green1 = Winout1;
red1 = not(Winout1);
color1 = [red1,green1,zeros(length(Up),1)];

green2 = Winout2;
red2 = not(Winout2);
color2 = [red2,green2,zeros(length(Up),1)];
place=i-0;
subplot(4,4,place);
scatter((expval1(Event1Select)), diff1(Event1Select), (Bet1(Event1Select)+Bet2(Event1Select)+3)/3, color1(Event1Select,:),'s');
hold on
title(['Subject #',int2str(i)]);
% axis([-40 120 -100 100]);
xlabel('Expected Val');
ylabel('Change in Bet');
scatter((expval2(Event2Select)), diff2(Event2Select), (Bet2(Event2Select)+Bet3(Event2Select)+3)/3, color2(Event2Select,:),'d');

hold off
end
%%

for i=21:24;
Event1Select = (strcmpi(Event,'evaluation_1') & Subject==i);
Event2Select = (strcmpi(Event,'evaluation_1') & Subject==i);

diff1 = Bet2 - Bet1;
diff2 = Bet3 - Bet2;
risk= Up - Down;
averageBet1 = mean([Bet2,Bet1],2);
averageBet2 = mean([Bet2,Bet3],2);

green1 = Winout1;
red1 = not(Winout1);
color1 = [red1,green1,zeros(length(Up),1)];

green2 = Winout2;
red2 = not(Winout2);
color2 = [red2,green2,zeros(length(Up),1)];
place=i-20;
% subplot(2,2,place);
% scatter(risk(Event1Select), diff1(Event1Select),averageBet1(Event1Select)+3, color1(Event1Select,:),'s');
% hold on
% title(['Subject #',int2str(i)]);
% axis([110 260 -100 100]);
% xlabel('Riskiness');
% ylabel('Change in Bet');
% scatter(risk(Event2Select), diff2(Event2Select), averageBet2(Event2Select)+3, color2(Event2Select,:),'d');
% 
% hold off
end

%%
for q = 0:1
    if q==0
        side = 'larger';
    elseif q==1
        side = 'smaller';
    end
for i = 1:21
    
EventSelect = (strcmpi(Event,'evaluation_1')& Subject==i);
EventSelectW= (strcmpi(Event,'evaluation_1') & Subject==i & Winout1 == q);
EventSelectWW= (strcmpi(Event,'evaluation_1') & Subject==i & Winout2 ==q);


first = Bet1(EventSelect);
second = Bet2(EventSelectW);
third = Bet3(EventSelectWW);

groups = [ones(length(first),1);2*ones(length(second),1);2*ones(length(third),1)];

% figure,distributionPlot([first;second;third],'groups',groups);
% plotSpread(diff(EventSelect),'distributionIdx',groups);
% boxplot([first;second;third],groups);

[h,p] = kstest2(first,[second;third],[],side);
ps(i,(q+1)) = p;

end
end

scatter(ps(:,1),ps(:,2));

EventSelectF = (strcmpi(Event,'evaluation_1'));
EventSelectR = (strcmpi(Event,'evaluation_123'));

%%
for q = 0:1
    if q==0
        side = 'right';
    elseif q==1
        side = 'left';
    end
for i = 1:21
    
EventSelect = (strcmpi(Event,'evaluation_1')& Subject==i);
EventSelectW= (strcmpi(Event,'evaluation_1') & Subject==i & Winout1 == q);
EventSelectWW= (strcmpi(Event,'evaluation_1') & Subject==i & Winout2 ==q);


second = Bet2(EventSelectW)-Bet1(EventSelectW);
third = Bet3(EventSelectWW)-Bet2(EventSelectWW);

groups = [2*ones(length(second),1);2*ones(length(third),1)];

% figure,distributionPlot([first;second;third],'groups',groups);
% plotSpread(diff(EventSelect),'distributionIdx',groups);
% boxplot([first;second;third],groups);

[h,p] = ttest([Bet2(EventSelectW);Bet3(EventSelectWW)],[Bet1(EventSelectW);Bet2(EventSelectWW)],[],side);
ps(i,(q+1)) = p;

end
end

scatter(ps(:,1),ps(:,2));

EventSelectF = (strcmpi(Event,'evaluation_1'));
EventSelectR = (strcmpi(Event,'evaluation_123'));

%%
uniUp = unique(Up);
uniDown = unique(Down);
for sub = 1:21
for i = 1:length(uniUp)
    for j = 1:length(uniDown)
        
        EventSelectF = (strcmpi(Event,'evaluation_1') & Up == uniUp(i) & Down == uniDown(j) & Subject == sub);
        EventSelectR = (strcmpi(Event,'evaluation_123') & Up == uniUp(i) & Down == uniDown(j)& Subject == sub);
        
betsF(i,j,sub) = Bet1(EventSelectF);
betsR(i,j,sub) = Bet1(EventSelectR);
        
    end
end
end

plotF = reshape(betsF,[],1);
plotR = reshape(betsR,[],1);
diff = plotR-plotF; 

% scatter(plotF,plotR);
% figure,boxplot([plotF,plotR]);
% figure,distributionPlot(diff);
% figure,boxplot(diff);
% [h,p] = ttest2(plotF,plotR)
% [h,p] = ttest(diff)


