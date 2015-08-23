% dev version 1.4

function varargout = DataManipulator(varargin)
% DATAMANIPULATOR MATLAB code for DataManipulator.fig
%      DATAMANIPULATOR, by itself, creates a new DATAMANIPULATOR or raises the existing
%      singleton*.
%
%      H = DATAMANIPULATOR returns the handle to a new DATAMANIPULATOR or the handle to
%      the existing singleton*.
%
%      DATAMANIPULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAMANIPULATOR.M with the given input arguments.
%
%      DATAMANIPULATOR('Property','Value',...) creates a new DATAMANIPULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataManipulator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataManipulator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataManipulator

% Last Modified by GUIDE v2.5 28-Jan-2015 15:41:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataManipulator_OpeningFcn, ...
                   'gui_OutputFcn',  @DataManipulator_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DataManipulator is made visible.
function DataManipulator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataManipulator (see VARARGIN)

% add library paths
libdir = fullfile(pwd,'lib');
if exist(libdir,'dir')
    addpath(genpath(libdir));
end

set(0,'Units','pixels');

% Choose default command line output for DataManipulator
handles.output = hObject;

% Initialize log
setappdata(handles.main_figure,'log',cell(0));
updatestatus(handles.main_figure,'Welcome!');
[handles.mDir,handles.mName,ext] = fileparts(mfilename('fullpath'));

%%%%% Initialize default variables
handles.varsFileName = fullfile('private',[handles.mName '_vars.xlsx']);
vars = readVarScalars(handles.varsFileName);
for i=1:length(vars.keys)
    key = vars.keys{i};
    handles.(key) = vars.(key);
    updatestatus(handles.main_figure,['Set variable ' key ' specified in ' handles.varsFileName ' to: ' vars.varStr.(key)]);
end

% Color map for plotting multiple curves
handles.colors = lines(7);
set(handles.color_popupmenu,'String', getColorStr(handles.colors));

% Load vector variables
vars = readVarVectors(handles.varVectorsFileName,1);
for i=1:length(vars.keys)
    key = vars.keys{i};
    handles.(key) = vars.(key);
    updatestatus(handles.main_figure,['Set variable ' key ' specified in ' handles.varVectorsFileName ' to:']);
    updatestatus(handles.main_figure,vars.varStr.(key));
end

if exist(handles.guivarsFileName ,'file')
    load(handles.guivarsFileName ,'guiVars');
end

for i=1:length(handles.savedVars)
    var = handles.savedVars{i};
    if isfield(guiVars,var)
        handles.(var) = guiVars.(var);
        updatestatus(handles.main_figure,['Update variable ' var ' from guiVars.']);
        guiName = handles.guiName{i};
        if ~isempty(guiName)
            set(handles.(guiName),handles.guiType{i},handles.(var));
        end
    end
end

%filepath
handles = checkFilePath(handles,handles.filepath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Display standard menu bar menus.
set(handles.main_figure,'MenuBar','figure');  
set(handles.main_figure,'Units','pixels')

handles = initSubGUI(handles);

% Update handles structure
updatestatus(handles.main_figure,'Welcome!');
guidata(hObject, handles);

% UIWAIT makes DataManipulator wait for user response (see UIRESUME)
% uiwait(handles.main_figure);


function handles = initSubGUI(handles)
mainGUIPos = get(handles.main_figure, 'Position');  
set(handles.main_figure, 'Position', [30, 80, mainGUIPos(3), mainGUIPos(4)]);
    
% PlotSub('main', handles.main_figure);
% handles.subGUIName = 'PlotSub';
handles.subGUI_handle = openfig(handles.subGUIName,'reuse','visible');

set(handles.subGUI_handle,'Units','pixels')
subGUIPos = get(handles.subGUI_handle, 'Position');  
set(handles.subGUI_handle, 'Position', [50, 150+mainGUIPos(4), subGUIPos(3), subGUIPos(4)]);

handles.subGUIHandles = get(handles.subGUI_handle,'children');
set(handles.subGUI_handle,'MenuBar','figure');  

handles.subGUITags = get(handles.subGUIHandles,'Tag');
indices = find(strcmp(handles.subGUITags, handles.subGUIAxesName));
if isempty(indices)
    updatestatus(handles.main_figure,'Cannot find plot_axes');
else
    handles.subGUI_axes = handles.subGUIHandles(indices(1));
end


function str = getColorStr(colors)
% Convert colors from RGB to HTML string for popupmenu
str = {};
for idx = 1:size(colors,1)
    color = colors(idx,:);
    colorStr = '';
    for channel = color
        colorStr = [colorStr dec2hex(round(255*channel),2)];
    end
    str{idx} = ['<HTML><BODY bgcolor="#' colorStr '"><PRE>        </PRE></BODY></HTML>'];
end


% --- Outputs from this function are returned to the command line.
function varargout = DataManipulator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in exit_pushbutton.
function exit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
main_figure_CloseRequestFcn(handles.main_figure, eventdata, handles);


% --- Executes when user attempts to close main_figure.
function main_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to main_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
promptMessage = sprintf('Do you want to Continue exiting?\n(Click Cancel to stay running)');
selectedButton = questdlg(promptMessage, 'Exit Dialog','Continue exiting', 'Cancel', 'Continue exiting');
if strcmp(selectedButton, 'Cancel')        % Stay in the program. Do not exit.
    return;
end

% save gui variables
guiVars = struct;
for i=1:length(handles.savedVars)
    var = handles.savedVars{i};
    if isfield(handles,var)
        guiVars.(var) = handles.(var);
    end
end
save(handles.guivarsFileName,'guiVars');
    
% Continue to exit by deleting this GUI
updatestatus(handles.main_figure,'Goodbye!');

% save log
if handles.isLog
    saveLog_pushbutton_Callback(hObject, eventdata, handles);
end

delete(hObject);
if ishandle(handles.subGUI_handle)
    delete(handles.subGUI_handle);
end

% --- Executes during object creation, after setting all properties.
function filepath_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filepath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse_pushbutton.
function browse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to browse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,filedir]=uigetfile(handles.filepath,'Specify filepath...');
filepath = fullfile(filedir,filename);

handles = checkFilePath(handles,filepath);
guidata(hObject, handles);


function handles = checkFilePath(handles,filepath)
% Check if the filedir and filename are valid and update handles

[filedir,basename,fileext] =fileparts(filepath);
filename = [basename fileext];

if ~ischar(filename) || ~ischar(filedir)
    updatestatus(handles.main_figure,'Not a valid file path.');
    return;
end

%Always use / to separate folders
%No ending slash
handles.filedir = [strrep(filedir,'\','/') '/'];
handles.filepath = filepath;
handles.filename = filename;

set(handles.filepath_edit,'String',handles.filepath);


% --- Executes during object creation, after setting all properties.
function current_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function prefix_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = loadImageInSeries(num,handles)
% load an image in a series specified by num

% check if num is integer and in range
if mod(num,1)~=0 || num<1 || num>handles.numFiles
    updatestatus(handles.main_figure,'Specified index is out of range.');
    return;
end

currentFilePath = fullfile(handles.filedir, handles.fileNames{num});
handles = loadCurrentImage(currentFilePath,handles);

if ~isempty(handles.status)
     updatestatus(handles,handles.status);
     return;
end


function handles = current_edit_Callback(hObject, eventdata, handles)
% hObject    handle to current_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_edit as text
%        str2double(get(hObject,'String')) returns contents of current_edit as a double
num = round(str2double(get(hObject,'String')));
if num<1 || num>handles.numFiles
     updatestatus(handles.main_figure,'Invalid file index.');
     return;
end    

handles.iCurrentFile = num;
set(handles.current_slider,'Value',num);

filepath = fullfile(handles.filedir,handles.fileNames{num});
handles = checkFilePath(handles,filepath);


guidata(hObject, handles);



function filepath_edit_Callback(hObject, eventdata, handles)
% hObject    handle to filepath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filepath_edit as text
%        str2double(get(hObject,'String')) returns contents of filepath_edit as a double
filepath = get(handles.filepath_edit,'String');
handles = checkFilePath(handles,filepath);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function main_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to main_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate main_axes
set(0,'defaultaxeslinewidth',1);


% --- Executes on button press in loadSingle_pushbutton.
function handles = loadLabels(handles)
% hObject    handle to loadSingle_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xLabel = handles.xLabels{handles.iXLabel};
yLabel = handles.yLabels{handles.iYLabel};

xLabelsFound = find(ismember(handles.colheaders,xLabel));
yLabelsFound = find(ismember(handles.colheaders,yLabel));

if isempty(xLabelsFound)
    handles.iXLabel = 1;
else
    handles.iXLabel = xLabelsFound(1);
end
handles.yLabel = handles.colheaders{handles.iYLabel};

if isempty(yLabelsFound)
    handles.iYLabel = 1;
else
    handles.iYLabel = yLabelsFound(1);
end
handles.yLabel = handles.colheaders{handles.iYLabel};

set(handles.xLabel_popupmenu,'String',handles.colheaders);
set(handles.yLabel_popupmenu,'String',handles.colheaders);
set(handles.xLabel_popupmenu,'Value',handles.iXLabel);
set(handles.yLabel_popupmenu,'Value',handles.iYLabel);


% --- Executes on button press in loadFiles_pushbutton.
function handles = loadFiles_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadFiles_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.isSeries
    handles.filePattern = [handles.prefix '*' handles.suffix '.' handles.extension];
else
    handles.filePattern = handles.filename;
end

files = dir(fullfile(handles.filedir,handles.filePattern));
fileNames = {files(:).name};

if length(fileNames)<1
    updatestatus(handles.main_figure,'No file is found.');
    return;
end
numFiles = length(fileNames);

namesFound = find(ismember(fileNames,handles.filename));

if length(namesFound)<1
    iCurrentFile = 1;
else
    iCurrentFile = namesFound(1);
end    

currentFilePath = fullfile(handles.filedir, fileNames{iCurrentFile});

handles.files = files;
handles.fileNames = fileNames;
handles.numFiles = numFiles;
handles.iCurrentFile = iCurrentFile;

set(handles.current_edit,'String',num2str(iCurrentFile));
set(handles.numfiles_text,'String',['/  ',num2str(numFiles)]);

if numFiles==1
    maxSlider = 2; % so that the max value is bigger than the min value
else
    maxSlider = numFiles;
end
set(handles.current_slider,'Value',1,'Max',maxSlider,'SliderStep',[1/(maxSlider-1) 1/(maxSlider-1)]);

handles.seriesData = {};
for i=1:handles.numFiles
    filepath = fullfile(handles.filedir, handles.fileNames{i});
    M = importdata(filepath,'\t',1);
    if ~isfield(M,'data') || ~isfield(M,'colheaders')
        updatestatus(handles.main_figure,['Error reading data from file: ' filepath]);
        return;
    end
    handles.seriesData{i} = M.data;
    
    if i==handles.iCurrentFile
        handles.colheaders = M.colheaders;
        handles.base = struct;
        for iHeader = 1:length(handles.colheaders)
            handles.base.(handles.colheaders{iHeader}) = M.data(:,iHeader);
        end
    end
end

handles = loadLabels(handles);
updatestatus(handles.main_figure,['Data length for the first file: ' num2str(length(handles.seriesData{i}))]);

updatestatus(handles.main_figure,['Success loading files from: ' handles.filedir]);
guidata(hObject, handles);


function prefix_edit_Callback(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefix_edit as text
%        str2double(get(hObject,'String')) returns contents of prefix_edit as a double
handles.prefix = get(hObject,'String');
guidata(hObject, handles);


% --- Executes on slider movement.
function current_slider_Callback(hObject, eventdata, handles)
% hObject    handle to current_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
num = get(hObject,'Value');
if handles.numFiles==1
    num_index = 1;
else
    num_index = round(num);
end

handles.iCurrentFile = num_index;

filepath = fullfile(handles.filedir,handles.fileNames{num_index});
handles = checkFilePath(handles,filepath);

set(handles.current_edit,'String',num2str(num_index));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function current_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in isLog_checkbox.
function isLog_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isLog_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isLog_checkbox
handles.isLog = get(hObject,'Value');
guidata(hObject, handles);


function yScale_edit_Callback(hObject, eventdata, handles)
% hObject    handle to yScale_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yScale_edit as text
%        str2double(get(hObject,'String')) returns contents of yScale_edit as a double
handles.yScale = str2double(get(hObject,'String'));
updatestatus(handles.main_figure,['Values in y-axis will be multiplied by ' num2str(handles.yScale) ' for conversion to ' handles.yUnit]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function yScale_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yScale_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function suffix_edit_Callback(hObject, eventdata, handles)
% hObject    handle to suffix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of suffix_edit as text
%        str2double(get(hObject,'String')) returns contents of suffix_edit as a double
handles.suffix = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function suffix_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to suffix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function extension_edit_Callback(hObject, eventdata, handles)
% hObject    handle to extension_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of extension_edit as text
%        str2double(get(hObject,'String')) returns contents of extension_edit as a double
handles.extension = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function extension_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to extension_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dispImage(img,handles)
% display image on the axes
if handles.isAutoContrast
    img = autocontrast(img,handles.bitDepth);
end 
imshow(img,'Parent',handles.subGUI_axes);




% --- Executes on button press in saveAxes_pushbutton.
function saveAxes_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveAxes_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%img = getframe(handles.subGUI_axes);
%imwrite(img.cdata,savedImgPath);

% savedImgPath =  [handles.filedir 'img_' getTime_filename() '.png'];
% export_fig(savedImgPath,handles.subGUI_axes);
savedImgPath =  [handles.filedir 'img_' getTime_filename()];
% export_fig(savedImgPath,handles.subGUI_axes,'-png','-pdf','-painters');
export_fig(savedImgPath,handles.subGUI_handle,'-pdf','-painters');
export_fig(savedImgPath,handles.subGUI_handle,'-png','-painters','-m2');
saveas(handles.subGUI_handle,[savedImgPath '.fig'],'fig');

updatestatus(handles.main_figure,['Axes has been saved to file: ' savedImgPath]);

% saveas(handles.subGUI_axes,savedImgPath,'fig');  


% --- Executes on selection change in xLabel_popupmenu.
function xLabel_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to xLabel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns xLabel_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xLabel_popupmenu
handles.xLabels = cellstr(get(hObject,'String'));
handles.iXLabel = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function xLabel_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xLabel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveLog_pushbutton.
function saveLog_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveLog_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~exist(handles.filedir,'dir')
    filedir = '';
    updatestatus(handles.main_figure,'Directory does not exist. Log is saved to the program directory.');
else
    filedir = handles.filedir;
end

log = getappdata(handles.main_figure,'log');
logFilePath = fullfile(filedir,[handles.mName '.log']);

updatestatus(handles.main_figure,['Current log is being saved to: ' logFilePath]);
fid = fopen(logFilePath,'at');
fprintf(fid, '%s\n', log{:});
fclose(fid);
setappdata(handles.main_figure,'log',cell(0));




function xScale_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xScale_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xScale_edit as text
%        str2double(get(hObject,'String')) returns contents of xScale_edit as a double
handles.xScale = str2double(get(hObject,'String'));
updatestatus(handles.main_figure,['Values in x-axis will be multiplied by ' num2str(handles.xScale) ' for conversion to ' handles.xUnit]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function xScale_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xScale_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in left_uitable.
function left_uitable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to left_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.leftTable = get(handles.left_uitable,'Data');
updatestatus(handles.main_figure,'Left table has been updated.');
guidata(hObject,handles);



% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function main_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to main_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function c = insert(c,ins,idx)
% Insert a new cell ins into cell array c at index idx
c = [c(1:idx-1) {ins} c(idx:end)];


% --- Executes on button press in insertRow_pushbutton.
function insertRow_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to insertRow_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% currentRow = handles.left_uitable.getTable.getSelectedRows
if ~isfield(handles,'seriesData') || ~isfield(handles,'allData')
    updatestatus(handles.main_figure,'Error reading data.');
    return;
end

newData = handles.seriesData;
nNewData = length(newData);
if length(handles.allData)<nNewData
    % create empty arrays for all indices
    handles.allData{nNewData} = [];
end

% Adjust frame numbering
frameLabelsFound = find(ismember(handles.colheaders,'frame'));
if isempty(frameLabelsFound)
    updatestatus(handles.main_figure,'Frame not found in the data headers. Frames will not be shifted.');
else
    iFrameLabel = frameLabelsFound(1);
    for idx=1:nNewData
        newData{idx}(:,iFrameLabel) = newData{idx}(:,iFrameLabel)+handles.framesShifted;
        if handles.isShiftFrame
            if size(handles.allData{idx},1)==0
                lastFrame = 0;
            else
                lastFrame = handles.allData{idx}(end,iFrameLabel);
            end
            newData{idx}(:,iFrameLabel) = newData{idx}(:,iFrameLabel)+lastFrame;
        end
    end
end

for idx=1:nNewData
    handles.allData{idx} = [handles.allData{idx};newData{idx}];
end

set(handles.left_uitable,'Data',handles.allData{handles.iCurrentFile});
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in left_uitable.
function left_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to left_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in yLabel_popupmenu.
function yLabel_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to yLabel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns yLabel_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from yLabel_popupmenu
handles.yLabels = cellstr(get(hObject,'String'));
handles.iYLabel = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function yLabel_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yLabel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xUnit_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xUnit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xUnit_edit as text
%        str2double(get(hObject,'String')) returns contents of xUnit_edit as a double
handles.xUnit = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function xUnit_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xUnit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function yUnit_edit_Callback(hObject, eventdata, handles)
% hObject    handle to yUnit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yUnit_edit as text
%        str2double(get(hObject,'String')) returns contents of yUnit_edit as a double
handles.yUnit = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function yUnit_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yUnit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotAllData_pushbutton.
function plotAllData_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotAllData_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'allData')
    updatestatus(handles.main_figure,'No data has been loaded to allData table.');
    return;
end

plotData(handles,handles.allData);


% --- Executes on button press in clearAllData_pushbutton.
function clearAllData_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearAllData_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.allData = [];
set(handles.left_uitable,'Data',handles.allData);
guidata(hObject, handles);


% --- Executes on button press in isShiftFrame_checkbox.
function isShiftFrame_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isShiftFrame_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isShiftFrame_checkbox
handles.isShiftFrame = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in plotSeries_pushbutton.
function plotSeries_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotSeries_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'seriesData')
    updatestatus(handles.main_figure,'No data has been loaded.');
    return;
end

plotData(handles,handles.seriesData);


function plotData(handles,data)
% Plot data that is a cell array of matrices

cla(handles.subGUI_axes,'reset');
hold(handles.subGUI_axes,'on');

xlabel(handles.subGUI_axes,handles.xUnit);
ylabel(handles.subGUI_axes,handles.yUnit);

numColors = length(handles.colors);

if handles.isSeries
    idxRange = 1:handles.numFiles;
else
    idxRange = handles.iCurrentFile:handles.iCurrentFile;
end

for idx = idxRange
    color = handles.colors(mod(idx-1,numColors)+1,:);
    if handles.isAutoXData
        xData = 1:size(data{idx},1);
        xData = xData(:)*handles.xScale;
    else
        xData = data{idx}(:,handles.iXLabel)*handles.xScale;
    end
    yData = data{idx}(:,handles.iYLabel)*handles.yScale;
    plot(handles.subGUI_axes,xData,yData,handles.plotOptions,'Color',color,'LineWidth',0.7,'MarkerSize',2);
end

hold(handles.subGUI_axes,'off');



function xBar_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xBar_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xBar_edit as text
%        str2double(get(hObject,'String')) returns contents of xBar_edit as a double
s = get(hObject,'String');
handles.xBar = str2double(regexp( s, ',', 'split' ));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function xBar_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xBar_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in isSeries_checkbox.
function isSeries_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isSeries_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isSeries_checkbox
handles.isSeries = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in saveAllData_pushbutton.
function saveAllData_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveAllData_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trackstr = '';
for index = 1:length(handles.allData)
    trackstr = [trackstr num2str(index) ', '];
    savedBaseName = ['TrackAllData' num2str(index)];
    savedFilePath = [handles.filedir savedBaseName '.txt'];

    fid = fopen(savedFilePath,'wt');
    for col=1:length(handles.colheaders)-1
        fprintf(fid, '%s\t', handles.colheaders{col});
    end
    fprintf(fid, '%s\n', handles.colheaders{end});
    fclose(fid);

    dlmwrite(savedFilePath, handles.allData,'delimiter', '\t', '-append')
end    
    


% --- Executes on selection change in color_popupmenu.
function color_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to color_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color_popupmenu
handles.iColor = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function color_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in verticalBar_pushbutton.
function verticalBar_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to verticalBar_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hold(handles.subGUI_axes,'on');
yLim = get(handles.subGUI_axes,'YLim');
offset = (yLim(2)-yLim(1))*0.05;
yLim = [yLim(1)+offset, yLim(2)-offset];

if handles.isBarScale
    xBar = handles.xBar*handles.xScale;
else
    xBar = handles.xBar;
end

for x=xBar
    line([x x],yLim,'LineStyle','--','Color',handles.colors(handles.iColor,:),'LineWidth',0.5,'Parent',handles.subGUI_axes);
end
hold(handles.subGUI_axes,'off');


function framesShifted_edit_Callback(hObject, eventdata, handles)
% hObject    handle to framesShifted_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framesShifted_edit as text
%        str2double(get(hObject,'String')) returns contents of framesShifted_edit as a double
handles.framesShifted = round(str2double(get(hObject,'String')));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function framesShifted_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framesShifted_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calCorrelation_pushbutton.
function calCorrelation_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to calCorrelation_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.numFiles<2
    updatestatus(handles.main_figure,'At least two curves are needed to calculate correlation.');
    return;
end

nData = length(handles.seriesData{1}(:,handles.iYLabel));
handles.corrTotal = zeros(nData-1,1);
for idx1 = 1:handles.numFiles-1
    yData1 = handles.seriesData{idx1}(:,handles.iYLabel);
    for idx2 = idx1+1:handles.numFiles
        yData2 = handles.seriesData{idx2}(:,handles.iYLabel);
        corr = (yData1(2:end)-yData1(1:end-1)).*(yData2(2:end)-yData2(1:end-1));
        handles.corrTotal = handles.corrTotal + corr;
    end
end
updatestatus(handles.main_figure,'Correlation has been calculated.');
guidata(hObject, handles);


% --- Executes on button press in plotCorrelation_pushbutton.
function plotCorrelation_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotCorrelation_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.subGUI_axes,'reset');
hold(handles.subGUI_axes,'on');

xlabel(handles.subGUI_axes,handles.xUnit);
ylabel(handles.subGUI_axes,'correlation');

plot(handles.subGUI_axes,handles.seriesData{1}(1:end-1,handles.iXLabel),handles.corrTotal,'-','LineWidth',2);

hold(handles.subGUI_axes,'off');



function xLim_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xLim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xLim_edit as text
%        str2double(get(hObject,'String')) returns contents of xLim_edit as a double
s = get(hObject,'String');
handles.xLim = str2double(regexp( s, ',', 'split' ));
set(handles.subGUI_axes,'XLim',handles.xLim);

updatestatus(handles.main_figure,['XLim has been set to: ' s]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function xLim_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xLim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function yLim_edit_Callback(hObject, eventdata, handles)
% hObject    handle to yLim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yLim_edit as text
%        str2double(get(hObject,'String')) returns contents of yLim_edit as a double
s = get(hObject,'String');
handles.yLim = str2double(regexp( s, ',', 'split' ));
set(handles.subGUI_axes,'YLim',handles.yLim);

updatestatus(handles.main_figure,['YLim has been set to: ' s]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function yLim_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yLim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in isAutoXData_checkbox.
function isAutoXData_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isAutoXData_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isAutoXData_checkbox
handles.isAutoXData = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in isBarScale_checkbox.
function isBarScale_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isBarScale_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isBarScale_checkbox
handles.isBarScale = get(hObject,'Value');
guidata(hObject, handles);



function plotOptions_edit_Callback(hObject, eventdata, handles)
% hObject    handle to plotOptions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plotOptions_edit as text
%        str2double(get(hObject,'String')) returns contents of plotOptions_edit as a double
handles.plotOptions = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function plotOptions_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotOptions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in focusPlot_pushbutton.
function focusPlot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to focusPlot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(handles.subGUI_handle);


% --- Executes on button press in plotUncage_pushbutton.
function plotUncage_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotUncage_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
numColors = length(handles.colors);
for idx = handles.numFiles
    color = handles.colors(mod(idx-1,numColors)+1,:);
    
    iUncage = find(acq.results{i}(:,colUncage));
    xData = acq.results{i}(:,colFrame);
    xData = xData(iUncage)*acq.interval/60; % time in minute
    xData = data{idx}(:,handles.iXLabel)*handles.xScale;
    yData = data{idx}(:,handles.iYLabel)*handles.yScale;
    plot(handles.subGUI_axes,xData,yData,handles.plotOptions,'Color',color,'LineWidth',0.7,'MarkerSize',2);
end


% --- Executes on button press in evalin_pushbutton.
function evalin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to evalin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.base = evalin('base', 'dm');
guidata(hObject, handles);


% --- Executes on button press in assignin_pushbutton.
function assignin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to assignin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base','dm',handles.base);


% --- Executes on button press in plotBase_pushbutton.
function plotBase_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotBase_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles.base,'y')
    return;
end
if ~isfield(handles.base,'x')||handles.base.x==[]
    handles.base.x = 1:length(handles.base.y)
end
plot(handles.subGUI_axes,handles.base.x,handles.base.y,handles.plotOptions,'LineWidth',0.7,'MarkerSize',2);
