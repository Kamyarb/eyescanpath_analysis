function [label,bw]=findLabel(point,frmNumber,sz,vid,rotAng)
label=0;
addpath('jsonlab-master');
json_folder=['jsons/' num2str(vid)];
jsonfile = dir(fullfile(json_folder ,'*.json'));
indent = 20 ;

% f=fullfile(image_folder, filename(n).name);% it will specify images names with full path and extension
d = fullfile(json_folder, jsonfile(frmNumber).name);

data = loadjson(d);
% a = size(data.shapes{1, 1}.points);
mask=zeros(sz);
H = fspecial('gaussian',20); % Create the filter kernel.
%  RGB=zeros(776,720,3);
for idx= 1:4    
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
%     a = size(data.shapes{1, idx}.points);
    % b = reshape(data.shapes{1, i}.points', [1,a(1)*a(2)]);
    bw = poly2mask(data.shapes{1,idx}.points(:,1), data.shapes{1,idx}.points(:,2),sz(1),sz(2));
    bw = imfilter(bw,H);
    
    bw=imrot(bw,rotAng,0); %>>>>>> Rotate
    
    pt=zeros(size(bw));
    pt(max(point(2)-5,1):min(point(2)+5,size(pt,1)),max(1,point(1)-5):min(point(1)+5,size(pt,2)))=1;
%     pt(point(2)-5:point(2)+5,point(1)-5:point(1)+5)=1;
    pt=and(pt,bw);
    cnt=find(pt>0);
    if(size(cnt,1)>0)
        label=str2num(data.shapes{idx}.label);
        break;
    end
end
