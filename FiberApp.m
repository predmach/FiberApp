%FIBERAPP Start FiberApp

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function FiberApp
% Open main figure
figure('Name', 'FiberApp', 'NumberTitle', 'off', 'DockControls', 'off', ...
    'MenuBar', 'none', 'Tag', 'FiberApp', 'Position', [100, 100, 888, 658], ...
    'ResizeFcn', @ResizeFcn, ...
    'KeyPressFcn', @KeyPressFcn, ...
    'WindowScrollWheelFcn', @WindowScrollWheelFcn, ...
    'WindowButtonDownFcn', @WindowButtonDownFcn, ...
    'WindowButtonUpFcn', @WindowButtonUpFcn, ...
    'WindowButtonMotionFcn', @WindowButtonMotionFcn, ...
    'CloseRequestFcn', @CloseRequestFcn);

% Introduction string
intro_string = {['Publication of any type of results based on the use of this open source code ', ...
    'legally requires citation to the original publication:']; ...
    ['Usov, I and Mezzenga, R. FiberApp: an Open-source Software for Tracking ', ...
    'and Analyzing Polymers, Filaments, Biomacromolecules, and Fibrous Objects. ', ...
    'Macromolecules, 2015, 49, 1269-1280.']};
uicontrol(gcf, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [0.8, 0.8, 0.8], ...
    'Tag', 'intro_string', ...
    'String', intro_string, ...
    'Position', [-231, 1, 400, 100]);

% Initialize FiberAppDataClass
FA = FiberAppData;
guidata(gcf, FA);

% Open scroll panel
sp = imscrollpanel(gcf, image(0.94*ones(10,10,3)));
set(sp, 'Units', 'pixels');
% Make sliders more visible
set(findobj('Parent', sp, 'Type', 'uicontrol'), 'Background', [0.7 0.7 0.7]);
% Save handle to the main axes
FA.spAxes = findobj(sp, 'Type', 'axes', '-depth', 2);
% Get scroll panel API, register NewLocationCallback and NewMagnificationCallback
% for optimized fiber visualization
FA.spApi = iptgetapi(sp);
FA.spApi.addNewLocationCallback(@FA.renderFibers);
FA.spApi.addNewMagnificationCallback(@FA.renderFibers);

% Create menu and toolbar
CreateMenu;
CreateToolbar;

% Load panels from the '+panel' folder
main_path = fileparts(mfilename('fullpath'));
panel_files = what([main_path, filesep, '+panel']);
[~, panel_names] = cellfun(@fileparts, panel_files.m, 'UniformOutput', false);
for k = 1:length(panel_names)
    panel_name = panel_names{k};
    FA.panels.(panel_name) = panel.(panel_name);
end

% Get tags of the initially open panels and make them visible
tags = zeros(1, length(FA.defaultPanels));
for k = 1:length(FA.defaultPanels)
    tags(k) = FA.panels.(FA.defaultPanels{k});
end
FA.openPanels = tags;
set(FA.openPanels, 'Visible', 'on');

end

% -------------------------------------------------------------------------
% CreateMenu function -----------------------------------------------------
% -------------------------------------------------------------------------
function CreateMenu
% FiberApp
fiberAppMenu = uimenu(gcf, 'Label', 'FiberApp');
uimenu(fiberAppMenu, 'Label', 'Open Image', ...
    'Callback', @FiberAppGUI.OpenImage);
% ------------------------------
uimenu(fiberAppMenu, 'Label', 'New Data', 'Separator', 'on', 'Enable', 'off', ...
    'Callback', @FiberAppGUI.NewData);
uimenu(fiberAppMenu, 'Label', 'Open Data', ...
    'Callback', @FiberAppGUI.OpenData);
uimenu(fiberAppMenu, 'Label', 'Save Data', 'Enable', 'off', ...
    'Callback', @FiberAppGUI.SaveData);
uimenu(fiberAppMenu, 'Label', 'Save Data As', 'Enable', 'off', ...
    'Callback', @FiberAppGUI.SaveDataAs);
uimenu(fiberAppMenu, 'Label', 'Merge Data', ...
    'Callback', @FiberAppGUI.MergeData);
uimenu(fiberAppMenu, 'Label', 'Fork Data', ...
    'Callback', @FiberAppGUI.ForkData);
% ------------------------------
mainPanelsItem = uimenu(fiberAppMenu, 'Label', 'Main Panels', 'Separator', 'on');
uimenu(mainPanelsItem, 'Label', 'Image Parameters', 'Checked', 'on', ...
    'Tag', 'ImageParameters', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(mainPanelsItem, 'Label', 'Fiber Tracking Parameters', 'Checked', 'on', ...
    'Tag', 'FiberTrackingParameters', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(mainPanelsItem, 'Label', 'Fiber Data Information', 'Checked', 'on', ...
    'Tag', 'FiberDataInformation', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(mainPanelsItem, 'Label', 'View Properties', ...
    'Tag', 'ViewProperties', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(mainPanelsItem, 'Label', 'Mask Parameters', ...
    'Tag', 'MaskParameters', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
% ------------------------------
uimenu(fiberAppMenu, 'Label', 'Exit', 'Separator', 'on', ...
    'Callback', @FiberAppGUI.Exit);

% Image
imageMenu = uimenu(gcf, 'Label', 'Image', 'Enable', 'off');
uimenu(imageMenu, 'Label', 'Scale Bar', ...
    'Callback', @FiberAppGUI.ScaleBarImage);
uimenu(imageMenu, 'Label', 'Invert', ...
    'Callback', @FiberAppGUI.InvertImage);
uimenu(imageMenu, 'Label', 'Remove Surface', ...
    'Callback', @FiberAppGUI.RemoveSurfaceImage);
uimenu(imageMenu, 'Label', 'Set Zero Level', ...
    'Callback', @FiberAppGUI.SetZeroLevelImage);
% ------------------------------
uimenu(imageMenu, 'Label', 'Zoom In', 'Separator', 'on', ...
    'Callback', @(hObj, event, dir) FiberAppGUI.Zoom(hObj, event, 'in'));
uimenu(imageMenu, 'Label', 'Zoom Out', ...
    'Callback', @(hObj, event, dir) FiberAppGUI.Zoom(hObj, event, 'out'));
uimenu(imageMenu, 'Label', 'Actual Size', ...
    'Callback', @(hObj, event, dir) FiberAppGUI.Zoom(hObj, event, 'actual'));
% ------------------------------
colormapItem = uimenu(imageMenu, 'Label', 'Colormap', 'Separator', 'on');
uimenu(colormapItem, 'Label', 'gray', 'Checked', 'on', ...
    'Callback', @FiberAppGUI.Colormap);
uimenu(colormapItem, 'Label', 'jet', ...
    'Callback', @FiberAppGUI.Colormap);
uimenu(colormapItem, 'Label', 'hsv', ...
    'Callback', @FiberAppGUI.Colormap);
uimenu(colormapItem, 'Label', 'bone', ...
    'Callback', @FiberAppGUI.Colormap);
uimenu(colormapItem, 'Label', 'hot', ...
    'Callback', @FiberAppGUI.Colormap);
uimenu(colormapItem, 'Label', 'cool', ...
    'Callback', @FiberAppGUI.Colormap);
uimenu(colormapItem, 'Label', 'copper', ...
    'Callback', @FiberAppGUI.Colormap);
uimenu(colormapItem, 'Label', 'pink', ...
    'Callback', @FiberAppGUI.Colormap);
uimenu(colormapItem, 'Label', 'spring', ...
    'Callback', @FiberAppGUI.Colormap);
uimenu(colormapItem, 'Label', 'summer', ...
    'Callback', @FiberAppGUI.Colormap);
uimenu(colormapItem, 'Label', 'autumn', ...
    'Callback', @FiberAppGUI.Colormap);
uimenu(colormapItem, 'Label', 'winter', ...
    'Callback', @FiberAppGUI.Colormap);

% Fiber Tracking
fiberMenu = uimenu(gcf, 'Label', 'Fiber Tracking', 'Enable', 'off');
uimenu(fiberMenu, 'Label', 'Add Fiber', ...
    'Callback', @FiberAppGUI.AddFiber);
uimenu(fiberMenu, 'Label', 'Fit Fiber', ...
    'Callback', @FiberAppGUI.FitFiber);
uimenu(fiberMenu, 'Label', 'Fit All Fibers', ...
    'Callback', @FiberAppGUI.FitAllFibers);
uimenu(fiberMenu, 'Label', 'Remove Fiber', ...
    'Callback', @FiberAppGUI.RemoveFiber);
% ------------------------------
uimenu(fiberMenu, 'Label', 'Add Mask', 'Separator', 'on', ...
    'Callback', @FiberAppGUI.AddMask);
uimenu(fiberMenu, 'Label', 'Remove Mask', ...
    'Callback', @FiberAppGUI.RemoveMask);
% ------------------------------
ZInterpItem = uimenu(fiberMenu, 'Label', 'Z Interpolation', 'Separator', 'on');
uimenu(ZInterpItem, 'Label', 'nearest', ...
    'Callback', @FiberAppGUI.ZInterpolation);
uimenu(ZInterpItem, 'Label', 'linear', ...
    'Callback', @FiberAppGUI.ZInterpolation);
uimenu(ZInterpItem, 'Label', 'cubic', 'Checked', 'on', ...
    'Callback', @FiberAppGUI.ZInterpolation);

% Tools
toolsMenu = uimenu(gcf, 'Label', 'Tools');
uimenu(toolsMenu, 'Label', 'Fiber/Image Generator', ...
    'Tag', 'FiberImageGenerator', ...
    'Callback', @FiberAppGUI.ShowHidePanel);

% Processing
processingMenu = uimenu(gcf, 'Label', 'Processing');
uimenu(processingMenu, 'Label', 'Height Profile', ...
    'Tag', 'HeightProfile', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(processingMenu, 'Label', 'Height ACF', ...
    'Tag', 'HeightACF', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(processingMenu, 'Label', 'Height DFT', ...
    'Tag', 'HeightDFT', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
% ------------------------------
uimenu(processingMenu, 'Label', 'Height Distribution', 'Separator', 'on', ...
    'Tag', 'HeightDistribution', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(processingMenu, 'Label', 'Length Distribution', ...
    'Tag', 'LengthDistribution', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(processingMenu, 'Label', 'Orientation Distribution', ...
    'Tag', 'OrientationDistribution', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(processingMenu, 'Label', 'Curvature Distribution', ...
    'Tag', 'CurvatureDistribution', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(processingMenu, 'Label', 'Kink Angle Distribution', ...
    'Tag', 'KinkAngleDistribution', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
% ------------------------------
uimenu(processingMenu, 'Label', 'Bond Correlation Function', 'Separator', 'on', ...
    'Tag', 'BondCorrelationFunction', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(processingMenu, 'Label', 'MS End-to-end Distance', ...
    'Tag', 'MSEnd2EndDistance', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(processingMenu, 'Label', 'MS Midpoint Displacement', ...
    'Tag', 'MSMidpointDisplacement', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
% ------------------------------
uimenu(processingMenu, 'Label', 'Scaling Exponent', 'Separator', 'on', ...
    'Tag', 'ScalingExponent', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
uimenu(processingMenu, 'Label', 'Excess Kurtosis', ...
    'Tag', 'ExcessKurtosis', ...
    'Callback', @FiberAppGUI.ShowHidePanel);
% ------------------------------
uimenu(processingMenu, 'Label', 'Order Parameter 2D', 'Separator', 'on', ...
    'Tag', 'OrderParameter2D', ...
    'Callback', @FiberAppGUI.ShowHidePanel);

% Help
helpMenu = uimenu(gcf, 'Label', 'Help');
uimenu(helpMenu, 'Label', 'View Help', ...
    'Callback', @FiberAppGUI.ViewHelp);
uimenu(helpMenu, 'Label', 'Tutorial', ...
    'Callback', @FiberAppGUI.Tutorial);
uimenu(helpMenu, 'Label', 'About FiberApp', ...
    'Callback', @FiberAppGUI.About);
end

% -------------------------------------------------------------------------
% CreateToolbar function --------------------------------------------------
% -------------------------------------------------------------------------
function CreateToolbar
    % Function to read an icon from file
    function icon = readIcon(file)
        [icon, ~, alpha] = imread(file);
        icon = double(icon)./255;
        icon(alpha == 0) = NaN;
    end

uitoolbar;
uipushtool('CData', readIcon(['+icons' filesep 'open_image.png']), ...
    'TooltipString', 'Open Image', ...
    'ClickedCallback', @FiberAppGUI.OpenImage);
uipushtool('CData', readIcon(['+icons' filesep 'open_data.png']), ...
    'TooltipString', 'Open Data', ...
    'ClickedCallback', @FiberAppGUI.OpenData);
uipushtool('CData', readIcon(['+icons' filesep 'save_data.png']), ...
    'Enable', 'off', ...
    'TooltipString', 'Save Data', ...
    'ClickedCallback', @FiberAppGUI.SaveData);
uipushtool('CData', readIcon(['+icons' filesep 'merge_data.png']), ...
    'TooltipString', 'Merge Data', ...
    'ClickedCallback', @FiberAppGUI.MergeData);
uipushtool('CData', readIcon(['+icons' filesep 'fork_data.png']), ...
    'TooltipString', 'Fork Data', ...
    'ClickedCallback', @FiberAppGUI.ForkData);
% ------------------------------
uipushtool('CData', readIcon(['+icons' filesep 'zoom_in.png']), 'Separator', 'on', ...
    'Enable', 'off', ...
    'TooltipString', 'Zoom In', ...
    'ClickedCallback', @(hObj, event, dir) FiberAppGUI.Zoom(hObj, event, 'in'));
uipushtool('CData', readIcon(['+icons' filesep 'zoom_out.png']), 'Enable', 'off', ...
    'TooltipString', 'Zoom Out', ...
    'ClickedCallback', @(hObj, event, dir) FiberAppGUI.Zoom(hObj, event, 'out'));
% ------------------------------
uitoggletool('CData', readIcon(['+icons' filesep 'image_parameters.png']), 'Separator', 'on', ...
    'State', 'on', ...
    'TooltipString', 'Image Parameters', ...
    'Tag', 'ImageParameters', ...
    'ClickedCallback', @FiberAppGUI.ShowHidePanel);
uitoggletool('CData', readIcon(['+icons' filesep 'fiber_tracking_parameters.png']), ...
    'State', 'on', ...
    'TooltipString', 'Fiber Tracking Parameters', ...
    'Tag', 'FiberTrackingParameters', ...
    'ClickedCallback', @FiberAppGUI.ShowHidePanel);
uitoggletool('CData', readIcon(['+icons' filesep 'fiber_data_information.png']), ...
    'State', 'on', ...
    'TooltipString', 'Fiber Data Information', ...
    'Tag', 'FiberDataInformation', ...
    'ClickedCallback', @FiberAppGUI.ShowHidePanel);
uitoggletool('CData', readIcon(['+icons' filesep 'view_properties.png']), ...
    'State', 'off', ...
    'TooltipString', 'View Properties', ...
    'Tag', 'ViewProperties', ...
    'ClickedCallback', @FiberAppGUI.ShowHidePanel);
uitoggletool('CData', readIcon(['+icons' filesep 'mask_parameters.png']), ...
    'State', 'off', ...
    'TooltipString', 'Mask Parameters', ...
    'Tag', 'MaskParameters', ...
    'ClickedCallback', @FiberAppGUI.ShowHidePanel);
% ------------------------------
uitoggletool('CData', readIcon(['+icons' filesep 'fiber_image_generator.png']), 'Separator', 'on', ...
    'State', 'off', ...
    'TooltipString', 'Fiber/Image Generator', ...
    'Tag', 'FiberImageGenerator', ...
    'ClickedCallback', @FiberAppGUI.ShowHidePanel);
% ------------------------------
uipushtool('CData', readIcon(['+icons' filesep 'add_fiber.png']), 'Separator', 'on', ...
    'Enable', 'off', ...
    'TooltipString', 'Add Fiber (Space)', ...
    'ClickedCallback', @FiberAppGUI.AddFiber);
uipushtool('CData', readIcon(['+icons' filesep 'remove_fiber.png']), ...
    'Enable', 'off', ...
    'TooltipString', 'Remove Fiber (Delete)', ...
    'ClickedCallback', @FiberAppGUI.RemoveFiber);
uipushtool('CData', readIcon(['+icons' filesep 'fit_fiber.png']), ...
    'Enable', 'off', ...
    'TooltipString', 'Fit Fiber (F)', ...
    'ClickedCallback', @FiberAppGUI.FitFiber);
end

% -------------------------------------------------------------------------
% FiberApp figure callback functions --------------------------------------
% -------------------------------------------------------------------------
function ResizeFcn(hObject, eventdata)
FA = guidata(hObject);
if isempty(FA); return; end

FA.updatePanelPosition;
end

function KeyPressFcn(hObject, eventdata)
% 'Leftarrow' - move image 10% of its length to the left
% 'Rightarrow' - move image 10% of its length to the right
% 'Uparrow' - move image 10% of its length up
% 'Downarrow' - move image 10% of its length down
% 'Space' - add new fiber
% 'F' - fit fiber
% 'Delete' - remove selected fiber

FA = guidata(hObject);
if isempty(FA.curIm); return; end

eventchar = uint8(eventdata.Character);
if isempty(eventchar); return; end
switch eventchar
    case 28 % Leftarrow
        FA.pan_zoom('p_left');
    case 29 % Rightarrow
        FA.pan_zoom('p_right');
    case 30 % Uparrow
        FA.pan_zoom('p_up');
    case 31 % Downarrow
        FA.pan_zoom('p_down');
    case 32 % Space
        FiberAppGUI.AddFiber(hObject, eventdata)
    case 102 % F
        FiberAppGUI.FitFiber(hObject, eventdata)
    case 127 % Delete
        FiberAppGUI.RemoveFiber(hObject, eventdata)
end
end

function WindowScrollWheelFcn(hObject, eventdata)
% Scroll down - zoom out
% Scroll up - zoom in

FA = guidata(hObject);
if isempty(FA.curIm); return; end

if eventdata.VerticalScrollCount > 0
    FA.pan_zoom('z_out'); % scroll down
else
    FA.pan_zoom('z_in'); % scroll up
end
end

function WindowButtonDownFcn(hObject, eventdata)
% Left click on fiber - select it
% Right click and drag - pan image

FA = guidata(hObject);
if isempty(FA.curIm); return; end

switch get(hObject, 'SelectionType')
    case 'normal' % Left click
        if isempty(FA.curIm.xy); return; end
        
        mag = FA.spApi.getMagnification();
        border = 5/mag;
        cp = get(gca, 'CurrentPoint');
        x = cp(1,1);
        y = cp(1,2);
        
        for k = 1:length(FA.curIm.xy)
            data = FA.curIm.xy{k};
            ind = find(x-border <= data(1,:) & data(1,:) < x+border);
            if ~isempty(ind)
                ind = find(y-border <= data(2,ind) & data(2,ind) < y+border, 1);
                if ~isempty(ind)
                    FA.sel = k;
                    break
                end
            end
        end
        
    case 'alt' % Right click
        cp = get(gcf, 'CurrentPoint');
        r = FA.spApi.getVisibleLocation();
        mag = FA.spApi.getMagnification();
        set(gcf, 'WindowButtonMotionFcn', @wbmf_shift);
end

    function wbmf_shift(hObject, eventdata)
        % Get coordinates of the mouse cursor
        shift = (get(gcf, 'CurrentPoint')-cp)/mag;
        % Pan image
        FA.spApi.setVisibleLocation(r(1)-shift(1), r(2)+shift(2));
    end
end

function WindowButtonUpFcn(hObject, eventdata)
switch get(hObject, 'SelectionType')
    case 'alt'
        set(gcf, 'WindowButtonMotionFcn', @WindowButtonMotionFcn);
end
end

function WindowButtonMotionFcn(hObject, eventdata)
% Just to update the 'CurrentPoint' field
end

function CloseRequestFcn(hObject, eventdata)
FA = guidata(hObject);
if FA.isDataModified
    switch questdlg('Do you want to save changes?', 'FiberApp')
        case 'Yes'
            isSaved = FiberAppGUI.SaveData(hObject, eventdata);
            if ~isSaved; return; end
        case 'No'
        case {'Cancel', ''}
            return
    end
end

delete(gcf);
end
