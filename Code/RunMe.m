%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% >> RunMe By Shiva Kamkar
% >> To start the program, set the correct block and subject name. Then,
% >> simply run!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pause(2)

clear all
close all
clc 
all=tic

blck=0; %for test            
% blck=1; %for first block
% blck=2; %for second block  
% blck=3; %for third block  
% blck=4; %for forth block
             
subName=['pupil7' num2str(blck)];

MLTracking(subName,blck);

 
toc(all)/60                                 