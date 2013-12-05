%% Load bwhavioral data for all subjects
[Subject Period Stage Condition Event Onset Duration ...
    Up	Down Bet1 Bet2 Bet3 Winout1 Winout2 Winout3] = ...
    textread('/Users/Dalton/Documents/MATLAB/neuroeconlab/Jarek/Tommy_combsedit/BehavioralAnalysisScripts/dcj_dynamic_for_matlab.txt', ...
    '%d %d %d %d %s %d %d %d %d %d %d %d %d %d %d', ...
    'headerlines', 1);


for subj= 1;
Event1Select = (strcmpi(Event,'evaluation_1') & Subject==subj);

Up1 = Up(Event1Select);
Bet = Bet1(Event1Select);
Down1 = Down(Event1Select);


handle = @(alpha)OptimalProspectGainandLoss(Up1,Down1,Bet,alpha(1),alpha(2));

x0 = [.38; 1];
lb = [0 ; 0];
ub = [1 ; 100];

[x,fval] = fmincon(handle,x0,[],[],[],[],lb,ub);


for i = 1:length(Up1)

bet = fminbnd(@(Obet)-(.5*(((Up(i)*Obet)/100).^x(1)) - .5*x(2)*((abs(Down(i)*Obet)/100)).^x(1)),0,100);

optimalBet(i) = bet;

end
error(:,subj) = abs(Bet-optimalBet');

end
