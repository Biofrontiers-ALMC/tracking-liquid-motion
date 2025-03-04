clearvars
clc

ROI = [42, 1200, 9, 1200];

vidObj = VideoReader('../data/RT_instability1_0.1__60fps.mp4');

storeVid = zeros(ROI(2) - ROI(1) + 1,ROI(4) - ROI(3) + 1, 50, 'uint16');

frameCtr = 0;
while hasFrame(vidObj) && frameCtr < 50

    vidFrame = readFrame(vidObj);
    frameCtr = frameCtr + 1;

    vidFrame = vidFrame(ROI(1):ROI(2), ROI(3):ROI(4), 1);

    storeVid(:, :, frameCtr) = vidFrame;    

    %Can we segment?   

    % imshow(vidFrame)
    % 
    % keyboard

end

%%
storeVidDiff = double(storeVid) - double(storeVid(:, :, 1));

vidOut = VideoWriter('testVid.avi');
open(vidOut)

for iZ = 1:size(storeVidDiff, 3)

    currDiffFrame = medfilt2(storeVidDiff(:, :, iZ), [5 5]);
    mask = currDiffFrame < -10;
    mask = imopen(mask, strel('disk', 10));
    mask = bwareaopen(mask, 500);
    %imshow(mask)
    % imshowpair(currDiffFrame, bwperim(mask))

    %Trace edge to get only leading edge
    maskEdge = nan(size(mask, 1), 1);

    for iRow = 1:size(mask, 1)
        idx = find(mask(iRow, :), 1, 'last');
        if ~isempty(idx)
            maskEdge(iRow) = idx;
        end        
    end

    Iout = double(storeVid(:, :, iZ));
    Iout = (Iout - (min(Iout(:))))/(max(Iout(:))-min(Iout(:)));
    for iRow = 1:10:size(mask, 1)
        if ~isnan(maskEdge(iRow))
            Iout = insertShape(Iout, 'filled-circle', ...
                [maskEdge(iRow), iRow, 2]);
        end
    end

    %imshowpair(storeVid(:, :, iZ), edgeMask)
    imshow(Iout)
    frame = getframe(gcf);
    writeVideo(vidOut, frame);
    
end
close(vidOut)