%-------------------------------------------------------------------------%
%                           MAIN EXECUTABLE                               %
%-------------------------------------------------------------------------%


% Main file to execute the inversion of 2.5D electrical resistivity data 
% acquired with cross-borehole ERT in a context of aquifer remediation.
% - L. Lelimouzin
% January 2024


clear all; clc;
t_start = tic;                                                             

disp('***     START OF PROGRAM     ***')


%% Parameters

tabVar = cell(1,16);                                                     

tabVar{1} = 'testDFN';                                                     % Name of the folder containing DFN input files
tabVar{2} = 'testEPM';                                                     % Name of the folder containing EPM input files                               
tabVar{4} = 128; 							   % Number of electrodes
tabVar{3} = '../FieldData/data_xxzz_R4.txt';                               % Path to the file containing the coordinates of the electrodes
tabVar{5} = load('FieldData/R3.txt');                                      % Load field data before injection (baseline)
tabVar{6} = load('FieldData/R4.txt');                                      % Load field data after injection                                               
tabVar{7} = '../Results/inv_Farum';                                        % Path and name of the folder storing the results

%parpool(30)                                                                % To be adapted to the number of workers of the computing resources

rng('default')                                                             % Initialize a generator seed  

%% Preparation

cd Inversion                                                               

nameFolder = strcat(tabVar{7});                                            % Create the folder containing the output files
mkdir(nameFolder);    


cd ../Input/testDFN 

delete('DFN.txt');                                                         % To be sure to start from an empty file
ID = fopen('DFN.txt', 'w');                                                % Create a new DFN.txt file
fprintf(ID, strcat('DETERMINISTIC1', '\n'));                               % Parameter detailed in Caballero-Sanz et al. (2017)
fprintf(ID, strcat('0', '\n'));                                            % Set the number of fractures to 0
fclose(ID);

cd ../../Inversion


%% Main

mainInversion(tabVar);                                                     % Run the inversion procedure

delete(gcp('nocreate'))                                                    % Deconnect the parpool

t_end = toc(t_start);                                                     

disp('BULK COMPUTING TIME: ')
disp(t_end)

fileID = fopen([tabVar{7},'/computingTime.txt'],'w'); 
fprintf(fileID, num2str(t_end));
fclose(fileID);

cd ../Input/
copyfile('testDFN/DFN.txt',[tabVar{7} '/DFN_final.txt'])

disp('***     END OF PROGRAM     ***')

