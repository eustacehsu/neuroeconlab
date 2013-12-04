%% combo with functions to increase readability + FACTORIAL + Conditional Models + Model Based + SubjectType
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
dur_target=[0,1];%,1.5,2,0];
specialSubject=[2 5 6 7 9 11 15 16 17 19]; % p-value <0.1
group1=[2 3 5 6 7 9 11 15 16 17 19]; % p-value almost 0.1
%%
%% Parametric (a-la Giorgio) models for the Evaluation Phase

for t=2%:length(dur_target)
%% model1
%BOLD = eval1+(eval12W+eval3w)+(eval12l+eval3l)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (eval2+ eval3 +outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\condtional\specialsubj\2groups\gainminusloss\evaluation\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj =  unique(Subject)'

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
%% eval2+3 w
        n = n+1;
        names{n} = 'evaluation2+3_win'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;           
%% eval2+3 l
        n = n+1;
        names{n} = 'evaluation2+3_l'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;  
        i(:,n) = i_2 | i_3 ;
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
if ~isempty(find(group1==Subj, 1))

        outdir = fullfile(statdir,'\FFX','group1', sprintf('Subject%02d', Subj), 'LOG'); 
else
        outdir = fullfile(statdir,'\FFX','group2', sprintf('Subject%02d', Subj), 'LOG'); 
end

                         
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
convec=vertcat(convec,ones(1,length(names)+totpar));
name_array=convec2name_array_param_2group(convec,names,npar,pmod);

%ffx jobs
ffx_jobmaker_2groups(statdir,datadir,name_array,convec,Subj,group1);  
end

rfx_jobmaker_fullfactorial_2groups(name_array,statdir)


end
%effect of previous outcome
for t=1%:length(dur_target)
%% model1
%BOLD = eval1+(eval12W+eval3w)+(eval12l+eval3l)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (eval2+ eval3 +outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\condtional\specialsubj\2groups\previouseffect\evaluation\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj =  unique(Subject)'

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

%% eval2+3 w
        n = n+1;
        names{n} = 'evaluation2+3_win'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
%%                
        pmod(n).name{1} = 'Up*invest(-1)'; 
        allBet=Bet1.*i_2  +Bet2.*i_3;
        pmod(n).param{1} = Up(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1;       
%% eval2+3 l
        n = n+1;
        names{n} = 'evaluation2+3_l'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
%%                
        pmod(n).name{1} = 'Down*invest(-1)'; 
        allBet=Bet1.*i_2  +Bet2.*i_3;
        pmod(n).param{1} = -Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1;                
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
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
if ~isempty(find(group1==Subj, 1))

        outdir = fullfile(statdir,'\FFX','group1', sprintf('Subject%02d', Subj), 'LOG'); 
else
        outdir = fullfile(statdir,'\FFX','group2', sprintf('Subject%02d', Subj), 'LOG'); 
end

                         
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
convec=vertcat(convec,ones(1,length(names)+totpar));
name_array=convec2name_array_param_2group(convec,names,npar,pmod);

%ffx jobs
ffx_jobmaker_2groups(statdir,datadir,name_array,convec,Subj,group1);  
end

rfx_jobmaker_fullfactorial_2groups(name_array,statdir)


end

%% without controlling for eval in the outcome condition
for t=1%:length(dur_target)
%% model1
%BOLD = eval1+(eval12W+eval3w)+(eval12l+eval3l)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\condtional\specialsubj\2groups\gainminusloss_nocontrol\evaluation\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj =  unique(Subject)'

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
%% eval2+3 w
        n = n+1;
        names{n} = 'evaluation2+3_win'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;           
%% eval2+3 l
        n = n+1;
        names{n} = 'evaluation2+3_l'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;  
        i(:,n) = i_2 | i_3 ;
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
        names{n} = 'outcome;3+123';
        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_3 | i_123 ;
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
if ~isempty(find(group1==Subj, 1))

        outdir = fullfile(statdir,'\FFX','group1', sprintf('Subject%02d', Subj), 'LOG'); 
else
        outdir = fullfile(statdir,'\FFX','group2', sprintf('Subject%02d', Subj), 'LOG'); 
end

                         
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
convec=vertcat(convec,ones(1,length(names)+totpar));
name_array=convec2name_array_param_2group(convec,names,npar,pmod);

%ffx jobs
ffx_jobmaker_2groups(statdir,datadir,name_array,convec,Subj,group1);  
end

rfx_jobmaker_fullfactorial_2groups(name_array,statdir)


end

for t=1%:length(dur_target)
%% model1
%BOLD = eval1+(eval12W+eval3w)+(eval12l+eval3l)+evaluation_123+(decision_1+decision_2+decision_3+decision_123) + (+outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\condtional\specialsubj\2groups\previouseffect_nocontrol\evaluation\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj =  unique(Subject)'

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

%% eval2+3 w
        n = n+1;
        names{n} = 'evaluation2+3_win'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
%%                
        pmod(n).name{1} = 'Up*invest(-1)'; 
        allBet=Bet1.*i_2  +Bet2.*i_3;
        pmod(n).param{1} = Up(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1;       
%% eval2+3 l
        n = n+1;
        names{n} = 'evaluation2+3_l'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
%%                
        pmod(n).name{1} = 'Down*invest(-1)'; 
        allBet=Bet1.*i_2  +Bet2.*i_3;
        pmod(n).param{1} = -Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1;                
%% eval123
        n = n+1;
        names{n} = 'evaluation;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
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
        names{n} = 'outcome;3+123';
        
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   =  i_3 | i_123 ;
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
if ~isempty(find(group1==Subj, 1))

        outdir = fullfile(statdir,'\FFX','group1', sprintf('Subject%02d', Subj), 'LOG'); 
else
        outdir = fullfile(statdir,'\FFX','group2', sprintf('Subject%02d', Subj), 'LOG'); 
end

                         
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
convec=vertcat(convec,ones(1,length(names)+totpar));
name_array=convec2name_array_param_2group(convec,names,npar,pmod);

%ffx jobs
ffx_jobmaker_2groups(statdir,datadir,name_array,convec,Subj,group1);  
end

rfx_jobmaker_fullfactorial_2groups(name_array,statdir)


end

%% eval1 and eval123 together
for t=1%:length(dur_target)
%% model1
%BOLD = (eval1+evaluation_123)(eval12W+eval3w)+(eval12l+eval3l)+(decision_1+decision_2+decision_3+decision_123) + (eval2+ eval3 +outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\condtional\specialsubj\2groups\gainminusloss_aggeval1123\evaluation\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj =  unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% eval1+eval123
        n = n+1;
        names{n} = 'evaluation;1+eval123'; % name of the regressors
        i_1 = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        i_123= (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});  
        i(:,n) = i_1 | i_123 ;
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;      
%% eval2+3 w
        n = n+1;
        names{n} = 'evaluation2+3_win'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1;           
%% eval2+3 l
        n = n+1;
        names{n} = 'evaluation2+3_l'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;  
        i(:,n) = i_2 | i_3 ;
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
if ~isempty(find(group1==Subj, 1))

        outdir = fullfile(statdir,'\FFX','group1', sprintf('Subject%02d', Subj), 'LOG'); 
else
        outdir = fullfile(statdir,'\FFX','group2', sprintf('Subject%02d', Subj), 'LOG'); 
end

                         
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
convec=vertcat(convec,ones(1,length(names)+totpar));
name_array=convec2name_array_param_2group(convec,names,npar,pmod);

%ffx jobs
ffx_jobmaker_2groups(statdir,datadir,name_array,convec,Subj,group1);  
end

rfx_jobmaker_fullfactorial_2groups(name_array,statdir)


end
%effect of previous outcome
for t=1:length(dur_target)
%% model1
%BOLD = (eval1+evaluation_123)+(eval12W+eval3w)+(eval12l+eval3l)++(decision_1+decision_2+decision_3+decision_123) + (eval2+ eval3 +outcome_3+outcome_123)
% + Residual;1;1+2+3 + Residual123
modname='model_01';
statdir = ['A:\DCJ\SPM\stat\tom\model_based\condtional\specialsubj\2groups\previouseffect_aggeval1123\evaluation\dur_',num2str(dur_target(t)),'\',modname];  
mkdir(statdir)
%dur_target
% Duration(i(:,n))=Duration(i(:,n))%>>> has to be put inside the code
%%
for Subj =  unique(Subject)'

    for iRuns = 1:numel(Runs)
%% log structure definition        
        names = {};
        onsets = {};
        durations = {};
        pmod = struct('name', {}, 'param', {}, 'poly', {}); %% What is poly???
        n = 0;
%% eval1+eval123
        n = n+1;
        names{n} = 'evaluation;1+eval123'; % name of the regressors
        i_1 = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns});
        i_123= (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});  
        i(:,n) = i_1 | i_123 ;
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end %the duration of the event, this ve non-zero elements in Onset        

%% eval2+3 w
        n = n+1;
        names{n} = 'evaluation2+3_win'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 1;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 1;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
%%                
        pmod(n).name{1} = 'Up*invest(-1)'; 
        allBet=Bet1.*i_2  +Bet2.*i_3;
        pmod(n).param{1} = Up(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1;       
%% eval2+3 l
        n = n+1;
        names{n} = 'evaluation2+3_l'; %guess this means
        i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout1 == 0;
        i_3 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & Winout2 == 0;  
        i(:,n) = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
                if dur_target(t)==0             durations{n} = Duration(i(:,n));         else             durations{n} = dur_target(t);               end    
%%                
        pmod(n).name{1} = 'Down*invest(-1)'; 
        allBet=Bet1.*i_2  +Bet2.*i_3;
        pmod(n).param{1} = -Down(i(:,n)).*allBet(i(:,n)); %where invest(i) comes from the previous block
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
if ~isempty(find(group1==Subj, 1))

        outdir = fullfile(statdir,'\FFX','group1', sprintf('Subject%02d', Subj), 'LOG'); 
else
        outdir = fullfile(statdir,'\FFX','group2', sprintf('Subject%02d', Subj), 'LOG'); 
end

                         
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
convec=vertcat(convec,ones(1,length(names)+totpar));
name_array=convec2name_array_param_2group(convec,names,npar,pmod);

%ffx jobs
ffx_jobmaker_2groups(statdir,datadir,name_array,convec,Subj,group1);  
end

rfx_jobmaker_fullfactorial_2groups(name_array,statdir)


end
