% % % cytometerLoading_Mona.m
% %
%
clearvars; close all
tic
% In with parameters are you interested in?p
intParameters = ["FSC-H", "FSC-A", "SSC-H", "SSC-A", "SSC-Width","Time", "FL1-H", "FL2-H", "FL3-H"];
intParameters = ["FSC-H", "FSC-A", "SSC-H", "SSC-A", "SSC-Width","Time", "FL1-H", "FL2-H", "FL3-H"];


% MeasDayStart = "20220316A";
% MeasDayEnd   = "20220316A";
% expName    = "_LibSCBvalCM42_";p
% expName    = "_Bs166CM42_";
% plateName = "_plate2";
% measTimes = [4 8]; % in h

MeasDayStart = "20230824";
MeasDayEnd   = "20230824";
expName    = "_LibBvalwS3ctld5pops_Bs175_004_";
plateName = ""; % add "_plate2" if specified in the name
gfp = "Bs175";
measTimes = [0 18]; % in h


basePath = "H:\fitnessDistribution\2021_HighThroughputCompetition\";
basePath = "H:\fitnessDistribution\2022_withSelection\";
basePath = "H:\evolinLiquid\competitionExp\";

outPath = basePath;
savePlotPath = basePath + "resultsTmp\";

fcsPath_t0 = basePath + "RAW\" + MeasDayStart + expName + string(measTimes(1)) + "h" + plateName + "\";
fcsPath_t1 = basePath + "RAW\" + MeasDayEnd   + expName + string(measTimes(2)) + "h" + plateName + "\";

loadGate = "H:\evolinLiquid\competitionExp\gateFC_July2023_v1.mat";
% loadGate = "J:\sciebo\ResultsShared\DFE_HighThroughput\gateFC_Feb2022_withSelLibs.mat"; % for selection libraries (LibBvalwS2/3(ctl))
% loadGate = "H:\evolinLiquid\competitionExp\gateFC_2023_v1.mat"
load(loadGate)
gateVertices = gateFC.gateVertices; gateMode = gateFC.gateMode; 



% plots for each sample
infoFigs = "OFF";
whichSampl = [1 10 20 30 40 50 60 70];
whichSampl = 1:5:80;

%   For a subset of data sets, defined in whichFigures, 
% % you can get an overview figure.
overviewFigs = "ON";
whichFigs = [1 10 20 30 40 50 60 70];
whichFigs = whichSampl;
printFigs = "OFF";

% % % OPTIONAL: exclude large gaps in which little gfp is detected
excludeGapsOPT = "ON";
% --------- paramters to find gaps 
% ------------ XXX
events_onAv = 100;
cutOff_Gap   = 10;
% --------- additionally, exclude gfp leakage in the forbidden corridor!
% --- --------- this is only possible if you are already excluding 
% --- --------- gaps with excludeGapsOPT
excludeCorrOPT = "OFF";
% how to exclude the gfp leakage?? set here a corridor in which no data
% should appear!
corridor        = [10000 70000];
cutOff_forbidden = 5;            % this is the cutOff for the forbidden events

% % % exclude samples that have less than minEvents
minEvents = 15000;

%% load the gate 
% (created with: FindAGate_CytoMeasure.m & gateVerticesStructMaker.m)
% A lot of information is contained in the gate that is extracted here:

gate = load(loadGate);
gateFC = gate.gateFC;
gateVertices = gateFC.gateVertices; 
gateMode = gateFC.gateMode; 

% for working with Bs213/Bs212 Pveg_mScarlet/Pveg_gfp:
if numel(gateFC.gfpCutOff) == 1
    gfpCutOff = gateFC.gfpCutOff;
else
    tmp = gateFC.gfpCutOff;
    gfpCutOff = tmp(find([tmp.expName]== expName)).cutoff_t1;
    changeCutOff = 1;
end

% gateMode determines if height or area data are used
if gateMode == "A"
    fscPar = "FSC-A";
    sscPar = "SSC-A";
elseif gateMode == "H"
    fscPar = "FSC-H";
    sscPar = "SSC-H";
end

%% Predefine:
% --- subplots
% --- the grid fo the data

MultiFig(1) = ceil(sqrt(numel(whichFigs)));
MultiFig(2) = ceil(sqrt(numel(whichFigs)));

if MultiFig(1) == 1
    MultiFig(1) = 2;
end

% Calculating binEdges to be equidistant in logarithmic scale (ratio
% between two adjacent points is constant = binWidthLog)
xLin = 1 : 100;
binWidthLog = repmat(1.2, 1, length(xLin)); % Factor between two edges
binEdges = binWidthLog.^xLin;

% Creating a grid all over the SSC-A/FSC-A data
noSteps = 50;
if gateMode == "A"
    startXX = -10000; endXX = 100000;
    startYY = -10000; endYY = 100000;
elseif gateMode == "H"
    startXX = 0; endXX = 450000;
    startYY = 0; endYY = 400000;
end

xx = startXX : (endXX + abs(startXX))/(noSteps-1) : endXX;
yy = startYY : (endYY + abs(startYY))/(noSteps-1) : endYY;
[meshX,meshY] = meshgrid(xx+(endXX + abs(startXX))/(noSteps-1)/2,yy+(endYY + abs(startYY))/(noSteps-1)/2);

%% Evaluating the samples
% % % -- for both time points
for t = 1:2
    clear gfpFrac
    
    fprintf("Processing the data of the " + measTimes(t)+ "h - measurements ...\n");
    % predefine for the overview plots
    f1 = 0;
    
    if overviewFigs == "ON"
        if ~isempty(whichFigs)
            figure(10  + t)
            set(gcf,"Renderer", "Painters", 'Position', [1 1 1350 900]);
            figure(100 + t)
            set(gcf,"Renderer", "Painters", 'Position', [1 1 1350 900]);
            %         figure(50 + t)
            %         set(gcf,"Renderer", "Painters", 'Position', [1 1 1350 900]);
        end
    end
    
    if t == 1
        allFiles = dir(fcsPath_t1);
        fcsFiles(1,:) = fcsPath_t0 + string({allFiles(:).name});
        fcsFiles(2,:) = string(cellfun(@(x) x{1},...
            cellfun(@(x) split(x,".fcs"),{allFiles(:).name}, "UniformOutPut", false), "UniformOutPut", false));
        fcsFiles = fcsFiles(:,[allFiles(:).isdir]==0 & contains({allFiles(:).name}, "fcs"));
        fcsFilesRaw = fcsFiles;
        if ~contains(fcsFiles(2,1), "plate")
            fcsFiles(1,:) = fcsPath_t0 + fcsFilesRaw(2,:) + plateName + ".fcs";
            sampleNames = fcsFilesRaw(2,:) + plateName;
        else
            fcsFiles(1,:) = fcsPath_t0 + fcsFilesRaw(2,:) + ".fcs";
            sampleNames = fcsFilesRaw(2,:);
        end
    elseif t == 2
        fcsFiles(1,:) = fcsPath_t1 + fcsFilesRaw(2,:) + ".fcs";
    end
    
    
    % Keep track of how many events are detected
    keep_EnoughEvents_msk = true(length(fcsFiles),2);
    
    for i = 1:length(fcsFiles)
        
        % % Read out the data with the function: fca_readfcs
        % % output:
        % -- fcsdat is filled with all parameter values for all events
        % -- fcshdr is struct with information (paramter names, times...)
        % -- fcsdatscaled contains the log-scaled parameters

        [fcsdat, fcshdr, fcsdatscaled] = fca_readfcs(char(fcsFiles(1,i)));
        
        timestamp(i) = string(fcshdr.starttime);
        if t == 1 && i == 1
            % this date is printed into the output
            dateofmeasurement = string(fcshdr.date); 
        end
        
        % In the following, keep only interesting channels of events:
        % --- defined as intParameters
        % -- get the according paramters (in the right order)

        intFcsDat = fcsdat(:,(contains(string({fcshdr.par.name}), intParameters)));
        parOrder  = string({fcshdr.par(contains(string({fcshdr.par.name}), intParameters)).name});
        
        % Define the gfp and non-gfp data according to the gfpCutOff
        gfpCondition = intFcsDat(:,parOrder == "FL1-H") > gfpCutOff;
        gfpFcsDat    = intFcsDat(gfpCondition, :);
        NongfpFcsDat = intFcsDat(~gfpCondition, :);
        
        % Identify periods where little data is measured and exclude
        % --- in the following, we distinguish between excluding gaps and
        %     excluding data that "leaked" into a forbidden region

        if excludeGapsOPT == "ON"
             
            % Divide the data time windows that are evaluated:
            % % --- define the time windows (window_array) that on average
            %       comprise of *events_onAv* events
            % % --- these windows have the same duration but do not contain
            %       the same number of events
            
            num_timeWindows  = floor(size(intFcsDat,1)/events_onAv);
            maxTime          = intFcsDat(end,parOrder == "Time");
            windowDuration   = maxTime/num_timeWindows;
            window_array     = [0:num_timeWindows;1:num_timeWindows+1].*windowDuration;
            
            % collect the events in the windows
            inWin_intFcsDatEvents   = zeros(size(window_array,2),1);  % to find gaps
            inWin_forbiddenCorridor = zeros(size(window_array,2),1);  % to find gfp leakage
            
            for w=1:size(window_array,2)
                mask_Window_Events   = intFcsDat(:,parOrder == "Time")>=window_array(1,w) & intFcsDat(:,parOrder == "Time")<window_array(2,w);
                mask_Window_Corridor = intFcsDat(:,parOrder == "Time")>=window_array(1,w) & intFcsDat(:,parOrder == "Time")<window_array(2,w) &...
                    intFcsDat(:,parOrder == "FL1-H") > corridor(1) & intFcsDat(:,parOrder == "FL1-H") < corridor(2);
                
                inWin_intFcsDatEvents(w)   = sum(mask_Window_Events);
                inWin_forbiddenCorridor(w) = sum(mask_Window_Corridor);
            end
            
            % Exclude data in gaps if it is below the threshold cutOff_Gap
            excludeGaps_msk      = inWin_intFcsDatEvents <  cutOff_Gap;
            excludeGaps          = window_array(:,excludeGaps_msk');

            % here exclude the data that is in Gap
            intFcsDat_excludeGap_msk_mat = intFcsDat(:,parOrder == "Time") >= excludeGaps(1,:) & intFcsDat(:,parOrder == "Time") < excludeGaps(2,:);
            intFcsDat_excludeGap_msk_vec = sum(intFcsDat_excludeGap_msk_mat,2);
            
            if excludeCorrOPT == "ON"
                excludeForbidden_msk = inWin_forbiddenCorridor > cutOff_forbidden ;
                excludeForbidden     = window_array(:,excludeForbidden_msk');

                % here exclude the data that is in forbidden regions
                intFcsDat_excludeLeak_msk_mat= intFcsDat(:,parOrder == "Time") >= excludeForbidden(1,:) & intFcsDat(:,parOrder == "Time") < excludeForbidden(2,:);
                intFcsDat_excludeLeak_msk_vec= sum(intFcsDat_excludeLeak_msk_mat,2);
                intFcsDat_temp = intFcsDat(~intFcsDat_excludeGap_msk_vec & ~intFcsDat_excludeLeak_msk_vec,:);
            else
                intFcsDat_temp = intFcsDat(~intFcsDat_excludeGap_msk_vec,:);
            end

            % Now, we plot an overview of the methods
            % -- this plot only appears if you exclude gaps and/ or
            % forbidden regions

            if any(i == [10 length(fcsFiles)]) %|| ~isempty(excludeGaps)
                
                figure(t*1000 + i); set(gcf, "Renderer", "Painters", "Position", [1150 50 550 410]); hold on
                
                scatter(intFcsDat(:,parOrder == "Time")*fcshdr.timestep, intFcsDat(:,parOrder == "FL1-H"),"k."); hold on
                scatter(gfpFcsDat(:,parOrder == "Time")*fcshdr.timestep, gfpFcsDat(:,parOrder == "FL1-H"),"g.", "MarkerFaceAlpha", 0.02);
                xlabel("Time [s]"); ylabel("FL1-H");
                title(fcsFiles(2,i),'Interpreter','none');
                set(gca, "YScale", "log");
                xlim([0 (max(intFcsDat(:,parOrder == "Time"))+10000)*fcshdr.timestep]);
                ylim([0 10e7]);
                
                % plot the stuff for excluding gaps
                ss = scatter(mean(window_array*fcshdr.timestep,1),inWin_intFcsDatEvents,'Marker','d','MarkerEdgeColor','b',...
                    'MarkerFaceColor','none');
                p1 = plot(excludeGaps*fcshdr.timestep,repmat([2e5;2e5],1,size(excludeGaps,2)),'m','LineWidth',5,'HandleVisibility','off');
                cut1 = plot([0 maxTime*fcshdr.timestep],[cutOff_Gap cutOff_Gap],'-.','LineWidth',2,'Color','b');

                if excludeCorrOPT == "ON"
                figure(t*1000 + i);
                % plot the stuff for excluding stuff in forbidden region
                area([0 maxTime*fcshdr.timestep],[corridor;corridor],'BaseValue',corridor(1),'FaceColor',[0.7 0.7 0.7],'FaceAlpha',0.5,'LineStyle','none','EdgeColor','none');
                sss = scatter(mean(window_array*fcshdr.timestep,1),inWin_forbiddenCorridor,'Marker','d','MarkerEdgeColor',[0.3 0.3 0.3],...
                    'MarkerFaceColor',[0.7 0.7 0.7]);
                p2 = plot(excludeForbidden*fcshdr.timestep,repmat([2e5;2e5],1,size(excludeForbidden,2)),'Color',[0.7 0.7 0.7],'LineWidth',5);
                cut2 = plot([0 maxTime*fcshdr.timestep],[cutOff_forbidden cutOff_forbidden],'-.','LineWidth',2,'Color',[0.7 0.7 0.7]);
                legend_content =  [ss sss cut1 cut2];
                legend_Names   =  ["events per time window","events in forbidden region","cutOff Gap","cutOff leakage"];
                else 
                          legend_content =  [ss cut1];
                legend_Names   =  ["events per time window","cutOff Gap"];
                end
                

                if ~isempty(excludeGaps)
                    legend_content =  [legend_content p1(1)];
                    legend_Names   =  [legend_Names "exclude Gap"];
                end
                
                if excludeCorrOPT == "ON" && ~isempty(excludeForbidden)
                    legend_content =  [legend_content p2(1)];
                    legend_Names   =  [legend_Names "exclude Leakage"];
                end
                
                % Plot which windows are kept on top (to see we did nothing wrong!)
                figure(t*1000 + i);
                res = scatter(intFcsDat_temp(:,parOrder == "Time")*fcshdr.timestep, repmat(1e6,numel(intFcsDat_temp(:,parOrder == "Time")),1), "b.");
                
                legend([legend_content res],[legend_Names "included data"],'NumColumns',2)
            end
            % update the data
             intFcsDat = intFcsDat_temp;
            
            % renew what is gfp
            gfpCondition = intFcsDat(:,parOrder == "FL1-H") > gfpCutOff;
            gfpFcsDat    = intFcsDat(gfpCondition, :);
            NongfpFcsDat = intFcsDat(~gfpCondition, :);
        end
        
       % % Now, get back to the general analysis:
       % -- Keep track of samples with too little events ( <=minEvents)
       % ---- exclude samples later
       if size(intFcsDat,1) <= minEvents
           keep_EnoughEvents_msk(i,t) = false;
       end
        
        if ismember(i,whichFigs) && overviewFigs == "ON"
            
            figure(10 + t);
            f1 = f1 +1;
            subplot(MultiFig(1),MultiFig(2),f1)
            scatter(intFcsDat(:,parOrder == "Time")*fcshdr.timestep, intFcsDat(:,parOrder == "FL1-H"), "k."); hold on
            scatter(gfpFcsDat(:,parOrder == "Time")*fcshdr.timestep, gfpFcsDat(:,parOrder == "FL1-H"), "g.", "MarkerFaceAlpha", 0.02);
            xlabel("Time [s]"); ylabel("FL1-H");
            title(fcsFiles(2,i),'Interpreter','none');
            set(gca, "YScale", "log");
            xlim([0 max(intFcsDat(:,parOrder == "Time"))*fcshdr.timestep]); ylim([10 10e6]);
            
            %             figure(50 + t);
            %             subplot(MultiFig(1),MultiFig(2),f1)
            %             scatter(intFcsDat(:,parOrder == "SSC-Width"), intFcsDat(:,parOrder == fscPar), "k."); hold on
            %             scatter(gfpFcsDat(:,parOrder == "SSC-Width"), gfpFcsDat(:,parOrder == fscPar), "g.", "MarkerFaceAlpha", 0.02);
            %             xlabel("SSC-Width"); ylabel(fscPar);
            %             title(fcsFiles(2,i),'Interpreter','none');
            %             set(gca, "YScale", "log");
            %             xlim([min(intFcsDat(:,parOrder == "SSC-Width")) max(intFcsDat(:,parOrder == "SSC-Width"))]); ylim([0 1e07])
            
            %%%%% DOT PLOT
            % Setting/Checking the gate
            
            figure(100 + t); hold on
            subplot(MultiFig(1),MultiFig(2),f1)
            scatter(intFcsDat(:,parOrder == fscPar), intFcsDat(:,parOrder == sscPar), "k.", "MarkerEdgeAlpha", 0.4); hold on;
            scatter(gfpFcsDat(:,parOrder == fscPar), gfpFcsDat(:,parOrder == sscPar), "g.", "MarkerEdgeAlpha", 0.2);
            xlabel(fscPar); ylabel(sscPar);
            title(fcsFiles(2,i),'Interpreter','none');
            xlim([startXX endXX]); ylim([startYY endYY])
            xlim([0 max(gateVertices(1,:))+4000]); ylim([0 max(gateVertices(2,:))+4000])
        end
        
        
        %%%%% CONTOUR PLOTTING - SSC-A vs. FSC-A
        
        % Counting the hits (all data) within the fields of the xx/yy - grid
        densCounts = zeros(length(xx), length(yy));
        outside_Grid = 0;
        
        for c = 1 : length(intFcsDat)
            pox = find(xx > intFcsDat(c,parOrder == fscPar),1, "first")-1;
            poy = find(yy > intFcsDat(c,parOrder == sscPar),1, "first")-1;
            
            if isempty(poy) || isempty(pox) || poy == 0 || pox == 0
                outside_Grid = outside_Grid + 1;
            else
                densCounts(pox, poy) =  densCounts(pox, poy) + 1;
            end
            
        end
        
        % Defining the contourLines
        contourLinesAll = 0 : 20 : round(max(densCounts(:)),-1);
        
        if infoFigs == "ON" && ismember(i,whichSampl)
            %
            % % %  Fig 11 - shows all data points ! % % %
            %
            figure; hold on; box on; title("All measured data points - "+fcsFiles(2,i), "Interpreter", "none");
            set(gcf, "Renderer", "Painters", "Position", [0 500 550 410])
            
            % Plotting...
            % Dot plot
            scatter(intFcsDat(:,parOrder == fscPar), intFcsDat(:,parOrder == sscPar), "k.", "MarkerEdgeAlpha", 0.2);
            % Countour plot
            contour(meshX,meshY,densCounts', contourLinesAll, "LineWidth", 2, "ShowText", "on", "Fill", "off");
            
            xlim([min(xx) max(xx)]); ylim([min(yy) max(yy)])
            xlabel(fscPar); ylabel(sscPar);
            
            % Flourescent cells ...
            % Counting the hits (flourescent cells) within the fields of the xx/yy - grid
            gfpDensCounts = zeros(length(xx), length(yy));
            gfpoutside_Grid = 0;
            
            for c = 1 : length(gfpFcsDat)
                pox2 = find(xx > gfpFcsDat(c,parOrder == fscPar),1, "first")-1;
                poy2 = find(yy > gfpFcsDat(c,parOrder == sscPar),1, "first")-1;
                
                if isempty(poy2) || isempty(pox2) || poy2 == 0 || pox2 == 0
                    gfpoutside_Grid = gfpoutside_Grid + 1;
                else
                    gfpDensCounts(pox2, poy2) =  gfpDensCounts(pox2, poy2) + 1;
                end
            end
            
            contourLinesGFP = 0 : 5E-4 : 10E-3;
            
            %
            % % %  Fig 300 - only shows the flourescent data points ! % % %
            %
            figure; hold on; box on; title("All flourescent data points - " + fcsFiles(2,i), "Interpreter", "none");
            set(gcf, "Renderer", "Painters", "Position", [560 500 550 410])
            % Plotting...
            % Dot plot
            scatter(gfpFcsDat(:,parOrder == fscPar), gfpFcsDat(:,parOrder == sscPar), "k.", "MarkerEdgeAlpha", 0.2);
            % Contour plot
            gfpDenceCounts_perc = gfpDensCounts/sum(gfpDensCounts(:));
            [countours,~] = contour(meshX,meshY,gfpDenceCounts_perc', contourLinesGFP, "LineWidth", 2, "ShowText", "on");
            % Showing the size of the grid (densityCounts)
            plot([xx(4) xx(7)], [yy(end-3) yy(end-3)], "k-", "LineWidth", 1.4)
            plot([xx(4) xx(7)], [yy(end-4) yy(end-4)], "k-", "LineWidth", 1.4)
            plot([xx(5) xx(5)], [yy(end-5) yy(end-2)], "k-", "LineWidth", 1.4)
            plot([xx(6) xx(6)], [yy(end-5) yy(end-2)], "k-", "LineWidth", 1.4)
            
            xlim([min(xx) max(xx)]); ylim([min(yy) max(yy)])
            xlabel(fscPar); ylabel(sscPar);
        end
        
        if ismember(i,whichFigs) && overviewFigs == "ON"
            figure(100 + t)
            subplot(MultiFig(1),MultiFig(2),f1); hold on
            contour2gate = plot(gateVertices(1,:),gateVertices(2,:) , "r-", "LineWidth", 1.2); hold on
        end
        
        % % % % Find all points within the polygon [allVert40(1,:), allVert40(2,:)]
        gateMask = inpolygon(intFcsDat(:,parOrder == fscPar), intFcsDat(:,parOrder == sscPar),...
            gateVertices(1,:), gateVertices(2,:));
        NongfpGateMask = inpolygon(NongfpFcsDat(:,parOrder == fscPar), NongfpFcsDat(:,parOrder == sscPar),...
            gateVertices(1,:), gateVertices(2,:));
        gfpGateMask = inpolygon(gfpFcsDat(:,parOrder == fscPar), gfpFcsDat(:,parOrder == sscPar),...
            gateVertices(1,:), gateVertices(2,:));
        
        
        % lost means that these events are not in theb gate
        % now we can ask: what frac of non-gfp and gfp events do we
        % normally loose?
        %
        lostGFPAllGFP(i,t)       = sum(gfpGateMask==0)/length(gfpGateMask)*100;
        lostNonGFPAllNonGFP(i,t) = sum(NongfpGateMask==0)/length(NongfpGateMask)*100;
        lostGFPAllEvents(i,t)    = sum(gfpGateMask==0)/length(gateMask)*100;
        lostNonGFPAllEvents(i,t) = sum(NongfpGateMask==0)/length(gateMask)*100;
        lostAllEvents(i,t)       = sum(gateMask==0)/length(gateMask)*100;
        
        if infoFigs == "ON" && ismember(i,whichSampl)
            figure; hold on; title(fcsFiles(2,i), "Interpreter", "none");
            set(gcf, "Renderer", "Painters", "Position", [550 50 500 350])
            scatter(gfpFcsDat(:,parOrder == fscPar), gfpFcsDat(:,parOrder == sscPar), ".")
            scatter(gfpFcsDat(gfpGateMask,parOrder == fscPar), gfpFcsDat(gfpGateMask,parOrder == sscPar), "k.")
            xlim([min(xx) max(xx)+10000]); ylim([min(yy) max(yy)+10000])
            xlabel(fscPar); ylabel(sscPar);
        end
        
        % gfp vs non-gfp - histogram
        
        if infoFigs == "ON" && ismember(i,whichSampl)
            figure(100*t + i + 3); hold on;
            set(gcf, "Renderer", "Painters", "Position", [1150 500 760 450])
            set(gca, "XScale", "log");
            
            hAllRep = histogram(intFcsDat(:,parOrder == "FL1-H"), "BinEdges", binEdges, "EdgeAlpha", 0, "FaceAlpha", 0.3, "FaceColor", [0 0 0]); hold on;
            hGfpGate = histogram(gfpFcsDat(gfpGateMask,parOrder == "FL1-H"), "BinEdges", binEdges, "EdgeAlpha", 0, "FaceAlpha", 0.3, "FaceColor", [0 1 0]);
            hAllGate = histogram(intFcsDat(gateMask,parOrder == "FL1-H"), "BinEdges", binEdges, "FaceAlpha", 0, "LineWidth", 1.2);
            pCut = plot([gfpCutOff gfpCutOff], [0 round(max(hAllRep.Values)+250, -2)], "k--", "LineWidth", 1.4);
            xlim([1E1 1E6]); ylim([0 round(max(hAllRep.Values)+250, -2)])
            legend([hAllRep, hAllGate, hGfpGate, pCut],["Ungated data" , "Gated data", "Gated gfp data", "gfp cut-off"],...
                'Location','NorthWest')
            gfpFrac(i) = round(sum(hGfpGate.Values)/sum(hAllGate.Values)*100,2);
            totalCountsGate(i) = numel(nonzeros(gateMask));
            clear ungatedGfpFrac
            ungatedGfpFrac = length(gfpFcsDat)/(size(fcsdat,1)+length(gfpFcsDat))*100;
            
            text(gfpCutOff+gfpCutOff/2, round(max(hAllRep.Values))*0.65, num2str(gfpFrac(i), "%.2f") + " %", "FontSize", 14);
            text(2E1, round(max(hAllRep.Values))*0.65, num2str(100-gfpFrac(i), "%.2f") + " %", "FontSize", 14);
            
            text(gfpCutOff+gfpCutOff/2, round(max(hAllRep.Values))*0.55, num2str(ungatedGfpFrac, "%.2f") + " %", "FontSize", 12, "Color", [0.6 0.6 0.6]);
            text(2E1, round(max(hAllRep.Values))*0.55, num2str(100-ungatedGfpFrac, "%.2f") + " %", "FontSize", 12, "Color", [0.6 0.6 0.6]);
            
            text(gfpCutOff+gfpCutOff/2, round(max(hAllRep.Values))*0.85, "Excluded gfp datapoints: "+ num2str(lostGFPAllGFP(i,t), "%.2f") + " %", "FontSize", 12, "Color", [0 0 0]);
            text(gfpCutOff+gfpCutOff/2, round(max(hAllRep.Values))*0.80, "Excluded non gfp datapoints: "+ num2str(lostNonGFPAllNonGFP(i,t), "%.2f") + " %", "FontSize", 12, "Color", [0 0 0]);
            
            title("All data points within the gate - "+fcsFiles(2,i), "Interpreter", "none")
            
        else
            hAllRep  = histcounts(intFcsDat(:,parOrder == "FL1-H"), "BinEdges", binEdges);
            hGfpGate = histcounts(gfpFcsDat(gfpGateMask,parOrder == "FL1-H"), "BinEdges", binEdges);
            hAllGate = histcounts(intFcsDat(gateMask,parOrder == "FL1-H"), "BinEdges", binEdges);
            
            gfpFrac(i) = round(sum(hGfpGate)/sum(hAllGate)*100,2);
            totalCountsGate(i) = numel(nonzeros(gateMask));
        end
        
        if infoFigs == "ON" && ismember(i,whichSampl)
            figure; hold on; title(fcsFiles(2,i), "Interpreter", "none");
            set(gcf, "Renderer", "Painters", "Position", [0 50 500 350])
            scatter(intFcsDat(:,parOrder == "SSC-Width"), intFcsDat(:,parOrder == fscPar), "k.")
            xlabel("SSC-Width"); ylabel(fscPar);
            xlim([0 3000]); ylim([-10E3 200E3])
            scatter(gfpFcsDat(:, parOrder == "SSC-Width"), gfpFcsDat(:,parOrder == fscPar), "g.", "MarkerEdgeAlpha", 0.2);
        end
        
    end
    
    % save the data to variables
    if t == 1
        gfpStart = gfpFrac;
        countsStart = totalCountsGate;
        timestampStart = timestamp;
    elseif t == 2
        gfpEnd = gfpFrac;
        countsEnd = totalCountsGate;
        timestampEnd = timestamp;
    end
    
    if printFigs == "ON"
        % print the overview figures!!
        print(figure(10  + t),'-dpng',outPlot + MeasDayStart + expName + string(measTimes(t)) + "h" + plateName + "_TimeLine" + ".png");
        print(figure(100 + t),'-dpng',outPlot + MeasDayStart + expName + string(measTimes(t)) + "h" + plateName + "_FSCvsSSC" + ".png");
    end
    
    
    % some more stuff
    clear diff_Events
    figure(1111); hold on; set(gca,'FontSize',12)
    diff_Events        = round(lostNonGFPAllNonGFP(:,t) - lostGFPAllGFP(:,t),1);
    diff_Events_gfp    = diff_Events(ismember(sampleNames,["_Bs175_1_","_Bs175_2_","_Bs175_3_"]+plateName));
    diff_Events_nongfp = diff_Events(~ismember(sampleNames,["_Bs175_1_","_Bs175_2_","_Bs175_3_"]+plateName));
    
    histogram(diff_Events,'BinEdges',[min(diff_Events)-1:1:max(diff_Events)+1],'FaceColor','b',...
        'EdgeColor','b','FaceAlpha',0.2,'Displayname','lost NonGFP Events - lost GFP Events');
    histogram(diff_Events_gfp,[min(diff_Events)-1:1:max(diff_Events)+1],'FaceColor',[0.75, 0, 0.75],...
        'EdgeColor',[0.75, 0, 0.75],'FaceAlpha',0.5,'Displayname','pure gfp samples');
    legend
    
    % Here we print the samples that have a lot of crap!
    ext = 7; % look for the 10 most extreme crappy samples and print them
    [diff_Events_sort,~] = sort(diff_Events_nongfp);
    diff_Events_ext = diff_Events_sort(end-ext+1:end);
    diff_Events_ext_idx = find(ismember(diff_Events_nongfp,diff_Events_ext));
    diff_Events_ext_Smp = sampleNames(diff_Events_ext_idx);
    
    for s=1:ext
        fprintf("The following samples have the most crap: %s >>>>>>>>>>> namely app. %f %% \n", diff_Events_ext_Smp(s), diff_Events_nongfp(diff_Events_ext_idx(s)));
    end
    
    
end
%%

% which samples to exclude:
exclude_lessEvents = keep_EnoughEvents_msk(:,1) & keep_EnoughEvents_msk(:,2);
exlude_Samples     = sampleNames(exclude_lessEvents==0);

if any(exclude_lessEvents==0)
    for l=1:numel(exlude_Samples)
        fprintf("The following samples are excluded because they have less than %i events: %s \n", minEvents, exlude_Samples(l));
    end
end

summary = struct("sampleName", cellstr(sampleNames), ... %cellstr(fcsFiles(2,:)), ...
    "nonGfpStart_"+measTimes(1)+"h", num2cell(round(100 - gfpStart, 2)), ...
    "nonGfpEnd_"+measTimes(2)+"h", num2cell(round(100 - gfpEnd, 2)), ...
    "gateCountsStart", num2cell(countsStart), "gateCountsEnd", num2cell(countsEnd), "timestampStart", num2cell(timestampStart), "timestampEnd", num2cell(timestampEnd));


% Saving output
outStruct_temp = struct("sampleName", cellstr(sampleNames), ... %cellstr(fcsFiles(2,:)), ...
    "nonGfpStart_"+measTimes(1)+"h", num2cell(round(100 - gfpStart, 2)), "nonGfpEnd_"+measTimes(2)+"h", num2cell(round(100 - gfpEnd, 2)), "timestampStart", num2cell(timestampStart), "timestampEnd", num2cell(timestampEnd));
outStruct = outStruct_temp(exclude_lessEvents);

T=struct2table(outStruct);
writetable(T,outPath + "tmpTable",'Delimiter','\t')

%Create Header
fid = fopen(outPath + "tmpHeader.txt", "w");
gateName = regexp(loadGate, "\", "split");
fprintf(fid, "#Date of measurement: " + dateofmeasurement + "; Date of analysis: " + datestr(now, "dd-mmm-yyyy") + "; Used gate: " + gateName(end) + "; \n" );
fclose(fid);


% Merge the 2 txt-files
% LINUX - version:
% % system("cat " + outPath + "tmpHeader.txt >>" + outPath + expName + plateName + ".txt");
% % system("cat " + outPath + "tmpTable.txt >>" + outPath + expName + plateName + ".txt");
% % system("rm "+ outPath + "tmpHeader.txt");
% % system("rm "+ outPath + "tmpTable.txt");
% WINDOWS - version:
if excludeGapsOPT == "ON"
    system("copy " +outPath+"tmpHeader.txt+" + outPath + "tmpTable.txt "+ outPath+ MeasDayStart + expName + plateName + "_woGaps.txt");
else 
    system("copy " +outPath+"tmpHeader.txt+" + outPath + "tmpTable.txt "+ outPath+ MeasDayStart + expName + plateName + ".txt");
end
system("del /f "+ outPath + "tmpHeader.txt");
system("del /f "+ outPath + "tmpTable.txt");

toc

print(figure(101),  '-painters', '-dpng', savePlotPath + MeasDayStart +expName+""+measTimes(1)+"h"+plateName+"_FSCHSSCH")
print(figure(102),  '-painters', '-dpng', savePlotPath + MeasDayStart +expName+""+measTimes(2)+"h"+plateName+"_FSCHSSCH")
print(figure(11),  '-painters', '-dpng', savePlotPath + MeasDayStart +expName+""+measTimes(1)+"h"+plateName+"_FL1-H-Time")
print(figure(12),  '-painters', '-dpng', savePlotPath + MeasDayStart +expName+""+measTimes(2)+"h"+plateName+"_FL1-H-Time")
