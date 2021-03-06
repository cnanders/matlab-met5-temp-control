function tempReadTimerCallback

global currentTemp      % vector holding the current temperature values for all physical channels
global csgHandle;
global tempSensorTimer  % handle to the control loop timer
persistent bufferFull;

try
    %% ensure that the Control Loop Timer is still running
    % I have this here because I have observed timers being shut off for not reason
    if ~isempty(tempSensorTimer)
        if ~strcmp(get(tempSensorTimer,'running'),'on')
            start(tempSensorTimer);
        end;
    end;
    
    %% Determine the averaging buffer status
    if isempty(bufferFull)
        bufferFull=0;
    end;

    currentTemp.avgCnt = currentTemp.avgCnt+1;
    if currentTemp.avgCnt > currentTemp.avg
        currentTemp.avgCnt = 1;
        bufferFull=1;
    end;

    %% get the noise values for each channel such that we can use that to implement error checking
    if bufferFull
        nv=std(currentTemp.buffer,1,2)*6+0.6;
        nvTemps=nv(4:currentTemp.Nchan-4)';
        nvChills=nv(currentTemp.Nchan-3:currentTemp.Nchan)';
    end;

    %% read actual hardware temps and implement error checking
    % error checking
    bs_new = readTemps(); % read raw temps from data translation
    if bufferFull
        lastIdx = currentTemp.avgCnt-1;
        if (lastIdx==0)
            lastIdx = currentTemp.avg;
        end;
        bs_old = currentTemp.buffer(4:currentTemp.Nchan-4,lastIdx)'; % get last reading
        w = find(nvTemps-abs(bs_new-bs_old)<0); % look for greater than 6 sigma change
        bs_new(w)=bs_old(w); % if new reading is outlier, replace with previous reading
    end;
    currentTemp.buffer(4:currentTemp.Nchan-4,currentTemp.avgCnt) = bs_new;  % read raw temps from data translation

    bs_new = readChillers(); % read raw temps from data translation
    if bufferFull
        lastIdx = currentTemp.avgCnt-1;
        if (lastIdx==0)
            lastIdx = currentTemp.avg;
        end;
        bs_old = currentTemp.buffer(currentTemp.Nchan-3:currentTemp.Nchan,lastIdx)'; % get last reading
        w = find(nvChills-abs(bs_new-bs_old)<0); % look for greater than 6 sigma change
        bs_new(w)=bs_old(w);  % if new reading is outlier, replace with previous reading
    end;
    currentTemp.buffer(currentTemp.Nchan-3:currentTemp.Nchan,currentTemp.avgCnt) = bs_new;  % read raw temps from chillers

    %% create virtual temperature channels
    %currentTemp.buffer(1,currentTemp.avgCnt)=mean(currentTemp.buffer([17:20,31,32]+3,currentTemp.avgCnt));  % average optic temp
    currentTemp.buffer(1,currentTemp.avgCnt)=mean(currentTemp.buffer([18,19,20]+3,currentTemp.avgCnt));  % average optic temp excluding M2
    currentTemp.buffer(2,currentTemp.avgCnt)=mean(currentTemp.buffer(currentTemp.Nchan-3:currentTemp.Nchan,currentTemp.avgCnt));  % average chiller temp
    currentTemp.buffer(3,currentTemp.avgCnt)=mean(currentTemp.buffer([10,14,16,24]+3,currentTemp.avgCnt));  % average subframe temp

    %% get rolling average
    if bufferFull
        currentTemp.avgTemps=mean(currentTemp.buffer,2);
    else
        currentTemp.avgTemps=mean(currentTemp.buffer(:,1:currentTemp.avgCnt),2);
    end;

    %% Display "real time" temps in control panel
    h=findobj(csgHandle,'Tag','st_ot');
    set(h,'String',num2str(currentTemp.avgTemps(1),'%5.3f'));
    h=findobj(csgHandle,'Tag','st_cp1');
    set(h,'String',num2str(currentTemp.avgTemps(currentTemp.Nchan-3),'%4.2f'));
    h=findobj(csgHandle,'Tag','st_cp2');
    set(h,'String',num2str(currentTemp.avgTemps(currentTemp.Nchan-2),'%4.2f'));
    h=findobj(csgHandle,'Tag','st_cp3');
    set(h,'String',num2str(currentTemp.avgTemps(currentTemp.Nchan-1),'%4.2f'));
    h=findobj(csgHandle,'Tag','st_cp4');
    set(h,'String',num2str(currentTemp.avgTemps(currentTemp.Nchan),'%4.2f'));
    h=findobj(csgHandle,'Tag','st_sf1'); 
    set(h,'String',num2str(currentTemp.avgTemps(10+3),'%4.2f'));
    h=findobj(csgHandle,'Tag','st_sf2'); 
    set(h,'String',num2str(currentTemp.avgTemps(14+3),'%4.2f'));
    h=findobj(csgHandle,'Tag','st_sf3'); 
    set(h,'String',num2str(currentTemp.avgTemps(16+3),'%4.2f'));
    h=findobj(csgHandle,'Tag','st_sf4'); 
    set(h,'String',num2str(currentTemp.avgTemps(24+3),'%4.2f'));
catch mE
   error(getReport(mE));
end;