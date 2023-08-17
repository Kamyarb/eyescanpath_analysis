close all
clear all
addpath edf-converter-master\
trial_num = 10 ; %insert Trial No.



%% Reading EDF files
% batch = 1;
% for i = 1:30
%     eval(sprintf('edf_%d_%d =read_edf(i,1)' , i, batch));
% 
% end
% 
% edf_1 = cell(30,1);
% for subjects = 1:30
%     edf_1{subjects} = eval(sprintf('edf_%d_%d',subjects,1));
% end



function edf = read_edf(i, j)

    mypath = strcat('./Code/edf+files/sub', num2str(i));
    edf = Edf2Mat([mypath '/sub' num2str(i) num2str(j) '.edf']);
end


