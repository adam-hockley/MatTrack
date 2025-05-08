%% Tracking_AH
% Tracks objects, as in: https://www.mathworks.com/help/vision/ug/track-a-face.html
% Updates allow relabelling of objects after loosing tracking, and removing
% the error that occur when labelling outside the frame

clear
videoReader = VideoReader('C:\Users\ANL\Documents\CristianVids\Rec6_Oddball_Cam1.avi');
videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);

frame = readFrame(videoReader);

pointsDiff = [nan nan];
output = [nan nan];
while hasFrame(videoReader)
    
    frame = readFrame(videoReader);

    if isnan(pointsDiff(1))
        
        try 
            figure; imshow(frame);
            objectRegion=round(getPosition(imrect));
            close
        catch % if no box made (error), then go back to previous labelled frame
            videoReader.CurrentTime = (prevlabelframe/5)-0.2;
            frame = readFrame(videoReader);
            figure; imshow(frame);
            objectRegion=round(getPosition(imrect));
            close
        end
        objectRegion(objectRegion<1) = 1;
        if objectRegion(1) + objectRegion(3) > 640
            objectRegion(3) = 640 - objectRegion(1);
        end
        if objectRegion(2) + objectRegion(4) > 480
            objectRegion(4) = 480 - objectRegion(2);
        end
        close all
        points = detectMinEigenFeatures(im2gray(frame),'ROI',objectRegion,'FilterSize', 3);
        tracker = vision.PointTracker('MaxBidirectionalError',5);
        initialize(tracker,points.Location,frame);
        clear pointsOld
        prevlabelframe = (videoReader.CurrentTime*5);
    end

    [points,validity] = tracker(frame);
    out = insertMarker(frame,points(validity, :),'+');
    videoPlayer(out);

    if ~exist('pointsOld')
        pointsOld = points;
        pointsDiff = [0 0];
    else
        pointsDiff = points-pointsOld;
        pointsDiff(all(pointsDiff == 0,2),:) = [];        
        if isempty(pointsDiff)
            pointsDiff = [nan nan];
        end
    end
    currframe = (videoReader.CurrentTime*5);
    output(currframe,:) = mean(pointsDiff,1);

    pointsOld = points;
end
