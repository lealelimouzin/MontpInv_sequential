%-------------------------------------------------------------------------%
%                       EPM FORWARD SIMULATION                            %
%-------------------------------------------------------------------------%

% This function is part of ERT_DDP_2.5D software (Cabllero-Sanz et al., 2017).
% It is the main file for inverting 2.5D data provided in the Fourier domain 
% from the C++ code to the real domain - D. Roubinet 

% The function was first created for surface electrode settings, the
% present version is an adaptation of D. Roubinet's script to a 
% cross-borehole setting. - L. Lelimouzin
% January 2024


%% Function

function [rho_a_EPM] = mainEPM(tabVar)


%% 0. Parameters

% Electrode configurations
expt_name = tabVar{2};
nb_electrodes = tabVar{4};
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

% Results in the Fourier domain (from C++ code)
path_results_EPM = strcat('../Output/',expt_name,'/');
file_name_EPM = 'Results';


%% 1. Define the position of the electrodes

addpath(strcat('../Input/',expt_name))
file_name_positionsElectrodes = 'ElectrodesPositions.txt';


%% 2. Define the electrode configurations

[elec_configx,elec_configy] = Farum_elecConfig(data_xx_zz);
matrixIndex = Farum_index(strcat(path_MatrixProperties,file_name_positionsElectrodes),data_xx_zz,Lz);


%% 3. Define the difference of potential V_MN for each experiment

nb_exp = size(elec_configx,1);
rho_a_EPM = zeros(nb_exp,1);

% load all the results
AllResultsEPM = zeros(4*Nz,Nx,nb_electrodes);

parfor (i=1:nb_electrodes,30)                                             
    AllResultsEPM(:,:,i) = load(strcat(path_results_EPM,strcat(file_name_EPM,strcat(num2str(i),'.txt'))));
end

parfor (i=1:nb_exp,30)                                                  


    index_elec_A=matrixIndex(i,1); 
    index_elec_B=matrixIndex(i,2);

    position_elec_xA=elec_configx(i,1); position_elec_yA=elec_configy(i,1);
    position_elec_xB=elec_configx(i,2); position_elec_yB=elec_configy(i,2);
    position_elec_xM=elec_configx(i,3); position_elec_yM=elec_configy(i,3);
    position_elec_xN=elec_configx(i,4); position_elec_yN=elec_configy(i,4);

   
   % Potential distributions in Fourier domain for an injection at electrodes A and B
   Fourier_potential_A_EPM=AllResultsEPM(:,:,index_elec_A);
   Fourier_potential_B_EPM=AllResultsEPM(:,:,index_elec_B);
   
   % Difference of potential VMN for injection in A and extraction in B
   Fourier_pot_AB_EPM=Fourier_potential_A_EPM-Fourier_potential_B_EPM;
 
   % Inversion of the potential distribution in the real domain
   [x,z,Potential_matrix_AB_EPM] = InverseFourierPotential(Fourier_pot_AB_EPM,Nx,Nz,Lx,Lz,position_elec_xA,position_elec_xB,position_elec_yA,position_elec_yB);
   V_MN_EPM = Potential_matrix_AB_EPM(ceil(position_elec_yM/delta_z),ceil(position_elec_xM/delta_x))-Potential_matrix_AB_EPM(ceil(position_elec_yN/delta_z),ceil(position_elec_xN/delta_x));
  
   % Geometric factor
   AM = sqrt((position_elec_xM-position_elec_xA)^2+(position_elec_yM-position_elec_yA)^2);
   AMinv = 1/AM;
   AN = sqrt((position_elec_xN-position_elec_xA)^2+(position_elec_yN-position_elec_yA)^2);
   ANinv = 1/AN;
   BM = sqrt((position_elec_xM-position_elec_xB)^2+(position_elec_yM-position_elec_yB)^2);
   BMinv = 1/BM;
   BN = sqrt((position_elec_xN-position_elec_xB)^2+(position_elec_yN-position_elec_yB)^2);
   BNinv = 1/BN;

   k_fact = 4*pi/(AMinv-ANinv-BMinv+BNinv);
   
   % Apparent resistivity
   rho_a_EPM(i) = V_MN_EPM * k_fact;
   
end

end
