function varargout = ActuatorControl(varargin)
% ACTUATORCONTROL Application M-file for ActuatorControl.fig
%    FIG = ACTUATORCONTROL launch ActuatorControl GUI.
%    ACTUATORCONTROL('callback_name', ...) invoke the named callback.

% Last Modified by Layton Hale 7/23/2001

if nargin == 0  % LAUNCH GUI

	fig2 = openfig(mfilename,'reuse');
    BackgroundColor = get(0,'defaultUicontrolBackgroundColor');
	set(fig2,'Color',BackgroundColor);
    colors = [  0       0.55    0       % 1, green
                0.85    0       0       % 2, red
                0.9     0.9     0       % 3, yellow
                0.5     0.5     0.5     % 4, dark gray
                BackgroundColor];       % 5, light gray

    set(fig2,'UserData',colors)         % figure2 UserData stores colors

	% Generate a structure containing gui handles. This structure can
    % also hold application data to pass to callbacks. When finished 
    % adding application data, store it using guidata(). 
	Data = guihandles(fig2);
    Data.figure1 = [];
    
    % Open the New Focus Picomotor Driver
    g2 = gpib('ni',0,2);            % Create GPIB object
    g2.name = 'off';                % Use GPIB name as a control state
    fopen(g2);                      % Open connection
	Data.g2 = g2;
	guidata(fig2, Data);

    ID = query(g2,'*IDN?');         % Instrument identification
    disp(['Connecting to the ',ID])
	if nargout > 0
		varargout{1} = fig2;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
		disp(lasterr);
    end

end


%| ABOUT HANDLES:
%| A structure containing handles of components in the GUI (using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2, etc.)
%| is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback. You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| ABOUT CALLBACKS:
%| Subfunctions in this file execute when objects' callback properties 
%| call them through the FEVAL switchyard above. 
%| This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the object. Add any extra arguments after the 
%| last argument, before the final closing parenthesis.

% --------------------------------------------------------------------
function XTarget_Callback(h)
% Callback subfunction for the edit text XTarget (Data.XTarget)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

XTarget = sscanf(get(Data2.XTarget,'String'),'%f');
XDiff = XTarget - get(Data2.XActual,'Value');

set(Data2.XTarget,'Value',XTarget,'String',sprintf('%0.3f',XTarget))
set(Data2.XDiff,'Value',XDiff,'String',sprintf('%0.3f',XDiff))
UpdateActuators(Data1,Data2)

% --------------------------------------------------------------------
function XDiff_Callback(h)
% Callback subfunction for the edit text XDiff (Data.XDiff)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

XDiff = sscanf(get(Data2.XDiff,'String'),'%f');
XTarget = XDiff + get(Data2.XActual,'Value');

set(Data2.XTarget,'Value',XTarget,'String',sprintf('%0.3f',XTarget))
set(Data2.XDiff,'Value',XDiff,'String',sprintf('%0.3f',XDiff))
UpdateActuators(Data1,Data2)

% --------------------------------------------------------------------
function YTarget_Callback(h)
% Callback subfunction for the edit text YTarget (Data.YTarget)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

YTarget = sscanf(get(Data2.YTarget,'String'),'%f');
YDiff = YTarget - get(Data2.YActual,'Value');

set(Data2.YTarget,'Value',YTarget,'String',sprintf('%0.3f',YTarget))
set(Data2.YDiff,'Value',YDiff,'String',sprintf('%0.3f',YDiff))
UpdateActuators(Data1,Data2)

% --------------------------------------------------------------------
function YDiff_Callback(h)
% Callback subfunction for the edit text YDiff (Data.YDiff)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

YDiff = sscanf(get(Data2.YDiff,'String'),'%f');
YTarget = YDiff + get(Data2.YActual,'Value');

set(Data2.YTarget,'Value',YTarget,'String',sprintf('%0.3f',YTarget))
set(Data2.YDiff,'Value',YDiff,'String',sprintf('%0.3f',YDiff))
UpdateActuators(Data1,Data2)

% --------------------------------------------------------------------
function ZTarget_Callback(h)
% Callback subfunction for the edit text ZTarget (Data.ZTarget)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

ZTarget = sscanf(get(Data2.ZTarget,'String'),'%f');
ZDiff = ZTarget - get(Data2.ZActual,'Value');

set(Data2.ZTarget,'Value',ZTarget,'String',sprintf('%0.3f',ZTarget))
set(Data2.ZDiff,'Value',ZDiff,'String',sprintf('%0.3f',ZDiff))
UpdateActuators(Data1,Data2)

% --------------------------------------------------------------------
function ZDiff_Callback(h)
% Callback subfunction for the edit text ZDiff (Data.ZDiff)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

ZDiff = sscanf(get(Data2.ZDiff,'String'),'%f');
ZTarget = ZDiff + get(Data2.ZActual,'Value');

set(Data2.ZTarget,'Value',ZTarget,'String',sprintf('%0.3f',ZTarget))
set(Data2.ZDiff,'Value',ZDiff,'String',sprintf('%0.3f',ZDiff))
UpdateActuators(Data1,Data2)

% --------------------------------------------------------------------
function RxTarget_Callback(h)
% Callback subfunction for the edit text RxTarget (Data.RxTarget)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

RxTarget = sscanf(get(Data2.RxTarget,'String'),'%f');
RxDiff = RxTarget - get(Data2.RxActual,'Value');

set(Data2.RxTarget,'Value',RxTarget,'String',sprintf('%0.2f',RxTarget))
set(Data2.RxDiff,'Value',RxDiff,'String',sprintf('%0.2f',RxDiff))
UpdateActuators(Data1,Data2)

% --------------------------------------------------------------------
function RxDiff_Callback(h)
% Callback subfunction for the edit text RxDiff (Data.RxDiff)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

RxDiff = sscanf(get(Data2.RxDiff,'String'),'%f');
RxTarget = RxDiff + get(Data2.RxActual,'Value');

set(Data2.RxTarget,'Value',RxTarget,'String',sprintf('%0.2f',RxTarget))
set(Data2.RxDiff,'Value',RxDiff,'String',sprintf('%0.2f',RxDiff))
UpdateActuators(Data1,Data2)

% --------------------------------------------------------------------
function RyTarget_Callback(h)
% Callback subfunction for the edit text RyTarget (Data.RyTarget)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

RyTarget = sscanf(get(Data2.RyTarget,'String'),'%f');
RyDiff = RyTarget - get(Data2.RyActual,'Value');

set(Data2.RyTarget,'Value',RyTarget,'String',sprintf('%0.2f',RyTarget))
set(Data2.RyDiff,'Value',RyDiff,'String',sprintf('%0.2f',RyDiff))
UpdateActuators(Data1,Data2)

% --------------------------------------------------------------------
function RyDiff_Callback(h)
% Callback subfunction for the edit text RyDiff (Data.RyDiff)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

RyDiff = sscanf(get(Data2.RyDiff,'String'),'%f');
RyTarget = RyDiff + get(Data2.RyActual,'Value');

set(Data2.RyTarget,'Value',RyTarget,'String',sprintf('%0.2f',RyTarget))
set(Data2.RyDiff,'Value',RyDiff,'String',sprintf('%0.2f',RyDiff))
UpdateActuators(Data1,Data2)

% --------------------------------------------------------------------
function A1Target_Callback(h)
% Callback subfunction for the edit text A1Target (Data.A1Target)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A1Target = sscanf(get(Data2.A1Target,'String'),'%f');
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A1Target < -cal{13}              % clamp at negative limit
    A1Target = -cal{13};
elseif A1Target > cal{13}           % clamp at positive limit
    A1Target = cal{13};
end

A1Actual = get(Data2.A1Actual,'Value');
A1Diff = A1Target - A1Actual;
set(Data2.A1Diff,'Value',A1Diff,'String',sprintf('%0.3f',A1Diff))
set(Data2.A1Target,'Value',A1Target)
SetDisplayCond(Data2,1);

set(Data2.A1Target,'String',sprintf('%0.3f',A1Target))
UpdateAxes(Data2,1,A1Target,A1Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function A1Diff_Callback(h)
% Callback subfunction for the edit text A1Diff (Data.A1Diff)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A1Diff = sscanf(get(Data2.A1Diff,'String'),'%f');
A1Actual = get(Data2.A1Actual,'Value');
A1Target = A1Diff + A1Actual;
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A1Target < -cal{13}              % clamp at negative limit
    A1Target = -cal{13};
    A1Diff = A1Target - A1Actual;
elseif A1Target > cal{13}           % clamp at positive limit
    A1Target = cal{13};
    A1Diff = A1Target - A1Actual;
end

set(Data2.A1Diff,'Value',A1Diff,'String',sprintf('%0.3f',A1Diff))
set(Data2.A1Target,'Value',A1Target)
SetDisplayCond(Data2,1);

set(Data2.A1Target,'String',sprintf('%0.3f',A1Target))
UpdateAxes(Data2,1,A1Target,A1Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function A2Target_Callback(h)
% Callback subfunction for the edit text A2Target (Data.A2Target)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A2Target = sscanf(get(Data2.A2Target,'String'),'%f');
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A2Target < -cal{13}              % clamp at negative limit
    A2Target = -cal{13};
elseif A2Target > cal{13}           % clamp at positive limit
    A2Target = cal{13};
end

A2Actual = get(Data2.A2Actual,'Value');
A2Diff = A2Target - A2Actual;
set(Data2.A2Diff,'Value',A2Diff,'String',sprintf('%0.3f',A2Diff))
set(Data2.A2Target,'Value',A2Target)
SetDisplayCond(Data2,2);

set(Data2.A2Target,'String',sprintf('%0.3f',A2Target))
UpdateAxes(Data2,2,A2Target,A2Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function A2Diff_Callback(h)
% Callback subfunction for the edit text A2Diff (Data.A2Diff)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A2Diff = sscanf(get(Data2.A2Diff,'String'),'%f');
A2Actual = get(Data2.A2Actual,'Value');
A2Target = A2Diff + A2Actual;
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A2Target < -cal{13}              % clamp at negative limit
    A2Target = -cal{13};
    A2Diff = A2Target - A2Actual;
elseif A2Target > cal{13}           % clamp at positive limit
    A2Target = cal{13};
    A2Diff = A2Target - A2Actual;
end

set(Data2.A2Diff,'Value',A2Diff,'String',sprintf('%0.3f',A2Diff))
set(Data2.A2Target,'Value',A2Target)
SetDisplayCond(Data2,2);

set(Data2.A2Target,'String',sprintf('%0.3f',A2Target))
UpdateAxes(Data2,2,A2Target,A2Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function A3Target_Callback(h)
% Callback subfunction for the edit text A3Target (Data.A3Target)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A3Target = sscanf(get(Data2.A3Target,'String'),'%f');
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A3Target < -cal{13}              % clamp at negative limit
    A3Target = -cal{13};
elseif A3Target > cal{13}           % clamp at positive limit
    A3Target = cal{13};
end

A3Actual = get(Data2.A3Actual,'Value');
A3Diff = A3Target - A3Actual;
set(Data2.A3Diff,'Value',A3Diff,'String',sprintf('%0.3f',A3Diff))
set(Data2.A3Target,'Value',A3Target)
SetDisplayCond(Data2,3);

set(Data2.A3Target,'String',sprintf('%0.3f',A3Target))
UpdateAxes(Data2,3,A3Target,A3Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function A3Diff_Callback(h)
% Callback subfunction for the edit text A3Diff (Data.A3Diff)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A3Diff = sscanf(get(Data2.A3Diff,'String'),'%f');
A3Actual = get(Data2.A3Actual,'Value');
A3Target = A3Diff + A3Actual;
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A3Target < -cal{13}              % clamp at negative limit
    A3Target = -cal{13};
    A3Diff = A3Target - A3Actual;
elseif A3Target > cal{13}           % clamp at positive limit
    A3Target = cal{13};
    A3Diff = A3Target - A3Actual;
end

set(Data2.A3Diff,'Value',A3Diff,'String',sprintf('%0.3f',A3Diff))
set(Data2.A3Target,'Value',A3Target)
SetDisplayCond(Data2,3);

set(Data2.A3Target,'String',sprintf('%0.3f',A3Target))
UpdateAxes(Data2,3,A3Target,A3Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function A4Target_Callback(h)
% Callback subfunction for the edit text A4Target (Data.A4Target)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A4Target = sscanf(get(Data2.A4Target,'String'),'%f');
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A4Target < -cal{13}              % clamp at negative limit
    A4Target = -cal{13};
elseif A4Target > cal{13}           % clamp at positive limit
    A4Target = cal{13};
end

A4Actual = get(Data2.A4Actual,'Value');
A4Diff = A4Target - A4Actual;
set(Data2.A4Diff,'Value',A4Diff,'String',sprintf('%0.3f',A4Diff))
set(Data2.A4Target,'Value',A4Target)
SetDisplayCond(Data2,4);

set(Data2.A4Target,'String',sprintf('%0.3f',A4Target))
UpdateAxes(Data2,4,A4Target,A4Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function A4Diff_Callback(h)
% Callback subfunction for the edit text A4Diff (Data.A4Diff)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A4Diff = sscanf(get(Data2.A4Diff,'String'),'%f');
A4Actual = get(Data2.A4Actual,'Value');
A4Target = A4Diff + A4Actual;
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A4Target < -cal{13}              % clamp at negative limit
    A4Target = -cal{13};
    A4Diff = A4Target - A4Actual;
elseif A4Target > cal{13}           % clamp at positive limit
    A4Target = cal{13};
    A4Diff = A4Target - A4Actual;
end

set(Data2.A4Diff,'Value',A4Diff,'String',sprintf('%0.3f',A4Diff))
set(Data2.A4Target,'Value',A4Target)
SetDisplayCond(Data2,4);

set(Data2.A4Target,'String',sprintf('%0.3f',A4Target))
UpdateAxes(Data2,4,A4Target,A4Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function A5Target_Callback(h)
% Callback subfunction for the edit text A5Target (Data.A5Target)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A5Target = sscanf(get(Data2.A5Target,'String'),'%f');
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A5Target < -cal{13}              % clamp at negative limit
    A5Target = -cal{13};
elseif A5Target > cal{13}           % clamp at positive limit
    A5Target = cal{13};
end

A5Actual = get(Data2.A5Actual,'Value');
A5Diff = A5Target - A5Actual;
set(Data2.A5Diff,'Value',A5Diff,'String',sprintf('%0.3f',A5Diff))
set(Data2.A5Target,'Value',A5Target)
SetDisplayCond(Data2,5);

set(Data2.A5Target,'String',sprintf('%0.3f',A5Target))
UpdateAxes(Data2,5,A5Target,A5Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function A5Diff_Callback(h)
% Callback subfunction for the edit text A5Diff (Data.A5Diff)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A5Diff = sscanf(get(Data2.A5Diff,'String'),'%f');
A5Actual = get(Data2.A5Actual,'Value');
A5Target = A5Diff + A5Actual;
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A5Target < -cal{13}              % clamp at negative limit
    A5Target = -cal{13};
    A5Diff = A5Target - A5Actual;
elseif A5Target > cal{13}           % clamp at positive limit
    A5Target = cal{13};
    A5Diff = A5Target - A5Actual;
end

set(Data2.A5Diff,'Value',A5Diff,'String',sprintf('%0.3f',A5Diff))
set(Data2.A5Target,'Value',A5Target)
SetDisplayCond(Data2,5);

set(Data2.A5Target,'String',sprintf('%0.3f',A5Target))
UpdateAxes(Data2,5,A5Target,A5Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function A6Target_Callback(h)
% Callback subfunction for the edit text A6Target (Data.A6Target)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A6Target = sscanf(get(Data2.A6Target,'String'),'%f');
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A6Target < -cal{13}              % clamp at negative limit
    A6Target = -cal{13};
elseif A6Target > cal{13}           % clamp at positive limit
    A6Target = cal{13};
end

A6Actual = get(Data2.A6Actual,'Value');
A6Diff = A6Target - A6Actual;
set(Data2.A6Diff,'Value',A6Diff,'String',sprintf('%0.3f',A6Diff))
set(Data2.A6Target,'Value',A6Target)
SetDisplayCond(Data2,6);

set(Data2.A6Target,'String',sprintf('%0.3f',A6Target))
UpdateStage(Data1,Data2)
UpdateAxes(Data2,6,A6Target,A6Actual)

% --------------------------------------------------------------------
function A6Diff_Callback(h)
% Callback subfunction for the edit text A6Diff (Data.A6Diff)
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

A6Diff = sscanf(get(Data2.A6Diff,'String'),'%f');
A6Actual = get(Data2.A6Actual,'Value');
A6Target = A6Diff + A6Actual;
cal = get(Data1.Calibration,'UserData');    % cell array, use {12}

if A6Target < -cal{13}              % clamp at negative limit
    A6Target = -cal{13};
    A6Diff = A6Target - A6Actual;
elseif A6Target > cal{13}           % clamp at positive limit
    A6Target = cal{13};
    A6Diff = A6Target - A6Actual;
end

set(Data2.A6Diff,'Value',A6Diff,'String',sprintf('%0.3f',A6Diff))
set(Data2.A6Target,'Value',A6Target)
SetDisplayCond(Data2,6);

set(Data2.A6Target,'String',sprintf('%0.3f',A6Target))
UpdateAxes(Data2,6,A6Target,A6Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function Start_Callback(h)
% Callback subfunction for the push button Start (Data.Start).
% Button is active only when start is allowed.
Data = guidata(h);
Data.g2.name = 'on';                % Set picomotor state to on

% --------------------------------------------------------------------
function Stop_Callback(h)
% Callback subfunction for the push button Stop (Data.Stop)
% Button is active only when start is allowed.
Data = guidata(h);
Data.g2.name = 'off';               % Set picomotor state to off

% --------------------------------------------------------------------
function Deadband_Callback(h)
% Callback subfunction for the popup menu Deadband (Data.Deadband)
Data = guidata(h);

% Set the display deadband and overtravel conditions
ATarget = SetDisplayCond(Data,1:6);
AActual = [GetA123Actuals(Data);GetA456Actuals(Data)];
UpdateAxes(Data,1:6,ATarget,AActual)

% --------------------------------------------------------------------
function CloseRequestFcn(h)
% Close request subfunction to close the Actuator Control window
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

Data2.g2.name = 'off';          % Stop picomotors
Data1.g1.name = 'off';          % deactivate action functions

if ~strcmp(Data1.g1.TransferStatus,'idle')
    stopasync(Data1.g1)
    pause(0.1)
    fscanf(Data1.g1);           % clear the input buffer
end

fprintf(Data2.g2,'*RST')        % stop picomotors
ID = query(Data2.g2,'*IDN?');   % instrument identification
fclose(Data2.g2)
disp([ID,' is now ',Data2.g2.Status])
delete(Data2.g2)

Data1.g1.name = 'SL';           % control state for Sensor Log
Data1.figure2 = [];             % clear figure 2 handle
guidata(Data1.figure1, Data1);
SensorLog('ReConfigScan',Data1)

% Close the Actuator Control window
delete(Data2.figure2)            

% --------------------------------------------------------------------
function SliderStart(h)
% Button Down subfunction to start slider input to actuator target.
Data = guidata(h);

MoveFcn = 'ActuatorControl(''SliderMove'',gcbo)';
StopFcn = 'ActuatorControl(''SliderStop'',gcbo)';
set(Data.figure2,'WindowButtonMotionFcn',MoveFcn,...
                 'WindowButtonUpFcn',StopFcn)

% --------------------------------------------------------------------
function SliderMove(h)
% Window Button Motion subfunction to change display per slider input.
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

cal = get(Data1.Calibration,'UserData');    % cell array, use {13}

% Get the value of the slider in units of the axes
hAxes = get(Data2.figure2,'CurrentAxes');
point = get(hAxes,'CurrentPoint');
Target = point(1,2);

if Target < -cal{13}                % clamp at negative limit
    Target = -cal{13};
elseif Target > cal{13}             % clamp at positive limit
    Target = cal{13};
end

current = get(hAxes,'UserData');
switch current(3)                   % current actuator number
case 1
    hTarget = Data2.A1Target;
    hActual = Data2.A1Actual;
    hDiff   = Data2.A1Diff;
case 2
    hTarget = Data2.A2Target;
    hActual = Data2.A2Actual;
    hDiff   = Data2.A2Diff;
case 3
    hTarget = Data2.A3Target;
    hActual = Data2.A3Actual;
    hDiff   = Data2.A3Diff;
case 4
    hTarget = Data2.A4Target;
    hActual = Data2.A4Actual;
    hDiff   = Data2.A4Diff;
case 5
    hTarget = Data2.A5Target;
    hActual = Data2.A5Actual;
    hDiff   = Data2.A5Diff;
case 6
    hTarget = Data2.A6Target;
    hActual = Data2.A6Actual;
    hDiff   = Data2.A6Diff;
end

Actual = get(hActual,'Value');
Diff = Target - Actual;
set(hTarget,'Value',Target,'String',sprintf('%0.3f',Target))
set(hDiff,'Value',Diff,'String',sprintf('%0.3f',Diff))
SetDisplayCond(Data2,current(3));
UpdateAxes(Data2,current(3),Target,Actual)
UpdateStage(Data1,Data2)

% --------------------------------------------------------------------
function SliderStop(h)
% Window Button Up subfunction to reset slider to ready condition.

set(h,'WindowButtonMotionFcn','','WindowButtonUpFcn','')

% --------------------------------------------------------------------
function Initialize(h1,h2)
% Use to initialize the Actuator Control display.
Data1 = guidata(h1);
Data2 = guidata(h2);

% Store the Sensor Log handle h1
Data2.figure1 = h1;
guidata(h2, Data2);

% Display the most recent actual LVTD values
TV = Data1.g1.UserData;                         % times and values
[A,S] = UpdateActuals(Data1,Data2,1:6,TV(size(TV,1),11:16));

% Set Target values to equal actual values (differences are zero)
SetActuatorTargets(Data2,A)
SetStageTargets(Data2,S)
UpdateAxes(Data2,1:6,A,A)

% --------------------------------------------------------------------
function MotorCommand(h,I,V)
% Called by BytesAvailableAction_Fcn to compute and issue motor commands.
% I contains indices 1:3 or 4:6, and V contains the corresponding values.
% Updates the display and commands A123 or A456 in alternating fashion.
Data2 = guidata(h);
Data1 = guidata(Data2.figure1);

% Set actuator actual values
[A,S] = UpdateActuals(Data1,Data2,I,V);

if strcmp(Data2.g2.name,'on')       % Picomotor state is on
    if all(I == 1:3)
        ATarget = GetA123Targets(Data2);
        ADiff = [(ATarget - A);GetA456Diff(Data2)];
        SetA123Diff(Data2,ADiff(1:3))
    elseif all(I == 4:6)
        ATarget = GetA456Targets(Data2);
        ADiff = [GetA123Diff(Data2);(ATarget - A)];
        SetA456Diff(Data2,ADiff(4:6))
    else
        error('Indices do not match in ActuatorControl(MotorCommand)')
    end
    J = TestDeadband(Data2,ADiff);      % Actuators within deadband
    K = setdiff(I,J);                   % Actuators to drive
    k = -600;                           % steps/micron
    if K
        Motor(Data2.g2,K,ADiff(K)*k)    % Move motors to zero out ADiff
    end
    if length(J) == 6
        Data2.g2.name = 'off';          % Set picomotor state to off
    end
    SetDisplayCond(Data2,I,J);
    SetStageDiff(Data2,GetStageTargets(Data2) - S)
    UpdateAxes(Data2,I,ATarget,A)
end

% --------------------------------------------------------------------
function Motor(g2,I,C)
% Sends motor commands to the picomotor driver.
% g: gpib object handle
% I: a vector of indices of motors to drive.
% C: a vector of motor commands corresponding to I (+/-counts).

motor = {'111', '112', '113', '121', '122', '123'};     % motor ID
dir = {'CCW','CW'};
max_count = 1300;               % (time to move)*(max frequency)
sgn_count = (C >= 0) + 1;       % 2 if positive, 1 if negative
abs_count = round(min(max_count,abs(C)));  
pulse_period = floor(max_count./abs_count)/1.5;

for j = 1:length(I)
    motorID = sprintf('INST:NSEL %s',motor{I(j)});
    motorCom = sprintf('SOUR:DIR %s;SOUR:PULS:PER %0.3gms;SOUR:PULS:COUN %d',...
                        dir{sgn_count(j)},pulse_period(j),abs_count(j));
    
    if strcmp(query(g2,motorID),'OK')           % okay to execute motorCom
        if ~strcmp(query(g2,motorCom),'OK')     % failed to execute motorCom
            disp(['Failed to command motor' motor{I(j)}]);
        end
    else
        disp(['Failed to recognize motor' motor{I(j)}]);
    end
end

% --------------------------------------------------------------------
function [A,S] = UpdateActuals(Data1,Data2,I,V)
% Use to display actual LVDT readings for stage and actuators.
% I contains indices 1:3, 4:6 or 1:6 and V contains the corresponding values.
% A contains the actuator actuals corresponding to I and S contains the
% stage actuals.

% Apply calibration table to selected channels
cal = get(Data1.Calibration,'UserData');        % cell array, use {1-6}
n = length(I);
A = zeros(n,1);
for j=1:n
    A(j) = interp1(cal{I(j)}(1,:),cal{I(j)}(2,:),V(j),'linear','extrap');
end

% Set actuator actual values
if (I(1) == 1) & (I(n) == 6)                    % I = 1:6
    SetA123Actuals(Data2,A(1:3))
    SetA456Actuals(Data2,A(4:6))
    S = cal{12}*A;
elseif I(1) == 1                                % I = 1:3
    SetA123Actuals(Data2,A)
    S = cal{12}*[A;GetA456Actuals(Data2)];
elseif I(1) == 4                                % I = 4:6
    SetA456Actuals(Data2,A)
    S = cal{12}*[GetA123Actuals(Data2);A];
else
    error('Indices do not match in ActuatorControl(UpdateActuals)')
end

SetStageActuals(Data2,S)

% --------------------------------------------------------------------
function UpdateStage(Data1,Data2)
% Use to update the stage display (X-Ry) based on the actuator display.
% The stage target values are transformed from the actuator targets and
% the stage differences are calculated from actual values.

% Compute stage targets and  differences
cal = get(Data1.Calibration,'UserData');    % cell array, use {12} S = T*A
STarget = cal{12}*[GetA123Targets(Data2);GetA456Targets(Data2)];
SDiff = STarget - GetStageActuals(Data2);

% Update the display
SetStageTargets(Data2,STarget)
SetStageDiff(Data2,SDiff)

% --------------------------------------------------------------------
function UpdateActuators(Data1,Data2)
% Use to update the actuator display (A1-A6) based on the stage display.
% The actuator target values are transformed from the stage targets and
% the actuator differences are calculated from actual values.

% Compute actuator targets
cal = get(Data1.Calibration,'UserData');    % cell array, use {11} A = T*S
A = cal{11}*GetStageTargets(Data2);
v = [1;-1;1;-1;1;-1];
ATarget = A - 0.5*(max(A.*v) + min(A.*v)).*v;

% Compute actuator differences
AActual = [GetA123Actuals(Data2);GetA456Actuals(Data2)];
ADiff = ATarget - AActual;

% Check for actuators deadband condition and overtravel command
J = TestDeadband(Data2,ADiff);              % indices within the deadband
K = find(abs(ATarget) > cal{13});           % indices outside travel limit
SetDisplayCond(Data2,1:6,J,K)

% Update the display
SetActuatorTargets(Data2,ATarget)
SetA123Diff(Data2,ADiff(1:3))
SetA456Diff(Data2,ADiff(4:6))
UpdateAxes(Data2,1:6,ATarget,AActual)

% --------------------------------------------------------------------
function UpdateAxes(Data,I,Target,Actual)
% Use to display actuator target and actual positions on axes.
% Will plot any set of axes determined by the indices in I.
% Inputs Target and Actual are vectors with as many components as I.
% The current colors are stored in the axes UserData.

p = get(Data.figure2,'Position');   % figure position, p(3) = width
n = length(I);
colors = get(Data.figure2,'UserData');

for i = 1:n
    switch I(i)                 % get handle to particular axes
    case 1
        hAxes = Data.axes1;
    case 2
        hAxes = Data.axes2;
    case 3
        hAxes = Data.axes3;
    case 4
        hAxes = Data.axes4;
    case 5
        hAxes = Data.axes5;
    case 6
        hAxes = Data.axes6;
    end
    
    current = get(hAxes,'UserData');
    hPlot = plot(0.25,Target(i),'>k',0.75,Actual(i),'<k','parent',hAxes);
    set(hPlot,'MarkerSize',12*p(3)/112)
    set(hPlot(1),'ButtonDownFcn','ActuatorControl(''SliderStart'',gcbo)')
    set(hPlot(1),'MarkerFaceColor',colors(current(1),:))    % Target marker
    set(hPlot(2),'MarkerFaceColor',colors(current(2),:))    % Actual marker
end

% --------------------------------------------------------------------
function I = TestDeadband(Data,ADiff)
% Compares the actuator differencs to the deadband and returns the 
% indices of those within.

if nargin < 2
    ADiff  = [GetA123Diff(Data);GetA456Diff(Data)];
end

deadband_index = get(Data.Deadband,'Value');
deadband_array = get(Data.Deadband,'UserData');
I = find(abs(ADiff) < deadband_array(deadband_index));

% --------------------------------------------------------------------
function varargout = SetDisplayCond(Data,I,J,K)
% Sets the display condition according to indices I, J, and K, where 
% I indicates the actuators to set, J indicates those within the
% deadband, and K indicates those outside the travel limit.
% J and K are computed internally if not passed to the function.
% Returns ATarget if K is not passed to the function.

if nargin < 3
    ADiff = [GetA123Diff(Data);GetA456Diff(Data)];
    J = TestDeadband(Data,ADiff);
end
if nargin < 4
    Data1 = guidata(Data.figure1);
    cal = get(Data1.Calibration,'UserData');    % cell array, use {13}
    
    ATarget = [GetA123Targets(Data);GetA456Targets(Data)];
    varargout{1} = ATarget;
    K = find(abs(ATarget) > cal{13});   % indices outside travel limit
end
colors = get(Data.figure2,'UserData');
n = length(I);

% Set display conditions for Start, Stop and Arrows.
if length(J) == 6       % All actuators are within the deadband
    
    set(Data.Start,'BackgroundColor',colors(5,:),...    % light gray
                   'ForegroundColor',colors(3,:),...    % yellow
                   'Enable','off',...
                   'String','Start')   
    set(Data.Stop, 'BackgroundColor',colors(5,:),...    % light gray
                   'ForegroundColor',colors(3,:),...    % yellow
                   'Enable','off')   
    set(Data.RtArrow,'ForegroundColor',colors(4,:))     % dark gray
    set(Data.LtArrow,'ForegroundColor',colors(4,:))     % dark gray

elseif K        % Some actuator targets are outside the travel limit
    
    set(Data.Start,'BackgroundColor',colors(3,:),...    % yellow
                   'ForegroundColor',colors(2,:),...    % red
                   'Enable','inactive',...
                   'String','Limit')   
    set(Data.Stop, 'BackgroundColor',colors(2,:),...    % red
                   'ForegroundColor',colors(3,:),...    % yellow
                   'Enable','inactive')   
    set(Data.RtArrow,'ForegroundColor',colors(3,:))     % yellow
    set(Data.LtArrow,'ForegroundColor',colors(2,:))     % red

else        % All actuators can move to target or are at target
    
    set(Data.Start,'BackgroundColor',colors(1,:),...    % green
                   'ForegroundColor',colors(3,:),...    % yellow
                   'Enable','on',...
                   'String','Start')   
    set(Data.Stop, 'BackgroundColor',colors(2,:),...    % red
                   'ForegroundColor',colors(3,:),...    % yellow
                   'Enable','on')   
    set(Data.RtArrow,'ForegroundColor',colors(1,:))     % green
    set(Data.LtArrow,'ForegroundColor',colors(2,:))     % red
end

% Set display conditions for Actuator Targets and Axes
for i = 1:n
    switch I(i)             % Get handles to particular axes
    case 1
        hText = Data.A1Target;
        hAxes = Data.axes1;
    case 2
        hText = Data.A2Target;
        hAxes = Data.axes2;
    case 3
        hText = Data.A3Target;
        hAxes = Data.axes3;
    case 4
        hText = Data.A4Target;
        hAxes = Data.axes4;
    case 5
        hText = Data.A5Target;
        hAxes = Data.axes5;
    case 6
        hText = Data.A6Target;
        hAxes = Data.axes6;
    end
    if ismember(I(i),J)         % Actuator within deadband
        
        set(hText,'BackgroundColor',colors(5,:))    % light gray
        set(hText,'ForegroundColor','black')
        set(hAxes,'UserData',[4,4,I(i)])            % dark gray
        
    elseif ismember(I(i),K)     % Actuator outside the travel limit
        
        set(hText,'BackgroundColor',colors(3,:))    % yellow
        set(hText,'ForegroundColor',colors(2,:))    % red
        set(hAxes,'UserData',[3,2,I(i)])            % yellow/red
        
    else                        % Actuator can move to target

        set(hText,'BackgroundColor',colors(5,:))    % light gray
        set(hText,'ForegroundColor','black')
        set(hAxes,'UserData',[1,2,I(i)])            % green/red
    end
end

% --------------------------------------------------------------------
function S = GetStageTargets(Data)
S = [get(Data.XTarget, 'Value')
     get(Data.YTarget, 'Value')
     get(Data.ZTarget, 'Value')
     get(Data.RxTarget,'Value')
     get(Data.RyTarget,'Value')];

% --------------------------------------------------------------------
function S = GetStageActuals(Data)
S = [get(Data.XActual, 'Value')
     get(Data.YActual, 'Value')
     get(Data.ZActual, 'Value')
     get(Data.RxActual,'Value')
     get(Data.RyActual,'Value')];

% --------------------------------------------------------------------
function A = GetA123Targets(Data)
A = [get(Data.A1Target,'Value')
     get(Data.A2Target,'Value')
     get(Data.A3Target,'Value')];

% --------------------------------------------------------------------
function A = GetA456Targets(Data)
A = [get(Data.A4Target,'Value')
     get(Data.A5Target,'Value')
     get(Data.A6Target,'Value')];
    
% --------------------------------------------------------------------
function A = GetA123Actuals(Data)
A = [get(Data.A1Actual,'Value')
     get(Data.A2Actual,'Value')
     get(Data.A3Actual,'Value')];
 
% --------------------------------------------------------------------
function A = GetA456Actuals(Data)
A = [get(Data.A4Actual,'Value')
     get(Data.A5Actual,'Value')
     get(Data.A6Actual,'Value')];

% --------------------------------------------------------------------
function A = GetA123Diff(Data)
A = [get(Data.A1Diff,'Value')
     get(Data.A2Diff,'Value')
     get(Data.A3Diff,'Value')];
 
% --------------------------------------------------------------------
function A = GetA456Diff(Data)
A = [get(Data.A4Diff,'Value')
     get(Data.A5Diff,'Value')
     get(Data.A6Diff,'Value')];

% --------------------------------------------------------------------
function SetStageTargets(Data,S)
set(Data.XTarget, 'Value',S(1),'String',sprintf('%0.3f',S(1)))
set(Data.YTarget, 'Value',S(2),'String',sprintf('%0.3f',S(2)))
set(Data.ZTarget, 'Value',S(3),'String',sprintf('%0.3f',S(3)))
set(Data.RxTarget,'Value',S(4),'String',sprintf('%0.2f',S(4)))
set(Data.RyTarget,'Value',S(5),'String',sprintf('%0.2f',S(5)))

% --------------------------------------------------------------------
function SetStageActuals(Data,S)
set(Data.XActual, 'Value',S(1),'String',sprintf('%0.3f',S(1)))
set(Data.YActual, 'Value',S(2),'String',sprintf('%0.3f',S(2)))
set(Data.ZActual, 'Value',S(3),'String',sprintf('%0.3f',S(3)))
set(Data.RxActual,'Value',S(4),'String',sprintf('%0.2f',S(4)))
set(Data.RyActual,'Value',S(5),'String',sprintf('%0.2f',S(5)))

% --------------------------------------------------------------------
function SetStageDiff(Data,S)
set(Data.XDiff, 'Value',S(1),'String',sprintf('%0.3f',S(1)))
set(Data.YDiff, 'Value',S(2),'String',sprintf('%0.3f',S(2)))
set(Data.ZDiff, 'Value',S(3),'String',sprintf('%0.3f',S(3)))
set(Data.RxDiff,'Value',S(4),'String',sprintf('%0.2f',S(4)))
set(Data.RyDiff,'Value',S(5),'String',sprintf('%0.2f',S(5)))

% --------------------------------------------------------------------
function SetActuatorTargets(Data,A)
set(Data.A1Target,'Value',A(1),'String',sprintf('%0.3f',A(1)))
set(Data.A2Target,'Value',A(2),'String',sprintf('%0.3f',A(2)))
set(Data.A3Target,'Value',A(3),'String',sprintf('%0.3f',A(3)))
set(Data.A4Target,'Value',A(4),'String',sprintf('%0.3f',A(4)))
set(Data.A5Target,'Value',A(5),'String',sprintf('%0.3f',A(5)))
set(Data.A6Target,'Value',A(6),'String',sprintf('%0.3f',A(6)))

% --------------------------------------------------------------------
function SetA123Actuals(Data,A)
set(Data.A1Actual,'Value',A(1),'String',sprintf('%0.3f',A(1)))
set(Data.A2Actual,'Value',A(2),'String',sprintf('%0.3f',A(2)))
set(Data.A3Actual,'Value',A(3),'String',sprintf('%0.3f',A(3)))

% --------------------------------------------------------------------
function SetA456Actuals(Data,A)
set(Data.A4Actual,'Value',A(1),'String',sprintf('%0.3f',A(1)))
set(Data.A5Actual,'Value',A(2),'String',sprintf('%0.3f',A(2)))
set(Data.A6Actual,'Value',A(3),'String',sprintf('%0.3f',A(3)))

% --------------------------------------------------------------------
function SetA123Diff(Data,A)
set(Data.A1Diff,'Value',A(1),'String',sprintf('%0.3f',A(1)))
set(Data.A2Diff,'Value',A(2),'String',sprintf('%0.3f',A(2)))
set(Data.A3Diff,'Value',A(3),'String',sprintf('%0.3f',A(3)))

% --------------------------------------------------------------------
function SetA456Diff(Data,A)
set(Data.A4Diff,'Value',A(1),'String',sprintf('%0.3f',A(1)))
set(Data.A5Diff,'Value',A(2),'String',sprintf('%0.3f',A(2)))
set(Data.A6Diff,'Value',A(3),'String',sprintf('%0.3f',A(3)))

% --------------------------------------------------------------------
