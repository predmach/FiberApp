%TUTORIAL Show tutorial messages

function tutorial(this, varargin)
if ~this.isTutorial; return; end

tutorial_message = varargin{1};

% Check if a message was already shown
if any(strcmp(tutorial_message, this.tutorialShowed)); return; end

switch tutorial_message
    case 'tutorial_is_on'
        helpdlg({'Welcome to the FiberApp tutorial.', ...
            ' ', ...
            'From now on, you will see pop-up windows throughout the working', ...
            'process with FiberApp. They provide information about typical', ...
            'actions that can be performed in order to obtain optimal results.'}, ...
            'FiberApp tutorial');
        
    case 'open_tif_image'
        helpdlg({'1) To scale this image in real units (nm) using a scale bar', ...
            'select "Image -> Scale Bar" in the main menu', ...
            ' ', ...
            '2) In case of an uneven illumination in the background', ...
            'select "Image -> Remove Surface"', ...
            ' ', ...
            '3) Set up the "Fiber Intensity" by pressing the button on the right', ...
            'of the edit field and clicking on a typical fibrillar object', ...
            ' ', ...
            '4) Start tracking by pressing "Space" or selecting "Fiber Tracking -> Add Fiber"'}, ...
            'FiberApp tutorial');
        
    case 'open_afm_image'
        helpdlg({'1) In case of an uneven illumination in the background', ...
            'select "Image -> Remove Surface"', ...
            ' ', ...
            '2) In order to get leveled height values', ...
            'press "Image -> Set Zero Value" and select a rectangular area', ...
            'which only covers the background of the image', ...
            ' ', ...
            '3) Set up the "Fiber Intensity" by pressing a button on the right', ...
            'of the edit field and clicking on a typical fibrillar object', ...
            ' ', ...
            '4) Start tracking by pressing "Space" or', ...
            'selecting "Fiber Tracking -> Add Fiber"'}, ...
            'FiberApp tutorial');
        
    case 'start_tracking'
        helpdlg({'Some typical suggestions for tracking parameters are the following:', ...
            ' ', ...
            '1) The step size should be about or slightly smaller than', ...
            'the thickness of fibrillar objects.', ...
            ' ', ...
            '2) Most of the time the only parameter to vary is Beta.', ...
            'The lower rigidity of the fibers, the smaller Beta should be.'}, ...
            'FiberApp tutorial');
        
    case 'save_as'
        helpdlg({'The data file contains all information on tracked objects,', ...
            'tracking parameters and the name to the corresponding image.', ...
            'One data file can contain information on several images.'}, ...
            'FiberApp tutorial');
        
    otherwise
        errordlg('Unknow tutorial message', ...
            'FiberApp tutorial');
        return
end

% Save the message, so it won't be shown for the second time in a session
this.tutorialShowed{end+1} = tutorial_message;

end
