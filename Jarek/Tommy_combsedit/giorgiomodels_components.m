%% definition of each regressor to compose giorgio models
%dur defines the length of the period of interest
%% Outcomes condtional on winning
%outcome of the first choice
i_1 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & winout1 == 1;
% outcome of the second choice        
i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & winout2 == 1;
% outcome of the third choice        
i_3 = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & winout3 == 1;
% outcome of the three choices        
i_3 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & winout??? == 1; %which is the right one for the 123 condition probably all three
%% Outcomes condtional on loosing
%outcome of the first choice
i_1 = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & winout1 == 0;
% outcome of the second choice        
i_2 = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & winout2 == 0;
% outcome of the third choice        
i_3 = (Subject == Subj) & strcmp(Event, 'outcome_3') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & winout3 == 0;
% outcome of the three choices        
i_3 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ... %%index corresponding to subject subj event evaluation_1 periods 1:24
            ismember(Period, Runs{iRuns}) & winout??? == 0; %which is the right one for the 123 condition probably all three                     
        
%% residual
        j = 1;% id of the regressor which it refers to 
        names{n} = [names(j),'_Residual'];
        onsets{n} = Onset(i(:,j)) + dur; % starts at the end of the corresponding regressor
        durations{n} = Duration(i(:,j)) - dur_target; %last the length of the corresponding regressor - dur
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
%% (eval1+eval12+eval3)
        n = n+1;
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
%% (eval_1+eval_2+eval_3+eval_123)
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
        durations{n} = dur_control;
%% (eval_1+eval_123)During outcome models
        n = n+1;
        names{n} = 'evaluation;3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_1') & ...
            ismember(Period, Runs{iRuns});
        i_123 = (Subject == Subj) & strcmp(Event, 'evaluation_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_control;
        
%% decision based components
%% decision1
        n = n+1;
        names{n} = 'decision;1'; % name of the regressors
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_1') & ... %%index corresponding to subject subj event decision_1 periods 1:24
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n)); %the n regressor starts in the periods indicated by, namely those correspondin to the right subject right even and member of the current period
        durations{n} = dur; %the duration of the event, this vector is long as the amount of non-zero elements in Onset        
%% decision2
        n = n+1;
        names{n} = 'decision;2';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur;
%% decision3
        n = n+1;
        names{n} = 'decision;3';
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur;
%% decision123
        n = n+1;
        names{n} = 'decision;123'; %guess this means
        i(:,n) = (Subject == Subj) & strcmp(Event, 'decision_123') & ...
            ismember(Period, Runs{iRuns});
        onsets{n} = Onset(i(:,n));
        durations{n} = dur;
%% (decision1+decision12+decision3)
        n = n+1;
        names{n} = 'decision;1+2+3';
        i_1 = (Subject == Subj) & strcmp(Event, 'decision_1') & ...
            ismember(Period, Runs{iRuns});
        i_2 = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = dur;
%% (decision12+decision3)
        n = n+1;
        names{n} = 'decision;1+2+3';
        i_2 = (Subject == Subj) & strcmp(Event, 'decision_2') & ...
            ismember(Period, Runs{iRuns});
        i_3 = (Subject == Subj) & strcmp(Event, 'decision_3') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_2 | i_3 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = dur;
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
        durations{n} = dur_control;
%% Outcomes component
%% (outcome_3+outcome_123) during eval models
        n = n+1;
        names{n} = 'outcome;3+123';
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = dur_control;

%% (outcome1+outcome2+outcome_3+outcome_123)=(eval2+eval3+outcome_3+outcome_123) during decisions models
        n = n+1;
        names{n} = 'outcome;1+2+3+123';
        i_1   = (Subject == Subj) & strcmp(Event, 'evaluation_2') & ...
            ismember(Period, Runs{iRuns});
        i_2   = (Subject == Subj) & strcmp(Event, 'evaluation_3') & ...
            ismember(Period, Runs{iRuns});
        i_3   = (Subject == Subj) & strcmp(Event, 'outcome_3') & ...
            ismember(Period, Runs{iRuns});      
        i_123 = (Subject == Subj) & strcmp(Event, 'outcome_123') & ...
            ismember(Period, Runs{iRuns});        
        i(:,n)   = i_1 | i_2 | i_3 | i_123 ;
        onsets{n} = Onset(i(:,n));
        durations{n} = dur;

 %% economic model components
 
 %% (GAIN-LOSS) variable
        pmod(n).name{1} = 'Up-Down'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n));
        pmod(n).poly{1} = 1; 
%%   Gain and Loss Variables, loss is considered to be positive sucht that positive beta implies brain activity positevely correlated with losses
        pmod(n).name{1} = 'Up'; 
        pmod(n).param{1} = Up(i(:,n));
        pmod(n).poly{1} = 1; 
        pmod(n).name{2} = 'Down';
        pmod(n).param{2} = abs(Down(i(:,n)));
        pmod(n).poly{2} = 1;
%%  Investment variable %%% This variable need to be fixed!!!
%4Dalton, here I need somehow to specify how much the subject invested during the trials associated with time i
%indipendently of this parameter being associated to an
%evaluation/decision/outcome situation. I can't really understand how the
%variables Bet1 Bet2 and Bet3 are done, so may yuou please fix this one?
        pmod(n).name{1} = 'invest1'; 
        pmod(n).param{1} = bet1(i(:,n));
        pmod(n).poly{1} = 1; 
        %%
        pmod(n).name{1} = 'invest2'; 
        pmod(n).param{1} = bet2(i(:,n));
        pmod(n).poly{1} = 1; 
        %%
        pmod(n).name{1} = 'invest3'; 
        pmod(n).param{1} = bet3(i(:,n));
        pmod(n).poly{1} = 1; 
        
%%  Investment*(GAIN-LOSS) Variable for 123 and 1
  pmod(n).name{1} = '(Up-Down)*invest'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n))*bet1(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
        %%  Investment*(GAIN-LOSS) Variable for 2
  pmod(n).name{1} = '(Up-Down)*invest'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n))*bet2(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
        %%  Investment*(GAIN-LOSS) Variable fior 3
  pmod(n).name{1} = '(Up-Down)*invest'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n))*bet3(i(:,n)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
 %%  Investment*(GAIN-LOSS) Variable for 1+2+3
  pmod(n).name{1} = '(Up-Down)*invest'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n))*(bet1(i_1)+bet1(i_2)+bet1(i_3)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1; 
%%  Investment*(GAIN-LOSS) Variable for 1+2+3
  pmod(n).name{1} = '(Up-Down)*invest'; 
        pmod(n).param{1} = Up(i(:,n))+Down(i(:,n))*(bet1(i_2)+bet1(i_3)); %where invest(i) comes from the previous block
        pmod(n).poly{1} = 1;        

