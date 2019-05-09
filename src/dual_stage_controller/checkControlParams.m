function controlParams = checkControlParams(controlParams)

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

if ~isfield(controlParams,'Kpsf')
    controlParams.Kpsf=1;
end
if isempty(controlParams.Kpsf)
    controlParams.Kpsf=1;
end
if controlParams.Kpsf<0 
    controlParams.Kpsf=1;
end

if ~isfield(controlParams,'Kisf')
    controlParams.Kisf=0.1;
end
if isempty(controlParams.Kisf)
    controlParams.Kisf=0.1;
end
if controlParams.Kisf<0 
    controlParams.Kisf=0.1;
end

if ~isfield(controlParams,'Kdsf')
    controlParams.Kdsf=10;
end
if isempty(controlParams.Kdsf)
    controlParams.Kdsf=10;
end
if controlParams.Kdsf<0 
    controlParams.Kdsf=10;
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

if ~isfield(controlParams,'sfTempErrorHist')
    controlParams.sfTempErrorHist=zeros(1,controlParams.Nbuf);
end
if isempty(controlParams.sfTempErrorHist)
    controlParams.sfTempErrorHist=zeros(1,controlParams.Nbuf);
end