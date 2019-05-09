function toggleHeatMode

global controlParams;

s=get(gcbo,'Value');
if (s)
   controlParams.controlMode=3;
   h=findobj(gcbf,'Tag','cb_cool');
   set(h,'Value',0);
   h=findobj(gcbf,'Tag','cb_coast');
   set(h,'Value',0);
else
   controlParams.controlMode=1;
end;