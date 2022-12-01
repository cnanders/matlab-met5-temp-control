function measurePoint = init_measurePoint()

% Initiate a MesaurPoint client
    cIP = '192.168.20.27';
    measurePoint = datatranslation.MeasurPoint(cIP);
    measurePoint.connect(); % Connect the instrument through TCP/IP
    measurePoint.idn(); % Ask the instument its id using SCPI standard queries
    measurePoint.enable(); % Enable readout on protected channels
    
     % Show all MeasurePoint channel hardware types (These cannot be set)
    [tc, rtd, volt] = measurePoint.channelType();
    fprintf('bl12014.Logger.init():\n');
    fprintf('DataTranslation MeasurPoint Hardware configuration:\n');
    fprintf('TC   sensor channels = %s\n',num2str(tc,'%1.0f '))
    fprintf('RTD  sensor channels = %s\n',num2str(rtd,'%1.0f '))
    fprintf('Volt sensor channels = %s\n',num2str(volt,'%1.0f '))

    % Configure MeasurePoint to know what hardware we have connected
    % to each channel
    channels = 0 : 7;
    for n = channels
       measurePoint.setSensorType(n, 'J');
    end

    channels = 8 : 15;
    for n = channels
        measurePoint.setSensorType(n, 'PT1000');
    end

    channels = 16 : 19;
    for n = channels
        measurePoint.setSensorType(n, 'PT100');
    end

    channels = 20 : 23;
    for n = channels
       measurePoint.setSensorType(n, 'PT1000');
    end

    channels = 24 : 31;
    for n = channels
        measurePoint.setSensorType(n, 'PT100');
    end

    channels = 32 : 47;
    for n = channels
        measurePoint.setSensorType(n, 'V');
    end

    % Set up continuous population of internal memory buffer
    measurePoint.setScanList(0:47);
    measurePoint.setScanPeriod(0.1);
    measurePoint.initiateScan();
    % measurePoint.abortScan();
    measurePoint.clearBytesAvailable();
