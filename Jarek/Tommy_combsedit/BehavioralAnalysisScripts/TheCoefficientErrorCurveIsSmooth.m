%%This plots the error or the model fit as a function of alpha. The
%%punchline is that for some subjects this model is smooth.

[Subject Period Stage Condition Event Onset Duration ...
    Up	Down Bet1 Bet2 Bet3 Winout1 Winout2 Winout3] = ...
    textread('/Users/Dalton/Documents/MATLAB/neuroeconlab/Jarek/Tommy_combsedit/BehavioralAnalysisScripts/dcj_dynamic_for_matlab.txt', ...
    '%d %d %d %d %s %d %d %d %d %d %d %d %d %d %d', ...
    'headerlines', 1);

for subj = 1:21

Event1Select = (strcmpi(Event,'evaluation_1') & Subject==subj);

Up1 = Up(Event1Select);
Bet = Bet1(Event1Select);
Down1 = Down(Event1Select);

for i = 1:100
    j = i/100;
error(i) = OptimalProspectGainOnly(Up1,Down1,Bet,j);


end

subplot(4,4,subj);
xlabel('Alpha');
ylabel('Error');
plot(error);

end