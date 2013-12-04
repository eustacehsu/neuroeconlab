%% combo with functions to increase readability + FACTORIAL + Conditional Models
clear all
tic
addpath(genpath('C:\Users\NeuroEconUser\Documents\GitHub\neuroeconlab\Jarek\Tommy_combsedit'));
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
dur_target=[0.5,1];%,1.5,2,0];
%%
%% Non-Parametric (a-la Giorgio) models of the Conditional Outcome phase

for t=1:length(dur_target)
%testing this
%BOLD = (eval12_win+eval3_win)+outcome3+(eval12_loss+eval3_loss)+outcome123+(decision_1+decision_2+decision_3+decision_123) + (eval1+ eval2 +eval3 +eval123)
% + Residual;ev2 +Residualev3 + Residualoutc3 + Residualoutc123
modname='mincomplexity';
statdir = ['A:\DCJ\SPM\stat\tom\outcome_cond\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj=unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%%
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
% %% eval2 w
%         n = n+1;
%         names{n} = 'evaluation;2_win'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout1 == 1;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% %% eval3 w
%         n = n+1;
%         names{n} = 'evaluation;3_win'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout2 == 1;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% %% outcome3 w
%         n = n+1;
%         names{n} = 'outcome3_win'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout3 == 1;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% outcome3 
        n = n+1;
        names{n} = 'outcome3'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}); % & Winout3 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% eval2+3 l
        n = n+1;
        names{n} = 'evaluation2+_loss'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
% %% eval2 l
%         n = n+1;
%         names{n} = 'evaluation;2_loss'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout1 == 0;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% %% eval3 w
%         n = n+1;
%         names{n} = 'evaluation;3_loss'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout2 == 1;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% %% outcome3 l
%         n = n+1;
%         names{n} = 'outcome3_loss'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout3 == 0;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% outcome123
        n = n+1;
        names{n} = 'outcome123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_123') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end                

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
%% (eval1+eval12+eval3+eval123)
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
%% residual
        n = n+1;
        j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
        n = n+1;
        j = 4;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur        
% %% residual
%         n = n+1;
%         j = 5;% id of the regressor which it refers to 
%         names{n} = [names{j},'_Residual'];
%         onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
%         durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
% %% residual
%         n = n+1;
%         j = 6;% id of the regressor which it refers to 
%         names{n} = [names{j},'_Residual'];
%         onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
%         durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur       
% %% residual
%         n = n+1;
%         j = 7;% id of the regressor which it refers to 
%         names{n} = [names{j},'_Residual'];
%         onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
%         durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur                
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
%  convec=[+1,-1,0];
% convec=vertcat(convec,eye(length(convec(1,:))));
convec=eye(4);
name_array=convec2name_array(convec,names);
%ffx jobs
% ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end
rfx_jobmaker_fullfactorial(name_array,statdir)
% rfx_jobmaker(name_array,statdir);  
end

for t=1:length(dur_target)
%% model1
%BOLD = eval12_win+eval3_win+outcome3_win++eval12_loss+eval3_loss+outcome3_loss+outcome123+(decision_1+decision_2+decision_3+decision_123) + (eval1+ eval2 +eval3 +eval123)
% + Residual;ev2 +Residualev3 + Residualoutc3 + Residualoutc123
%testing this
%BOLD = (eval12_win+eval3_win)+outcome3w+(eval12_loss+eval3_loss)+outcome3l + outcome123+(decision_1+decision_2+decision_3+decision_123) + (eval1+ eval2 +eval3 +eval123)
% + Residual;ev2 +Residualev3 + Residualoutc3 + Residualoutc123
modname='maxcomplexity';
statdir = ['A:\DCJ\SPM\stat\tom\outcome_cond\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj=unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%%
% %% eval2+3 w
%         n = n+1;
%         names{n} = 'evaluation2+_win'; %guess this means
%         i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout1 == 1;
%         i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout2 == 1;  
%         i(:,n) = i_2 | i_3 ;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
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
% %% outcome3 
%         n = n+1;
%         names{n} = 'outcome3'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}); % & Winout3 == 1;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% eval2+3 l
%         n = n+1;
%         names{n} = 'evaluation2+_loss'; %guess this means
%         i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout1 == 0;
%         i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout2 == 0;  
%         i(:,n) = i_2 | i_3 ;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
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
            ismember(Period, Runs{iRuns}) & Winout2 == 0;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% outcome3 l
        n = n+1;
        names{n} = 'outcome3_loss'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout3 == 0;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% outcome123
        n = n+1;
        names{n} = 'outcome123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_123') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end                

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
%% (eval1+eval12+eval3+eval123)
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
%% residual
        n = n+1;
        j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
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
%  convec=[+1,-1,0];
% convec=vertcat(convec,eye(length(convec(1,:))));
convec=eye(7);
name_array=convec2name_array(convec,names);
%ffx jobs
% ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end
rfx_jobmaker_fullfactorial(name_array,statdir)
% rfx_jobmaker(name_array,statdir);  
end

for t=1:length(dur_target)
%% model1
%BOLD = eval12_win+eval3_win+outcome3_win++eval12_loss+eval3_loss+outcome3_loss+outcome123+(decision_1+decision_2+decision_3+decision_123) + (eval1+ eval2 +eval3 +eval123)
% + Residual;ev2 +Residualev3 + Residualoutc3 + Residualoutc123
%testing this
%BOLD = (eval12_win+eval3_win)+outcome3w+(eval12_loss+eval3_loss)+outcome3l + outcome123+(decision_1+decision_2+decision_3+decision_123) + (eval1+ eval2 +eval3 +eval123)
% + Residual;ev2 +Residualev3 + Residualoutc3 + Residualoutc123
modname='avgcomplexity';
statdir = ['A:\DCJ\SPM\stat\tom\outcome_cond\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj=unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%%
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
% %% eval2 w
%         n = n+1;
%         names{n} = 'evaluation;2_win'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout1 == 1;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% %% eval3 w
%         n = n+1;
%         names{n} = 'evaluation;3_win'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout2 == 1;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% outcome3 w
        n = n+1;
        names{n} = 'outcome3_win'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout3 == 1;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% %% outcome3 
%         n = n+1;
%         names{n} = 'outcome3'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}); % & Winout3 == 1;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% eval2+3 l
        n = n+1;
        names{n} = 'evaluation2+_loss'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
% %% eval2 l
%         n = n+1;
%         names{n} = 'evaluation;2_loss'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout1 == 0;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
% %% eval3 w
%         n = n+1;
%         names{n} = 'evaluation;3_loss'; %guess this means
%         i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
%             ismember(Period, Runs{iRuns}) & Winout2 == 1;
%         onsets{n} = Onset(i(:,n));
%                 if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% outcome3 l
        n = n+1;
        names{n} = 'outcome3_loss'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout3 == 0;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end
%% outcome123
        n = n+1;
        names{n} = 'outcome123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'outcome_123') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end                

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
%% (eval1+eval12+eval3+eval123)
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
%% residual
        n = n+1;
        j = 3;% id of the regressor which it refers to 
        names{n} = [names{j},'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur
%% residual
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
% %% residual
%         n = n+1;
%         j = 6;% id of the regressor which it refers to 
%         names{n} = [names{j},'_Residual'];
%         onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
%         durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur       
% %% residual
%         n = n+1;
%         j = 7;% id of the regressor which it refers to 
%         names{n} = [names{j},'_Residual'];
%         onsets{n} = Onset(i(:,j)) + dur_target(t); % starts at the end of the corresponding regressor
%         durations{n} = Duration(i(:,j)) - dur_target(t); %last the length of the corresponding regressor - dur                
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
%  convec=[+1,-1,0];
% convec=vertcat(convec,eye(length(convec(1,:))));
convec=eye(5);
name_array=convec2name_array(convec,names);
%ffx jobs
ffx_jobmaker(statdir,datadir,name_array,convec,Subj);  
end

 rfx_jobmaker_fullfactorial(name_array,statdir);  
end


