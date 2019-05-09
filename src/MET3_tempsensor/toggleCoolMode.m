function toggleCoolMode

global coolMode;
global heatMode;
global coastMode;

s=get(gcbo,'Value');
if (s)
   coolMode=1;
   heatMode=0;
   coastMode=0;
   h=findobj(gcbf,'Tag','cb_coast');
   set(h,'Value',0);
   h=findobj(gcbf,'Tag','cb_heat');
   set(h,'Value',0);
else
   coolMode=0;
end;