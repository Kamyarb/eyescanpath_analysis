% 
close all
minimum = 1e5;
distances = zeros(30,30);
for i = 1:30
    for j =1:30
        if j>i
            dtw_x = dtw(set_posx{i},set_posx{j});
            dtw_y = dtw(set_posy{i},set_posy{j});
            dtw_total=dtw_x + dtw_y;
            distances(i,j)= dtw_total;
            distances(j,i)= dtw_total;
            if dtw_total < minimum
                minimum = dtw_total;
                i_min = i;
                j_min = j;
            end


        end
    end
end

dtw(set_posy{i_min},set_posy{j_min})
figure(2)
dtw(set_posx{i_min},set_posx{j_min})
