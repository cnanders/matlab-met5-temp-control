function toggleCoastMode

global coolMode;
global heatMode;
global coastMode;

s=get(gcbo,'Value');
if (s)
   coolMode=0;
   heatMode=0;
   coastMode=1;
   h=findobj(gcbf,'Tag','cb_cool');
   set(h,'Value',0);
   h=findobj(gcbf,'Tag','cb_heat');
   set(h,'Value',0);
else
   coastMode=0;
end;