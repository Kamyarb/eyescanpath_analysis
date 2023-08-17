% targets: determine which targets to show
% frmNumber: The number of frame that we want ground truth for it
% sz: frame size
% vid: Video index: can be 1 or 7 or 10
function output=trackingGT(targets,frmNumber,sz,vid)

addpath('jsonlab-master');
json_folder=['jsons/' num2str(vid)];
jsonfile = dir(fullfile(json_folder ,'*.json'));
indent = 20 ;

% it will specify images names with full path and extension
d = fullfile(json_folder, jsonfile(frmNumber).name);

data = loadjson(d);
% a = size(data.shapes{1, 1}.points);
mask=zeros(sz);
H = fspecial('gaussian',20); % Create the filter kernel.
%  RGB=zeros(776,720,3);
for i= 1:size(targets,2)
    idx=0;
    for(k=1:4)
        if(str2num(data.shapes{k}.label)==targets(i))
            idx=k;
        end
    end
    if(idx==0)
        err=1;
    end
    if(vid==1)
        data.shapes{1,idx}.points(:,2)=data.shapes{1,idx}.points(:,2)-(25-indent);
        data.shapes{1,idx}.points(:,1)=data.shapes{1,idx}.points(:,1)-(110-indent);
    elseif(vid==7)
        data.shapes{1,idx}.points(:,2)=data.shapes{1,idx}.points(:,2)-(45-indent);% 46
        data.shapes{1,idx}.points(:,1)=data.shapes{1,idx}.points(:,1)-(45-indent);% 40
    else % vid=10
        data.shapes{1,idx}.points(:,2)=data.shapes{1,idx}.points(:,2)-(45-indent);
        data.shapes{1,idx}.points(:,1)=data.shapes{1,idx}.points(:,1)-(45-indent);
    end
    a = size(data.shapes{1, idx}.points);
    % b = reshape(data.shapes{1, i}.points', [1,a(1)*a(2)]);
    bw = poly2mask(data.shapes{1,idx}.points(:,1), data.shapes{1,idx}.points(:,2),sz(1),sz(2));
    bw = imfilter(bw,H);
    mask=or(mask,bw);
    %         imshow(mask);
    %RGB= imread('C:\Users\User\Desktop\ipm\01\img1.jpg'); %read images
    % RGB = insertShape(RGB,'FilledPolygon',{b}, 'Color', {'red'},'Opacity',0.9);
end

output=255*uint8(mask);