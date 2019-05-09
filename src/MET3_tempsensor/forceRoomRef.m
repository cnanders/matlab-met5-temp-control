function forceRoomRef(ref)

global roomSetPointHist
global adp_kpr
global roomTempErrorHist
global tempErrorHist
global coolMode

adp_kpr=ref;

roomSetPointHist=roomSetPointHist*0+adp_Kpr;
roomTempErrorHist=roomTempErrorHist*0;
tempErrorHist=tempErrorHist*0;
coolMode=0;
