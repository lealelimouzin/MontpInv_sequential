%-------------------------------------------------------------------------%
%                     PREPARATION TO DFN FORWARD SIMULATION               %
%-------------------------------------------------------------------------%


% This function is part of ERT_DDP_2.5D software (Cabllero-Sanz et al., 2017).
% It is a preparatory file for inverting 2.5D data provided in the Fourier
% domain from the C++ code to the real domain - D. Roubinet 

% The function was first created for surface electrode settings, the
% present version is an adaptation of D. Roubinet's script to a 
% cross-borehole setting. - L. Lelimouzin
% January 2024



function [configx, configy, matrixIndex,Nx,Nz,delta_x,delta_z] = pre_mainDFN(tabVar)

%% Properties

% Electrode configurations
expt_name = tabVar{1};
data_xx_zz = tabVar{3};

% Domain properties
path_MatrixProperties = strcat('../Input/',expt_name,'/');
file_name_MatrixProperties = 'DomainProperties.txt';
matrix_properties = load(strcat(path_MatrixProperties,file_name_MatrixProperties)); 
Lx = matrix_properties(1);
Lz = matrix_properties(2);

% Simu
file_name_simu = 'Simu.txt';
Simu = importdata(strcat(path_MatrixProperties,file_name_simu),' ',2);
Nx = Simu.data(1);
Nz = Simu.data(2);
delta_x = Lx/Nx;
delta_z = Lz/Nz;


%% Define the position of the electrodes

addpath(strcat('../Input/',expt_name))
file_name_positionsElectrodes = 'ElectrodesPositions.txt';


%% Define the electrode configurations

[configx,configy] = Farum_elecConfig(data_xx_zz);
matrixIndex = Farum_index(strcat(path_MatrixProperties,file_name_positionsElectrodes),data_xx_zz,Lz);


end

