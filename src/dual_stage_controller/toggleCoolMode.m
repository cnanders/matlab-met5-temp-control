function toggleCoolMode

global controlParams;
global ATEC302

s=get(gcbo,'Value');
if (s)
   controlParams.controlMode=2;
   h=findobj(gcbf,'Tag','cb_coast');
   set(h,'Value',0);
   h=findobj(gcbf,'Tag','cb_heat');
   set(h,'Value',0);
   h=findobj(gcbf,'Tag','cb_vent');
   set(h,'Value',0);
   for i=1:4
       ATEC302(i).comm.enableSPON;
   end;
else
   h=findobj(gcbf,'Tag','cb_coast');
   set(h,'Value',0);
   h=findobj(gcbf,'Tag','cb_heat');
   set(h,'Value',0);
   h=findobj(gcbf,'Tag','cb_vent');
   set(h,'Value',0);
   controlParams.controlMode=1;
end;
tempSensorTimerCallback;