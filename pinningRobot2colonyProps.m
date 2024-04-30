% pinningRobot2colonyProps.m
%
% use pinningrobot pix to find:
% 1. area/contour growth
% 2. roughness 
% ---> save in struct "colonyProps"
%
% use "plot_colonyProps.m" to plot the results

% written by Mona @07/09/2023
clearvars; close all

basePath = "H:\evolonPlates\20231207_Evolution\";
sampleBaseName = "Bs224hyb";
expFolder = "20231219_cy5\" + sampleBaseName + "\";
plotsON = "ON";

basePath = "H:\evolonPlates\20230110_Adaptation\";
% sampleBaseName = "Bs224hyb";
expFolder = "plate1_34ndshot\";%"20231219_cy5\" + sampleBaseName + "\";
plotsON = "ON";

useThresh = "adaptthresh"; %  "adaptthresh" or "multithresh"
posName = string(1:16); % from left to right, from up to down

%% Parameter that could be changed
% Since I am using a pinning tool, we can give the software expected
% positions (for each entry: xmin, xmax, ymin, ymax)
expectedPos = [530 1290 240 745; ... % 1
 1500 2220 240 745; ... % 2
 2670 3430 240 700; ... % 3
 3620 4400 240 700; ... % 4
 830 1600 900 1400; ... % 5
 1870 2620 900 1420; ... % 6
 2990 3690 905 1390; ...
 3980 4700 910 1400; ...
 1130 1800 1700 2190; ...
 2240 3000 1650 2100; ...
 3310 4000 1670 2120; ...
 4270 4960 1670 2120; ...
 570 1130 2400 2850; ...
 1420 2210 2400 2850; ...
 2630 3360 2360 2850; ...
 3650 4400 2360 2850];

% If you want to see the expected Positions
% for k = 1 : 16
%     fill([expectedPos(k,1) expectedPos(k,1) expectedPos(k,2) expectedPos(k,2)],...
%     [expectedPos(k,3) expectedPos(k,4) expectedPos(k,4) expectedPos(k,3)], "w" );
% end

% Create a plateMask (so that the plate is not included in the colonies)
plateMask = true(3456, 5184);
for i = 1 : 3456 
    % remove left side
    k = round(-1/91.4*i+530.78);
    plateMask(i,1:k) = false;
    % remove right side
    k2 = round(-1/162*i+4969);
    plateMask(i,k2:end) = false;
end
for i = 1 : 5184
    % remove upperpart
    k = round(-0.006*i+250);
    plateMask(1:k, i) = false;
    % remove lowerpart
    if i < 710
        k2 = i + 2301;
        plateMask(k2:end, i) = false;
    elseif i>=710 & i < 4750
        k2 = 3011;
        plateMask(k2:end, i) = false;
    elseif i>= 4750
        k2 = -i + 7761;
        plateMask(k2:end, i) = false;
    end
end
    
%% Reading in data
% Extract all pics you want to go through:
allFiles = dir(basePath + expFolder);
% Filter out folders
allFiles = allFiles([allFiles.isdir]==0);
allFiles = allFiles(contains({allFiles.name}, "JPG") | contains({allFiles.name}, "CR2"));

flaeche = [];
contour = [];
roughness = []; 
timeofMeasurement = [];
% intProfile = []; % Intensitätsprofil

%% Looping over all pictures
for snapshots = 1 : length(allFiles) 
    
imgName = allFiles(snapshots).name;
% Extract time information
findDate = split(imgName, ["_", "."]);
timeofMeasurementAdd = string(findDate{end-2}) + " " + string(findDate{end-1});
    
img = imread(basePath + expFolder + imgName);
    if plotsON == "ON" & (snapshots == 1 | snapshots == length(allFiles))
        figure(snapshots); hold on;
        imshow(img)
        hold on
    end

% imgBin3d=imbinarize(img, 'global');
% imgBin= imgBin3d(:,:,3);
imgGray = rgb2gray(img);

if useThresh == "multithresh"
    % threshold with Otsu method
    thresm = multithresh(imgGray,2);
    imgGrayQ = imquantize(imgGray, thresm);
    
    % Fill surrounding so they are not included in the analysis
    imgGrayQ = imgGrayQ.*plateMask;
    imgGrayQ(imgGrayQ==0) = 1;
    imgGrayL = label2rgb(imgGrayQ);

elseif useThresh == "adaptthresh"
    % adaptthreshold with local first-order statistics
    thresm = adaptthresh(imgGray,0.59);
    imgGrayQ = imbinarize(imgGray,thresm);
    
    % Fill surrounding so they are not included in the analysis
    imgGrayQ = imgGrayQ.*plateMask;
    imgGrayL = label2rgb(~imgGrayQ);

end 
[B,L] = bwboundaries(imgGrayL(:,:,1),'noholes');

    for k = 1 : size(expectedPos, 1)
        L_tmp = L(expectedPos(k,3):expectedPos(k,4), expectedPos(k,1):expectedPos(k,2));
        idxCol(k)= median(L_tmp(L_tmp>0));
    end


areaAdd = []; % number of pixels hit
contourAdd = []; % number of entries for boundary
roughnessAdd = []; 

    for k = 1 : length(idxCol)
       idx = round(idxCol(k));
       boundary_tmp = B{idx};
           if plotsON == "ON"
               if snapshots == 2 || snapshots == length(allFiles)
                   figure(snapshots); hold on
                   plot(boundary_tmp(:,2), boundary_tmp(:,1), 'm', 'LineWidth', 2)
               end
%                figure(snapshots); hold on
%                plot(boundary_tmp(:,2), boundary_tmp(:,1), 'm', 'LineWidth', 2)
           end
       B_filt{k} = boundary_tmp;
       % calculate area
       arX = sum(L==idx);
       arXY =sum(arX);

       areaAdd = [areaAdd arXY];

       % calculate contour
       contourAdd = [contourAdd size(boundary_tmp,1)];
       
       if mod(snapshots, 10)==0 
       % intensity profile
       iPtemp = double(imgGray).*(L == idx);
       intensityProfile{k}{snapshots/10} = iPtemp(sum(iPtemp')>0,sum(iPtemp)>0);
       end
    end

% Calculate roughness
roughnessAdd = contourAdd ./ areaAdd;

flaeche = [flaeche; areaAdd];
contour = [contour; contourAdd];
roughness = [roughness; roughnessAdd];

timeofMeasurement = [timeofMeasurement; timeofMeasurementAdd];

clear B L_tmp boundary roughnessAdd contourAdd timeofMeasurmentAdd areaAdd
end

% Sort chronologically 
% timepoint strings to numbers
for k = 1 : length(timeofMeasurement)
    timeP(k) = datetime(timeofMeasurement(k), "InputFormat", "yyyy-MM-dd HH-mm-ss");
end
% sort timepoints
[~, idx] = sort(timeP);



contour = contour(idx,:);
roughness = roughness(idx,:);
flaeche = flaeche(idx,:);
timeP = timeP(idx);


colonyProps = struct("sample", num2cell(sampleBaseName+ "_" +posName), "area", num2cell(flaeche',2)',...
    "roughness", num2cell(roughness',2)', "contour", num2cell(contour',2)',...
    "timePoints", num2cell(repmat(timeP, size(posName,2),1),2)', "intensityProfile", intensityProfile);


%% You want to remove samples? Because of contaminations or ... ?
% you count from upper left to right (1 - 16)
figure; imshow(img) % show last timepoint

if exist("removeColonies", "var")
    rm_idx = [1 10 11];
    rm_idx = 4
    rmMask = 1 : length(colonyProps);
    rmMask(rm_idx) = [];
    colonyProps = colonyProps(rmMask);

end


%% Play around with intensityProfile (before you include it into colonyProps

% % % 1. Profil mitteln über Abstand zum Rand 
% % figure(10)
% % hold on
% % for i = 1 : 6
% %     plot(mean(intensityProfile{1}{i}), "k.")
% % end
% % 
% % figure(11)
% % hold on
% % for i = 1 : 6
% %     plot(mean(intensityProfile{1}{i}'), "k.")
% % end





