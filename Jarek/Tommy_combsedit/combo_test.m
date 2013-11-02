clear all

[Subject Period Stage Condition Event Onset Duration ...
    Up	Down Bet1 Bet2 Bet3 Winout1 Winout2 Winout3] = ...
    textread('A:\DCJ\SPM\data\log\dcj_dynamic_for_matlab.txt', ...
    '%d %d %d %d %s %d %d %d %d %d %d %d %d %d %d', ...
    'headerlines', 1);

statdir = 'A:\DCJ\SPM\stat\tom\test01\FFX';
mkdir(statdir)

% Set time in seconds
Onset = Onset / 1000;
Duration = Duration / 1000;

nSubj = numel(unique(Subject));

% RUN 1 --> trial 1-24
% RUN 2 --> trial 25-48
% RUN 3 --> trial 49-72
Runs = {1:24 25:48 49:72};
%% model1 
 %BOLD = (eval1+eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (eval2+eval3+outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123  
dur=0.5;
for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        
        n = 1; % first regressor 
        names{n} = 'evaluation;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = (i_1 + i_2 + i_3 + i_123)>0 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = dur;
       

        % both up and down are associated with the same event, same trigger
        % and duration. (i defines it)
        
        
        n = n + 1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur;
        
        n = n + 1;
        
         names{n} = 'decision;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'decision_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = (i_1 + i_2 + i_3 + i_123)>0 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = dur;
        %% we miss the outcomes here
        
        outdir = fullfile(statdir, sprintf('Subject%02d', Subj), 'LOG');
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
end
%%

datadir = 'A:\DCJ\SPM\data';
% statdir = 'A:\DCJ\SPM\stat\Model_test\FFX';

Subj = 1;%[1:21];

% Load template
%--------------------------------------------------------------------------
load('template_stat_FFX');

% Make jobs
%--------------------------------------------------------------------------
for cSubj = Subj
    dSPM  = fullfile(statdir, sprintf('Subject%02d', cSubj), 'SPM');
    dLog  = fullfile(statdir, sprintf('Subject%02d', cSubj), 'LOG');
    dRun1 = fullfile(datadir, sprintf('Subject%02d', cSubj), 'Functional', 'Run1');
    dRun2 = fullfile(datadir, sprintf('Subject%02d', cSubj), 'Functional', 'Run2');
    dRun3 = fullfile(datadir, sprintf('Subject%02d', cSubj), 'Functional', 'Run3');

    % Create SPM directory if it doesn't exist
    if ~exist(dSPM, 'dir')
        mkdir(dSPM);
    end

    % Read .img files
    fRun1 = spm_select('FPList', dRun1, '^swaf.*\.img$');
    fRun2 = spm_select('FPList', dRun2, '^swaf.*\.img$');
    fRun3 = spm_select('FPList', dRun3, '^swaf.*\.img$');

    % Read realigment parameters files
    fRP1 = spm_select('FPList', dRun1, '^rp_.*\.txt$');
    fRP2 = spm_select('FPList', dRun2, '^rp_.*\.txt$');
    fRP3 = spm_select('FPList', dRun3, '^rp_.*\.txt$');
    
    matlabbatch{1}.spm.stats.fmri_spec.dir{1} = dSPM;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(strcat(fRun1, ',1'));
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi{1} = fullfile(dLog, 'logRun1.mat');
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg{1} = fRP1;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = cellstr(strcat(fRun2, ',1'));
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi{1} = fullfile(dLog, 'logRun2.mat');
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg{1} = fRP2;

    matlabbatch{1}.spm.stats.fmri_spec.sess(3).scans = cellstr(strcat(fRun3, ',1'));
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).multi{1} = fullfile(dLog, 'logRun3.mat');
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).multi_reg{1} = fRP3;
    
    matlabbatch=cont_generator(name_array,convec)

    % Save batch
    %--------------------------------------------------------------------------
    fbs = fullfile(statdir, sprintf('Subject%02d', cSubj), 'batch_FFX');
    save(fbs', 'matlabbatch');

    % Launch batch
    %--------------------------------------------------------------------------
    spm('defaults', 'FMRI');
    spm_jobman('run', matlabbatch);
end

