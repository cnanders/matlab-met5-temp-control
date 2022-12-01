function toggleVentMode

global controlParams;
global ATEC302

s=get(gcbo,'Value');
if (s)
   controlParams.controlMode=4;
   h=findobj(gcbf,'Tag','cb_coast');
   set(h,'Value',0);
   h=findobj(gcbf,'Tag','cb_heat');
   set(h,'Value',0);
   h=findobj(gcbf,'Tag','cb_cool');
   set(h,'Value',0);
   % 6/15/22 change, we now keep chillers in closed loop mode during vent
   % but add a 0.3 degree positive offset to the PO target temp
   % this is done in the "vent mode" section of tempControlLoop.m
   for i=1:4
      % ATEC302(i).comm.disable;
   end;
else
   h=findobj(gcbf,'Tag','cb_coast');
   set(h,'Value',0);
   h=findobj(gcbf,'Tag','cb_heat');
   set(h,'Value',0);
   h=findobj(gcbf,'Tag','cb_cool');
   set(h,'Value',0);
   controlParams.controlMode=1;
   for i=1:4
      % ATEC302(i).comm.enableSPON;
   end;
end;
tempSensorTimerCallback;