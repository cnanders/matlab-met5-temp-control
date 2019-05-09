% function controlParams = tempControlLoop(data,controlParams)
%
% data structure:
%     temps: 2d array with circular buffer history of temp data [channel,index]
%     currentIdx: index to current reading
%     Nbuf: buffer size
%     Nchan: number of channels
%     Labels: channel labels cell array
%
% controlParams structure:
%     tempGoal: target temperature
%     controlChannel: data channel being controlled
%     controlMode: 0 = coast, 1 = normal, 2 = cool, 3 = heat
%     Kp: proportional gain
%     Ki: integral gain
%     Kd: derivative gain
%     T: Sample interval time in minutes
%     KdT: Derivative measurement time delay in minutes
%     Nbuf: history buffer size
%     currentIdx: index to current position in history buffer
%     loopPassCnt: index to current position in history buffer
%     chillPlateTemp: chill plate current temperature
%     setPoint: chill plate set point
%     adp_Kpr: adaptive chiller reference point
%     maxSetPoint: chiller max set point
%     minSetPoint: chiller min set point
%     setPointHist: history of the setPoint
%     chillplateHist: history of the chillplate temp
%     tempErrorHist: history of the temperature error
%     tempDerivHist: history of the temperature error derivate

function controlParams = tempControlLoop(data,controlParams)

global csgHandle;
global epHandle;

%% error checking
if ~isfield(controlParams,'tempGoal')
    controlParams.tempGoal=22;
end
if isempty(controlParams.tempGoal)
    controlParams.tempGoal=22;
end
if controlParams.tempGoal<21 | controlParams.tempGoal>23
    controlParams.tempGoal=22;
end

if ~isfield(controlParams,'controlChannel')
    controlParams.controlChannel=1;
end
if isempty(controlParams.controlChannel)
    controlParams.tempGoal=1;
end

if ~isfield(controlParams,'minSetPoint')
    controlParams.minSetPoint=10;
end
if isempty(controlParams.minSetPoint)
    controlParams.minSetPoint=10;
end
if controlParams.minSetPoint<10 | controlParams.minSetPoint>28
    controlParams.minSetPoint=10;
end

if ~isfield(controlParams,'maxSetPoint')
    controlParams.maxSetPoint=28;
end
if isempty(controlParams.maxSetPoint)
    controlParams.maxSetPoint=28;
end
if controlParams.maxSetPoint<10 | controlParams.maxSetPoint>28
    controlParams.maxSetPoint=28;
end

if ~isfield(controlParams,'setPoint')
    controlParams.setPoint=12;
end
if isempty(controlParams.setPoint)
    controlParams.setPoint=12;
end
if controlParams.setPoint<controlParams.minSetPoint | controlParams.setPoint>controlParams.maxSetPoint
    controlParams.setPoint=12;
end

if ~isfield(controlParams,'Kp')
    controlParams.Kp=1;
end
if isempty(controlParams.Kp)
    controlParams.Kp=1;
end
if controlParams.Kp<0 
    controlParams.Kp=1;
end

if ~isfield(controlParams,'Ki')
    controlParams.Ki=0.1;
end
if isempty(controlParams.Ki)
    controlParams.Ki=0.1;
end
if controlParams.Ki<0 
    controlParams.Ki=0.1;
end

if ~isfield(controlParams,'Kd')
    controlParams.Kd=10;
end
if isempty(controlParams.Kd)
    controlParams.Kd=10;
end
if controlParams.Kd<0 
    controlParams.Kd=10;
end

if ~isfield(controlParams,'T')
    controlParams.T=15;
end
if isempty(controlParams.T)
    controlParams.T=15;
end
if controlParams.T<1 | controlParams.T>60
    controlParams.T=15;
end

if ~isfield(controlParams,'KdT')
    controlParams.KdT=60;
end
if isempty(controlParams.KdT)
    controlParams.KdT=60;
end
if controlParams.KdT<controlParams.T | controlParams.KdT>180
    controlParams.KdT=60;
end

if ~isfield(controlParams,'Nbuf')
    controlParams.Nbuf=2688;
end
if isempty(controlParams.Nbuf)
    controlParams.Nbuf=2688;
end
if controlParams.T<1000 | controlParams.T>10000
    controlParams.Nbuf=2688;
end

if ~isfield(controlParams,'loopPassCnt')
    controlParams.loopPassCnt=0;
end
if isempty(controlParams.loopPassCnt)
    controlParams.loopPassCnt=0;
end

if ~isfield(controlParams,'currentIdx')
    controlParams.currentIdx=0;
end
if isempty(controlParams.currentIdx)
    controlParams.currentIdx=0;
end
if controlParams.currentIdx<1 | controlParams.currentIdx>controlParams.Nbuf
    controlParams.currentIdx=0;
end

if ~isfield(controlParams,'controlMode')
    controlParams.controlMode=1;
end
if isempty(controlParams.controlMode)
    controlParams.controlMode=1;
end
if controlParams.controlMode<0 | controlParams.controlMode>3
    controlParams.controlMode=1;
end

if ~isfield(controlParams,'setPointHist')
    controlParams.setPointHist=zeros(1,controlParams.Nbuf)+12;
end
if isempty(controlParams.setPointHist)
    controlParams.setPointHist=zeros(1,controlParams.Nbuf)+12;
end

if ~isfield(controlParams,'tempErrorHist')
    controlParams.tempErrorHist=zeros(1,controlParams.Nbuf);
end
if isempty(controlParams.tempErrorHist)
    controlParams.tempErrorHist=zeros(1,controlParams.Nbuf);
end

if ~isfield(controlParams,'tempDerivHist')
    controlParams.tempDerivHist=zeros(1,controlParams.Nbuf);
end
if isempty(controlParams.tempDerivHist)
    controlParams.tempDerivHist=zeros(1,controlParams.Nbuf);
end

if ~isfield(controlParams,'chillplateHist')
    controlParams.chillplateHist=zeros(1,controlParams.Nbuf)+12;
end
if isempty(controlParams.chillplateHist)
    controlParams.chillplateHist=zeros(1,controlParams.Nbuf)+12;
end

if ~isfield(controlParams,'subframeHist')
    controlParams.subframeHist=zeros(1,controlParams.Nbuf)+22.5;
end
if isempty(controlParams.subframeHist)
    controlParams.subframeHist=zeros(1,controlParams.Nbuf)+22.5;
end
% end of parameter error checking

%% extract the current temperature for the target controlled channel
currentTemp=data.temps(controlParams.controlChannel,data.currentIdx);
  
%% Make sure we are in reasonable optic temp bounds before entering the control loop
if (currentTemp<15) 
    fprintf('Not updating chiller on this cycle because OPTIC temp is < 15 C. Something must be wrong \n');
    fprintf('tempControlLoop.m: Optic temperature is %1.2f.\n', currentTemp);
    return;
end;
if (currentTemp>29)
    fprintf('Not updating chiller on this cycle because OPTIC temp is > 29 C. Something must be wrong \n')
    fprintf('tempControlLoop.m: Optic temperature is %1.2f.\n', currentTemp);
    return;
end
%====================================================================================

%% update the control loop index count
controlParams.currentIdx=controlParams.currentIdx+1;
if controlParams.currentIdx>controlParams.Nbuf
    controlParams.currentIdx=1;
end;

%% get current control temp, chillplate temp, and temp error
% determine the control temp error
tempError=currentTemp-controlParams.tempGoal;

% get current chillplate temp (channel #2) and add to control loop history
controlParams.chillplateHist(controlParams.currentIdx)=data.temps(2,data.currentIdx);

% get current subframe temp (channel #3) and add to control loop history
controlParams.subframeHist(controlParams.currentIdx)=data.temps(3,data.currentIdx);

% add temp error to control loop history
controlParams.tempErrorHist(controlParams.currentIdx)=tempError;
if (abs(controlParams.tempErrorHist(controlParams.currentIdx))>1) 
    controlParams.tempErrorHist(controlParams.currentIdx)=1*sign(controlParams.tempErrorHist(controlParams.currentIdx)); 
end;

%% coast mode
if(controlParams.controlMode==0)  % coast mode
    h=findobj(csgHandle,'Tag','cb_cool');
    set(h,'Value',0);
    h=findobj(csgHandle,'Tag','cb_heat');
    set(h,'Value',0);
    h=findobj(csgHandle,'Tag','cb_coast');
    set(h,'Value',1);
    fprintf('%s ',datestr(now));
    fprintf('Coast: Goal=%3.1f  Temp=%4.3f  Chiller=%3.1f\n',controlParams.tempGoal,currentTemp,controlParams.setPoint);
	% log file
	fid=fopen('log.txt','at');
	fprintf(fid,'%s,',datestr(now));
	for i=1:10
        % write the individual channel temps
	end
    fprintf(fid,'%3.1f,%4.3f,%4.2f,%4.2f,%3.1f,%4.2f,%4.3f,%4.3f\n',controlParams.tempGoal,currentTemp,controlParams.setPoint,controlParams.adp_Kpr,controlParams.Kp,controlParams.Ki,controlParams.Kd,controlParams.T);
	fclose(fid);
    
	figure(epHandle);
    bs=historyUnwrap(controlParams.tempErrorHist,controlParams.currentIdx);
    t=plotdom(-controlParams.Nbuf*controlParams.T/60,0,controlParams.Nbuf);
	plot(t,bs,t,bs*0+0.01,'r',t,bs*0-0.01,'r');
    title('COAST MODE');
    grid;
    xlabel('hours');
    ylabel('Control temperature error');
    return;
end;
    
%% cool mode
if (controlParams.controlMode==2)
    h=findobj(csgHandle,'Tag','cb_cool');
    set(h,'Value',1);
    h=findobj(csgHandle,'Tag','cb_heat');
    set(h,'Value',0);
    h=findobj(csgHandle,'Tag','cb_coast');
    set(h,'Value',0);
    if (tempError>0.05) 
        fprintf('%s ',datestr(now));
        fprintf('Temp=%4.2f, Cooling mode, closed loop disabled, chiller set to min\n',currentTemp);
        % log file
        fid=fopen('log.txt','at');
        fprintf(fid,'%s,',datestr(now));
        for i=1:10
            % write the individual channel temps
        end
        fprintf(fid,'%3.1f,%4.3f,%4.2f,%4.2f,%3.1f,%4.2f,%4.3f,%4.3f\n',controlParams.tempGoal,currentTemp,controlParams.setPoint,controlParams.adp_Kpr,controlParams.Kp,controlParams.Ki,controlParams.Kd,controlParams.T);
        fclose(fid);

        figure(epHandle);
        bs=historyUnwrap(controlParams.tempErrorHist,controlParams.currentIdx);
        t=plotdom(-controlParams.Nbuf*controlParams.T/60,0,controlParams.Nbuf);
        plot(t,bs,t,bs*0+0.01,'r',t,bs*0-0.01,'r');
        title('COOL MODE');
        grid;
        xlabel('hours');
        ylabel('Control temperature error');
        controlParams.setPoint=controlParams.minSetPoint;
        return;
    else
        controlParams.controlMode=1;
        h=findobj(csgHandle,'Tag','cb_cool');
        set(h,'Value',0);
        h=findobj(csgHandle,'Tag','cb_heat');
        set(h,'Value',0);
        h=findobj(csgHandle,'Tag','cb_coast');
        set(h,'Value',0);
    end;
end;

%% heat mode
if (controlParams.controlMode==3)
    h=findobj(csgHandle,'Tag','cb_cool');
    set(h,'Value',0);
    h=findobj(csgHandle,'Tag','cb_heat');
    set(h,'Value',1);
    h=findobj(csgHandle,'Tag','cb_coast');
    set(h,'Value',0);    
    if (tempError<-0.05) 
        fprintf('%s ',datestr(now));
        fprintf('Temp=%4.2f, Cooling mode, closed loop disabled, chiller set to min\n',currentTemp);
        % log file
        fid=fopen('log.txt','at');
        fprintf(fid,'%s,',datestr(now));
        for i=1:10
            % write the individual channel temps
        end
        fprintf(fid,'%3.1f,%4.3f,%4.2f,%4.2f,%3.1f,%4.2f,%4.3f,%4.3f\n',controlParams.tempGoal,currentTemp,controlParams.setPoint,controlParams.adp_Kpr,controlParams.Kp,controlParams.Ki,controlParams.Kd,controlParams.T);
        fclose(fid);

        figure(epHandle);
        bs=historyUnwrap(controlParams.tempErrorHist,controlParams.currentIdx);
        t=plotdom(-controlParams.Nbuf*controlParams.T/60,0,controlParams.Nbuf);
        plot(t,bs,t,bs*0+0.01,'r',t,bs*0-0.01,'r');
        title('HEAT MODE');
        grid;
        xlabel('hours');
        ylabel('Control temperature error');
        controlParams.setPoint=controlParams.maxSetPoint;
        return;
    else
        controlParams.controlMode=1;
        h=findobj(csgHandle,'Tag','cb_cool');
        set(h,'Value',0);
        h=findobj(csgHandle,'Tag','cb_heat');
        set(h,'Value',0);
        h=findobj(csgHandle,'Tag','cb_coast');
        set(h,'Value',0);
    end;
end;

%% adaptive Kp and Ki section
% if temperature error is large turn off Ki and set Kp to 10
if tempError>0.1
    KpMem=controlParams.Kp;
    KiMem=controlParams.Ki;
    controlParams.Kp=10;
    controlParams.Ki=0;
end;

%% increase the control loop index counter
controlParams.loopPassCnt=controlParams.loopPassCnt+1;  

%% determine derivative
% convert the derivative time difference to index and error check the result
idx_derivative=controlParams.currentIdx-ceil(controlParams.KdT/controlParams.T); 
if (idx_derivative<=0)
    idx_derivative=controlParams.Nbuf-idx_derivative;
end;
if (idx_derivative<=0)
    idx_derivative=1;
end;
% assuming we have been running for at least as long as the target
% derivative delay, compute the temperature error derivative
if controlParams.loopPassCnt>ceil(controlParams.KdT/controlParams.T)
    tempDeriv=controlParams.tempErrorHist(idx_derivative)-controlParams.tempErrorHist(controlParams.currentIdx);
else
    tempDeriv=0;
end;
if (abs(tempDeriv)>0.1) tempDeriv=0; end; % disable Kd under temp spike conditions

controlParams.tempDerivHist(controlParams.currentIdx)=tempDeriv;

%% Determine intergral term
bs=historyUnwrap(controlParams.tempErrorHist,controlParams.currentIdx);
KiBoost=sum(flipline(bs).*(exp((-([0:controlParams.Nbuf-1]))/10)))*controlParams.Ki; % put exponential decay on integral
if (abs(KiBoost)>3) KiBoost=3*sign(KiBoost); end; 

%% determine the target steady state chillplate temperature
% weight set by (1-error)^2 with exponential decay as a function of past time
bs=flipline(historyUnwrap(controlParams.tempErrorHist,controlParams.currentIdx));
w_factor=(max(1-abs(bs*10),0).^2).*((1-abs(bs*10)).^2).*(exp((-([0:controlParams.Nbuf-1]))/600)); % ignore points where optic error is too large

bs=flipline(historyUnwrap(controlParams.chillplateHist,controlParams.currentIdx));
adp_Kpr=sum(bs.*w_factor)./sum(w_factor);
controlParams.adp_Kpr=adp_Kpr;

%% determine the target instantaneous chillplate temperature
% applies Kp, Kd, and Ki corrections to the steady state chillplate temp target determined above
controlParams.setPoint=adp_Kpr-KiBoost-controlParams.Kp*tempError+tempDeriv*controlParams.Kd; % combined Kp Ki Kp method

controlParams.setPointHist(controlParams.currentIdx)=controlParams.setPoint;

%% display status in control window
fprintf('%s ',datestr(now));
fprintf('Goal=%3.1f  Temp=%4.3f  Chiller=%3.1f  ChillerAdpRef=%4.2f Kp=%4.3f Ki=%4.3f Kd=%4.3f\n',controlParams.tempGoal,currentTemp,controlParams.setPoint,controlParams.adp_Kpr,controlParams.Kp,controlParams.Ki,controlParams.Kd);

%% Send "I'm Alive" email
% 	global aliveCounter;
% 	if isempty(aliveCounter)
%         aliveCounter=str2num(datestr(now,'dd'));
% 	end;
% 	if str2num(datestr(now,'dd')) ~= aliveCounter
%         bs=datestr(now,'HH:MM');
%         bs=str2num(bs(1:2));
%         if bs>9
%             aliveCounter=str2num(datestr(now,'dd'));
%             sendTroubleEmail(sprintf('Matlab MET Temp Control Loop is Alive:  Optic Temp = %4.3f,   Room Temp = %4.2f,  Chiller Temp ==%3.1f ',currentTemp,controlParams.setPoint),sprintf('MET Temperature Daily Update'));
%         end;
% 	end;
    

%% log file
fid=fopen('log.txt','at');
fprintf(fid,'%s,',datestr(now));
for i=1:10
    % write the individual channel temps
end
fprintf(fid,'%3.1f,%4.3f,%4.2f,%4.2f,%3.1f,%4.2f,%4.3f\n',controlParams.tempGoal,currentTemp,controlParams.setPoint,controlParams.Kp,controlParams.Ki,controlParams.Kd,controlParams.T);
fclose(fid);


%% temprature control status and control GUI
h=findobj(csgHandle,'Tag','ed_set_arr');
set(h,'String',num2str(adp_Kpr,'%4.2f'));
h=findobj(csgHandle,'Tag','ed_set_chiller');
set(h,'String',num2str(controlParams.setPoint,'%3.1f'));
h=findobj(csgHandle,'Tag','st_ot');
set(h,'String',num2str(currentTemp,'%5.3f'));
h=findobj(csgHandle,'Tag','st_cpt');
set(h,'String',num2str(controlParams.chillPlateTemp,'%4.2f'));

h=findobj(csgHandle,'Tag','st_kpg');
set(h,'String',num2str(-controlParams.Kp*tempError,'%4.2f'));
h=findobj(csgHandle,'Tag','st_kig');
set(h,'String',num2str(-KiBoost,'%4.2f'));
h=findobj(csgHandle,'Tag','st_kdg');
set(h,'String',num2str(tempDeriv*controlParams.Kd,'%4.2f'));

figure(epHandle);
bs=historyUnwrap(controlParams.tempErrorHist,controlParams.currentIdx);
t=plotdom(-controlParams.Nbuf*controlParams.T/60,0,controlParams.Nbuf);
subplot(3,1,1);
plot(t,bs,t,bs*0+0.01,'r',t,bs*0-0.01,'r');
grid;
xlabel('hours');
ylabel('Control Temperature Error');
subplot(3,1,2);
bs=historyUnwrap(controlParams.chillplateHist,controlParams.currentIdx);
plot(t,bs);
grid;
xlabel('hours');
ylabel('Chill Plate Temp');
subplot(3,1,3);
bs=historyUnwrap(controlParams.subframeHist,controlParams.currentIdx);
plot(t,bs);
grid;
xlabel('hours');
ylabel('Subframe Temp');

%% reset adaptive Kp and Ki section
if tempError>0.1
    controlParams.Kp=KpMem;
    controlParams.Ki=KiMem;
end;

%% send trouble email if problem has been detected
% global troubleEmailSent;
% if (controlParams.setPoint<15)
%     if isempty(troubleEmailSent)
%         troubleEmailSent=0;
%     end;
%     if ~troubleEmailSent
%         troubleEmailSent=1; % disable further email warnings
% %        sendTroubleEmail(sprintf('MET room temp > 20    %s   Temp=%4.3f  RoomTemp=%4.2f  RoomGoal=%4.2f  Chiller=%3.1f  RoomAdpRef=%4.2f Kp=%4.3f Ki=%4.3f ChillerKi=%4.3f Kd=%4.3f',datestr(now),currentTemp,roomTemp,roomSetPoint,setPoint,adp_Kpr,Kp,Ki,Kic,Kd),'MET temperature problem!!!');
%     end;
% else
%     troubleEmailSent=0;  % enable future email warnings
% end;

% END OF TEMPERATURE CONTROL
