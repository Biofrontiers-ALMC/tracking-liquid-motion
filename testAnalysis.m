clearvars
clc

vidObj = VideoReader('../data/RT_instability1_0.1__60fps.mp4');

while hasFrame(vidObj)

    vidFrame = readFrame(vidObj);

    %Can we segment?
    

    imshow(vidFrame)

    pause;

end