function output=imrot(firstFrame,rotAngle,color)
cr=320;
tmptmp=imrotate(firstFrame,rotAngle);
if(size(size(firstFrame),2)==3)
    b=color*ones(size(tmptmp,1),size(tmptmp,2),3);
    bCent=round([size(tmptmp,1)/2,size(tmptmp,2)/2]);
    [yy,xx,~]=ndgrid( (1:size(b,1))-bCent(1), (1:size(b,2))-bCent(2) ,1:3);
else
    b=color*ones(size(tmptmp,1),size(tmptmp,2));
    bCent=round([size(tmptmp,1)/2,size(tmptmp,2)/2]);
    [yy,xx,~]=ndgrid( (1:size(b,1))-bCent(1), (1:size(b,2))-bCent(2),1);
end

% Replace

map=(yy.^2+xx.^2<=cr^2);
b(map)=double(tmptmp(map));
firstFrametmp=b(bCent(1)-round(size(firstFrame,1)/2)+1:bCent(1)+round(size(firstFrame,1)/2)-1,bCent(2)-round(size(firstFrame,2)/2)+1:bCent(2)+round(size(firstFrame,2)/2)-1,:);
output=imresize(firstFrametmp,[size(firstFrame,1),size(firstFrame,2)]);  % << Rotate