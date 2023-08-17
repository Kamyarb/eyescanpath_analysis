%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function plays a video at the center of screen
% moviename='*.avi'
% ESC ends the demo.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PlayVideo(win, playRect, movie, numOfFrames, rotAng)

% Switch KbName into unified mode: It will use the names of the OS-X
% platform on all platforms in order to make this script portable:
KbName('UnifyKeyNames');
esc=KbName('ESCAPE');

try
    % Seek to start of movies (timeindex 0):
    Screen('SetMovieTimeIndex', movie, 0);
    
    rate=1;
    
    % Start playback of movies. This will start
    % the realtime playback clock and playback of audio tracks, if any.
    % Play 'movie', at a playbackrate = 1, once loop=0 (with endless loop=1)
    % and 1.0 == 100% audio volume.
    Screen('PlayMovie', movie, rate, 0, 1.0);
    
    t1 = GetSecs;
    frameCnt=0;
    % Infinite playback loop: Fetch video frames and display them...
    while(frameCnt<numOfFrames)
        % Return next frame in movie, in sync with current playback
        % time and sound.
        % tex either the texture handle or zero if no new frame is
        % ready yet.
%         [movietexture pts] = Screen('GetMovieImage', win, movie, 0);
        frame = Screen('GetMovieImage', win, movie, 0);
        % Valid frame returned?
        if frame > 0            
            % Draw the new texture immediately to screen:
            Screen('DrawTexture', win, frame, [], playRect, -rotAng);
            % Release texture:
            Screen('Close', frame);
            Screen('Flip', win, 0, 1);
            frameCnt=frameCnt+1;
        end
        % Check for abortion:
        [keyIsDown,secs,keyCode]=KbCheck;
        if (keyIsDown==1 && keyCode(esc))
            break;
        end
    end
    fprintf('Elapsed time %f secs.\n', GetSecs - t1);
    
    % Done. Stop playback:
    Screen('PlayMovie', movie, 0);
    
    % Close movie objects:
    Screen('CloseMovie', movie);
    
catch %#ok<CTCH>
    % Error handling: Close all windows and movies, release all ressources.
    sca;
end