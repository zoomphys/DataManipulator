function varargout = PlotSub(varargin)
% PLOTSUB MATLAB code for PlotSub.fig
%      PLOTSUB, by itself, creates a new PLOTSUB or raises the existing
%      singleton*.
%
%      H = PLOTSUB returns the handle to a new PLOTSUB or the handle to
%      the existing singleton*.
%
%      PLOTSUB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTSUB.M with the given input arguments.
%
%      PLOTSUB('Property','Value',...) creates a new PLOTSUB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotSub_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotSub_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlotSub

% Last Modified by GUIDE v2.5 08-Jan-2014 16:10:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotSub_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotSub_OutputFcn, ...
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


% --- Executes just before PlotSub is made visible.
function PlotSub_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotSub (see VARARGIN)

% Is the changeme_main gui's handle is passed in varargin?
% if the name 'changeme_main' is found, and the next argument
% varargin{mainGuiInput+1} is a handle, assume we can open it.

set(0,'Units','pixels');

dontOpen = false;
mainGuiInput = find(strcmp(varargin, 'main'));
if (isempty(mainGuiInput)) ...
    || (length(varargin) <= mainGuiInput) ...
    || (~ishandle(varargin{mainGuiInput+1}))
    dontOpen = true;
else
    % Remember the handle, and adjust our position
    handles.mainFigure = varargin{mainGuiInput+1};
    
    % Obtain handles using GUIDATA with the caller's handle 
    handles.mainHandles = guidata(handles.mainFigure);
    
end

% Position to be relative to parent:
% parentPosition = getpixelposition(handles.mainFigure);
% currentPosition = get(hObject, 'Position');  
% % set(hObject, 'Position', [200, parentPosition(2)+parentPosition(4), currentPosition(3), currentPosition(4)]);
% set(hObject, 'Position', [20,20,20,20]);
    
% Choose default command line output for untitled
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if dontOpen
   disp('-----------------------------------------------------');
   disp('Improper input arguments. Pass a property value pair') 
   disp('whose name is "main" and value is the handle')
   disp('to the main figure, e.g:');
   disp('   x = main()');
   disp('   settings(''main'', x)');
   disp('-----------------------------------------------------');
end


% --- Outputs from this function are returned to the command line.
function varargout = PlotSub_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% varargout{1} = [];
% delete(hObject);


% --- Executes when user attempts to close settings_figure.
function plot_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to settings_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% uiresume(hObject);
delete(hObject);
