% % %% %% %% %% FACS_Plot.m %% %% %% %% % %
% This scripts reads in your measured competition experiment fractions,
% calculates the selection coeffients.
% You can choose to correct for 
% 1. the fraction of non-fluorescent events in the pure GFP signal,
% 2. the fitness difference between ancestor and GFP reporter strain
%
% When reading in the results of more than one experiment, the different
% experiments will be compared.
%
%Functions needed: 
% ----> scoeff -- gives the selection coefficient and a error based on the
%       uncertainty of the cytometer measurement of the fractions
% ----> getMeanError -- gives you the error through error propagation of a
%       mean
%     
% ------ Outputs ------
%
% **outSIndividual**
% contains the start/end fraction and the calculated selection coefficient 
% for very single measured sample
%
% **outS** 
% contains mean(selCoeff) and std(selCoeff) of a sample for each run 
% --> the mean equals the points you get from a standard competition exp.
%
% **outCollect** 
% collects the mean of the means per run
%
% ----------------------
% % %% %% %% %% %% %% %% %% %% %% %% %% % %

clearvars -except figCounter
close all

% Where do I find your measured fractions of the non-reporter strains?

%%%%%% W/O LAG IN COMPETENCE MEDIUM %%%%%%
% ANC DISTRIBUTION %% !!!! Turn on: corrANCopt and excludeSampleOpt!!!! <-- because we did not shift columns here --> artifical shifting
% facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210329_Bs166_Bs175_allPlates.txt";
% facsdata(2) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210330_Bs166_Bs175_allPlates.txt";
% facsdata(3) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210331_Bs166_Bs175_allPlates.txt"; 
% facsdata(4) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210524_Bs166_Bs175_allPlates.txt";

% resampPath = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\";
% resamp = resampPath + ["20210331_Bs166_Bs175_plate2" "20210330_Bs166_Bs175_plate3" "20210330_Bs166_Bs175_plate2" "20210329_Bs166_Bs175_plate3" "20210329_Bs166_Bs175_plate2"] + ".txt"
% facsdata = resamp;

%%%% BVAL - WITHOUT LAG
% facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210325_LibSCBval_allPlates.txt";
% % % % facsdata(2) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210326_LibSCBval_allPlates.txt";
% facsdata(2) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210327_LibSCBval_allPlates.txt";
% facsdata(3) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210409_LibSCBval_allPlates.txt";
% % % % % % facsdata(5) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210410_LibSCBval_allPlates.txt";
% facsdata(4) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210526_LibSCBval_allPlates.txt";
% facsdata(5) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210528_LibSCBval_plate3.txt";
% facsdata(6) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20211110_LibSCBval_allPlates.txt"; % NEU

%%%%% W23 - W/O LAG
% facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210406_LibSCW23_allPlates.txt";
% facsdata(2) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210407_LibSCW23_allPlates.txt";
% % % % %AUSSCHLIEßEN - corrANC shifted % % % facsdata(3) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210408_LibSCW23_allPlates.txt";
% % % % %AUSSCHLIEßEN MÜLL facsdata(4) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210411_LibSCW23_allPlates.txt"; 
% facsdata(3) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210525_LibSCW23_allPlates.txt";
% facsdata(4) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210527_LibSCW23_allPlates.txt";

%%%%% BMOJ - W/O LAG
% facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20211123A_LibSCBmoj_allPlates_woGaps.txt";

%%%%% LibGRBval - W/O LAG - Melihs Lib
% % facsdata(1) =  "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210721_LibGRBval_allPlates_woGaps.txt";
% % facsdata(2) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210714_LibGRBval_allPlates_woGaps.txt";
% % facsdata(3) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210718_LibGRBval_allPlates_woGaps.txt";
% % facsdata(4) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210719_LibGRBval_allPlates_woGaps.txt";


%%%% Cy10/Cy20 - no Selection - W/O LAG
% facsdata(4) = "H:\kleinesPaper\fitness\20210720_LibEvolExpCy10-20_allPlates.txt";
% % % % % NOOOOOO --facsdata(1) = "H:\kleinesPaper\fitness\20210722_LibEvolExpCy10-20_allPlates.txt";
% facsdata(2) = "H:\kleinesPaper\fitness\20210726_LibEvolExpCy10-20_allPlates.txt";
% facsdata(3) = "H:\kleinesPaper\fitness\20210728_LibEvolExpCy10-20_allPlates.txt";
% facsdata(1) = "H:\kleinesPaper\fitness\20210917_LibEvolExpCy10-20_allPlates.txt";


%%%%%% IN MINIMAL MEDIUM %%%%%%
% %%%%% ANC - W/O LAG - in MM
% facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_MMwoLag\20210730_Bs166_Bs175MM_allPlates_woGaps.txt";
% facsdata(2) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_MMwoLag\20210906_Bs166_Bs175MM_plate4_woGaps.txt";
% facsdata(3) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_MMwoLag\20210907_Bs166_Bs175MM_allPlates_woGaps.txt";
% facsdata(4) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_MMwoLag\20210923_Bs166_Bs175MM_plate4_woGaps.txt";
%%%%% BVAL - W/O LAG - in MM
% facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_MMwoLag\20210727_LibSCBvalMM_allPlates_woGaps.txt";
% facsdata(2) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_MMwoLag\20210729_LibSCBvalMM_allPlates_woGaps.txt";
% facsdata(3) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_MMwoLag\20210908_LibSCBvalMM_allPlates_woGaps.txt";
% facsdata(4) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_MMwoLag\20210910_LibSCBvalMM_allPlates_woGaps.txt";
%%%%% LibGRBval - w/o Lag - in MM
% facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_MMwoLag\20210914_LibGRBvalMM_allPlates_woGaps.txt";
% facsdata(2) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_MMwoLag\20210922_LibGRBvalMM_allPlates_woGaps.txt";

%%%%% ---- DFE - SCREENING ---- %%%%%
%%%% BVAL - W/O LAG - in LB at 37 °C
% % % % % do not use:facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_screening\20211018_LibSCBvalLB_plate2_woGaps.txt"; 
% % facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_screening\20211102_LibSCBvalinLB37_plates124_woGaps.txt"; 
% % facsdata(2) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_screening\20211116B_LibSCBval_LB37_woGaps_allPlates.txt"; 
% % % % with new protocol (overnight dilution)
% facsdata(1) = "H:\fitnessDistribution\2022_withSelection\20220204_LibBvalLB37_allPlates_woGaps.txt"; 
%%%% BVAL - W/O LAG - in CM at 30 °C
% facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_screening\20211103_LibSCBval_CM30_allPlates_woGaps.txt"; 
%%%% BVAL - W/O LAG - in MMGlycerol at 37 °C
% facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_screening\20211109_LibSCBval_MMGlycerol37_allPlates_woGaps.txt";
%%%% BVAL - W/O LAG - in CM at 42 °C
% facsdata(1) = "H:\fitnessDistribution\2022_withSelection\20211108_LibSCBvalCM42_woGaps_allPlates.txt"; 
% facsdata(2) = "H:\fitnessDistribution\2022_withSelection\20220303A_LibSCBvalCM42_allPlates_woGaps.txt"; 
% facsdata(3) = "H:\fitnessDistribution\2022_withSelection\20220304A_LibSCBvalCM42_allPlates_woGaps.txt";
% facsdata(4) = "H:\fitnessDistribution\2022_withSelection\20220316B_LibSCBvalCM42_allPlates_woGaps.txt";
%%%% ANC - W/O LAG - in CM at 42 °C
% % % % % Leave out:facsdata(1) = "H:\fitnessDistribution\2022_withSelection\20220303B_Bs166CM42_allPlates_woGaps.txt"; 
% facsdata(1) = "H:\fitnessDistribution\2022_withSelection\20220304B_Bs166CM42_allPlates_woGaps.txt"; 
% facsdata(2) = "H:\fitnessDistribution\2022_withSelection\20220316A_Bs166CM42_woGaps_plate1.txt"; 
% facsdata(3) = "H:\fitnessDistribution\2022_withSelection\20220321_Bs166CM42_allPlates_woGaps.txt"; 

%%%% BVAL - W/O LAG - in MMGlycerol at 37 °C
% facsdata(1) = "H:\fitnessDistribution\2022_withSelection\20220317B_LibSCBvalMMGlycerol_allPlates_woGaps.txt"; 
% facsdata(2) = "H:\fitnessDistribution\2022_withSelection\20220322B_LibSCBvalMMGlycerol_allPlates_woGaps.txt"; 
% facsdata(3) = "H:\fitnessDistribution\2022_withSelection\20220329A_LibSCBvalMMGlycerol_woGaps_allPlates.txt";
% facsdata(4) = "H:\fitnessDistribution\2022_withSelection\20220329B_LibSCBvalMMGlycerol_woGaps_allPlates.txt";
%%%% ANC - W/O LAG - in MMGlycerol at 37 °C
% facsdata(1) = "H:\fitnessDistribution\2022_withSelection\20220317A_Bs166MMGlycerol_allPlates_woGaps.txt"; 
% facsdata(2) = "H:\fitnessDistribution\2022_withSelection\20220322A_Bs166MMGlycerol_allPlates_woGaps.txt"; 
% % % EXCLUDE: facsdata(3) = "H:\fitnessDistribution\2022_withSelection\20220324A_Bs166MMGlycerol_woGaps_allPlates.txt";
% facsdata(3) = "H:\fitnessDistribution\2022_withSelection\20220324B_Bs166MMGlycerol_woGaps_plate2.txt";

if ~exist("figCounter", "var")
    figCounter = 0;
end
figCounter = figCounter + 1; 
%%%%% WITH SELECTION %%%%%% GATE: FEB2022 !!! "NEW"
% % %%% LibBvalwS1d5 
% % % facsdata(1) = "H:\fitnessDistribution\2022_withSelection\DFE\20211221A_LibBvalwS1d5_allPlates_woGaps.txt";
% % %%% LibBvalwS1cntrld5
% % % facsdata(1) = "H:\fitnessDistribution\2022_withSelection\DFE\20220104_LibBvalwS1cntrld5_plate1_woGaps.txt";
%%% LibBvalwS3d5
% facsdata(1) = "H:\fitnessDistribution\2022_withSelection\20220207B_LibBvalwS3d5_allPlates_woGaps.txt"; 
% facsdata(2) = "H:\fitnessDistribution\2022_withSelection\20220208_LibBvalwS3d5_allPlates_woGaps.txt"; 
% facsdata(3) = "H:\fitnessDistribution\2022_withSelection\20220212A_LibBvalwS3d5_woGaps_allPlates.txt";
% facsdata(4) = "H:\fitnessDistribution\2022_withSelection\20220212B_LibBvalwS3d5_woGaps_allPlates.txt";
% facsdata(5) = "H:\fitnessDistribution\2022_withSelection\20220223_LibBvalwS3d5OUTLIER_allPlates_woGaps.txt";
% facsdata(6) = "H:\fitnessDistribution\2022_withSelection\20220224_LibBvalwS3d5OUTLIER_allPlates_woGaps.txt";
%%% LibBvalwS3ctld5
% facsdata(1) = "H:\fitnessDistribution\2022_withSelection\20220209A_LibBvalwS3ctld5_allPlates_woGaps.txt"; 
% facsdata(2) = "H:\fitnessDistribution\2022_withSelection\20220209B_LibBvalwS3ctld5_allPlates_woGaps.txt"; 
% facsdata(3) = "H:\fitnessDistribution\2022_withSelection\20220214A_LibBvalwS3ctld5_allPlates_woGaps.txt"; 
% facsdata(4) = "H:\fitnessDistribution\2022_withSelection\20220214B_LibBvalwS3ctld5_allPlates_woGaps.txt"; 
% facsdata(5) = "H:\fitnessDistribution\2022_withSelection\20220223_LibBvalwS3ctld5OUTLIER_allPlates_woGaps.txt"; 
% facsdata(6) = "H:\fitnessDistribution\2022_withSelection\20220224_LibBvalwS3ctld5OUTLIER_allPlates_woGaps.txt"; 
%%% LibBvalwS2d12.5
% facsdata(1) = "H:\fitnessDistribution\2022_withSelection\20220215A_LibBvalwS2d12_allPlates_woGaps.txt";
% facsdata(2) = "H:\fitnessDistribution\2022_withSelection\20220215B_LibBvalwS2d12_allPlates_woGaps.txt";
% facsdata(3) = "H:\fitnessDistribution\2022_withSelection\20220219A_LibBvalwS2d12_allPlates_woGaps.txt";
% facsdata(4) = "H:\fitnessDistribution\2022_withSelection\20220221B_LibBvalwS2d12_allPlates_woGaps.txt";
%%% LibBvalwS2ctld12.5
% facsdata(1) = "H:\fitnessDistribution\2022_withSelection\20220217A_LibBvalwS2ctld12_allPlates_woGaps.txt";
% facsdata(2) = "H:\fitnessDistribution\2022_withSelection\20220217B_LibBvalwS2ctld12_allPlates_woGaps.txt";
% facsdata(3) = "H:\fitnessDistribution\2022_withSelection\20220219B_LibBvalwS2ctld12_allPlates_woGaps.txt";
% facsdata(4) = "H:\fitnessDistribution\2022_withSelection\20220221A_LibBvalwS2ctld12_allPlates_woGaps.txt";


%%%%%% WITH LAG %%%%%%
%%%%% ANC - WITH LAG 
% facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_withLag\20210129_Bs166_Bs175_allPlates.txt";
% facsdata(2) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_withLag\20210205_Bs166_Bs175_allPlates.txt";
% facsdata(3) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_withLag\20210212_Bs166_Bs175_allPlates.txt";

%%%% BVAL - WITH LAG  
% EXCLUDEfacsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_withLag\20210118_LibSCBval_allPlates.txt";
% facsdata(1) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_withLag\20210119_LibSCBval_allPlates.txt";
% facsdata(2) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_withLag\20210125_LibSCBval_allPlates.txt";
% facsdata(3) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_withLag\20210128_LibSCBval_allPlates.txt";
% facsdata(4) = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_withLag\20210712_LibSCBval_allPlates.txt";

%%%%% C3 - Bs213HybLib Cntrl
% facsdata(1) = "H:\evolinLiquid\20230313_C3_Bs212_001.txt"; 
% facsdata(2) = "H:\evolinLiquid\20230313_C3_Bs212_002.txt"; 
% facsdata(3) = "H:\evolinLiquid\20230315_C3_Bs212_003.txt"; 
% facsdata(4) = "H:\evolinLiquid\20230315_C3_Bs212_004_badGate.txt"; 

% %%%%% H3 - Bs213HybLib
% facsdata(1) = "H:\evolinLiquid\20230314_H3_Bs212_001.txt"; 
% facsdata(2) = "H:\evolinLiquid\20230314_H3_Bs212_002.txt"; 
% facsdata(3) = "H:\evolinLiquid\20230316_H3_Bs212_003.txt"; 
% facsdata(4) = "H:\evolinLiquid\20230316_H3_Bs212_004.txt"; 

%%%%% hybLib3T 
% facsdata(1) = "H:\evolinLiquid\resultsTmp\20230616_hybLib_results_quickanddirty\20230612_hybLib3T_Bs212_001.txt"; 
% facsdata(2) = "H:\evolinLiquid\resultsTmp\20230616_hybLib_results_quickanddirty\20230612_hybLib3T_Bs212_002.txt"; 
% facsdata(3) = "H:\evolinLiquid\resultsTmp\20230616_hybLib_results_quickanddirty\20230613_hybLib3T_Bs212_003.txt"; 
% facsdata(4) = "H:\evolinLiquid\resultsTmp\20230616_hybLib_results_quickanddirty\20230613_hybLib3T_Bs212_004.txt"; 
% facsdata(5) = "H:\evolinLiquid\resultsTmp\20230616_hybLib_results_quickanddirty\20230615_hybLib3T_Bs212_005.txt"; 
% facsdata(6) = "H:\evolinLiquid\resultsTmp\20230616_hybLib_results_quickanddirty\20230615_hybLib3T_Bs212_006.txt"; 

% %%%%% Proof of principle - BVAL (try to reproduce old results):
% facsdata(1) = "H:\evolinLiquid\competitionExp\20230626_BVAL_Bs175_001.txt"; 
% facsdata(2) = "H:\evolinLiquid\competitionExp\20230626_BVAL_Bs175_002.txt"; 
% facsdata(3) = "H:\evolinLiquid\competitionExp\20230627_BVAL_Bs175_003.txt"; 
% facsdata(4) = "H:\evolinLiquid\competitionExp\20230627_BVAL_Bs175_004.txt"; 

%%%%%% Precision of 18 h comp exp wo ONC -- Bs166 vs Bs175
% facsdata(1) = "H:\evolinLiquid\competitionExp\20230703_Bs166_Bs175_001.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20230704_Bs166_Bs175_002.txt";
% facsdata(3) = "H:\evolinLiquid\competitionExp\20230809_Bs166_Bs175_003.txt";
% facsdata(4) = "H:\evolinLiquid\competitionExp\20230809_Bs166_Bs175_004.txt";

%%% Population fitness - LibBvalwS3d5
% facsdata(1) = "H:\evolinLiquid\competitionExp\20230810_LibBvalwS3d5pops_Bs175_001.txt";
% % % % % facsdata(1) =  "H:\evolinLiquid\competitionExp\20230810_LibBvalwS3d5pops_Bs175_002_gfpCO18h-1100.txt";  Do not use !
% facsdata(2) = "H:\evolinLiquid\competitionExp\20230815_LibBvalwS3d5pops_Bs175_003.txt";
% facsdata(3) = "H:\evolinLiquid\competitionExp\20230815_LibBvalwS3d5pops_Bs175_004.txt";
%%% Population fitness - LibBvalwS3ctld5
% facsdata(1) = "H:\evolinLiquid\competitionExp\20230823_LibBvalwS3ctld5pops_Bs175_001.txt";
% facsdata(2) =  "H:\evolinLiquid\competitionExp\20230823_LibBvalwS3ctld5pops_Bs175_002.txt"; 
% facsdata(3) = "H:\evolinLiquid\competitionExp\20230824_LibBvalwS3ctld5pops_Bs175_003.txt";
% % % % % % facsdata(4) = "H:\evolinLiquid\competitionExp\20230824_LibBvalwS3ctld5pops_Bs175_004.txt"; % % Do not use... the gfp cutoff is strange after 18 h

% Bs210CtlEvol5
% facsdata(1) = "H:\evolinLiquid\competitionExp\20231220_Bs210CtlEvol5.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240104_Bs210CtlEvol5.txt"; % new
% facsdata(3) = "H:\evolinLiquid\competitionExp\20240105A_Bs210CtlEvol5.txt";
% facsdata(4) = "H:\evolinLiquid\competitionExp\20240105B_Bs210CtlEvol5.txt";
% facsdata(5) = "H:\evolinLiquid\competitionExp\20240131A_Bs210CtlEvol5.txt";
% facsdata(6) = "H:\evolinLiquid\competitionExp\20240131B_Bs210CtlEvol5.txt";
% Bs210CtlEvol5 - filament correction v4
expName = "Bs210CtlEvol5_6runs_filCorr_v4";
facsdata(1) = "H:\evolinLiquid\competitionExp\20231220_Bs210CtlEvol5_woGaps_filamentCorr_v4.txt";
facsdata(2) = "H:\evolinLiquid\competitionExp\20240104_Bs210CtlEvol5_woGaps_filamentCorr_v4.txt"; 
facsdata(3) = "H:\evolinLiquid\competitionExp\20240105A_Bs210CtlEvol5_woGaps_filamentCorr_v4.txt";
facsdata(4) = "H:\evolinLiquid\competitionExp\20240105B_Bs210CtlEvol5_woGaps_filamentCorr_v4.txt";
facsdata(5) = "H:\evolinLiquid\competitionExp\20240131A_Bs210CtlEvol5_woGaps_filamentCorr_v4.txt";
facsdata(6) = "H:\evolinLiquid\competitionExp\20240131B_Bs210CtlEvol5_woGaps_filamentCorr_v4.txt";

% Bs210HybEvol5
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240110A_Bs210HybEvol5.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240110B_Bs210HybEvol5.txt"; 
% facsdata(3) = "H:\evolinLiquid\competitionExp\20240111A_Bs210HybEvol5.txt";
% facsdata(4) = "H:\evolinLiquid\competitionExp\20240111B_Bs210HybEvol5.txt";
% Bs210HybEvol5 - filament correction v4
% expName = "Bs210HybEvol5_4runs_filCorr_v4"
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240110A_Bs210HybEvol5_woGaps_filamentCorr_v4.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240110B_Bs210HybEvol5_woGaps_filamentCorr_v4.txt"; 
% facsdata(3) = "H:\evolinLiquid\competitionExp\20240111A_Bs210HybEvol5_woGaps_filamentCorr_v4.txt";
% facsdata(4) = "H:\evolinLiquid\competitionExp\20240111B_Bs210HybEvol5_woGaps_filamentCorr_v4.txt";


% Bs224CtlEvol5
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240116A_Bs224CtlEvol5.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240116B_Bs224CtlEvol5.txt"; 
% facsdata(3) = "H:\evolinLiquid\competitionExp\20240117A_Bs224CtlEvol5.txt";
% facsdata(4) = "H:\evolinLiquid\competitionExp\20240117B_Bs224CtlEvol5.txt";
% Bs224CtlEvol5 - filament correction
% expName = "Bs224CtlEvol5_4runs_filCorr_v4"
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240116A_Bs224CtlEvol5_woGaps_filamentCorr_v4.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240116B_Bs224CtlEvol5_woGaps_filamentCorr_v4.txt"; 
% facsdata(3) = "H:\evolinLiquid\competitionExp\20240117A_Bs224CtlEvol5_woGaps_filamentCorr_v4.txt";
% facsdata(4) = "H:\evolinLiquid\competitionExp\20240117B_Bs224CtlEvol5_woGaps_filamentCorr_v4.txt";


% Bs224CtlEvol5 against Bs211 !! Wrong Anc wrong GFP ... no real meaning
% since also Anc wrong...
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240108A_Bs224CtlEvol5_Bs211_wrongAnc.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240108B_Bs224CtlEvol5_Bs211_wrongAnc.txt"; 

% Bs224HybEvol5
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240124A_Bs224HybEvol5.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240124B_Bs224HybEvol5.txt"; 
% facsdata(3) = "H:\evolinLiquid\competitionExp\20240125A_Bs224HybEvol5.txt";
% facsdata(4) = "H:\evolinLiquid\competitionExp\20240125B_Bs224HybEvol5.txt";
% Bs224HybEvol5 -- filament correction v4
% expName = "Bs224HybEvol5_4runs_filCorr_v4"
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240124A_Bs224HybEvol5_woGaps_filamentCorr_v4.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240124B_Bs224HybEvol5_woGaps_filamentCorr_v4.txt"; 
% facsdata(3) = "H:\evolinLiquid\competitionExp\20240125A_Bs224HybEvol5_woGaps_filamentCorr_v4.txt";
% facsdata(4) = "H:\evolinLiquid\competitionExp\20240125B_Bs224HybEvol5_woGaps_filamentCorr_v4.txt";

% Bs210Anc - measured with HTS --> HTS precision
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240112A_Bs210.txt";
% % % % facsdata(2) = "H:\evolinLiquid\competitionExp\20240112B_Bs210.txt"; % exclude ! I forgot to measure the plate and started 2 h too late
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240115A_Bs210.txt";
% facsdata(3) = "H:\evolinLiquid\competitionExp\20240115B_Bs210.txt";
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240130A_Bs210.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240130B_Bs210.txt";
% Bs210Anc - measured with HTS --> HTS precision -- filament corr v4
% expName = "Bs210anc_5runs_filCorr_v4"
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240112A_Bs210_woGaps_filamentCorr_v4.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240115A_Bs210_woGaps_filamentCorr_v4.txt";
% facsdata(3) = "H:\evolinLiquid\competitionExp\20240115B_Bs210_woGaps_filamentCorr_v4.txt";
% facsdata(4) = "H:\evolinLiquid\competitionExp\20240130A_Bs210_woGaps_filamentCorr_v4.txt";
% facsdata(5) = "H:\evolinLiquid\competitionExp\20240130B_Bs210_woGaps_filamentCorr_v4.txt";

% Fitness effect of the barcodes !
% Bs210BC 
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240319A_Bs210BC_woGaps_filamentcorr_v4.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240319B_Bs210BC_woGaps_filamentcorr_v4.txt";
% facsdata(3) = "H:\evolinLiquid\competitionExp\20240321_Bs210BC_woGaps_filamentcorr_v4.txt";
% Bs224BC 
% facsdata(1) = "H:\evolinLiquid\competitionExp\20240321A_Bs224BC_woGaps_filamentcorr_v4.txt";
% facsdata(2) = "H:\evolinLiquid\competitionExp\20240321B_Bs224BC_woGaps_filamentcorr_v4.txt";
% facsdata(3) = "H:\evolinLiquid\competitionExp\20240321C_Bs224BC_woGaps_filamentcorr_v4.txt";



% Do you want to compare with the ancestor?
compareAnc = "OFF";

% .. then I need to know which outCollect.mat of the ancestor to use ..
%%%%%% %%%%%% %%%%%% 4 h competition %%%%%% %%%%%% %%%%%% 
%%% with LagPhase %%%
% AncDist = "H:\fitnessDistribution\2021_HighThroughputCompetition\AncRef_Run1to4_outCollect.mat";
%%% without LagPhase %%%
% % % % in CM at 37°C (standard)
% AncDist = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210628_outCollect_Bs166_woLag.mat";
% % % % in CM at 42°C
% AncDist = "H:\fitnessDistribution\2022_withSelection\20220406_outCollect_Bs166CM42_run1-4.mat";
% % % % in MM
% AncDist = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_MMwoLag\20210924_Bs166_Bs175_outCollect_4runs.mat";
% AncDist = "H:\fitnessDistribution\2021_HighThroughputCompetition\AncRef_inMM_Run1-3_genTime1_outCollect.mat";
% % % % in MMGlycerol
% AncDist = "H:\fitnessDistribution\2022_withSelection\20220408_outCollect_Bs166MMGly_run1-4.mat";
% % % for all cy10/20 samples
% AncDist = "H:\fitnessDistribution\2021_HighThroughputCompetition\2021_woLag\20210628_outCollect_Bs166_woLag.mat";
%%% with Selection %%%
% % % after 5 days in CM at 37°C
% AncDist = "H:\fitnessDistribution\2022_withSelection\20220329_outCollect_LibBvalwS3ctld5_run1-6.mat";
% % % after 12.5 days in MM at 37°C
% AncDist = "H:\fitnessDistribution\2022_withSelection\20220331_outCollect_LibBvalwS2ctld12_run1-4.mat";

%%%%%% %%%%%% %%%%%%  18 h competition %%%%%% %%%%%% %%%%%% 
% % % in CM at 30°C (CntrlLib - anc:Bs213)
% % AncDist = "H:\evolinLiquid\20230222_outCollect_C3_Run001-004_gatev1.mat";
% % in CM at 37°C (Bs166)
% AncDist = "H:\evolinLiquid\competitionExp\20230822_outCollect_Bs166CM37_Run001-004.mat";

% Populations - Bs166 anc evolved for 5 days in CM
AncDist = "H:\evolinLiquid\competitionExp\analyseData\LibBvalwS3ctld5pops_Run1-3\20230908_outCollect_LibBvalwS3ctld5.mat"

% what do you want to plot?
plotSingleRuns = "ON";  % default: "ON" 
plotComparingSingleRuns = "ON";
plotSystematics = "ON";
plotErrorPlots = "OFF";

printFigs = "OFF";

corrNonFluorescentGFP = "ON";   % You can switch "OFF" and "ON"
corrANCvsGFP          = "ON";   % You can switch "OFF" and "ON"

samplePrefix = "Bs210Ctl"; % Lib or LibSCW23 or Bs166
ExpOutName   = expName;%"Bs210ctl-HTS-6runs_filCorr_v4";

% outPath for plots
savePlotPath = "H:\fitnessDistribution\2021_HighThroughputCompetition\resultsTmp\";
savePlotPath = "H:\fitnessDistribution\2022_withSelection\resultsTmp\";
savePlotPath = "H:\evolinLiquid\competitionExp\resultsTmp\";

% % % Here you have to specify some options

% how are your ancestor and gfp samples called -- needed for plot legends
% ancestor = "Bs19"; % Melihs Lib - LibGRBval
% gfp      = "Bs205";
% ancestor = "Bs166"; % LibBval / LibBspiz / Cy10/20-noSel-Lib
% gfp      = "Bs175";
% ancestor = "Bs213"; % hybLib3T / H3
% gfp      = "Bs212";
ancestor = "Bs210"; % Bs210CtlEvol5
gfp      = "Bs211";
% ancestor = "Bs224"; % Bs224CtlEvol5
% gfp      = "Bs226";

% Here you have the option to exclude samples from the merged plots (100,
% 101, ...) that contain a certain string, e.g. "Bs166"
excludeType = "ismember" ; % "ismember", "contains", "notcontains"
excludeSample = [];
% excludeSample = ancestor + string([12 24 36 48 60]); 
excludeSample = ancestor + ["V", "W", "X", "Y", "Z"]; 

% excludeType = "contains"
% excludeSample = ["Bs166" + string([12 24 36 48 60]) "Wns" "Bans" "Vns" "No" "Bspiz" "20"];
% excludeSample = ["No"];#


% OTHER OPTION - ANC DISTR: If you want to correct each day with another set of anc
% (for ANC Distr!!!) and exclude other samples as the correction ones ...
% excludeSampleopt(1,:) = ["Bs166" + string([12 24 36 48 60] - 2)];%  
% excludeSampleopt(2,:) = ["Bs166" + string([12 24 36 48 60] - 5)];%  
% excludeSampleopt(3,:) = ["Bs166" + string([12 24 36 48 60] - 11)];%
% excludeSampleopt(4,:) = ["Bs166" + string([12 24 36 48 60] - 4)];% 


% with which samples do you want to correct in corrANCvsGFP?
% these will also be excluded in all distributions
% corrANCsamples = "Bs166" + string([12 24 36 48 60]); 
% corrANCsamples = ancestor+ string([12 24 36 48 60]); 
corrANCsamples = ancestor + ["V", "W", "X", "Y", "Z"]; 
% corrANCsamples = "Bs19-" + string([12 24 36 48 60]); % Melihs Lib

% OTHER OPTION - ANC DISTR: If you want to correct each day with another set of anc
% (for ANC Distr!!!)
% % corrANCopt(1,:) = "Bs166" + string([12 24 36 48 60]-1 - randi(10,1)); 
% % corrANCopt(2,:) = "Bs166" + string([12 24 36 48 60]-1 - randi(10,1));
% % corrANCopt(3,:) = "Bs166" + string([12 24 36 48 60]-1 - randi(10,1)); 
% % corrANCopt(4,:) = "Bs166" + string([12 24 36 48 60]-1 - randi(10,1));

%%% corrANCopt - DFE - paper
% corrANCopt(1,:) = "Bs166" + string([12 24 36 48 60]-2); 
% corrANCopt(2,:) = "Bs166" + string([12 24 36 48 60]-5);
% corrANCopt(3,:) = "Bs166" + string([12 24 36 48 60]-11); 
% corrANCopt(4,:) = "Bs166" + string([12 24 36 48 60]-4);

minFracAnc = 30; % default: 30
maxFracAnc = 70; % default: 70

genTime = 16.1/60; %in hours; for Bs166 in CM medium at 37 °C it is 17.1/60 h; for MM it is 39/60 h for CM30 its 23.5/60
                    % for Bs210: 16.1 in CM at 37 °C
                    % for Bs224: 16.2 in CM at 37 °C
% what is the uncertainty of the fraction measurement?
uncertain = 5; % default: 5

% Do you want to exclude samples with a start fraction smaller than
minFrac = 40; % default: 40
% or greater than:
maxFrac = 60; % default: 60
% from the selection coefficient calculations?

% All selection coefficients that come from less than dataPointExcl data
% points (runs), will be excluded in the outCollect
% If you want to check one plate/one day, set to 1
dataPointExcl = 2; % default: 2


% plan the histograms
hists = []; histLegends = []; histmax = []; histBinWidth = 0.0025; 
histBinEdges = -40*histBinWidth-0.5*histBinWidth:histBinWidth:40*histBinWidth+0.5*histBinWidth;
cmp = repmat([0 76 255; 0 0 0; 189 38 38; 81 189 81; 235 235 84; 130 218 250; 247 134 247]/255, 70,1);
cmp_runs = [3 136 252; 88 166 111; 254 179 67; 250 69 10; 150 150 150;34 186 152]/255; 
% which samples did you expect to measure? the missing ones will be saved
% to samplesLost
upperLim = 96;
notIn = 12*[1:8];
nam = repmat(samplePrefix,1,upperLim) + string(1:upperLim);
names_all = nam(~ismember(1:upperLim,notIn));

%% Run through all sets of data seperately (merging begins in line ~126)

for c = 1 : length(facsdata)
    
    clear data outc meanS stdS time_* t
    
    if exist("corrANCopt", "var")
        % Check correct length of corrANCopt
        if size(corrANCopt,1)~= size(facsdata,2)
            error("Specify your corrANCopt samples for each input or delete the variable and use corrANCsamples instead!"); 
        end
        corrANCsamples = corrANCopt(c,:);
    end
    
    if exist("excludeSampleopt", "var")
        % Check correct length of corrANCopt
        if size(excludeSampleopt,1)~= size(facsdata,2)
            error("Specify your excludeSampleopt samples for each input or delete the variable and use corrANCsamples instead!"); 
        end
        excludeSample = excludeSampleopt(c,:);
    end
    
    % read data
    fid = fopen(facsdata(c));
    fgetl(fid); % Skip first headerline
    % Read in second headerline and extract t(1) and t(2):
    columnNames = fgetl(fid); columnNamesSep = strsplit(columnNames, {'\tnonGfpStart_', 'h\tnonGfpEnd_', 'h\ttimestampStart\t'});
    t(1) = str2num(columnNamesSep{2}); t(2) = str2num(columnNamesSep{3}); 
    
    imp = textscan(fid,'%s %f %f %s %s','delimiter','\t');
    fclose(fid);
    data.sample=imp{1}; data.start=imp{2}; data.ende=imp{3}; data.startTime = imp{4}; data.endeTime = imp{5};
    clear imp
    
    % get names and times
    nameSplit = cellfun(@(x) strsplit(x, '_'), [data.sample], 'UniformOutput', false);
    name_first = cellfun(@(x) x{1}, nameSplit, 'UniformOutput', false);
    name_last = cellfun(@(x) x{2}, nameSplit, 'UniformOutput', false);
    if size(nameSplit{10},2)>2 && size(nameSplit{end-6},2)>2 % zufällige Einträge
        plate = cellfun(@(x) x{end}, nameSplit, 'UniformOutput', false);
        plateSplit = cellfun(@(x) strsplit(x,'plate'), plate, 'UniformOutput', false);
        plateNum = cellfun(@(x) str2num(x{2}), plateSplit);
    else 
        plateNum = ones(size(nameSplit,1),1);
    end
    
    timeSplit_start = cellfun(@(x) str2double(strsplit(x,':')),data.startTime,'UniformOutput',false);
    timeSplit_ende  = cellfun(@(x) str2double(strsplit(x,':')),data.endeTime,'UniformOutput',false);
    
    for i=1:length(data.sample)
        time_start(i) = timeSplit_start{i}(1)*3600 + timeSplit_start{i}(2)*60 + timeSplit_start{i}(3);
        time_ende(i)  = timeSplit_ende{i}(1)*3600  + timeSplit_ende{i}(2)*60  + timeSplit_ende{i}(3);
    end
    % Find gfps
    pureGFPMask{c} = cellfun('isempty', name_first) & cellfun(@(x) contains(x,gfp), name_last);
    s_woGFP{c} = find(~cellfun('isempty', name_first));
    
    %% Correct raw data - 1 - non-fluorenscent GFP correction:
    
    switch corrNonFluorescentGFP
        
        case "ON"
            start_corr = nan(numel(data.start),1); ende_corr = nan(numel(data.start),1);
            % percentage of counts that are nongfp if we measure a 100% gfp sample:
            plUniq = unique(plateNum);
            for pl = 1 : numel(plUniq)
                maskPl = plateNum == plUniq(pl);
                if sum(pureGFPMask{c} & maskPl) > 0 
                    nongfp_start = mean(data.start(pureGFPMask{c} & maskPl)./(100-data.start(pureGFPMask{c} & maskPl)));
                    nongfp_ende  = mean( data.ende(pureGFPMask{c} & maskPl)./(100- data.ende(pureGFPMask{c} & maskPl)));
                else
                    nongfp_start = 0; nongfp_ende = 0 ;
                end

                start_corr(find(maskPl)) = (data.start(find(maskPl)) - (100-data.start(find(maskPl)))* nongfp_start);
                ende_corr =  (data.ende(:)  - (100-data.ende(:)) * nongfp_ende);
                
            end 
            data.start_corr = start_corr;
            data.ende_corr = ende_corr; 
            
            if sum(isnan(data.start_corr))>0
                error("Not all points are gfp-corrected correctly!")
            end
            
% %         case "ON"
% %             % percentage of counts that are nongfp if we measure a 100% gfp sample:
% %             if ~isempty(pureGFP{c})
% %                 nongfp_start = mean(data.start(pureGFP{c})./(100-data.start(pureGFP{c})));
% %                 nongfp_ende  = mean( data.ende(pureGFP{c})./(100- data.ende(pureGFP{c})));
% %             else
% %                 nongfp_start = 0; nongfp_ende = 0 ;
% %             end
% %             
% %             start_corr = (data.start(:) - (100-data.start(:))* nongfp_start);
% %             data.start_corr = start_corr;  
% %             ende_corr =  (data.ende(:)  - (100-data.ende(:)) * nongfp_ende);
% %             data.ende_corr = ende_corr; 
% %             
        case "OFF"
            data.start_corr = data.start;
            data.ende_corr = data.ende;
            
        otherwise
            error("Your correction 1 - non-fluorenscent GFP correction - needs to be turned ON or OFF.");
            
    end
    
    %% Calculate selection coefficients
    % in outc, only the samples appear, that are not pure gfp ..
    fprintf("Calculating selection coefficients (t = [" + num2str(t(1))+ " "+ num2str(t(2))+ "])... \n");
    
    for i = 1 : length(s_woGFP{c})
        idx_woGFP = s_woGFP{c}(i);
        outc(i).sample = string(data.sample(idx_woGFP));
        outc(i).start_s = data.start_corr(idx_woGFP);
        outc(i).ende_s = data.ende_corr(idx_woGFP);
        
        [outc(i).s,outc(i).s_Err] = scoeff(outc(i).start_s,outc(i).ende_s,uncertain,genTime,t(2)-t(1));
        outc(i).s_ErrPerc = 100 * outc(i).s_Err/outc(i).s;
        
        outc(i).sampleID = string(name_first{idx_woGFP});
        outc(i).plate = plateNum(idx_woGFP);
        outc(i).tendency = "neutral";
        
        outc(i).startTime = time_start(idx_woGFP);
        outc(i).endeTime  = time_ende(idx_woGFP);
    end

    % TENDENCY from plate to plate
    % we want to test if for all experiment days the tendency is correct,
    % meaning, if the amount of gfp goes up from plate 1 to 4
    
    [namesHere,~]     = unique([outc(:).sampleID]);
        
    for i=1:numel(namesHere)
        idx = find(ismember([outc(:).sampleID],namesHere(i)));
        starts_test = [outc(idx).start_s];
        plates_test = [outc(idx).plate];
        [a,~,where] = unique(plates_test);
        if numel(a)==1
            [outc(idx).tendency] = deal("neutral");
        elseif numel(a)==2 && mean(starts_test(where==2)) - mean(starts_test(where==1)) < 4
            [outc(idx).tendency] = deal("good");
            
        elseif numel(a)==3 && mean(starts_test(where==2)) - mean(starts_test(where==1)) < 4 ...
                && mean(starts_test(where==3)) - mean(starts_test(where==2)) < 4
            
            [outc(idx).tendency] = deal("good");
        elseif numel(a)==4 && mean(starts_test(where==2)) - mean(starts_test(where==1)) < 4 ...
                && mean(starts_test(where==3)) - mean(starts_test(where==2)) < 4 ...
                && mean(starts_test(where==4)) - mean(starts_test(where==3)) < 4
            
            [outc(idx).tendency] = deal("good");
        else
            [outc(idx).tendency] = deal("bad");
        end
        
    end
    
    countTendency{c} = sum([outc.tendency]=="bad")/numel([outc.tendency]);
    
    clear numbers sortOrder
    %% Correct raw data - 2 - Correction of difference btw reporter and anc PER PLATE:
    
    % Create mask for excluding all ancestor entries with start fractions smaller than
    % minFrac or greater than maxFrac 
    fracMaskcorrAnc = ~([outc.start_s]<minFracAnc | [outc.start_s]>maxFracAnc);
    
    switch corrANCvsGFP
        case "ON"
        
        for pl=1:5
            outc_plateMask = [];
            outc_plateMask = [outc.plate]==pl;
            outc_plateIdx = find([outc.plate]==pl);
            if sum(outc_plateMask) > 0
            
                % Find ancestors with which to correct
                ancs = ismember([outc.sampleID], corrANCsamples) & outc_plateMask;
                fprintf("Correcting plate " + num2str(pl) + " with " + sum(ancs&fracMaskcorrAnc) + ".\n");
                if sum(ancs&fracMaskcorrAnc) == 0
                    fprintf("There are no ancestors to correct plate " + num2str(pl) + ", \nso all data points from plate " + num2str(pl) + " will be excluded in the following anaylsis!\n")
                    for i = 1 : length(outc_plateIdx)
                        tmp = outc_plateIdx(i);
                        outc(tmp).s_corr = NaN;
                        outc(tmp).s_corrErr = NaN;
                    end
                    continue
                end
                
                [anc_Mean,anc_MeanErr] = getMeanError([outc(ancs&fracMaskcorrAnc).s],[outc(ancs&fracMaskcorrAnc).s_Err]);
            
                
            for i = 1 : length(outc_plateIdx)
                tmp = outc_plateIdx(i);
                outc(tmp).s_corr = outc(tmp).s - anc_Mean;
                
                outc(tmp).s_corrErr = sqrt( outc(tmp).s_Err ^2 + anc_MeanErr ^2) / 2;
                
            end
            
            end
        end
            
           
        case "OFF"
            for i = 1 : length(s_woGFP{c})
                outc(i).s_corr = outc(i).s;
                outc(i).s_corrErr = outc(i).s_Err;
            end
            
        otherwise
            error("Your ANC vs GFP - correction is not working properly!");
    end
    
    
%% Exclude samples:
    % % -- from excludeSample
    % % -- the ones that cannot be corrected (no anc on the plate)

    % % % % % % % % % % % % % % % % % 
    % % % % A mask for exclude is made
    exclMask = zeros(1,length([outc.sample]));
    if ~isempty(excludeSample) && excludeType == "ismember"
        exclMask = ismember([outc.sampleID],excludeSample);
    elseif ~isempty(excludeSample) && excludeType == "contains"
        exclMask = contains([outc.sampleID],excludeSample);
    elseif ~isempty(excludeSample) && excludeType == "notcontains"
        exclMask = ~contains([outc.sampleID],excludeSample); % | ~contains([outc.sampleID],"20");
    end
    
    % find all samples that cannot be corrected
    exclMask = exclMask | isnan([outc.s_corr]);
    
% % % % % % % % % % % % % % % % % 

    % indices of samples of interest:
    s_idx = find(~exclMask)';
    
    % apply mask
    outc = outc(s_idx);
    fracMaskcorrAnc = fracMaskcorrAnc(s_idx);
    if isempty(outc)
        error("Remove " +facsdata(c)+ " ! All datapoints are excluded from the analysis!")
    end
    
    % sort the samples numerically according to their number
    numbers = regexp([outc.sampleID],'\d*','Match');  % extract the numbers
    numbLen = cellfun(@(x) numel(x), numbers);
    
    % if there are more numbers or no numbers in some names, then dont sort
    if sum(cellfun(@(x) numel(x)>1,numbers))>0 | sum(cellfun(@(x) numel(x)==0,numbers))>0 
        sortOrder = [1:numel(numbers)];  
    else
        [~,sortOrder] = sort(double([numbers{numbLen==1}]));       % sort      
    end

    % % % %
    % this is the preliminary data 
    outc = outc(sortOrder);
    fracMaskcorrAnc = fracMaskcorrAnc(sortOrder);
    samples{c} = unique([outc.sampleID],'stable');
    
    % with the data at this point, create a frac mask
    fracMask = ~([outc.start_s]<minFrac | [outc.start_s]>maxFrac);
    
    %% Plotting results of the single runs
    
    if plotSingleRuns == "ON"
        
        fprintf("Plotting results ... \n");
        
        % Plot with UNCORRECTED s ... figure(1),(7),(13)...
        figure(c*6-5);
        title("Sample" + c + "-- the UNCORRECTED s")
        hold on;
        set(gcf, 'Position', [25 570 560 420], 'Renderer', 'painters')
        plot([0.5 length(samples{c})+0.5],[0 0], '--', 'Color', [0.2 0.2 0.2])
        
        tmpS = [outc.s];
        tmpID = [outc.sampleID];
        boxplot(tmpS(fracMask),tmpID(fracMask)); ylabel('selection coeff uncorrected')

        if length(samples{c}) > 4
            set(gca, 'XTickLabelRotation', 15)
        end
        
        % Plot with CORRECTED s ... figure(2),(8),(14)...
        figure(c*6-4); hold on;
        title("Sample" + c + "-- the CORRECTED s")
        set(gcf, 'Position', [600 570 560 420], 'Renderer', 'painters')
        plot([0.5 length(samples{c})+0.5],[0 0], '--', 'Color', [0.2 0.2 0.2])
        tmpSCorr = [outc.s_corr];
        tmpID = [outc.sampleID];
        boxplot(tmpSCorr(fracMask),tmpID(fracMask));
        ylabel('selection coeff corrected')

        if length(samples{c}) > 4
            set(gca, 'XTickLabelRotation', 15)
        end

        % Set x/y Limit
        yLimit = max([abs(tmpS(fracMask)) abs(tmpSCorr(fracMask)) 0.0001]);
        figure(c*6-5);
        ylim([-yLimit-yLimit/5 yLimit+yLimit/5])
        xlim([0 numel(tmpID(fracMask))+1])
        figure(c*6-4);
        ylim([-yLimit-yLimit/5 yLimit+yLimit/5])
        xlim([0 numel(tmpID(fracMask))+1])
        
    end
    
    if plotSystematics == "ON"
        % Plot CORRECTED s against start frac for each plate. .. figure(310)..
        % Plot CORRECTED s against meas. order for each plate. .. figure(410)..
        %%% Is there a systematic? %%%
        
        outc_plateMask = zeros(4,size(outc,2));
        
        for pl=1:5
            outc_plateMask = [];
            outc_plateMask = [outc.plate]==pl;
            
            if sum(outc_plateMask) > 0
                corrMask = ismember([outc.sampleID],corrANCsamples);
                sanity   = [outc.start_s] > 0 & ~isnan([outc.s_corr]);
                
                collect_s_corr    = [outc(outc_plateMask & sanity).s_corr];
                collect_start_s   = [outc(outc_plateMask & sanity).start_s];
                collect_ende_s    = [outc(outc_plateMask & sanity).ende_s];
                collect_timeStart = [outc(outc_plateMask & sanity).startTime];
                collect_timeEnde = [outc(outc_plateMask & sanity).endeTime];
                lengthStartMeas = max(collect_timeStart) - min(collect_timeStart);
                lengthEndeMeas = max(collect_timeEnde) - min(collect_timeEnde);
                
            figure(300 + 10*c); hold on; set(gcf, 'Renderer', 'painters'); box on;
                m_fD     = scatter(collect_start_s,collect_s_corr,'*','MarkerEdgeColor',cmp(pl,:), 'LineWidth', 1.2); hold on; %cmp_runs(pl,:)); hold on
                m_fDcorr = scatter([outc(outc_plateMask & sanity & corrMask).start_s],[outc(outc_plateMask & sanity & corrMask).s_corr],'d','MarkerEdgeColor','m'); hold on
                
            figure(400 + 10*c + pl); set(gcf, 'Position', [1200 70 560 850], 'Renderer', 'painters')
                subplot(3, 1, 1); box on; hold on;
                m_fD2     = scatter(collect_timeStart,collect_s_corr,'*','MarkerEdgeColor','k'); hold on%cmp_runs(pl,:)); hold on
                m_fD2corr = scatter([outc(outc_plateMask & sanity & corrMask).startTime],[outc(outc_plateMask & sanity & corrMask).s_corr],'d','MarkerEdgeColor','m');
                local_corrMean = mean([outc(outc_plateMask & sanity & corrMask).s_corr]);
                plot([0 1e7],[local_corrMean local_corrMean],'m--')
                
                
            figure(300 + 10*c);
                xlim([minFrac-10 maxFrac+10]);
                ax = gca;
                ylim([min([collect_s_corr ax.YLim+0.1])-0.1 max([collect_s_corr ax.YLim-0.1])+0.1]);
                
                if numel(collect_start_s) >= 5
                    [corrCov,~] = corrcoef(collect_start_s,collect_s_corr);
                    text(max(collect_start_s)-5,max(collect_s_corr)+0.05,"Correlation = " + num2str(corrCov(2,1), "%0.3f"), "Color", cmp(pl,:));
                end
                
                title("Dependency start fraction and s" + "-- sample" + string(c))
                xlabel('Start Frac Sample'); ylabel('Selection Coeff corrected')
                
            figure(400 + 10*c + pl); subplot(3, 1, 1);
                xlim([min(collect_timeStart)-50 max(collect_timeStart)+50]);
                ylim([min(collect_s_corr)-0.1 max(collect_s_corr)+0.1]);
                
                if numel(collect_timeStart) >= 5
                    [corrCov,~] = corrcoef(collect_timeStart,collect_s_corr);
                    text(max(collect_timeStart)-0.35*lengthStartMeas,max(collect_s_corr+0.05),"Correlation = " + num2str(corrCov(2,1), "%0.3f"))
                end
                
                title("Dependency on order of measurement -- sample " + string(c) + " -- plate" + string(pl))
                xlabel('Time [s]'); ylabel('Selection Coeff Corrected')
                
            figure(400 + 10*c + pl); subplot(3, 1, 2); box on;
                hold on; ylabel("Start Fraction [%]")
                plot(collect_timeStart, collect_start_s, "kx", "LineWidth", 1.4)
                xlim([min(collect_timeStart)-50 max(collect_timeStart)+50]);
                ylim([20 80])
                xlabel("Duration: " + num2str(lengthStartMeas/60, "%0.1f") + " min")
                if numel(collect_timeStart) >= 5
                    [corrCov,~] = corrcoef(collect_timeStart, collect_start_s);
                    text(max(collect_timeStart)-0.35*lengthStartMeas,max(collect_start_s)+10,"Correlation = " + num2str(corrCov(2,1), "%0.3f"))
                end
                
            figure(400 + 10*c + pl); subplot(3, 1, 3); box on;
                 hold on; ylabel("End Fraction [%]")
                plot(collect_timeEnde, collect_ende_s, "kx", "LineWidth", 1.4)
                xlim([min(collect_timeEnde)-50 max(collect_timeEnde)+50]);
                ylim([20 80]);
                xlabel("Duration: " + num2str(lengthEndeMeas/60, "%0.1f") + " min")
                if numel(collect_timeEnde) >= 5
                    [corrCov,~] = corrcoef(collect_timeEnde, collect_ende_s);
                    text(max(collect_timeEnde)-0.35*lengthEndeMeas,max(collect_ende_s)+10,"Correlation = " + num2str(corrCov(2,1), "%0.3f"))
                end
            end
        end
        
    end
    
    
    %% Exclude samples
    
    % % -- all samples with too high/low start fractions 

    outc = outc(fracMask & ~contains([outc.sample], corrANCsamples) | fracMaskcorrAnc & contains([outc.sample], corrANCsamples));
    samples{c} = unique([outc.sampleID],'stable');
    
    samplesLost{c} = names_all(~ismember(names_all,samples{c}));
    
    %% Calculating means and stds, 
    % % -- saving them
    % % -- plotting histograms   
    % (here, the values with too high/low start fraction are excluded!!

    meanS = []; errorS = []; % -> the arrays will fit samples{c}
    for i = 1 : length(samples{c})
        % Find the sample in outc but exclude the ones with too high/low start
        % fracs (fracMask)
        idx = find(strcmp(samples{c}(i), [outc.sampleID]));
        
        tmpSCorr = [outc(idx).s_corr];
        tmpSError= [outc(idx).s_corrErr];
        
        % Here, instead of just calculating the std, we take the errors into
        % account and evaluate error of mean with error propagation
        [meanS(i),errorS(i)] = getMeanError(tmpSCorr,tmpSError);
        
    end
    
    samplesC = cellfun(@(x) {string(x)},cellstr(samples{c})); % convert samples to cell
    
    if ~exist("outSIndividual","var")
        % Saving all information about the individual samples
        outSIndividual = struct("Sample", {outc.sampleID},"Exp", num2cell(c*ones(1,length(outc))), "startFrac", num2cell([outc.start_s]), "endFrac", num2cell([outc.ende_s]),...
            "s", num2cell([outc.s_corr]),"sErr", num2cell([outc.s_corrErr]));
        % Saving the mean and std per sample PER RUN
        outS = struct("Sample", samplesC, "Run", num2cell(c*ones(1,length(samples{c}))), "meanS", num2cell(meanS), "errorS", num2cell(errorS));
    else
        outSaveAdd = struct("Sample", {outc.sampleID},"Exp", num2cell(c*ones(1,length(outc))), "startFrac", num2cell([outc.start_s]), "endFrac", num2cell([outc.ende_s]),...
            "s", num2cell([outc.s_corr]),"sErr", num2cell([outc.s_corrErr]));
        outSIndividual = [outSIndividual outSaveAdd];
        outSAdd = struct("Sample", samplesC, "Run", num2cell(c*ones(1,length(samples{c}))), "meanS", num2cell(meanS), "errorS", num2cell(errorS));
        outS = [outS outSAdd];
        clear *Add
    end
    
    
    % overlay the histograms
    f10 = figure(10); set(gcf, 'Position', [550 350 960/2 420/2], 'Renderer', 'painters');
    hold on; box on;
    set(gca, 'FontSize', 9);
    xlabel("selection coefficient"); ylabel("Counts");
    
    h_fDSingle = histogram(meanS, "BinEdges", histBinEdges, "Normalization", "probability");
    h_fDSingle.FaceColor = "none";
    h_fDSingle.EdgeColor = cmp(c,:);
    h_fDSingle.LineWidth = 1.2;
    
    m_fD = plot([mean(meanS) mean(meanS)], [0 4], "--", "LineWidth", 1.2,'Color',cmp(c,:));
    
    histmax = [histmax max(h_fDSingle.Values)];
    hists = [hists,h_fDSingle,m_fD];
    dateTmp = regexp(facsdata(c), "\d*", "Match"); dateMeasured = dateTmp(cellfun("length", dateTmp)==8);
    histLegends = [histLegends,"Run "+c + ": " + dateMeasured,"Mean Run " + c];
    legend(hists,histLegends,'Location','NorthWest')
    
    ylim([0 max(histmax) + 0.05]);
    
end

%% Plotting the results merged together

% ----------------------------------------------------------------------
% ------------------PLOT ------- outSIndividual ------------------------
% -----------------------------------------------------------------------

if plotComparingSingleRuns == "ON"
    
    % Give every sampleSet a unique name to not mix up the same replicates
    % measured at different days
    for i = 1 : length(outSIndividual)
        outSIndvNames(i) = outSIndividual(i).Sample + "_Run" + num2str(outSIndividual(i).Exp);
    end
    
    % Sort the samples for a better over view
    [sortSIndv, sortIdxSIndv] = sort(outSIndvNames);
    unsortSIndv = [outSIndividual(:).s];
    unsortSIndvErr = [outSIndividual(:).sErr];
    sortedSIndv = unsortSIndv(sortIdxSIndv);
    sortedSIndvErr = unsortSIndvErr(sortIdxSIndv);
    
    % Plot the selection coefficent seperately for each run
    f100 = figure(100); hold on; grid on;
    set(gcf, 'Position', [0 50 760/1.9 420/2], 'Renderer', 'painters') % for only one set of data
    set(gca, 'FontSize', 9);
    ylabel("Selection Coefficient");
    % set(gcf, 'Position', [0 50 960 420], 'Renderer', 'painters')
    set(gca, 'XTickLabelRotation', 40)
    boxplot(sortedSIndv,cellstr(sortSIndv))
    plot([0.5 length(unique(sortSIndv))+0.5],[0 0], '--', 'Color', [0.2 0.2 0.2])
    ylim([min(sortedSIndv)-0.1 max(sortedSIndv)+0.1])
    
    % plot each run with error
    f101 = figure(101); hold on; grid on;
    set(gcf, 'Position', [0 50 760 420], 'Renderer', 'painters') % for only one set of data
    set(gca, 'XTick',[1:numel(outSIndvNames)],'XTickLabel',outSIndvNames,'XTickLabelRotation', 15)
    ylabel("Selection Coefficient");
    plot([0 numel(outSIndvNames)+1], [0 0], "k--", "LineWidth",1.2)
    % set(gcf, 'Position', [0 50 960 420], 'Renderer', 'painters')
    set(gca, 'XTickLabelRotation', 15)
    errorbar(sortedSIndv,sortedSIndvErr,'o');
    yLimitf101 = max(abs(sortedSIndv+sortedSIndvErr))
    ylim([-yLimitf101-yLimitf101/5 yLimitf101+yLimitf101/5])
    xlim([0 numel(outSIndvNames)+1])
end


%% Collecting all the runs for each sample - create outCollect
clear sortOrder numbers numbers_temp

% Sort the sample summary outS for a better over view
numbers = regexp([outS.Sample],'\d*','Match');

% if there are more numbers in some names, then take first
if sum(cellfun(@(x) numel(x)>1,numbers))>0 | sum(cellfun(@(x) numel(x)==0,numbers))>0
    sortOrder = [1:numel(numbers)];
else
    [~,sortOrder] = sort(double([numbers{:}]));       % sort
end

MeanSamples_sort = [outS(sortOrder).Sample];
MeanS_sort = [outS(sortOrder).meanS];
Run_sort = [outS(sortOrder).Run];

% Calculating means and std again!: (over all experiment days!)
samplesOutput = unique(MeanSamples_sort,'stable');
for i = 1 : length(samplesOutput)
    idx = find(strcmp(samplesOutput{i}, [outS(:).Sample]));
    dataPoints(i) = length(idx);
    
    tmpS      = [outS(idx).meanS];
    tmpSError = [outS(idx).errorS];
    
    [meanMeanS(i),ErrorMeanS(i)] = getMeanError(tmpS,tmpSError);
    stdErrorMeanS(i)   = std(tmpS) / sqrt(length(tmpS));
end

samplesOut = cellfun(@(x) {string(x)},cellstr(samplesOutput));

% Saving the mean and std per sample per run
outCollect = struct("Sample", samplesOut,"dataPoints", num2cell(dataPoints),...
    "meanS", num2cell(meanMeanS), "stdErrorS", num2cell(stdErrorMeanS), "errorS", num2cell(ErrorMeanS));

% % Exclude all samples from outCollect
% % % --with less than dataPointExcl data points
dataPoExclMask = [outCollect.dataPoints]<dataPointExcl;

if sum(dataPoExclMask) == length(dataPoExclMask)
    error("'dataPointExcl' parameter is set wrong, all data points are excluded.")
end

% This is just printing while running the script, to know which samples are excluded
if sum(dataPoExclMask)>0
    fprintf("\nRemoving samples with less than "+ num2str(dataPointExcl)+ " data points........\n") ;
    exclSampl = [outCollect(dataPoExclMask).Sample];
    for i = 1 : sum(dataPoExclMask)
        fprintf("--> " + exclSampl(i) + "\n");
    end
    fprintf("\n");
end

outCollect_all = outCollect;
outCollect = outCollect(~dataPoExclMask);

samplesLostAll = names_all(~ismember(names_all,[outCollect.Sample]));

%% Plot collected data 
% ----------------------------------------------------------------------
% ------------------PLOT ------- outCollect----- ------------------------
% -----------------------------------------------------------------------

ymax = max([outSIndividual.s]) + 0.1;
ymin = min([outSIndividual.s]) - 0.05;

if plotErrorPlots == "ON"
    % for each sample the boxplot
    f200 = figure(200); hold on;
    ylabel("Selection Coefficient");
    title('s for each sample (each run contributes with max. 1 data point)')

    set(gcf, 'Position', [850 350 1000/1.5 1000/3], 'Renderer', 'painters')
    set(gca, 'XTick',1:length(MeanS_sort),'XTickLabelRotation', 15,'FontSize', 9)

    plot([0 length(MeanS_sort)+1],[0 0], '--', 'Color', [0.2 0.2 0.2])
    plot([1:length([outCollect_all.meanS])],[outCollect_all.meanS],'m*','HandleVisibility','off')
    boxplot(MeanS_sort,cellstr(MeanSamples_sort))
    ylim([ymin ymax])
end
    % for each sample the boxplot with supermuch infos extra
    f201 = figure(201); hold on; 
    ylabel("Selection Coefficient");
    title('s for each sample (each run contributes with max. 1 data point)')

    set(gcf, 'Position', [850 350 1000/1.5 1000/3], 'Renderer', 'painters')
    set(gca, 'XTick',1:length(MeanS_sort),'XTickLabelRotation', 65,'FontSize', 6)

    plot([0 length(MeanS_sort)+1],[0 0], '--', 'Color', [0.2 0.2 0.2],'HandleVisibility','off')
    boxplot(MeanS_sort,cellstr(MeanSamples_sort),'Colors',[0.8 0.8 0.8])
    plot([1:length([outCollect_all.meanS])],[outCollect_all.meanS],'kd','HandleVisibility','off','MarkerFaceColor','k', 'MarkerSize', 5)

    shift = linspace(-0.01,0.01,numel(unique(Run_sort)));
    % run over each run so that runs are plotted individually
    for i = unique(Run_sort)
        whereRun  = (Run_sort==i);

        [~,whereNames] = ismember(MeanSamples_sort(whereRun),[outCollect.Sample]);

        scatter(whereNames + shift(i),MeanS_sort(whereRun),'x','MarkerEdgeColor',cmp_runs(i,:),...
            'Displayname',"Run " + i, 'LineWidth', 1.2);
    end
    legend('NumColumns',4)
    ylim([ymin ymax])
    ylim([-0.3 0.3])

    
if plotErrorPlots == "ON"
    
    % for teach sample the boxplot with supermuch infos extra
    f202 = figure(202); hold on;
    ylabel("Selection Coefficient");
    title('s for each sample -- each measurement is shown from diff. days')

    set(gcf, 'Position', [850 350 1000/1.5 1000/3], 'Renderer', 'painters')
    set(gca, 'XTick',1:length(MeanS_sort),'XTickLabelRotation', 15,'FontSize', 9)

    plot([0 length(MeanS_sort)+1],[0 0], '--', 'Color', [0.2 0.2 0.2],'HandleVisibility','off')
    boxplot(MeanS_sort,cellstr(MeanSamples_sort),'Colors',[0.8 0.8 0.8])
    plot([1:length([outCollect.meanS])],[outCollect.meanS],'dm','HandleVisibility','off','MarkerFaceColor','m')

    shift = linspace(-0.3,0.3,numel(unique([outSIndividual.Exp])));
    for i = unique([outSIndividual.Exp])
        whereS  = ([outSIndividual.Exp]==i);
        [~,whereNames] = ismember([outSIndividual(whereS).Sample],[outCollect.Sample]);

        scatter(whereNames,[outSIndividual(whereS).s],'x','MarkerEdgeColor',cmp_runs(i,:),...
            'Displayname',"Run " + i);
    end
    legend('NumColumns',4)
    ylim([ymin ymax])

    % for each sample the error bars from measurement inaccuracy
    f210 = figure(210); hold on;
    ylabel("Selection Coefficient");

    set(gcf, 'Position', [850 350 1000/1.5 1000/3], 'Renderer', 'painters')
    set(gca, 'XTick',1:length([outCollect.Sample]),'XTickLabel',[outCollect.Sample],'XTickLabelRotation', 15,'FontSize', 9)
    errorbar([outCollect.meanS],[outCollect.errorS],'k.','HandleVisibility','off');
    plot(1:length([outCollect.Sample]),[outCollect.meanS],'m*','Displayname','s mean with error');

    plot([0 length([outCollect.Sample])+1],[0 0],'--','Color',[0.2 0.2 0.2],'HandleVisibility','off')
    legend('NumColumns',4)
    ylim([ymin ymax])

    % for each sample the standard mean error
    f220 = figure(220); hold on;
    ylabel("Selection Coefficient");

    set(gcf, 'Position', [850 350 1000/1.5 1000/3], 'Renderer', 'painters')
    set(gca, 'XTick',1:length([outCollect.Sample]),'XTickLabel',[outCollect.Sample],'XTickLabelRotation', 15,'FontSize', 9)
    errorbar([outCollect.meanS],[outCollect.stdErrorS],'k.','HandleVisibility','off');
    plot(1:length([outCollect.Sample]),[outCollect.meanS],'m*','Displayname','s mean with error');

    plot([0 length([outCollect.Sample])+1],[0 0],'--','Color',[0.2 0.2 0.2],'HandleVisibility','off')
    legend('NumColumns',4)
    ylim([ymin ymax])
end


%% Fitness distribution of all runs taken together
% but if there were ancestors, then these are plotted ontop

f11 = figure(11); set(gcf, 'Position', [1150 350 990/2 440/2], 'Renderer', 'painters');
title("All samples against the ancestor samples used for correction")
hold on; box on;
set(gca, 'FontSize', 9);

h_fD = histogram([outCollect(~ismember([outCollect.Sample], corrANCsamples)).meanS], 'BinEdges', histBinEdges,...
    'Normalization', 'count','FaceColor',cmp(1,:),'EdgeColor','none','LineWidth',1.5);
h_fDAnc = histogram([outCollect(ismember([outCollect.Sample], corrANCsamples)).meanS], 'BinEdges', histBinEdges,...
    'Normalization', 'count','FaceColor',[0.2 0.2 0.2],'FaceAlpha', 1,'EdgeColor','none','LineWidth',1.5);

ylabel("Counts");

ylim([0 1.15*max([h_fD.Values h_fDAnc.Values])]);
xlim([-max(abs(h_fD.BinLimits))-h_fD.BinWidth max(abs(h_fD.BinLimits))+h_fD.BinWidth]);

mean_fD    = mean([outCollect(~ismember([outCollect.Sample], corrANCsamples)).meanS]);
std_fD     = std([outCollect(~ismember([outCollect.Sample], corrANCsamples)).meanS]);
mean_fDAnc = mean([outCollect(ismember([outCollect.Sample], corrANCsamples)).meanS]);
std_fDAnc  = std([outCollect(ismember([outCollect.Sample], corrANCsamples)).meanS]);

m_fD = plot([mean_fD mean_fD], [0 1.15*max([h_fD.Values h_fDAnc.Values])], "-",...
    "LineWidth", 0.8, "Color", cmp(1,:));


%%% Here check if there are any ancestor data points -- if not, then skip %
%%% plotting the data in the legend

if all(isnan(h_fDAnc.Values))
    legend([h_fD m_fD ], "DFE library",...
        "Mean = " + num2str(mean_fD, "%0.4f") + "\newlineStd = " + num2str(std_fD, "%0.4f"),...
        'Location','NorthWest')
else
    m_fDAnc = plot([mean_fDAnc mean_fDAnc], [0 1.15*max([h_fD.Values h_fDAnc.Values])], "-",...
        "LineWidth", 0.8, "Color", [0.2 0.2 0.2 0.8]);
    legend([h_fD h_fDAnc m_fD m_fDAnc], "DFE library", "corr "+ ancestor + " samples",...
        "Mean = " + num2str(mean_fD, "%.1d") + "\newlineStd = " + num2str(std_fD, "%.1d"),...
        "Mean = " + num2str(mean_fDAnc, "%.1d") + "\newlineStd = " + num2str(std_fDAnc, "%.1d"),...
        'Location','NorthWest')
    legend([h_fD h_fDAnc m_fD m_fDAnc], ["DFE library", "corr "+ ancestor + " samples",...
        "Mean = " + num2str(mean_fD, "%.3f") + "\newlineStd = " + num2str(std_fD, "%.3f"),...
        "Mean = " + num2str(mean_fDAnc, "%.3f") + "\newlineStd = " + num2str(std_fDAnc, "%.3f")],...
        'Location','NorthWest')
end



%% Now compare the ancestor distribution to the evaluated data.
% Plot the distributions with mean and std
% do the ks test --  are they the same?

if compareAnc == "ON"
    
    % take the locally analysed data from outCollect
    % BUT --> avoid that ancestors get mixed up in the Lib, write output
    noAncs = ~ismember([outCollect.Sample], corrANCsamples);
    LibmeanS = [outCollect(noAncs).meanS];
    
    fprintf("--> %i ancestor sample*s in your local data excluded \n",sum(noAncs==0))
    
    %%%
    collectAnc = load(AncDist);
    AncmeanS = [collectAnc.outCollect(:).meanS];
        
% %     hists = []; histLegends = []; histmax = []; histBinWidth = 0.01/3; 
% %     histBinEdges = -40*histBinWidth-0.5*histBinWidth:histBinWidth:40*histBinWidth+0.5*histBinWidth;
    
    f30 = figure(30); set(gcf, 'Position', [550 350 700 420], 'Renderer', 'painters');
     set(gcf, 'Position', [550 350 520 260], 'Renderer', 'painters');
    hold on; box on; 
    set(gca, 'FontSize', 14);
    
    h_fD = histogram(LibmeanS, 'BinEdges', histBinEdges,...
        'Normalization', 'probability','FaceColor','none','EdgeColor',cmp(1,:),'LineWidth',1.5);
    h_fDAnc = histogram(AncmeanS, 'BinEdges', histBinEdges,...
        'Normalization', 'probability','FaceColor',[0.2 0.2 0.2],'FaceAlpha', 0.4, 'EdgeColor','none','LineWidth',1.5);


    ylabel("p");
    xlabel("Selection coefficient")
    
    ylim([0 1.15*max([h_fD.Values h_fDAnc.Values])]);
    xlim([-max(abs(h_fD.BinLimits))-h_fD.BinWidth max(abs(h_fD.BinLimits))+h_fD.BinWidth]);
%     xlim([-0.4 0.4])
    mean_fD    = mean(LibmeanS);
    std_fD     = std(LibmeanS);
    mean_fDAnc = mean(AncmeanS);
    std_fDAnc  = std(AncmeanS);
    
    plotOutliers = "OFF";
    if plotOutliers == "ON"
    yyaxis right
        ylim([0 numel(LibmeanS)*1.15*max([h_fD.Values h_fDAnc.Values])])
        set(gca, "YTickLabel", "")
        h_fDOutl = histogram(LibmeanS(abs(LibmeanS)>abs(mean_fD)+.318*std_fD), 'BinEdges', histBinEdges,...
            'Normalization', 'count','EdgeColor','none','FaceColor',[0.8000 0.1059 0], 'FaceAlpha', 1,'LineWidth',1.5);
        set(gca, "YColor", "k")    
    yyaxis left
    end
    

    m_fD = plot([mean_fD mean_fD], [0 1.15*max([h_fD.Values h_fDAnc.Values])], "--",...
        "LineWidth", 1.2, "Color", [cmp(1,:) 0.5]);
    m_fDAnc = plot([mean_fDAnc mean_fDAnc], [0 1.15*max([h_fD.Values h_fDAnc.Values])], "-.",...
        "LineWidth", 1.2, "Color", [0.2 0.2 0.2 0.5]);
    
%         legend([h_fD m_fD m_fDAnc h_fDOutl], ExpOutName,...
%             "Mean = " + num2str(mean_fD, "%.3f") + "\newlineStd = " + num2str(std_fD, "%.3f"),...
%             "Mean = " + num2str(mean_fDAnc, "%.3f") + "\newlineStd = " + num2str(std_fDAnc, "%.3f"),...
%             'Location','NorthWest')
%     
%         legend([h_fDAnc m_fDAnc h_fD m_fD h_fDOutl], "Control","Mean = " + num2str(mean_fDAnc, "%.3f") + "\newlineStd = " + num2str(std_fDAnc, "%.3f"),...
%             ExpOutName , "Mean = " + num2str(mean_fD, "%.3f") + "\newlineStd = " + num2str(std_fD, "%.3f"),...
%             "Outlier", 'Location','NorthWest')
    % 
            legend([h_fDAnc m_fDAnc h_fD m_fD], "Control","Mean = " + num2str(mean_fDAnc, "%.3f") + "\newlineStd = " + num2str(std_fDAnc, "%.3f"),...
                ExpOutName , "Mean = " + num2str(mean_fD, "%.3f") + "\newlineStd = " + num2str(std_fD, "%.3f"),...
                'Location','NorthWest')
                                                                        

    [h,p] = kstest2(AncmeanS,LibmeanS);
    if h==1
        testResult = "The null hypothesis was rejected, the distributions are significantly different! \n";
    elseif h==0
        testResult = "The null hypothesis was NOT rejected, the distributions are the same!";
    end
    sprintf(testResult + "The p-value is %0d",p)
    
else
    noAncs = ~ismember([outCollect.Sample], corrANCsamples);
    LibmeanS = [outCollect(noAncs).meanS];
    
    fprintf("--> %i ancestor sample*s in your local data excluded \n",sum(noAncs==0))
    
    f30 = figure(30); set(gcf, 'Position', [550 350 520 260], 'Renderer', 'painters');
    hold on; box on;
    set(gca, 'FontSize', 12);
    
    h_fD = histogram(LibmeanS, 'BinEdges', histBinEdges,...
        'Normalization', 'probability','FaceColor','none','EdgeColor',cmp(1,:),'LineWidth',1.5);
    m_fD = plot([mean_fD mean_fD], [0 1.15*max([h_fD.Values h_fDAnc.Values])], "--",...
        "LineWidth", 1.2, "Color", [cmp(2,:)]);
    
    ylabel("p"); %title("Distribution of fitness effects");
    
    ylim([0 round(1.15*max(h_fD.Values),2)]);
    xlim([-0.4 0.4])
    xlim([-max(abs(h_fD.BinLimits))-h_fD.BinWidth max(abs(h_fD.BinLimits))+h_fD.BinWidth]);

    mean_fD    = mean(LibmeanS);
    std_fD     = std(LibmeanS);
    legend([h_fD m_fD], ExpOutName,...
        "Mean = " + num2str(mean_fD, "%.3f") + "\newlineStd = " + num2str(std_fD, "%.3f"),...
        'Location','NorthWest')
end


%% print
if printFigs == "ON"
    print(f10,  '-painters', '-dpng', savePlotPath + datestr(now, "yyyymmdd") + ExpOutName + "_fitnessDist_separat");
    print(f11,  '-painters', '-dpng', savePlotPath + datestr(now, "yyyymmdd")  + ExpOutName + "_fitnessDist");
    figure(310);
    print(gcf,  '-painters', '-dpng', savePlotPath + datestr(now, "yyyymmdd")  + ExpOutName + "_correlationsStartFrac")    
    figure(411);
    print(gcf,  '-painters', '-dpng', savePlotPath + datestr(now, "yyyymmdd")  + ExpOutName + "_correlationsTime")
    figure(101);
    print(gcf,  '-painters', '-dpng', savePlotPath + datestr(now, "yyyymmdd")  + ExpOutName + "_s_w_stderror")
    
    if plotErrorPlots == "ON"
        print(f200,  '-painters', '-dpng', savePlotPath + datestr(now, "yyyymmdd")  + ExpOutName + "_BoxPlots" );
        print(f210,  '-painters', '-dpng', savePlotPath + datestr(now, "yyyymmdd")  + ExpOutName + "_MeansSError" );
        print(f220,  '-painters', '-dpng', savePlotPath + datestr(now, "yyyymmdd")  + ExpOutName + "_MeansSstdError" );
        print(f202,  '-painters', '-dpng', savePlotPath + datestr(now, "yyyymmdd")  + ExpOutName + "_BoxPlots+" );
    end 
    
    if compareAnc == "ON"
        print(f30,  '-painters', '-dpng', savePlotPath + datestr(now, "yyyymmdd") + "_fitnessDist_" + ExpOutName + ".png");
    end
end


