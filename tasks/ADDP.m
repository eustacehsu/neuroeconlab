function ADDP(subjectID,fileName)
% modified by Eustace Hsu, 8/2013
% text display for this version optimized for MacBook Pro 15"

%% Set up variables 
ks=[];
ks(1)=.0003;% k for small amounts from behavioral study

km=[];
km(1)=0.0006; % k for medium amounts 

nTrials=80;
TargetDispTime=0.5;
FeedbackDispTime=0.5;
LAG=2;% lag before main experiment 
TRIAL_DURATION=4;


White=[255 255 255];
Yellow=[255 255 0];
ppd=42; % pixels per degree
shapesize=2.8*ppd;
RespKey={'1','2','6','7'};
width=1024; height=768; hz=60;
shaperect=CenterRect([0 0 shapesize shapesize],[0 0 width height-10]);

stat1=zeros(3,1);
stat2=zeros(3,1);

%% Save recods 
if nargin<1, subjectID='ls'; end
saveToFile ='Save';
if nargin<2
    saveToFile = questdlg('','Save Record?','Save','Display','None','Display');
end
fun=mfilename; direc=fileparts(which(fun));
if strcmp(saveToFile,'None')
    fid=0;
elseif strcmp(saveToFile,'Display')
    fid=1;
else
    if ~exist('fileName','var'), fileName='junk'; end
    fileName=sprintf('%s_%s.rec',subjectID,fileName);
    fileName=fullfile(direc, fileName);
    makeCopy4existFile(fileName);
    fid=fopen(fileName,'w+');
end

fprintf(fid,'Program: %s\n',which(fun));
fprintf(fid,'ClockRandSeed: %10.0f\n',ClockRandSeed);
fprintf(fid,'Subject initials: %s\n',subjectID);


%% Design 

HDrange=[46 60];
meanHD=53;
while 1, HD=round(HDrange(1)+(HDrange(2)-HDrange(1)).*rand((nTrials/2-1),1));
    if mean(HD)==meanHD, break; end; end

LDrange=[21 35];
meanLD=28;
while 1, LD=round(LDrange(1)+(LDrange(2)-LDrange(1)).*rand((nTrials/2-1),1));
    if mean(LD)==meanLD, break; end; end

delay=120;

DV=[HD;LD];
DV=Shuffle(DV);
DV=[53;28;DV];

iamount=[];
iamount(1)=floor(53/(1+km(1)*delay))+1;
iamount(2)=floor(28/(1+ks(1)*delay))+1;


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
tasks='Experiment will start soon!\n \n Press any key to start!';
DrawFormattedText(w, tasks, 'center', 'center', [255 255 255]);
Screen('Flip',w); 

%% Experiment 
startsec = mlTRSync(1,[],'KbCheck');
fprintf(fid,'Start: %s, %s\n',datestr(now,'ddd'),datestr(now));
fprintf(fid, '%s\n', 'trial damount iamount k ok');

endsec=startsec+LAG; 
WaitTill(endsec);

post=ones(nTrials,1);
post(1:round(nTrials/2))=-1;
post=Shuffle(post);


stat1=zeros(2,1);
stat2=zeros(2,1);

j=1;
k=1;
RT=0;

for i=1:2
    Priority(MaxPriority(w));
    startt=endsec; endsec=endsec+TRIAL_DURATION; %is this necessary?
    
    if  post(i)>0
            Screen('TextStyle',w,1); 
            Screen('TextSize',w,50);
            Screen('TextFont',w,'Times New Roman');
            text=sprintf('$%g today',iamount(i));
            DrawFormattedText(w, text, [width/2+270*post(i)], 'center', White);
    
            Screen(w,'DrawLine', White, xyc(1), xyc(2)-60, xyc(1), xyc(2)+60);
    
            Screen('TextStyle',w,1); 
            Screen('TextSize',w,50);
            Screen('TextFont',w,'Times New Roman');
            text=sprintf('$%g in 120 days',DV(i));
            DrawFormattedText(w, text, [width/2-150*post(i)], 'center', White);
    else

            Screen('TextStyle',w,1);
            Screen('TextSize',w,50);
            Screen('TextFont',w,'Times New Roman');
            text=sprintf('$%g today',iamount(i));
            DrawFormattedText(w, text, [width/2+150*post(i)], 'center', White); 
    
            Screen(w,'DrawLine', White, xyc(1), xyc(2)-60, xyc(1), xyc(2)+60);
    
            Screen('TextStyle',w,1); 
            Screen('TextSize',w,50);
            Screen('TextFont',w,'Times New Roman');
            text=sprintf('$%g in 120 days',DV(i));
            DrawFormattedText(w, text, [width/2-270*post(i)], 'center', White);
        end
    
    %record response
    t0=Screen('Flip',w,[],1);
    [key, rt]=WaitTill(t0+4,RespKey,1);
    
    %please respond feedback if there is no response after 5s  
    
    if ~isempty(key) 
        RT=0;
        
    elseif isempty(key)  
        
        Screen('TextStyle',w,1); 
        Screen('TextSize',w,65);
        Screen('TextFont',w,'Times New Roman');
        text='Please Respond';
        DrawFormattedText(w, text, 'center', [height/2+125], [255 255 255]);
        Screen('Flip',w,[],1);
        [key, rt]=WaitTill(endsec,RespKey,1);
        
   end       
     
     if isempty(key)

          RT=15;
%          Screen('TextStyle',w,1); 
%          Screen('TextSize',w,65);
%          Screen('TextFont',w,'Times New Roman');
%          text='Please Respond';
%          DrawFormattedText(w, text, 'center', [height/2+125], [255 0 0]);
%          Screen('Flip',w,[],1);
          [key, rt]=WaitTill(endsec+RT,RespKey,1);
     else
          RT=0;
     end
     
     
       
  if str2num(key)<5 && str2num(key)~=0;
     if i==1
         if post(i)>0
              Screen('TextStyle',w,1); 
              Screen('TextSize',w,50);
              Screen('TextFont',w,'Times New Roman');
              text=sprintf('$%g in 120 days',DV(i));
              DrawFormattedText(w, text, [width/2-150*post(i)], 'center', Yellow);
              km(end+1)=km(end)*10^(-1/4);
              ok=2;
              okInd=2;
         else
              Screen('TextStyle',w,1);
              Screen('TextSize',w,50);
              Screen('TextFont',w,'Times New Roman');
              text=sprintf('$%g today',iamount(i));
              DrawFormattedText(w, text, [width/2+150*post(i)], 'center', Yellow); 
              km(end+1)=km(end)*10^(1/4);
              ok=1;
              okInd=1;
         end
     else
         if post(i)>0
              Screen('TextStyle',w,1); 
              Screen('TextSize',w,50);
              Screen('TextFont',w,'Times New Roman');
              text=sprintf('$%g in 120 days',DV(i));
              DrawFormattedText(w, text, [width/2-150*post(i)], 'center', Yellow);
              ks(end+1)=ks(end)*10^(-1/4);
              ok=2;
              okInd=2;
         else
              Screen('TextStyle',w,1);
              Screen('TextSize',w,50);
              Screen('TextFont',w,'Times New Roman');
              text=sprintf('$%g today',iamount(i));
              DrawFormattedText(w, text, [width/2+150*post(i)], 'center', Yellow); 
              ks(end+1)=ks(end)*10^(1/4);
              ok=1;
              okInd=1;
         end
         
         if DV(i+1)<40
         iamount(end+1)=floor(DV(i+1)/(1+ks(end)*delay))+1;
         else
         iamount(end+1)=floor(DV(i+1)/(1+km(end)*delay))+1; 
         end
      
         
     end
     
         if i==1

         t0=Screen('Flip',w,rt);
         Screen('FillRect',w,[0 0 0]);
         Screen('Flip',w,t0+0.5);
         stat1(okInd)=stat1(okInd)+1;
         WaitTill(endsec);
         fprintf(fid,'%d %d %d %5.4f %d\n',i,DV(i),iamount(i),km(end-1),ok);
         else
         t0=Screen('Flip',w,rt);
         Screen('FillRect',w,[0 0 0]);
         Screen('Flip',w,t0+0.5);
         stat2(okInd)=stat2(okInd)+1;
         WaitTill(endsec);
         fprintf(fid,'%d %d %d %5.4f %d\n',i,DV(i),iamount(i),ks(end-1),ok);   
         end
         
  end


     if str2num(key)>5
       if i==1
         if post(i)<0
             Screen('TextStyle',w,1); 
             Screen('TextSize',w,50);
             Screen('TextFont',w,'Times New Roman');
             text=sprintf('$%g in 120 days',DV(i));
             DrawFormattedText(w, text, [width/2-270*post(i)], 'center', Yellow);
             km(end+1)=km(end)*10^(-1/4);
             ok=2;
             okInd=2;
         else
             Screen('TextStyle',w,1); 
             Screen('TextSize',w,50);
             Screen('TextFont',w,'Times New Roman');
             text=sprintf('$%g today',iamount(i));
             DrawFormattedText(w, text, [width/2+270*post(i)], 'center', Yellow);
             km(end+1)=km(end)*10^(1/4);
             ok=1;
             okInd=1;
         end
       else
           if post(i)<0
             Screen('TextStyle',w,1); 
             Screen('TextSize',w,50);
             Screen('TextFont',w,'Times New Roman');
             text=sprintf('$%g in 120 days',DV(i));
             DrawFormattedText(w, text, [width/2-270*post(i)], 'center', Yellow);
             ks(end+1)=ks(end)*10^(-1/4);
             ok=2;
             okInd=2;
         else
             Screen('TextStyle',w,1); 
             Screen('TextSize',w,50);
             Screen('TextFont',w,'Times New Roman');
             text=sprintf('$%g today',iamount(i));
             DrawFormattedText(w, text, [width/2+270*post(i)], 'center', Yellow);
             ks(end+1)=ks(end)*10^(1/4);
             ok=1;
             okInd=1;
         end

         if DV(i+1)<40
         iamount(end+1)=floor(DV(i+1)/(1+ks(end)*delay))+1;
         else
         iamount(end+1)=floor(DV(i+1)/(1+km(end)*delay))+1; 
         end
      
       end


         if i==1

         t0=Screen('Flip',w,rt);
         Screen('FillRect',w,[0 0 0]);
         Screen('Flip',w,t0+0.5);
         stat1(okInd)=stat1(okInd)+1;
         WaitTill(endsec);
         fprintf(fid,'%d %d %d %5.4f %d\n',i,DV(i),iamount(i),km(end-1),ok);
         else
         t0=Screen('Flip',w,rt);
         Screen('FillRect',w,[0 0 0]);
         Screen('Flip',w,t0+0.5);
         stat2(okInd)=stat2(okInd)+1;
         WaitTill(endsec);
         fprintf(fid,'%d %d %d %5.4f %d\n',i,DV(i),iamount(i),ks(end-1),ok);   
         end
         
     end
end

     
    


for i=3:nTrials
    
Priority(MaxPriority(w));
startt=endsec; endsec=endsec+TRIAL_DURATION;

    if DV(i)>40  % medium amount
        j=j+1;
    else
        k=k+1;
    end
    
        if  post(i)>0
            Screen('TextStyle',w,1); 
            Screen('TextSize',w,50);
            Screen('TextFont',w,'Times New Roman');
            text=sprintf('$%g today',iamount(i));
            DrawFormattedText(w, text, [width/2+270*post(i)], 'center', White);
    
            Screen(w,'DrawLine', White, xyc(1), xyc(2)-60, xyc(1), xyc(2)+60);
    
            Screen('TextStyle',w,1); 
            Screen('TextSize',w,50);
            Screen('TextFont',w,'Times New Roman');
            text=sprintf('$%g in 120 days',DV(i));
            DrawFormattedText(w, text, [width/2-150*post(i)], 'center', White);
        else

            Screen('TextStyle',w,1);
            Screen('TextSize',w,50);
            Screen('TextFont',w,'Times New Roman');
            text=sprintf('$%g today',iamount(i));
            DrawFormattedText(w, text, [width/2+150*post(i)], 'center', White); 
    
            Screen(w,'DrawLine', White, xyc(1), xyc(2)-60, xyc(1), xyc(2)+60);
    
            Screen('TextStyle',w,1); 
            Screen('TextSize',w,50);
            Screen('TextFont',w,'Times New Roman');
            text=sprintf('$%g in 120 days',DV(i));
            DrawFormattedText(w, text, [width/2-270*post(i)], 'center', White);
        end
    
    %record response
    t0=Screen('Flip',w,[],1);
    [key, rt]=WaitTill(t0+4,RespKey,1);
    
    %please respond feedback if there is no response after 5s  
    
    
    if ~isempty(key) 
        RT=0;
        
    elseif isempty(key)  
        
%        Screen('TextStyle',w,1); 
%        Screen('TextSize',w,65);
%        Screen('TextFont',w,'Times New Roman');
%        text='Please Respond';
%        DrawFormattedText(w, text, 'center', [height/2+125], [255 255 255]);
%        Screen('Flip',w,[],1);
%        [key, rt]=WaitTill(endsec,RespKey,1);
        
   end       
     
     if isempty(key)

           RT=15;
 %         Screen('TextStyle',w,1); 
 %         Screen('TextSize',w,65);
 %         Screen('TextFont',w,'Times New Roman');
 %         text='Please Respond';
 %         DrawFormattedText(w, text, 'center', [height/2+125], [255 0 0]);
 %         Screen('Flip',w,[],1);
          [key, rt]=WaitTill(endsec+RT,RespKey,1);
     else
          RT=0;
     end

   if DV(i)>40
       
     if str2num(key)<5 && str2num(key)~=0;
         if post(i)>0
              Screen('TextStyle',w,1); 
              Screen('TextSize',w,50);
              Screen('TextFont',w,'Times New Roman');
              text=sprintf('$%g in 120 days',DV(i));
              DrawFormattedText(w, text, [width/2-150*post(i)], 'center', Yellow);
              km(end+1)=km(end)*10^(-1/4);
              ok=2;
              okInd=2;
         else
              Screen('TextStyle',w,1);
              Screen('TextSize',w,50);
              Screen('TextFont',w,'Times New Roman');
              text=sprintf('$%g today',iamount(i));
              DrawFormattedText(w, text, [width/2+150*post(i)], 'center', Yellow); 
              km(end+1)=km(end)*10^(1/4);
              ok=1;
              okInd=1;
         end
         
         if DV(i+1)>40
         iamount(end+1)=floor(DV(i+1)/(1+km(end)*delay))+1;
         else
         iamount(end+1)=floor(DV(i+1)/(1+ks(end)*delay))+1;
         end
         
         t0=Screen('Flip',w,rt);
         Screen('FillRect',w,[0 0 0]);
         Screen('Flip',w,t0+0.5);
         stat1(okInd)=stat1(okInd)+1;
         WaitTill(endsec);
         fprintf(fid,'%d %d %d %5.4f %d\n',i,DV(i),iamount(i),km(end-1),ok);
     end
     
     if str2num(key)>5
         if post(i)<0
             Screen('TextStyle',w,1); 
             Screen('TextSize',w,50);
             Screen('TextFont',w,'Times New Roman');
             text=sprintf('$%g in 120 days',DV(i));
             DrawFormattedText(w, text, [width/2-270*post(i)], 'center', Yellow);
             km(end+1)=km(end)*10^(-1/4);
             ok=2;
             okInd=2;
         else
             Screen('TextStyle',w,1); 
             Screen('TextSize',w,50);
             Screen('TextFont',w,'Times New Roman');
             text=sprintf('$%g today',iamount(i));
             DrawFormattedText(w, text, [width/2+270*post(i)], 'center', Yellow);
             km(end+1)=km(end)*10^(1/4);
             ok=1;
             okInd=1;
         end

         if DV(i+1)>40
         iamount(end+1)=floor(DV(i+1)/(1+km(end)*delay))+1;
         else
         iamount(end+1)=floor(DV(i+1)/(1+ks(end)*delay))+1;
         end
         
            t0=Screen('Flip',w,rt);
            Screen('FillRect',w,[0 0 0]);
            Screen('Flip',w,t0+0.5);
            stat1(okInd)=stat1(okInd)+1;
            WaitTill(endsec);
            fprintf(fid,'%d %d %d %5.4f %d\n',i,DV(i),iamount(i),km(end-1),ok);
     end

   else
        
        if str2num(key)<5 && str2num(key)~=0;
         if post(i)>0
              Screen('TextStyle',w,1); 
              Screen('TextSize',w,50);
              Screen('TextFont',w,'Times New Roman');
              text=sprintf('$%g in 120 days',DV(i));
              DrawFormattedText(w, text, [width/2-150*post(i)], 'center', Yellow);
              ks(end+1)=ks(end)*10^(-1/4);
              ok=2;
              okInd=2;
         else
              Screen('TextStyle',w,1);
              Screen('TextSize',w,50);
              Screen('TextFont',w,'Times New Roman');
              text=sprintf('$%g today',iamount(i));
              DrawFormattedText(w, text, [width/2+150*post(i)], 'center', Yellow); 
              ks(end+1)=ks(end)*10^(1/4);
              ok=1;
              okInd=1;
         end
         
         if DV(i+1)>40
         iamount(end+1)=floor(DV(i+1)/(1+km(end)*delay))+1;
         else
         iamount(end+1)=floor(DV(i+1)/(1+ks(end)*delay))+1;
         end
         
         t0=Screen('Flip',w,rt);
         Screen('FillRect',w,[0 0 0]);
         Screen('Flip',w,t0+0.5);
         stat2(okInd)=stat2(okInd)+1;
         WaitTill(endsec);
         fprintf(fid,'%d %d %d %5.4f %d\n',i,DV(i),iamount(i),ks(end-1),ok);
     end
     
     if str2num(key)>5
         if post(i)<0
             Screen('TextStyle',w,1); 
             Screen('TextSize',w,50);
             Screen('TextFont',w,'Times New Roman');
             text=sprintf('$%g in 120 days',DV(i));
             DrawFormattedText(w, text, [width/2-270*post(i)], 'center', Yellow);
             ks(end+1)=ks(end)*10^(-1/4);
             ok=2;
             okInd=2;
         else
             Screen('TextStyle',w,1); 
             Screen('TextSize',w,50);
             Screen('TextFont',w,'Times New Roman');
             text=sprintf('$%g today',iamount(i));
             DrawFormattedText(w, text, [width/2+270*post(i)], 'center', Yellow);
             ks(end+1)=ks(end)*10^(1/4);
             ok=1;
             okInd=1;
         end

         if DV(i+1)>40
         iamount(end+1)=floor(DV(i+1)/(1+km(end)*delay))+1;
         else
         iamount(end+1)=floor(DV(i+1)/(1+ks(end)*delay))+1;
         end
         
            t0=Screen('Flip',w,rt);
            Screen('FillRect',w,[0 0 0]);
            Screen('Flip',w,t0+0.5);
            stat2(okInd)=stat2(okInd)+1;
            WaitTill(endsec);
            fprintf(fid,'%d %d %d %5.4f %d\n',i,DV(i),iamount(i),ks(end-1),ok);
     end
   end
     
     if j>=8 && k>=8 && (log10(max(ks(k-7:k)))-log10(min(ks(k-7:k))))<=0.5 && (log10(max(km(j-7:j)))-log10(min(km(j-7:j))))<=0.5 || GetSecs-startsec>480
        
        
        kmax1=max(km(j-7:j));
        kmin1=min(km(j-7:j));
        
        for w=j-7:j
            if km(w)~=kmax1 && km(w)~=kmin1
                kmedium1=km(w);
            elseif km(w)==kmax1
                kmax1=km(w);kmedium1=0;
                
            else
                kmin1=km(w);kmedium1=0;
            end
        end 
        
        if kmedium1~=0
        kmax1=max(km(j-7:j));
        kmin1=min(km(j-7:j));
        
        x=[kmax1 kmin1 kmedium1];
        km_final=geomean(x,2);
        
        else
        kmax1=max(km(j-7:j));
        kmin1=min(km(j-7:j));
        
        x=[kmax1 kmin1];
        km_final=geomean(x,2);
        
        end
        kmax2=max(ks(k-7:k));
        kmin2=min(ks(k-7:k));
        
        for z=k-7:k
            if ks(z)~=kmax2 && ks(z)~=kmin2
                kmedium2=ks(z);
            elseif ks(z)==kmax2
                kmax2=ks(z);kmedium2=0;
            else
                kmin2=ks(z);kmedium2=0;
            end
        end 
        
        if kmedium2~=0
        kmax2=max(ks(k-7:k));
        kmin2=min(ks(k-7:k));
        
        x=[kmax2 kmin2 kmedium2];
        ks_final=geomean(x,2);
        else
        kmax2=max(ks(k-7:k));
        kmin2=min(ks(k-7:k));
        
        x=[kmax2 kmin2];
        ks_final=geomean(x,2); 
        end
        
        break;
    end;
   
end

        figure(1);
        plot(km,'b');
        title('K value for medium amounts');
        figure(2);
        plot(ks,'r');
        title('K value for small amounts');
        
        fprintf(fid,'Finish: %s\n', datestr(now));
        fprintf(fid,'Final Km: %5.4f\n', km_final);
        fprintf(fid,'Immediate Delay\n');
        fprintf(fid,'%d %d\n',stat1);
        stat1=stat1*100./j;
        fprintf(fid,'Immediate Delay\n');
        fprintf(fid,'%5.1f %5.1f\n', stat1);
        fprintf(fid,'Final Ks: %5.4f\n', ks_final);
        fprintf(fid,'Immediate Delay\n');
        fprintf(fid,'%d %d\n',stat2);
        stat2=stat2*100./k;
        fprintf(fid,'Immediate Delay\n');
        fprintf(fid,'%5.1f %5.1f\n', stat2);
       
        ScreenNumber=max(Screen('Screens'));
        [w rect]=Screen('OpenWindow',ScreenNumber,0,[],32,2);% comment out?
        Screen('TextStyle',w,1); 
        Screen('TextSize',w,55);
        Screen('TextFont',w,'Times New Roman');
        tasks='Thanks! It is done!';
        DrawFormattedText(w, tasks, 'center', 'center', [255 255 255]);
        tf=Screen('Flip',w); 
        Screen('Flip',w,tf+5);
        
        Priority(0);
        Screen('CloseAll');
        fclose('all');
