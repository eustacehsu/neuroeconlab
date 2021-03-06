% combo with functions to increase readability + FACTORIAL + Conditional Models
clear all
tic
addpath(genpath('C:\Users\NeuroEconUser\Documents\GitHub\neuroeconlab\Jarek\Tommy_combsedit'));
% Notes
Something about the different statdir between FFX and RFX. Probably we
should specify only one statdir and then change it as statdir\FFX in ffx
job maker or stadir\RFX in rfx jobmaker.
CHeck whether
the contrasts work and how the parameters come into consideration in the
contrasts. There is a difference between Regressors tagged (in duration specificatioN) as TARGET and
regressors tagged as CONTROL . TARGED have an associated residual and its
duration can by manipulated.
% Load data Necessary to retrieve conditions indexes
[Subject Period Stage Condition Event Onset Duration ...
    Up	Down Bet1 Bet2 Bet3 Winout1 Winout2 Winout3] = ...
    textread('A:\DCJ\SPM\data\log\dcj_dynamic_for_matlab.txt', ...
    '%d %d %d %d %s %d %d %d %d %d %d %d %d %d %d', ...
    'headerlines', 1);
%
Set time in seconds
Onset = Onset / 1000;
Duration = Duration / 1000;
nSubj = numel(unique(Subject));
RUN 1 --> trial 1-24
RUN 2 --> trial 25-48
RUN 3 --> trial 49-72
Runs = {1:24 25:48 49:72};
datadir = 'A:\DCJ\SPM\data';
dur_target=[0,1];%,1.5,2,0];
% GAIN-LOSS models
% Parametric (a-la Giorgio) models for the Evaluation Phase

for t=1:length(dur_target)
%% model1
%BOLD = (eval1+eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (eval2+ eval3 +outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_loss\evaluation\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj =unique(Subject)'

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
        if dur_target(t)==0
            durations{n} = Duration(i(:,n));
        else
            durations{n} = dur_target(t);      
        end
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;         
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN-LOSS) variable
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
% %% (outcome_3+outcome_123) during eval models
%         n = n+1;
%         names{n} = 'outcome;3+123';
%         i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
%             ismember(Period, Runs{iRuns});      
%         i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
%             ismember(Period, Runs{iRuns});        
%         i(:,n)   = i_3 | i_123 ;
%         onsets{n} = Onset(i(:,n));
%         durations{n} = Duration(i(:,n));
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
if dur_target(t)==0
else
%% residual
        n = n+1;
        j = 1;% id of the regressor which it refers to 
%         names{n} = [names{j},'_Residual']; 
        names{n} = [names{j},'_Residual'];

        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n = n+1;
        j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
end
%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    %% name_array and convec definition
par=paramcounter(pmod); 
[totpar,npar]=paramcounter(pmod);    
convec=eye(length(names)+totpar);%[+1,-1,0];
name_array=convec2name_array_param(convec,names,npar,pmod);

%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end

rfx_jobmaker_fullfactorial(name_array,statdir)


%% Model 2:
% BOLD = eval1 +(eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual(1) + Residual(2+3) + Residual(123)  
modname='model_02';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_loss\evaluation\dur_',num2str(dur_target(t)),'\',modname];   
mkdir(statdir)
%dur_target

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
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
 %% (GAIN-LOSS) variable
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
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;                 
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN-LOSS) variable
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
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

%% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur        
end
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
        %% name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,+1,-1;1,-1,+1];
name_array=convec2name_array_param(convec,names,npar,pmod);
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  

end
rfx_jobmaker_fullfactorial(name_array,statdir)

%% Model 3:
% BOLD = eval1 +eval2+eval3+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual1 + Residual(2)+ Residual(3) + Residual(123) 
modname='model_03';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_loss\evaluation\dur_',num2str(dur_target(t)),'\',modname]; 
mkdir(statdir)
%dur_target

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
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;                 
%% eval2
        n = n+1;
        names{n} = 'evaluation;2';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;                 
%% eval3
        n = n+1;
        names{n} = 'evaluation;3';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1; 
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                 %% (GAIN-LOSS) variable
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
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

%% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 4;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur 
end        
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    %% name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,1,1,-1;
name_array=convec2name_array_param(convec,names,npar,pmod); %should creates the names of the contrast from the convec vector
%% care whether this things actualyl works
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end
%rfx jobs
rfx_jobmaker_fullfactorial(name_array,statdir)
end



%% Parametric (a-la Giorgio) models for the Decision Phase

for t=1:length(dur_target)
%% model1
%BOLD = +(decision_1+decision_2+decision_3)+decision_123 + (eval1+eval12+eval3+evaluation_123)+(eval2+ eval3 +outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_loss\decision\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj =unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% (decision1+decision12+decision3)
        n = n+1 ;
        names{n} = 'decision;1+2+3';
        i_1 = (Subject == Subj) & strcmp(Event, 'decision_1') & ...
            ismember(Period, Runs{iRuns});
        i_2 = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
        if dur_target(t)==0
            durations{n} = Duration(i(:,n));
        else
            durations{n} = dur_target(t);      
        end
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;         
%% decision123
        n = n+1;
        names{n} = 'decision;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;                 
%% (evaluation_1+evaluation_2+evaluation_3+evaluation_123)
        n = n+1;
        names{n} = 'evaluation;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
% %% (outcome_3+outcome_123) during eval models
%         n = n+1;
%         names{n} = 'outcome;3+123';
%         i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
%             ismember(Period, Runs{iRuns});      
%         i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
%             ismember(Period, Runs{iRuns});        
%         i(:,n)   = i_3 | i_123 ;
%         onsets{n} = Onset(i(:,n));
%         durations{n} = Duration(i(:,n));
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
if dur_target(t)==0
else
%% residual
        n = n+1;
        j = 1;% id of the regressor which it refers to 
%         names{n} = [names{j},'_Residual']; 
        names{n} = [names{j},'_Residual'];

        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n = n+1;
        j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
end
%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    %% name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[+1,-1,0];
name_array=convec2name_array_param(convec,names,npar,pmod);
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end

rfx_jobmaker_fullfactorial(name_array,statdir)


%% Model 2:
% BOLD = decision1 +(decision12+decision3)+decision_123+(evaluation_1+evaluation_2+evaluation_3+evaluation_123) + (outcome_3+outcome_123)
% + Residual(1) + Residual(2+3) + Residual(123)  
modname='model_02';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_loss\decision\dur_',num2str(dur_target(t)),'\',modname];   
mkdir(statdir)
%dur_target

for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% decision1
        n = n+1;
        names{n} = 'decision;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_1') & ... %%index corresponding to subject subj event decision_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;                 
%% (decision12+decision3)
        n = n+1;
        names{n} = 'decision;2+3';
        i_2 = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;                 
%% decision123
        n = n+1;
        names{n} = 'decision;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;                 
%% (evaluation_1+evaluation_2+evaluation_3+evaluation_123)
        n = n+1;
        names{n} = 'evaluation;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

%% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur        
end
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
        %% name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,+1,-1;1,-1,+1];
name_array=convec2name_array_param(convec,names,npar,pmod);
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  

end
rfx_jobmaker_fullfactorial(name_array,statdir)

%% Model 3:
% BOLD = decision1 +decision2+decision3+decision_123+(evaluation_1+evaluation_2+evaluation_3+evaluation_123) + (outcome_3+outcome_123)
% + Residual1 + Residual(2)+ Residual(3) + Residual(123) 
modname='model_03';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_loss\decision\dur_',num2str(dur_target(t)),'\',modname]; 
mkdir(statdir)
%dur_target

for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% decision1
        n = n+1;
        names{n} = 'decision;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_1') & ... %%index corresponding to subject subj event decision_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;                 
%% decision2
        n = n+1;
        names{n} = 'decision;2';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;                 
%% decision3
        n = n+1;
        names{n} = 'decision;3';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;                 
%% decision123
        n = n+1;
        names{n} = 'decision;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;                 
%% (evaluation_1+evaluation_2+evaluation_3+evaluation_123)
        n = n+1;
        names{n} = 'evaluation;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

%% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 4;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur 
end        
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    %% name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,1,1,-1;
        
name_array=convec2name_array_param(convec,names,npar,pmod); %should creates the names of the contrast from the convec vector
%% care whether this things actualyl works
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end
%rfx jobs
rfx_jobmaker_fullfactorial(name_array,statdir)
end


%  Investment*(GAIN-LOSS) models
% Parametric (a-la Giorgio) models for the Evaluation Phase

for t=1:length(dur_target)
% model1
BOLD = (eval1+eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (eval2+ eval3 +outcome_3+outcome_123)
+ Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_lossXinvest\evaluation\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
dur_target
Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%
for Subj =unique(Subject)'

    for iRuns = 1:numel(Runs)
% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
% (eval1+eval12+eval3)
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
        if dur_target(t)==0
            durations{n} = Duration(i(:,n));
        else
            durations{n} = dur_target(t);      
        end
 %  Investment*(GAIN-LOSS) Variable for 1+2+3
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i_1 +Bet2.*i_2 +Bet3.*i_3;
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
        
% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
  %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
                   
% (decision_1+decision_2+decision_3+decision_123)
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
% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
if dur_target(t)==0
else
% residual
        n = n+1;
        j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        names{n} = [names{j},'_Residual'];

        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
end
 Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    % name_array and convec definition
par=paramcounter(pmod); 
[totpar,npar]=paramcounter(pmod);    
convec=eye(length(names)+totpar);%[+1,-1,0];
name_array=convec2name_array_param(convec,names,npar,pmod);

ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end

rfx_jobmaker_fullfactorial(name_array,statdir)


% Model 2:
BOLD = eval1 +(eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
+ Residual(1) + Residual(2+3) + Residual(123)  
modname='model_02';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_lossXinvest\evaluation\dur_',num2str(dur_target(t)),'\',modname];   
mkdir(statdir)
dur_target

for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
% eval1
        n = n+1;
        names{n} = 'evaluation;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
                
% (eval12+eval3)
        n = n+1;
        names{n} = 'evaluation;2+3';
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet2.*i_2 +Bet3.*i_3;
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 

% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
                
% (decision_1+decision_2+decision_3+decision_123)
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
% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur        
end
%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
        % name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,+1,-1;1,-1,+1];
name_array=convec2name_array_param(convec,names,npar,pmod);
ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  

end
rfx_jobmaker_fullfactorial(name_array,statdir)

% Model 3:
BOLD = eval1 +eval2+eval3+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
+ Residual1 + Residual(2)+ Residual(3) + Residual(123) 
modname='model_03';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_lossXinvest\evaluation\dur_',num2str(dur_target(t)),'\',modname]; 
mkdir(statdir)
dur_target

for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
% eval1
        n = n+1;
        names{n} = 'evaluation;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
                 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 

% eval2
        n = n+1;
        names{n} = 'evaluation;2';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet2.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 

% eval3
        n = n+1;
        names{n} = 'evaluation;3';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet3.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 

% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
                
% (decision_1+decision_2+decision_3+decision_123)
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
% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n=n+1; j = 4;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur 
end        
%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    % name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,1,1,-1;
name_array=convec2name_array_param(convec,names,npar,pmod); %should creates the names of the contrast from the convec vector
% care whether this things actualyl works
ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end
rfx jobs
rfx_jobmaker_fullfactorial(name_array,statdir)
end



% (GAin-Loss)* Investment Parametric (a-la Giorgio) models for the Decision Phase

for t=1:length(dur_target)
% model1
BOLD = +(decision_1+decision_2+decision_3)+decision_123 + (eval1+eval12+eval3+evaluation_123)+(eval2+ eval3 +outcome_3+outcome_123)
+ Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_lossXinvest\decision\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
dur_target
Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%
for Subj =unique(Subject)'

    for iRuns = 1:numel(Runs)
% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
% (decision1+decision12+decision3)
        n = n+1 ;
        names{n} = 'decision;1+2+3';
        i_1 = (Subject == Subj) & strcmp(Event, 'decision_1') & ...
            ismember(Period, Runs{iRuns});
        i_2 = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
        if dur_target(t)==0
            durations{n} = Duration(i(:,n));
        else
            durations{n} = dur_target(t);      
        end
         %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i_1 +Bet2.*i_2 +Bet3.*i_3;
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 

% decision123
        n = n+1;
        names{n} = 'decision;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 

% (evaluation_1+evaluation_2+evaluation_3+evaluation_123)
        n = n+1;
        names{n} = 'evaluation;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
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
% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
if dur_target(t)==0
else
% residual
        n = n+1;
        j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        names{n} = [names{j},'_Residual'];

        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
end
 Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    % name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[+1,-1,0];
name_array=convec2name_array_param(convec,names,npar,pmod);
ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end

rfx_jobmaker_fullfactorial(name_array,statdir)


% Model 2:
BOLD = decision1 +(decision12+decision3)+decision_123+(evaluation_1+evaluation_2+evaluation_3+evaluation_123) + (outcome_3+outcome_123)
+ Residual(1) + Residual(2+3) + Residual(123)  
modname='model_02';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_lossXinvest\decision\dur_',num2str(dur_target(t)),'\',modname];   
mkdir(statdir)
dur_target

for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
% decision1
        n = n+1;
        names{n} = 'decision;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_1') & ... %%index corresponding to subject subj event decision_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset
 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
                
% (decision12+decision3)
        n = n+1;
        names{n} = 'decision;2+3';
        i_2 = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet2.*i_2 +Bet3.*i_3;
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
                
% decision123
        n = n+1;
        names{n} = 'decision;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
 
% (evaluation_1+evaluation_2+evaluation_3+evaluation_123)
        n = n+1;
        names{n} = 'evaluation;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur        
end
%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
        % name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,+1,-1;1,-1,+1];
name_array=convec2name_array_param(convec,names,npar,pmod);
ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  

end
rfx_jobmaker_fullfactorial(name_array,statdir)

% Model 3:
BOLD = decision1 +decision2+decision3+decision_123+(evaluation_1+evaluation_2+evaluation_3+evaluation_123) + (outcome_3+outcome_123)
+ Residual1 + Residual(2)+ Residual(3) + Residual(123) 
modname='model_03';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain_lossXinvest\decision\dur_',num2str(dur_target(t)),'\',modname]; 
mkdir(statdir)
dur_target

for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
% decision1
        n = n+1;
        names{n} = 'decision;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_1') & ... %%index corresponding to subject subj event decision_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
                 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 

% decision2
        n = n+1;
        names{n} = 'decision;2';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet2.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 

% decision3
        n = n+1;
        names{n} = 'decision;3';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet3.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 

% decision123
        n = n+1;
        names{n} = 'decision;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                 %  Investment*(GAIN-LOSS) Variable
  pmod(n).name{1} = '(Up-Down)*invest'; 
        allBet=Bet1.*i(:,n);
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 

% (evaluation_1+evaluation_2+evaluation_3+evaluation_123)
        n = n+1;
        names{n} = 'evaluation;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n=n+1; j = 4;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur 
end        
%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    % name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,1,1,-1;
        
name_array=convec2name_array_param(convec,names,npar,pmod); %should creates the names of the contrast from the convec vector
% care whether this things actualyl works
ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end
rfx jobs
rfx_jobmaker_fullfactorial(name_array,statdir)
end

%% GAIN and LOSS models
%% Parametric (a-la Giorgio) models for the Evaluation Phase

for t=1:length(dur_target)
%% model1
%BOLD = (eval1+eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (eval2+ eval3 +outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain&loss\evaluation\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj =unique(Subject)'

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
        if dur_target(t)==0
            durations{n} = Duration(i(:,n));
        else
            durations{n} = dur_target(t);      
        end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1;
 %% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;                
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1;          
 %% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
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
% %% (outcome_3+outcome_123) during eval models
%         n = n+1;
%         names{n} = 'outcome;3+123';
%         i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
%             ismember(Period, Runs{iRuns});      
%         i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
%             ismember(Period, Runs{iRuns});        
%         i(:,n)   = i_3 | i_123 ;
%         onsets{n} = Onset(i(:,n));
%         durations{n} = Duration(i(:,n));
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
if dur_target(t)==0
else
%% residual
        n = n+1;
        j = 1;% id of the regressor which it refers to 
%         names{n} = [names{j},'_Residual']; 
        names{n} = [names{j},'_Residual'];

        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n = n+1;
        j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
end
%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    %% name_array and convec definition
par=paramcounter(pmod); 
[totpar,npar]=paramcounter(pmod);    
convec=eye(length(names)+totpar);%[+1,-1,0];
name_array=convec2name_array_param(convec,names,npar,pmod);

%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end

rfx_jobmaker_fullfactorial(name_array,statdir)


%% Model 2:
% BOLD = eval1 +(eval12+eval3)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual(1) + Residual(2+3) + Residual(123)  
modname='model_02';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain&loss\evaluation\dur_',num2str(dur_target(t)),'\',modname];   
mkdir(statdir)
%dur_target

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
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1;   
 %% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
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
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1; 
 %% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;                    
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1;  
  %% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
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
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

%% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur        
end
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
        %% name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,+1,-1;1,-1,+1];
name_array=convec2name_array_param(convec,names,npar,pmod);
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  

end
rfx_jobmaker_fullfactorial(name_array,statdir)

%% Model 3:
% BOLD = eval1 +eval2+eval3+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual1 + Residual(2)+ Residual(3) + Residual(123) 
modname='model_03';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain&loss\evaluation\dur_',num2str(dur_target(t)),'\',modname]; 
mkdir(statdir)
%dur_target

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
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1;     
%% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;            
%% eval2
        n = n+1;
        names{n} = 'evaluation;2';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1;   
%% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;            
%% eval3
        n = n+1;
        names{n} = 'evaluation;3';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1; 
%% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;            
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
                 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1; 
%% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
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
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

%% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 4;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur 
end        
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    %% name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,1,1,-1;
name_array=convec2name_array_param(convec,names,npar,pmod); %should creates the names of the contrast from the convec vector
%% care whether this things actualyl works
%ffx jobs
% ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end
%rfx jobs
rfx_jobmaker_fullfactorial(name_array,statdir)
end



%% Parametric (a-la Giorgio) models for the Decision Phase

for t=1:length(dur_target)
%% model1
%BOLD = +(decision_1+decision_2+decision_3)+decision_123 + (eval1+eval12+eval3+evaluation_123)+(eval2+ eval3 +outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain&loss\decision\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj =unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% (decision1+decision12+decision3)
        n = n+1 ;
        names{n} = 'decision;1+2+3';
        i_1 = (Subject == Subj) & strcmp(Event, 'decision_1') & ...
            ismember(Period, Runs{iRuns});
        i_2 = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
        if dur_target(t)==0
            durations{n} = Duration(i(:,n));
        else
            durations{n} = dur_target(t);      
        end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1; 
 %% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;           
%% decision123
        n = n+1;
        names{n} = 'decision;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1; 
 %% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;           
%% (evaluation_1+evaluation_2+evaluation_3+evaluation_123)
        n = n+1;
        names{n} = 'evaluation;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
% %% (outcome_3+outcome_123) during eval models
%         n = n+1;
%         names{n} = 'outcome;3+123';
%         i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
%             ismember(Period, Runs{iRuns});      
%         i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
%             ismember(Period, Runs{iRuns});        
%         i(:,n)   = i_3 | i_123 ;
%         onsets{n} = Onset(i(:,n));
%         durations{n} = Duration(i(:,n));
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
if dur_target(t)==0
else
%% residual
        n = n+1;
        j = 1;% id of the regressor which it refers to 
%         names{n} = [names{j},'_Residual']; 
        names{n} = [names{j},'_Residual'];

        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n = n+1;
        j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
end
%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    %% name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[+1,-1,0];
name_array=convec2name_array_param(convec,names,npar,pmod);
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end

rfx_jobmaker_fullfactorial(name_array,statdir)


%% Model 2:
% BOLD = decision1 +(decision12+decision3)+decision_123+(evaluation_1+evaluation_2+evaluation_3+evaluation_123) + (outcome_3+outcome_123)
% + Residual(1) + Residual(2+3) + Residual(123)  
modname='model_02';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain&loss\decision\dur_',num2str(dur_target(t)),'\',modname];   
mkdir(statdir)
%dur_target

for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% decision1
        n = n+1;
        names{n} = 'decision;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_1') & ... %%index corresponding to subject subj event decision_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1;  
%% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;            
%% (decision12+decision3)
        n = n+1;
        names{n} = 'decision;2+3';
        i_2 = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1;    
%% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;            
%% decision123
        n = n+1;
        names{n} = 'decision;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1;   
%% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;            
%% (evaluation_1+evaluation_2+evaluation_3+evaluation_123)
        n = n+1;
        names{n} = 'evaluation;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

%% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur        
end
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
        %% name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,+1,-1;1,-1,+1];
name_array=convec2name_array_param(convec,names,npar,pmod);
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  

end
rfx_jobmaker_fullfactorial(name_array,statdir)

%% Model 3:
% BOLD = decision1 +decision2+decision3+decision_123+(evaluation_1+evaluation_2+evaluation_3+evaluation_123) + (outcome_3+outcome_123)
% + Residual1 + Residual(2)+ Residual(3) + Residual(123) 
modname='model_03';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\gain&loss\decision\dur_',num2str(dur_target(t)),'\',modname]; 
mkdir(statdir)
%dur_target

for Subj = unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% decision1
        n = n+1;
        names{n} = 'decision;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_1') & ... %%index corresponding to subject subj event decision_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1;  
%% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;            
%% decision2
        n = n+1;
        names{n} = 'decision;2';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1; 
%% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;            
%% decision3
        n = n+1;
        names{n} = 'decision;3';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1; 
%% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;            
%% decision123
        n = n+1;
        names{n} = 'decision;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
 %% (GAIN) variable
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1;    
%% (LOSS) variable
        pmod(n).name{1} = 'Down'; 
        pmod(n).param{1} = -Down(i(:,n));
        pmod(n).poly{1} = 1;            
%% (evaluation_1+evaluation_2+evaluation_3+evaluation_123)
        n = n+1;
        names{n} = 'evaluation;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% (eval 2 eval3 outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'eval2+eval3;outcome;3+123';
        i_ev2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_ev3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_ev2 | i_ev3 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = Duration(i(:,n));
%% residual
if dur_target(t)==0
else
        n=n+1; j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur

%% residual
        n=n+1; j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n=n+1; j = 4;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur 
end        
%%  Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        % Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    %% name_array and convec definition
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[1,1,1,-1;
        
name_array=convec2name_array_param(convec,names,npar,pmod); %should creates the names of the contrast from the convec vector
%% care whether this things actualyl works
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end
%rfx jobs
rfx_jobmaker_fullfactorial(name_array,statdir)
end

return


% Non-Parametric (a-la Giorgio) models for the Outcome Phase
% Non-Parametric (a-la Giorgio) models of the Conditional Outcome phase






for t=1:length(dur_target)
testing this
BOLD = (eval12_win+eval3_win)+outcome3+(eval12_loss+eval3_loss)+outcome123+(decision_1+decision_2+decision_3+decision_123) + (eval1+ eval2 +eval3 +eval123)
+ Residual;ev2 +Residualev3 + Residualoutc3 + Residualoutc123
modname='mincomplexity';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\outcome_cond\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
dur_target
Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%
for Subj=unique(Subject)'

    for iRuns = 1:numel(Runs)
% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%
% eval2+3 w
        n = n+1;
        names{n} = 'evaluation2+_win'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
%% eval2 w
        n = n+1;
        names{n} = 'evaluation;2_win'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% eval3 w
        n = n+1;
        names{n} = 'evaluation;3_win'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% outcome3 w
        n = n+1;
        names{n} = 'outcome3_win'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout3 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% outcome3 
        n = n+1;
        names{n} = 'outcome3'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}); % & Winout3 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% eval2+3 l
        n = n+1;
        names{n} = 'evaluation2+_loss'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
%% eval2 l
        n = n+1;
        names{n} = 'evaluation;2_loss'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% eval3 w
        n = n+1;
        names{n} = 'evaluation;3_loss'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% outcome3 l
        n = n+1;
        names{n} = 'outcome3_loss'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout3 == 0;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% outcome123
        n = n+1;
        names{n} = 'outcome123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_123') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end                

% (decision_1+decision_2+decision_3+decision_123)
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
% (eval1+eval12+eval3+eval123)
        n = n+1 ;
        names{n} = 'evaluation;1+2+3+123';
        i_1 = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123;
        onsets{n} = Onset(i(:,n));
        if dur_target(t)==0
            durations{n} = Duration(i(:,n));
        else
            durations{n} = dur_target(t);      
        end

if dur_target(t)==0
else
% residual
        n = n+1;
        j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        names{n} = [names{j},'_Residual'];

        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 4;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur        
%% residual
        n = n+1;
        j = 5;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n = n+1;
        j = 6;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur       
%% residual
        n = n+1;
        j = 7;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur                
end
 Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    % name_array and convec definition
 [totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[+1,-1,0];
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%vertcat(convec,eye(length(convec(1,:))));
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%eye(4);
name_array=convec2name_array_param(convec,names,npar,pmod);
ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end
rfx_jobmaker_fullfactorial(name_array,statdir)
rfx_jobmaker_fullfactorial(name_array,statdir)
end

for t=1:length(dur_target)
% model1
BOLD = eval12_win+eval3_win+outcome3_win++eval12_loss+eval3_loss+outcome3_loss+outcome123+(decision_1+decision_2+decision_3+decision_123) + (eval1+ eval2 +eval3 +eval123)
+ Residual;ev2 +Residualev3 + Residualoutc3 + Residualoutc123
testing this
BOLD = (eval12_win+eval3_win)+outcome3w+(eval12_loss+eval3_loss)+outcome3l + outcome123+(decision_1+decision_2+decision_3+decision_123) + (eval1+ eval2 +eval3 +eval123)
+ Residual;ev2 +Residualev3 + Residualoutc3 + Residualoutc123
modname='maxcomplexity';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\outcome_cond\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
dur_target
Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%
for Subj=unique(Subject)'

    for iRuns = 1:numel(Runs)
% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%
%% eval2+3 w
        n = n+1;
        names{n} = 'evaluation2+_win'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
 % eval2 w
        n = n+1;
        names{n} = 'evaluation;2_win'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% eval3 w
        n = n+1;
        names{n} = 'evaluation;3_win'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% outcome3 w
        n = n+1;
        names{n} = 'outcome3_win'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout3 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% outcome3 
        n = n+1;
        names{n} = 'outcome3'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}); % & Winout3 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% eval2+3 l
        n = n+1;
        names{n} = 'evaluation2+_loss'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
% eval2 l
        n = n+1;
        names{n} = 'evaluation;2_loss'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% eval3 w
        n = n+1;
        names{n} = 'evaluation;3_loss'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% outcome3 l
        n = n+1;
        names{n} = 'outcome3_loss'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout3 == 0;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% outcome123
        n = n+1;
        names{n} = 'outcome123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_123') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end                

% (decision_1+decision_2+decision_3+decision_123)
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
% (eval1+eval12+eval3+eval123)
        n = n+1 ;
        names{n} = 'evaluation;1+2+3+123';
        i_1 = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123;
        onsets{n} = Onset(i(:,n));
        if dur_target(t)==0
            durations{n} = Duration(i(:,n));
        else
            durations{n} = dur_target(t);      
        end

if dur_target(t)==0
else
% residual
        n = n+1;
        j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        names{n} = [names{j},'_Residual'];

        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 4;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur        
% residual
        n = n+1;
        j = 5;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 6;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur       
% residual
        n = n+1;
        j = 7;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur                
end
 Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    % name_array and convec definition
 [totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[+1,-1,0];
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%vertcat(convec,eye(length(convec(1,:))));
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%eye(7);
name_array=convec2name_array_param(convec,names,npar,pmod);
ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end
rfx_jobmaker_fullfactorial(name_array,statdir)
rfx_jobmaker_fullfactorial(name_array,statdir)
end

for t=1:length(dur_target)
% model1
BOLD = eval12_win+eval3_win+outcome3_win++eval12_loss+eval3_loss+outcome3_loss+outcome123+(decision_1+decision_2+decision_3+decision_123) + (eval1+ eval2 +eval3 +eval123)
+ Residual;ev2 +Residualev3 + Residualoutc3 + Residualoutc123
testing this
BOLD = (eval12_win+eval3_win)+outcome3w+(eval12_loss+eval3_loss)+outcome3l + outcome123+(decision_1+decision_2+decision_3+decision_123) + (eval1+ eval2 +eval3 +eval123)
+ Residual;ev2 +Residualev3 + Residualoutc3 + Residualoutc123
modname='avgcomplexity';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\outcome_cond\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
dur_target
Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%
for Subj=unique(Subject)'

    for iRuns = 1:numel(Runs)
% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%
% eval2+3 w
        n = n+1;
        names{n} = 'evaluation2+3_win'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
%% eval2 w
        n = n+1;
        names{n} = 'evaluation;2_win'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% eval3 w
        n = n+1;
        names{n} = 'evaluation;3_win'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% outcome3 w
        n = n+1;
        names{n} = 'outcome3_win'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout3 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% outcome3 
        n = n+1;
        names{n} = 'outcome3'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}); % & Winout3 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% eval2+3 l
        n = n+1;
        names{n} = 'evaluation2+_loss'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
%% eval2 l
        n = n+1;
        names{n} = 'evaluation;2_loss'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% eval3 w
        n = n+1;
        names{n} = 'evaluation;3_loss'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% outcome3 l
        n = n+1;
        names{n} = 'outcome3_loss'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout3 == 0;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% outcome123
        n = n+1;
        names{n} = 'outcome123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_123') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end                

% (decision_1+decision_2+decision_3+decision_123)
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
% (eval1+eval12+eval3+eval123)
        n = n+1 ;
        names{n} = 'evaluation;1+2+3+123';
        i_1 = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});        
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123;
        onsets{n} = Onset(i(:,n));
        if dur_target(t)==0
            durations{n} = Duration(i(:,n));
        else
            durations{n} = dur_target(t);      
        end

if dur_target(t)==0
else
% residual
        n = n+1;
        j = 1;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual']; 
        names{n} = [names{j},'_Residual'];

        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 2;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% residual
        n = n+1;
        j = 4;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur        
% residual
        n = n+1;
        j = 5;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n = n+1;
        j = 6;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur       
%% residual
        n = n+1;
        j = 7;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur                
end
 Output

        outdir = fullfile(statdir,'\FFX', sprintf('Subject%02d', Subj), 'LOG'); 
                         
        Create output directory if it doesn't exist
        if ~exist(outdir, 'dir')
            mkdir(outdir);
        end     
        
        fname = fullfile(outdir, sprintf('logRun%d', iRuns));
        save(fname, 'names', 'onsets', 'durations', 'pmod');
    end
    % name_array and convec definition
 [totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%[+1,-1,0];
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%vertcat(convec,eye(length(convec(1,:))));
[totpar,npar]=paramcounter(pmod);     convec=eye(length(names)+totpar);%eye(5);
name_array=convec2name_array_param(convec,names,npar,pmod);
ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end

 rfx_jobmaker_fullfactorial(name_array,statdir);  
end


