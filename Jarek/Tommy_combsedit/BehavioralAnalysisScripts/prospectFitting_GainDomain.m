%% Load bwhavioral data for all subjects
[Subject Period Stage Condition Event Onset Duration ...
    Up	Down Bet1 Bet2 Bet3 Winout1 Winout2 Winout3] = ...
    textread('/Users/Dalton/Documents/MATLAB/neuroeconlab/Jarek/Tommy_combsedit/BehavioralAnalysisScripts/dcj_dynamic_for_matlab.txt', ...
    '%d %d %d %d %s %d %d %d %d %d %d %d %d %d %d', ...
    'headerlines', 1);


for subj= 1:21;
Event1Select = (strcmpi(Event,'evaluation_1') & Subject==subj);

Up1 = Up(Event1Select);
Bet = Bet1(Event1Select);
Down1 = Down(Event1Select);

% 
% upside = (Up(Event1Select).*Bet1(Event1Select))/100 + 100;
% 
% downside=(Down(Event1Select).*Bet1(Event1Select))/100 + 100;

handle = @(alpha)ProspectOptimizer(Up1,Down1,Bet,alpha);


% utilityFunc = @(alpha)-sum(.5*((upside).^alpha) + .5*((downside).^alpha));
% or
% (Up.*Bet1).^alpha1 + (Down.*Bet1*lamda)^alpha1);

% scatter3((Up(Event1Select)),(Down(Event1Select)),Bet1(Event1Select));

[alpha(subj),fit(subj)] = fminbnd(handle,0,1);

fit = fit/36;

% utilityFunc(x)

% u= (.5*((upside).^x) + .5*((downside).^x));

for i = 1:length(Up1)

bet = fminbnd(@(Obet)-(.5*(((Up1(i)*Obet)/100 + 100).^alpha(subj)) + .5*((Down1(i)*Obet)/100 + 100).^alpha(subj)),0,100);

optimalBet(i) = bet;

end
error(:,subj) = abs(Bet-optimalBet');
end
