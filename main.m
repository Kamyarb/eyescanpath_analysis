
%% Place this file in the main folder Task_oneSubjectVersion
close all
clear
trial_num = 35; %insert Trial No.
edf = read_edf(trial_num);
sample_rate = edf.RawEdf.RECORDINGS(2).sample_rate;



table = read_table(trial_num);
fullname = char(table.videoName(mod(trial_num, 40)));
[first_video,second_video,first_video_startingframe, ...
    second_video_startingframe,first_video_rot,second_video_rot,center_x,...
    center_y,type_of_trial ,video_name] = fileHandler(fullname);

total_rotation = table.rotAngle(mod(trial_num, 40));
first_video_rot = total_rotation + first_video_rot;
second_video_rot = second_video_rot + total_rotation;

v = VideoReader(strcat('./Data/videos_to_play/',type_of_trial , video_name));

video = VideoWriter(strcat('processed_', fullname));
video.FrameRate = 14;
open(video);




firstvideo_groundTruth_frameDetails = dir(sprintf('..\\Code\\jsons\\%d\\', first_video));
secondvideo_groundTruth_frameDetails = dir(sprintf('..\\Code\\jsons\\%d\\', second_video));


first_targets = cell2mat(num2cell(num2str(table.firstTargets(mod(trial_num,40)))));
second_targets = cell2mat(num2cell(num2str(table.secondTargets(mod(trial_num,40)))));


mapper_adjustment = getAdjustmentMapper();
[posx , posy] = finding_eye_position(trial_num, edf);


for num_frame = 1:v.NumFrames

    fname = sprintf('.\\Code\\jsons\\%d\\img%03d.json',first_video, first_video_startingframe + num_frame-1);
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    val = jsondecode(str);
    count_tar = 1;
    count_nontar = 1;
    for num_target = 1:length(val.shapes)
        adjust_values = mapper_adjustment(sprintf('%d', first_video));

      if any(first_targets == val.shapes(num_target).label)
          
          adjusted_coordination = val.shapes(num_target).points;
          adjusted_coordination(:,1) = adjusted_coordination(:,1) - adjust_values(1);
          adjusted_coordination(:,2) = adjusted_coordination(:,2) - adjust_values(2);
          shape = polyshape(adjusted_coordination(:,1),adjusted_coordination(:,2));
          rotated = rotate(shape , -first_video_rot, [center_x , center_y]);
          targets{count_tar} = reshape(rotated.Vertices.',1,[]);
          count_tar = count_tar +1;

      
      else

          adjusted_coordination = val.shapes(num_target).points;
          adjusted_coordination(:,1) = adjusted_coordination(:,1) - adjust_values(1);
          adjusted_coordination(:,2) = adjusted_coordination(:,2) - adjust_values(2);
          shape = polyshape(adjusted_coordination(:,1),adjusted_coordination(:,2));
          rotated = rotate(shape , -first_video_rot, [center_x ,center_y]);
          poses{count_nontar} = reshape(rotated.Vertices.',1,[]);
          count_nontar = count_nontar +1;
      end
      

      
    end

    frame = read(v,num_frame);
    frame = rgb2gray(frame);
    frame = rotation(frame , total_rotation);


    frame = insertShape(frame,"filled-polygon",poses,Opacity=0.1 , Color="blue");

    frame = insertShape(frame,"filled-polygon",targets,Color='red' , Opacity=0.7);

    fname = sprintf('.\\Code\\jsons\\%d\\img%03d.json', second_video , second_video_startingframe + num_frame-1);
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    val = jsondecode(str);
    count_tar = 1;
    count_nontar = 1;

    for num_target = 1:length(val.shapes)
        adjust_values = mapper_adjustment(sprintf('%d', second_video));
      if any(second_targets == val.shapes(num_target).label)
          
          adjusted_coordination = val.shapes(num_target).points;
          adjusted_coordination(:,1) = adjusted_coordination(:,1) - adjust_values(1);
          adjusted_coordination(:,2) = adjusted_coordination(:,2) - adjust_values(2);
          shape = polyshape(adjusted_coordination(:,1),adjusted_coordination(:,2));
          rotated = rotate(shape , -second_video_rot, [center_x , center_y]);
          targets{count_tar} = reshape(rotated.Vertices.',1,[]);
          count_tar = count_tar +1;
      
      else
          adjusted_coordination = val.shapes(num_target).points;
          adjusted_coordination(:,1) = adjusted_coordination(:,1) - adjust_values(1);
          adjusted_coordination(:,2) = adjusted_coordination(:,2) - adjust_values(2);
          shape = polyshape(adjusted_coordination(:,1),adjusted_coordination(:,2));
          rotated = rotate(shape , -second_video_rot, [center_x ,center_y]);
          poses{count_nontar} = reshape(rotated.Vertices.',1,[]);
          count_nontar = count_nontar +1;
      end
      

      
    end




    frame = insertShape(frame,"filled-polygon",poses,Opacity=0.1 , Color="cyan");

    frame = insertShape(frame,"filled-polygon",targets,Color='red' , Opacity=0.7);

    frame = insertShape(frame,"circle",[posx(num_frame) posy(num_frame) 5],LineWidth=2, Color='green');

    
    %% rotating the frame 
    
    imshow(frame)
    title(type_of_trial );
    M=getframe; 
    pause(1/v.FrameRate);
    writeVideo(video,frame);
    
end
movie(M)
close(video);


function [posx , posy] = finding_eye_position(trial_num, edf)

    t0 = find(ismember(edf.Events.Messages.info, ['MOT ',num2str(trial_num)]));
    t1 = find(ismember(edf.Events.Messages.info, ['MASK ',num2str(trial_num)]));
    t0 = edf.Events.Messages.time(t0);
    t1 = edf.Events.Messages.time(t1);
    posx = edf.Samples.posX(find(edf.Samples.time > t0,1): find(edf.Samples.time > t1,1)) - (1920 -660)/2;
    posy = edf.Samples.posY(find(edf.Samples.time > t0,1): find(edf.Samples.time > t1,1)) - (1080-660)/2 ;

    posx = posx(1:end/110:end , 1);
    posy = posy(1:end/110:end , 1);

    posx = fillmissing(posx , 'previous');
    posy = fillmissing(posy , 'previous');



end

function table = read_table(trial_num)
    if trial_num <40
        table = readtable('./Results_csv/Timo1.csv');
    elseif trial_num > 40 && trial_num <= 80
        table = readtable('./Results_csv/Timo2.csv');
         
    elseif trial_num > 80 && trial_num <= 120
        table = readtable('./Results_csv/Timo3.csv');
    else
        table = readtable('./Results_csv/Timo4.csv');
    end
end

function mapper_adjustment = getAdjustmentMapper()
    num_video = {'1' , '7' , '10'};
    adjust_1 = [90 5];
    adjust_7 = [25 25];
    adjust_10 = [25 25];
    valueset= {adjust_1 , adjust_7, adjust_10};
    mapper_adjustment = containers.Map(num_video,valueset);
end

function [first_video,second_video,first_video_startingframe, ...
    second_video_startingframe,first_video_rot,second_video_rot,center_x,...
    center_y, type_of_trial, just_name] = fileHandler(video_name)
    splitted_videoname = split(video_name, ',');
    type_of_trial = char(splitted_videoname(1));
    type_of_trial = type_of_trial(1:end-2);
    type_of_trial = strcat('/', type_of_trial, '/');
    just_name = char(splitted_videoname(2));
    splitted = split(just_name,'_');
    first_video = str2double(splitted(1));
    second_video = str2double(splitted(2));
    first_video_startingframe = str2double(splitted(3));
    second_video_startingframe = str2double(splitted(4));
    first_video_rot = str2double(splitted(5));
    second_video_rot = splitted(6);
    second_video_rot = str2double(regexp(char(second_video_rot),'\d*','Match'));
    second_video_rot = second_video_rot(1);
    center_x = 330;
    center_y = 330;

end




function edf = read_edf(trial_num)
    if trial_num <40
        edf = Edf2Mat('./Code/edf+files/pilot/Timo1.edf');
    elseif trial_num > 40 && trial_num <= 80
        edf = Edf2Mat('./Code/edf+files/pilot/Timo2.edf');
         
    elseif trial_num > 80 && trial_num <= 120
        edf = Edf2Mat('./Code/edf+files/pilot/Timo3.edf');
    else
        edf = Edf2Mat('./Code/edf+files/pilot/Timo4.edf');
    end
end

function rotated = rotation(frame, rotAngle)
    rotated = imrotate(frame, rotAngle, 'nearest' ,'crop');
    
    
    imageSize = size(rotated);
    ci = [330, 330, 315];    
    
    [xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2));
    rotated( xx.^2 + yy.^2 > ci(3)^2 ) = 128;
    
   
end