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

% Model 1:
% BOLD = evaluation_1 UP + evaluation_1 DOWN + evaluation_2 UP +
%        evaluation_2 DOWN + evaluation_3 UP + evaluation_3 DOWN +
%        evaluation_123 UP + evaluation_123 DOWN +
%        Residual;1;1 +  Residual;1;2 + Residual;1;3 + Residual;2;1

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
