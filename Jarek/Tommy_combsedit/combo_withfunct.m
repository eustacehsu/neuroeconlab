%% combo with functions to increase readability
clear all
%% Notes
% Something about the different statdir between FFX and RFX. Probably we
% should specify only one statdir and then change it as statdir\FFX in ffx
% job maker or stadir\RFX in rfx jobmaker.
% CHeck whether
% the contrasts work and how the parameters come into consideration in the
% contrasts. There is a difference between Regressors tagged (in duration specificatioN) as TARGET and
% regressors tagged as CONTROL . TARGED have an associated residual and its
% duration can by manipulated.
%% Load data Necessary to retrieve conditions indexes
[Subject Period Stage Condition Event Onset Duration ...
    Up	Down Bet1 Bet2 Bet3 Winout1 Winout2 Winout3] = ...
    textread('A:\DCJ\SPM\data\log\dcj_dynamic_for_matlab.txt', ...
    '%d %d %d %d %s %d %d %d %d %d %d %d %d %d %d', ...
    'headerlines', 1);
%%
% Set time in seconds
Onset = Onset / 1000;
Duration = Duration / 1000;
nSubj = numel(unique(Subject));
% RUN 1 --> trial 1-24
% RUN 2 --> trial 25-48
% RUN 3 --> trial 49-72
Runs = {1:24 25:48 49:72};
datadir = 'A:\DCJ\SPM\data';
%% Non-Parametric (a-la Giorgio) models for the Evaluation Phase
%% model1
%BOLD = (eval1+eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\',modname]; 
mkdir(statdir)
dur_target=0.5;
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% (eval1+eval12+eval3)
        n = n+1 ;
        names{n} = 'evaluation;1+2+3';
        i_1 = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;      
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
%% (decision_1+decision_2+decision_3+decision_123)
        n = n+1;
        names{n} = 'decision;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'decision_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% (outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'outcome;3+123';
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
        j = 1;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur
%% residual
        j = 2;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur

%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
end
%% name_array and convec definition
convec=[+1, -1];
name_array=convec2name_array(convec,names); %should creates the names of the contrast from the convec vector
%% care whether this things actualyl works
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec);
%rfx jobs
rfx_jobmaker(name_array,statdir);


%% Model 2:
% BOLD = eval1 +(eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual(1) + Residual(2+3) + Residual(123)  
modname='model_02';
statdir = ['A:\DCJ\SPM\stat\tom\',modname]; 
mkdir(statdir)
dur_target=0.5;
Duration(i(:,n))=Duration(i(:,n))
for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% eval1
        n = n+1;
        names{n} = 'evaluation;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
        durations{n} = dur_target; %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
%% (eval12+eval3)
        n = n+1;
        names{n} = 'evaluation;2+3';
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
%% (decision_1+decision_2+decision_3+decision_123)
        n = n+1;
        names{n} = 'decision;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'decision_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% (outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'outcome;3+123';
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
        j = 1;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur
%% residual
        j = 2;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur

%% residual
        j = 3;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur        
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
end
%% name_array and convec definition
convec=[1,+1,-1;1,-1,+1];
name_array=convec2name_array(convec,names); %should creates the names of the contrast from the convec vector
%% care whether this things actualyl works
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec);
%rfx jobs
rfx_jobmaker(name_array,statdir);

%% Model 3:
% BOLD = eval1 +eval2+eval3+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual1 + Residual(2)+ Residual(3) + Residual(123) 
modname='model_03';
statdir = ['A:\DCJ\SPM\stat\tom\',modname]; 
mkdir(statdir)
dur_target=0.5;
Duration(i(:,n))=Duration(i(:,n))
for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% eval1
        n = n+1;
        names{n} = 'evaluation;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
        durations{n} = dur_target; %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
%% eval2
        n = n+1;
        names{n} = 'evaluation;2';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
%% eval3
        n = n+1;
        names{n} = 'evaluation;3';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
%% (decision_1+decision_2+decision_3+decision_123)
        n = n+1;
        names{n} = 'decision;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'decision_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% (outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'outcome;3+123';
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
        j = 1;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur
%% residual
        j = 2;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur

%% residual
        j = 3;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur
%% residual
        j = 4;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur               
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
end
%% name_array and convec definition
convec=[1,1,1,-1;1,-1,-1,+1];
name_array=convec2name_array(convec,names); %should creates the names of the contrast from the convec vector
%% care whether this things actualyl works
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec);
%rfx jobs
rfx_jobmaker(name_array,statdir);

%% Evaluation Phase Parametric MOdels (a la Giorgio)
 %% (GAIN-LOSS) variable
%% model1(GAIN-LOSS) variable
%BOLD = (eval1+eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123 + (GAIN-LOSS)(1+2+3) + (GAIN-LOSS)(123)
modname='model_01_(GAIN-LOSS) variable';
statdir = ['A:\DCJ\SPM\stat\tom\',modname]; 
mkdir(statdir)
dur_target=0.5;
Duration(i(:,n))=Duration(i(:,n))
for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% (eval1+eval12+eval3)
        n = n+1 ;
        names{n} = 'evaluation;1+2+3';
        i_1 = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
         % (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1; 
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
         % (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1; 
%% (decision_1+decision_2+decision_3+decision_123)
        n = n+1;
        names{n} = 'decision;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'decision_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% (outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'outcome;3+123';
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
        j = 1;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur
%% residual
        j = 2;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur

%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
end
%% name_array and convec definition
convec=[+1, -1];
name_array=convec2name_array(convec,names); %should creates the names of the contrast from the convec vector
%% care whether this things actualyl works
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec);
%rfx jobs
rfx_jobmaker(name_array,statdir);


%% Model 2 (GAIN-LOSS) variable:
% BOLD = eval1 +(eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual(1) + Residual(2+3) + Residual(123)
%+ (GAIN-LOSS)(1) + (GAIN-LOSS)(2+3) + (GAIN-LOSS)(123)
modname='model_02_(GAIN-LOSS)';
statdir = ['A:\DCJ\SPM\stat\tom\',modname]; 
mkdir(statdir)
dur_target=0.5;
Duration(i(:,n))=Duration(i(:,n))
for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% eval1
        n = n+1;
        names{n} = 'evaluation;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
        durations{n} = dur_target; %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
         % (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1; 
%% (eval12+eval3)
        n = n+1;
        names{n} = 'evaluation;2+3';
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
         %(GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1; 
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
         % (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1; 
%% (decision_1+decision_2+decision_3+decision_123)
        n = n+1;
        names{n} = 'decision;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'decision_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% (outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'outcome;3+123';
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
        j = 1;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur
%% residual
        j = 2;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur

%% residual
        j = 3;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur        
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
end
%% name_array and convec definition
convec=[1,+1,-1;1,-1,+1];
name_array=convec2name_array(convec,names); %should creates the names of the contrast from the convec vector
%% care whether this things actualyl works
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec);
%rfx jobs
rfx_jobmaker(name_array,statdir);

%% Model 3 with (GAIN-LOSS) variable:
% BOLD = eval1 +eval2+eval3+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual1 + Residual(2)+ Residual(3) + Residual(123)
% + (GAIN-LOSS)(1) + (GAIN-LOSS)(2) + (GAIN-LOSS)(3) + (GAIN-LOSS)(123)
modname='model_03_(GAIN-LOSS)';
statdir = ['A:\DCJ\SPM\stat\tom\',modname]; 
mkdir(statdir)
dur_target=0.5;
Duration(i(:,n))=Duration(i(:,n))
for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% eval1
        n = n+1;
        names{n} = 'evaluation;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
        durations{n} = dur_target; %the duration of the event, this vector is long as the amount of non-zero elements in Onset
                 % (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1; 
%% eval2
        n = n+1;
        names{n} = 'evaluation;2';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
         % (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;         
%% eval3
        n = n+1;
        names{n} = 'evaluation;3';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
         % (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;         
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_target;
         % (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;         
%% (decision_1+decision_2+decision_3+decision_123)
        n = n+1;
        names{n} = 'decision;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'decision_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% (outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'outcome;3+123';
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
        j = 1;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur
%% residual
        j = 2;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur

%% residual
        j = 3;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur
%% residual
        j = 4;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur               
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
end
%% name_array and convec definition
convec=[1,1,1,-1;1,-1,-1,+1];
name_array=convec2name_array(convec,names); %should creates the names of the contrast from the convec vector
%% care whether this things actualyl works
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec);
%rfx jobs
rfx_jobmaker(name_array,statdir);