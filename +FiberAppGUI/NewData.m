%NEWDATA "New Data" menu item callback

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function NewData(hObject, eventdata)
FA = guidata(hObject);

% Check for modifications
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

FA.imageData = ImageData.empty;
FA.isDataModified = false;
FA.dataName = char.empty;
FA.dataPath = char.empty;
FA.checkAccordance();
