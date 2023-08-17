%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% >> Main Multiple Larvae tracking code By Shiva Kamkar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Cleaning
function []=MLTracking(sId, blck)

%% Opening
% Break and issue an eror message if the installed Psychtoolbox is not based on OpenGL or Screen() is not working properly.
AssertOpenGL;
% PsychDebugWindowConfiguration

%% Set Parameters
% Grey background:
background=[128, 128, 128];

% Draw fixation
barLength = 16; % in pixels
barWidth = 2; % in pixels
barColor = [255 255 255];
fixationDuration=2;

% Load necessary inforamtion
load RotationList.mat % list of rotations for all stimuli, similar for all subjects
load PlayingOrder.mat % the order of playing videos, similar for all subjects
load AllStimuliList.mat % Stimuli used for all subjects, similar again

% blck management
if(blck==0) % Training
    load practiceStimuli.mat
    load practicePlayingOrder.mat
    PlayingOrder=practicePlayingOrder;
    AllStimuliList=practiceStimuli;
    startCNT=1;
    stopCNT=4;
elseif(blck==1) % first 40 trials
    startCNT=1;
    stopCNT=40;
elseif(blck==2)% second 40 trials
    startCNT=41;
    stopCNT=80;
elseif(blck==3)% third 40 trials
    startCNT=81;
    stopCNT=120;
elseif(blck==4)% last 40 trials
    startCNT=121
    stopCNT=160;
end

%% Preparing Result File
fid = fopen(['..\..\Results\' sId '.txt'],'a'); % , 'w'
%write videoName firstTargets secondTargets clickedItemsfromFirstVid
%clickedItemsfromSecondVid respnseTimeFirstVid respnseTimeSecondVid rotAngle
fprintf(fid, '\nvideoName\trotAngle\tvideoLength\tfirstTargets\tsecondTargets\tclickedItemsfromFirstVid\tclickedItemsfromSecondVid\trespnseTimeFirstVid\trespnseTimeSecondVid\n');

% <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< should be corrected >>>>>>>>>>>>>>>>>
% Open onscreen window:
screen=max(Screen('Screens'));
[win, screenRect] = Screen('OpenWindow', screen, background);
ifi=Screen('GetFlipInterval', win);

%% Eyelink: start
dummymode=0;
if ~EyelinkInit(dummymode, 1)
    fprintf('Eyelink Init aborted.\n');
    Eyelink('Shutdown');
    return;
end
eye_used = -1;
el=EyelinkInitDefaults(win);
Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,DIAMETER'); % open file to record data to
edfFile=[sId '.edf'];
status= Eyelink('openfile',edfFile,1);
if status~= 0
   error('openfile error, status: ', status); 
end


Eyelink('trackersetup');
% start calibration and validation Press enter to exit
EyelinkDoTrackerSetup(el);

% start drift check
EyelinkDoDriftCorrect(el);

Eyelink('startrecording');
WaitSecs(1);
Eyelink('Message', 'SYNC  TIME');

disp('1');

if Eyelink( 'NewFloatSampleAvailable') > 0
    evt = Eyelink( 'NewestFloatSample');
    if eye_used ~= -1
        x = evt.gx(eye_used+1);
        y = evt.gy(eye_used+1);
    else % if we don't, first find eye that's   being tracked
        eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
%         if eye_used == el.BINOCULAR; % if both eyes are tracked
%             eye_used = el.RIGHT_EYE; % use left eye
%         end
    end
end


% Eyelink: end

% Make a trial for each file
for cnt=startCNT:stopCNT
    cnt
    
    % Displace mause to the corner to avoid any possible distraction
%     SetMouse(10,10); % ,win                                                                                                       
    
    % Rotate Image
    rotAngle=RotationList(cnt);
    rotMtx=[cos(deg2rad(rotAngle)) -sin(deg2rad(rotAngle));sin(deg2rad(rotAngle)) cos(deg2rad(rotAngle))];
    
    moviename = AllStimuliList{PlayingOrder(cnt)}{1};
    moviename=cell2mat(moviename);
    
    % Assign random duration to video: between 4.8 to 7.8 seconds
%     numOfFrames = 67+round(42*rand());
    numOfFrames=110;
    
    i1=strfind(moviename,'\');
    fprintf(fid, [AllStimuliList{PlayingOrder(cnt)}{3} ',' moviename(i1(end)+1:end) '\t' num2str(rotAngle) '\t' num2str(numOfFrames) '\t']);
    
    % Open movie file and retrieve basic info about movie:
    absPath='C:\Users\Eyelink\Desktop\Shiva\Task\Data\videos_to_play\';
    [movie movieduration fps imgw imgh] = Screen('OpenMovie', win, [absPath moviename(i1(end-1)+1:end)]);    
    
    % play the video at the center of the screen
    center=round([screenRect(3)/2 screenRect(4)/2]);
    playRect=SetRect(center(1)-imgw/2,center(2)-imgh/2,center(1)+imgw/2,center(2)+imgh/2);
    playRect=round(playRect);
    
    % Determine videos and related targets    
    Obj = VideoReader(moviename);
    firstFrame = read(Obj, 1);
    
    % Rotate Image change the size.
    firstFrame=uint8(imrot(firstFrame,rotAngle,128)); % << Rotate
    
     % Start Trial:start
    Eyelink('Message','TRIALID %d', cnt);
    mes=['start trial' num2str(cnt)];
    Eyelink('command','resord_status_messasge "%s"',mes);
    % Start Trial:end
    
    HideCursor(screen);    % disappear mouse
    
    %% Draw fixation (2 sec)
    W=center(1);
    H=center(2);  
    
    Eyelink('Message','FIXATION %d', cnt);
    
    Screen('FillRect', win, barColor,[ W-(barLength)/2 H-(barWidth)/2 W+(barLength)/2 H+(barWidth)/2]);
    Screen('FillRect', win, barColor ,[ W-(barWidth)/2 H-(barLength)/2 W+(barWidth)/2 H+(barLength)/2]);
    
    % Get the time that fixation starts
    tStart = Screen('Flip', win);
    tstart = Screen('Flip', win, tStart + fixationDuration- ifi,0);
    
    %% Cue presentation (totally 2 sec)
    Screen('PutImage', win, firstFrame, playRect);

    i2=strfind(moviename(i1(end):end),'_');
    i2=i2+i1(end)-1;
    i3=strfind(moviename,'.');
    
    firstVdo=str2num(moviename(i1(end)+1:i2(1)-1));
    secondVdo=str2num(moviename(i2(1)+1:i2(2)-1));
    ind1=str2num(moviename(i2(2)+1:i2(3)-1));
    ind2=str2num(moviename(i2(3)+1:i2(4)-1));
    rotA1=str2num(moviename(i2(4)+1:i2(5)-1));
    rotA2=str2num(moviename(i2(5)+1:i3(end)-1));
    
    tmp=AllStimuliList{PlayingOrder(cnt)}{2};
    firstTargets=[];
    secondTargets=[];
    for(ij=1:length(tmp))
        if(tmp(ij)<=4)
            firstTargets=[firstTargets tmp(ij)];
        else
            secondTargets=[secondTargets tmp(ij)-4];
        end
    end

    % saveText
    if(size(firstTargets,2)==0)
        fprintf(fid, '0');
    end
    for(u=1:size(firstTargets,2))
        fprintf(fid, num2str(firstTargets(u)));
    end
    fprintf(fid, '\t');
    if(size(secondTargets,2)==0)
        fprintf(fid, '0');
    end
    for(u=1:size(secondTargets,2))
        fprintf(fid, num2str(secondTargets(u)));
    end
    fprintf(fid, '\t');
    
    firstTargetMsk=trackingGT(firstTargets,ind1,[size(firstFrame,1) size(firstFrame,2)],firstVdo);
    secondTargetMsk=trackingGT(secondTargets,ind2,[size(firstFrame,1) size(firstFrame,2)],secondVdo);
    firstTargetMsk=uint8(imrot(firstTargetMsk,rotA1+rotAngle,0));
    secondTargetMsk=uint8(imrot(secondTargetMsk,rotA2+rotAngle,0));
          
    firstGT=firstFrame;
    firstGT(:,:,1)=max(100*firstTargetMsk,firstFrame(:,:,1));
    firstGT(:,:,1)=max(100*secondTargetMsk,firstGT(:,:,1));
    tic
    
    Eyelink('Message','CUE %d', cnt);
    subCueDuration=0.23; % This is set by experience to make the total cue presentation phase not to exeed from 2 seconds
    for(i=1:5)
        Screen('PutImage', win, firstGT, playRect);
        %         Screen('glTranslate', win, -100, -100);
        %         Screen('glRotate', win, rotAngle, 1, 0 ,0);
        %         Screen('glTranslate', win, center(1), center(2));
        tStart=Screen('Flip', win, tStart+subCueDuration-ifi,0);
        Screen('PutImage', win, firstFrame, playRect);
        tStart=Screen('Flip', win, tStart+subCueDuration-ifi,0);
    end
    disp(['cue presentation time= ' num2str(toc)]);
    
    %% Play video
    
    %     fprintf('Movie1: %s  : %f seconds duration, %f fps...\n', moviename, movieduration, fps);
    
    Eyelink('Message','MOT %d', cnt);
    
    PlayVideo(win, playRect, movie, numOfFrames, rotAngle);
    
    
    %% Mask presentation
    
    Eyelink('Message','MASK %d', cnt);
    
    numOfFrames1=numOfFrames+ind1-1;
    numOfFrames2=numOfFrames+ind2-1;
    
    firstCompleteMsk=trackingGT([1:4],numOfFrames1,[size(firstFrame,1) size(firstFrame,2)],firstVdo);
    secondCompleteMsk=trackingGT([1:4],numOfFrames2,[size(firstFrame,1) size(firstFrame,2)],secondVdo);
    firstCompleteMsk=uint8(imrot(firstCompleteMsk,rotA1,0));
    secondCompleteMsk=uint8(imrot(secondCompleteMsk,rotA2,0));
    
    Mask=firstCompleteMsk+secondCompleteMsk;
    Mask=max(128,Mask);
    Mask=imrot(Mask,rotAngle,128); %>>>>>> Rotate
    
    Screen('DrawText', win , 'Left click to select', 100, 100, [0 0 0]);
    Screen('DrawText', win , 'Right click to save the result ', 100, 130, [0 0 0]);
    Screen('DrawText', win , 'Press space to rest ', 100, 160, [0 0 0]);
    Screen('PutImage', win, Mask, playRect);
    tStart=Screen('Flip', win);
    
    % >>>>>>>>>>>>>>> Duraton for waiting in mask presentaion 10 seconds
    tic
    %% Get response: User expected to click on non-overlapped part
    
    %     KbName('UnifyKeyNames');
    %     spc=KbName('SPACE');
    %     result=zeros(size(lastGT(:,:,1)));
    %     markerSz=4;
    igHist=zeros(playRect(4)-playRect(2),playRect(3)-playRect(1));
    clckItm=[];
    SetMouse(center(1),center(2));%,win
    ShowCursor(screen);    % disappear mouse
%     ShowCursor();
    th=20; % 7 seconds time limitation for choosing targets
    clTm=tic;
    while(1)
        [clicks,x,y,whichButton] = GetClick(win,0,th,clTm);  
        Tm=toc(clTm);
        if (whichButton~=1)||toc(clTm)>th % time out || Rest or Left click -> Save results and Exit
%             if(clicks==0)||(clicks==1000)||(whichButton~=1) % time out || Rest or Left click -> Save results and Exit
            % save targets label from first video
            firstExist=false;
            for(u=1:size(clckItm,1))
                if(clckItm(u,2)==1)
                    fprintf(fid, num2str(clckItm(u,1)));
                    firstExist=true;
                end
            end
            if(firstExist==false)
                fprintf(fid, '0');
            end
            fprintf(fid, '\t');
            % save targets label from second video
            secondExist=false;
            for(u=1:size(clckItm,1))
                if(clckItm(u,2)==2)
                    fprintf(fid, num2str(clckItm(u,1)));
                    secondExist=true;
                end
            end
            if(secondExist==false)
                fprintf(fid, '0');
            end
            fprintf(fid, '\t');
            % save targets time from first video
            firstExist=false;
            for(u=1:size(clckItm,1))
                if(clckItm(u,2)==1)
                    fprintf(fid, [num2str(clckItm(u,3)) ' ']);
                    firstExist=true;
                end
            end
            if(firstExist==false)
                fprintf(fid, '0');
            end
            fprintf(fid, '\t');
            % save targets time from second video
            secondExist=false;
            for(u=1:size(clckItm,1))
                if(clckItm(u,2)==2)
                    fprintf(fid, [num2str(clckItm(u,3)) ' ']);
                    secondExist=true;
                end
            end
            if(secondExist==false)
                fprintf(fid, '0');
            end
            if(clicks==1000) % Space is pressed to Rest
                while(1)
                    keyIsDown=0;
                    secs=0;
                    keyCode=0;
                    [keyIsDown,secs,keyCode] = KbCheck;
                    if keyCode(KbName('space'))==1
                        break;
                    end
                end
            end
            break;  
        end
        % Update point by rotating back
        x=x-center(1); % change coordinate to center of screen
        y=center(2)-y;
        mr=[x y]*rotMtx;% rotate back
        mr=round(mr);
        x=mr(1);
        y=mr(2); 
        x=x+center(1);  
        y=center(2)-y;

        x=x-playRect(1);
        y=y-playRect(2);
        % Color the seleted objects from
        [lb,ig]=findLabel([x y],numOfFrames1,[playRect(4)-playRect(2),playRect(3)-playRect(1)],firstVdo,rotA1);
        if(lb>0) % A real item is tracked (toggle clicked object)
            if(igHist(y,x)==0) % select
                clckItm=[clckItm; lb, 1, Tm]; % save both label and time
                ig=ig*(-255);
                igHist=min(igHist,ig);
            elseif(igHist(y,x)==-255) % unselect
                clckItm(find(clckItm(:,1)==lb),:)=[];
                ig=ig*(255);
                igHist=igHist+ig;
            end
            
            Screen('DrawText', win , 'Left click to select', 100, 100, [0 0 0]);
            Screen('DrawText', win , 'Right click to save the result ', 100, 130, [0 0 0]);
            Screen('DrawText', win , 'Press space to rest ', 100, 160, [0 0 0]);
            Screen('PutImage', win, uint8(double(Mask)+imrot(igHist,rotAngle,0)), playRect); % rotate <<
            Screen('Flip', win);
        end
        if(lb==0)
            [lb,ig]=findLabel([x y],numOfFrames2,[playRect(4)-playRect(2),playRect(3)-playRect(1)],secondVdo,rotA2);
            if(lb>0) % A real item is tracked (toggle clicked object)
                if(igHist(y,x)==0) % select
                    clckItm=[clckItm; lb, 2, Tm]; % save both label and time
                    ig=ig*(-255);
                    igHist=min(igHist,ig);
                elseif(igHist(y,x)==-255) % unselect
                    clckItm(find(clckItm(:,1)==lb),:)=[];
                    ig=ig*(255);
                    igHist=igHist+ig;
                end
                
                Screen('DrawText', win , 'Left click to select', 100, 100, [0 0 0]);
                Screen('DrawText', win , 'Right click to save the result ', 100, 130, [0 0 0]);
                Screen('DrawText', win , 'Press space to rest ', 100, 160, [0 0 0]);
                Screen('PutImage', win, uint8(double(Mask)+imrot(igHist,rotAngle,0)), playRect);
                Screen('Flip', win);
            end
        end
    end
    % End Trial:start
    Eyelink('Message','TRIAL_RESULT', cnt);
    Eyelink('Message','trial OK');
    % End Trial:end
    %% Save the result
    fprintf(fid, '\n');
end
fprintf(fid, '\n');
Screen('FillRect', win, [128 128 128]);
Screen('DrawText', win , 'Thank you!', center(1)-50, center(2), [0 0 0]);
tStart = Screen('Flip', win);

%% Closing
% Close screens.

fclose(fid);

%******************* Eyelink: start
Eyelink('StopRecording');
Eyelink('CloseFile');
try
    fprintf('Receiving data file ''%s''\n', [sId '.edf'] );
    status=Eyelink('ReceiveFile', edfFile, pwd, 1);

    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(edfFile, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', [sId '.edf'], pwd );
    end
catch rdf
    fprintf('Problem receiving data file ''%s''\n', [sId '.edf'] );
    rdf;
end
Eyelink('Shutdown');
%******************* Eyelink: end

sca;

end