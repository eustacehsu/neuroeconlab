function kirby(subjectID,fileName)
% Kirby monetary choice task.  Presents 27-item task. User presses 1/2 to
% choose left and 6/7 to choose right.  
% command:
% kirby('subjectID','subjectID_kirby')
%
% 8/2013
%%%%%%%%%%%%%%%%%%%%
%% kirby design
kirby = fopen('kirby_trials.txt');
C = cell2mat(textscan(kirby,'%f %7.6f %f %f %f %f','Headerlines',1));
fclose(kirby);
Leftvals=C(:,3);
Rightvals=C(:,4);
kirbyk=C(:,2);
logk_kirby=log(kirbyk);
Delay=C(:,1);
post=C(:,3);
iamount=C(:,4);
DV=C(:,5);
mag=C(:,6);
kirbychoice=[];

nTrials = size(C,1);

%% Save records 
if nargin<1, subjectID='ls'; end
saveToFile ='Save';

if nargin<2
    saveToFile = questdlg('','Save Record?','Save','Display','None','Display');
end
fun=mfilename; direc=fileparts(which(fun));
if strcmp(saveToFile,'None')
    fidk=0;
elseif strcmp(saveToFile,'Display')
    fidk=1;
else
    if ~exist('fileName','var'), fileName='junk'; end
    fileName=sprintf('%s.rec',fileName);
    fileName=fullfile(direc, fileName);
    fidk=fopen(fileName,'w+');
end
fprintf(fidk,'Program: %s\n',which(fun));
fprintf(fidk,'Subject initials: %s\n',subjectID);

%% Make trial ordering

White=[255 255 255];
Yellow=[255 255 0];
RespKey={'1','2','6','7'};
width=1024; height=768; %this is kind of not useful
LAG=1;


%% Screen setup 
    
doublebuffer=1;
ScreenNumber=max(Screen('Screens'));
[w rect]=Screen('OpenWindow',ScreenNumber,0,[],32,doublebuffer+1);
HideCursor;
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);% enable alpha blending with proper blend function for drawing of smoothed points
[xyc(1) xyc(2)]=RectCenter(rect);
Screen('TextStyle',w,1); 
Screen('TextSize',w,55);
Screen('TextFont',w,'Times New Roman');
tasks='Press any key to start!';
DrawFormattedText(w, tasks, 'center', 'center', [255 255 255]);
Screen('Flip',w); 

%% Experiment 
startsec = mlTRSync(1,[],'KbCheck');
fprintf(fidk,'Start: %s, %s\n',datestr(now,'ddd'),datestr(now));
fprintf(fidk, '%s\n', 'trial damount iamount delay k ok RT');

endsec=startsec+LAG; 
WaitTill(endsec);

stat1=zeros(1,2);
stat3=zeros(1,2);
stat2=zeros(1,2);



j=0;

for i=1:(nTrials) 
    
    Priority(MaxPriority(w));
    startt=endsec; 
    
    if  post(i)>0      
            
       text=sprintf('$%g today',iamount(i));
       DrawFormattedText(w, text, width/2+270, 'center', White);
       Screen(w,'DrawLine', White, xyc(1), xyc(2)-60, xyc(1), xyc(2)+60);
       text=sprintf('$%g in %g days',DV(i),Delay(i));
       DrawFormattedText(w, text, width/2-150, 'center', White);
    elseif post(i)<0
       text=sprintf('$%g today',iamount(i));
       DrawFormattedText(w, text, width/2-150, 'center', White); 
       Screen(w,'DrawLine', White, xyc(1), xyc(2)-60, xyc(1), xyc(2)+60);
       text=sprintf('$%g in %g days',DV(i),Delay(i));
       DrawFormattedText(w, text, width/2+270, 'center', White);
   end
       
Stimdowntime=Screen('Flip',w,[],1);

%% record subjects choices  

    [key, rt]=WaitTill(Stimdowntime+4,RespKey,1); 
    
    if ~isempty(key) 
        RT=rt-Stimdowntime;
    elseif isempty(key)  
        text='Please Respond';
        DrawFormattedText(w, text, 'center', height/2+125, [255 255 255]);
        Screen('Flip',w,[],1);
        [key, rt]=WaitTill(Stimdowntime+15,RespKey,1);
    end       
    
    
 if ~isempty(key) 
     RT=rt-Stimdowntime;    
       
  if str2num(key)<5 && str2num(key)~=0;    %% left option selected 
                
      if post(i) > 0
           text=sprintf('$%g in %g days',DV(i),Delay(i));
           ok=2;
           okInd=2;
           
      elseif post(i) < 0
           text=sprintf('$%g today',iamount(i));
           ok=1;
           okInd=1;
      end
          
        
   j=j+1;
    
   DrawFormattedText(w, text, width/2-150, 'center', Yellow);
   
  end
    
     
   if str2num(key)>2 && str2num(key)~=0;   % right option 
               
         if post(i) < 0
           text=sprintf('$%g in %g days',DV(i),Delay(i));
           ok=2;
           okInd=2;           
         elseif post(i) > 0
           text=sprintf('$%g today',iamount(i));
           ok=1;
           okInd=1;
        end
               
    j=j+1;
       
   DrawFormattedText(w, text, width/2+270, 'center', Yellow);   % double scure choice 
   
   end
   
   t1=Screen('Flip',w,rt);
   WaitSecs(0.5);
   Screen('FillRect',w,[0 0 0]);
   Screen('Flip',w,t1+0.8);
   endsec=GetSecs+2;
   WaitTill(endsec);
   fprintf(fidk,'%d %d %d %d %5.4f %d %5.4f\n',i,DV(i),iamount(i),Delay(i),kirbyk(i),ok,RT);
   kirbychoice(end+1)=ok-1;
 
   if mag(i)==1
       stat1(okInd)=stat1(okInd)+1;
   elseif mag(i)==2
       stat2(okInd)=stat2(okInd)+1;
   else
       stat3(okInd)=stat3(okInd)+1;
   end
 end
end

        Screen('TextStyle',w,1); 
        Screen('TextSize',w,55);
        Screen('TextFont',w,'Times New Roman');
        tasks='Thanks! It is done!';
        DrawFormattedText(w, tasks, 'center', 'center', [255 255 255]);
        tf=Screen('Flip',w); 
        Screen('Flip',w,tf+10);
        figure(1);
        plot(log(kirbyk), kirbychoice,'b'); %log(ks) if we get rid of negative ks
        title('K value');

        fprintf(fidk,'Finish: %s\n', datestr(now));
        
        k1 = getk(stat1);
        fprintf(fidk, 'Final Kirby Small: %5.4f\n',k1);
        fprintf(fidk, 'Immediate Delay\n');
        fprintf(fidk,'%5.1f %5.1f\n', stat1);
        
        k2 = getk(stat2);
        fprintf(fidk, 'Final Kirby Medium: %5.4f\n',k2);
        fprintf(fidk, 'Immediate Delay\n');
        fprintf(fidk,'%5.1f %5.1f\n', stat2);
        k3 = getk(stat3);
        fprintf(fidk, 'Final Kirby Large: %5.4f\n',k3);
        fprintf(fidk, 'Immediate Delay\n');
        fprintf(fidk,'%5.1f %5.1f\n', stat3);
        
        
        Priority(0);
        Screen('CloseAll');
        fclose('all');
        
function kval = getk(choice)
    if choice == [0 9]
        kval = 0.00016;
    elseif choice == [1 8]
        kval = geomean([0.00016 0.0004]);
    elseif choice == [2 7]
        kval = geomean([0.0004 0.001]);
    elseif choice == [3 6]
        kval = geomean([0.001 0.0025]);
    elseif choice == [4 5]
        kval = geomean([0.0025 0.006]);
    elseif choice == [5 4]
        kval = geomean([0.006 0.016]);
    elseif choice == [6 3]
        kval = geomean([0.016 0.04]);
    elseif choice == [7 2]
        kval = geomean([0.04 0.1]);
    elseif choice == [8 1]
        kval = geomean([0.1 0.25]);
    elseif choice == [9 0]
        kval = 0.25;
    end
end
end
