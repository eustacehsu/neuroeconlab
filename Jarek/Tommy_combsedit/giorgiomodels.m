%%% Type of Events
%     'decision_1'
%     'decision_123'
%     'decision_2'
%     'decision_3'
%     'evaluation_1'
%     'evaluation_123'
%     'evaluation_2'
%     'evaluation_3'
%     'fixation'
%     'outcome_123'
%     'outcome_3'
%%% Where is outco0me 1 and Outcome 2???


[Subject Period Stage Condition Event Onset Duration ...
    Up	Down Bet1 Bet2 Bet3 Winout1 Winout2 Winout3] = ...
    textread('A:\DCJ\SPM\data\log\dcj_dynamic_for_matlab.txt', ...
    '%d %d %d %d %s %d %d %d %d %d %d %d %d %d %d', ...
    'headerlines', 1);

statdir = 'C:\fMRI data\DCJ\SPM\stat\Model_0001\FFX';

% Set time in seconds
Onset = Onset / 1000;
Duration = Duration / 1000;

nSubj = numel(unique(Subject));

% RUN 1 --> trial 1-24
% RUN 2 --> trial 25-48
% RUN 3 --> trial 49-72
Runs = {1:24 25:48 49:72};
%% Evaluation and Decision based models
% evaluation è solo nel trial 1  e 123negli altri trial li chiamamo
% outcome1 e outcome 2
%% Model 1:6 are only based on the conditions onset and not on economic parameter
%% Model 1:
% BOLD = (eval1+eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_1+outcome_2+outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123  
% BOLD = (eval1+eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%still 2 fix
for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        
        n = 1; % first regressor 
        names{n} = 'evaluation;1'; % name of the regressors
        i = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
        durations{n} = 0.5; %the duration of the event, this vector is long as the amount of non-zero elements in Onset

        % both up and down are associated with the same event, same trigger
        % and duration. (i defines it)
        
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i);
        pmod(n).poly{1} = 1; 
        pmod(n).name{2} = 'Down';
        pmod(n).param{2} = Down(i);
        pmod(n).poly{2} = 1;
        
        n = n + 1;
        names{n} = 'evaluation;2';
        i = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i);
        durations{n} = 0.5;

        pmod(n).name{1} = 'Up';
        pmod(n).param{1} = Up(i);
        pmod(n).poly{1} = 1;
        pmod(n).name{2} = 'Down';
        pmod(n).param{2} = Down(i);
        pmod(n).poly{2} = 1;

        n = n + 1;
        names{n} = 'evaluation;3';
        i = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i);
        durations{n} = 0.5;

        pmod(n).name{1} = 'Up';
        pmod(n).param{1} = Up(i);
        pmod(n).poly{1} = 1;
        pmod(n).name{2} = 'Down';
        pmod(n).param{2} = Down(i);
        pmod(n).poly{2} = 1;

        n = n + 1;
        names{n} = 'evaluation;123'; %guess this means
        i = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i);
        durations{n} = 0.5;

        pmod(n).name{1} = 'Up';
        pmod(n).param{1} = Up(i);
        pmod(n).poly{1} = 1;
        pmod(n).name{2} = 'Down';
        pmod(n).param{2} = Down(i);
        pmod(n).poly{2} = 1;

        n = n + 1;
        names{n} = 'Residual;1;1'; %% separates the resisdual of teh conditions from the baseline
        i = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i) + 0.5; % onsets after the evaluation 1 regressor is defined
        durations{n} = Duration(i) - 0.5; % duration is all the remaining time except those used for the evaluation regressor

        n = n + 1;
        names{n} = 'Residual;1;2';
        i = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i) + 0.5;
        durations{n} = Duration(i) - 0.5;

        n = n + 1;
        names{n} = 'Residual;1;3';
        i = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i) + 0.5;
        durations{n} = Duration(i) - 0.5;

        n = n + 1;
        names{n} = 'Residual;2;1';
        i = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i) + 0.5;
        durations{n} = Duration(i) - 0.5;

        outdir = fullfile(statdir, sprintf('Subject%02d', Subj), 'LOG');
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
end
%% Model 2:
% BOLD = eval1 +(eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_1+outcome_2+outcome_3+outcome_123)
% + Residual(1) + Residual(2+3) + Residual(123)  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%still 2 fix
%% Model 3:
% BOLD = eval1 +eval2+eval3+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_1+outcome_2+outcome_3+outcome_123)
% + Residual1 + Residual(2)+ Residual(3) + Residual(123)  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%still 2 fix
%% Models 4:6 are going to be like model 1:3 but focusing on the decision period and not the evaluation period
% Residual refers to the non-considered time of the decision process
%% Model 4:
% BOLD = (decision1+decision12+decision3)+decision_123+(eval_1+eval_2+eval_3+eval_123) + (outcome_1+outcome_2+outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%still 2 fix
%% Model 5:
% BOLD = decision1 +(decision12+decision3)+decisionuation_123+(eval_1+eval_2+eval_3+eval_123) + (outcome_1+outcome_2+outcome_3+outcome_123)
% + Residual(1) + Residual(2+3) + Residual(123)  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%still 2 fix
%% Model 6:
% BOLD = decision1 +decision2+decision3+decisionuation_123+(eval_1+eval_2+eval_3+eval_123) + (outcome_1+outcome_2+outcome_3+outcome_123)
% + Residual1 + Residual(2)+ Residual(3) + Residual(123)  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%still 2 fix
%% Models 7:9 are going to be like model 1:3 but focusing on the outcome period and not the evaluation period
% Residual refers to the non-considered time of the decision process
%% Model 7:
% BOLD =(outcome_1+outcome_2+outcome_3)+outcome_123+(eval_1+eval_123) + (decision1+decision12+decision3+decision_123)
%   + Residual;1;1+2+3 + Residual123  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%still 2 fix
%% Model 8:
% BOLD = outcome_1+ (outcome_2+outcome_3)+outcome_123+(eval_1+eval_123) + (decision1+decision12+decision3+decision_123)
%   + Residual;1 +Residual;2+3 + Residual123  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%still 2 fix
%% Model 9:
% BOLD =outcome_1+outcome_2+outcome_3+outcome_123+(eval_1+eval_123) + (decision1+decision12+decision3+decision_123)
%   + Residual;1+ Residual;2+Residual;3 + Residual123  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%still 2 fix
%% Models 10-36 are the economic parameter version of 1:6
% 10-18 considers the (GAIN-LOSS) variable
% 19-27 considers the Gain and Loss Variable
% 28-36 considers the Investment*(GAIN-LOSS) Variable
%% Model 37-38-39  evaluation\outcome\decision
% BOLD = (outcome_1+outcome_123) +outcome_2+outcome_3+(eval_1+eval_2+eval_3+eval_123) + (decision1+decision12+decision3+decision_123)
%   + Residual;1 +Residual;2+3 + Residual123
%% Model 38 drift parameter
% DeltaInvestment 

%%modelli condizionali