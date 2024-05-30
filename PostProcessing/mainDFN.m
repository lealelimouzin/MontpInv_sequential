%-------------------------------------------------------------------------%
%                       DFN FORWARD SIMULATION                            %
%-------------------------------------------------------------------------%


% This function is part of ERT_DDP_2.5D software (Cabllero-Sanz et al., 2017).
% It is the main file for inverting 2.5D data provided in the Fourier domain 
% from the C++ code to the real domain - D. Roubinet 

% The function was first created for surface electrode settings, the
% present version is an adaptation of D. Roubinet's script to a 
% cross-borehole setting. - L. Lelimouzin
% January 2024


%% Function

function [rho_a_DFN] = mainDFN(configx, configy, matrixIndex,Nx,Nz,delta_x,delta_z,nb_electrodes,expt_name)

%% Preparation

path_results_DFN = strcat('../Output/',expt_name,'/');
file_name_DFN = 'Matrix_Potential';
Lx = delta_x * Nx;
Lz = delta_z * Nz;


%% Define the difference of potential V_MN fexpt_name,data_coord,data_nb_elect,data_elec_spacingor each experiment

nb_exp = size(configx,1);
rho_a_DFN=zeros(nb_exp,1);

% Load all the results
AllResultsDFN = zeros(4*Nz,Nx,nb_electrodes);

parfor (i=1:nb_electrodes,30)                                             
    AllResultsDFN(:,:,i) = load(strcat(path_results_DFN,strcat(file_name_DFN,strcat(num2str(i),'.txt'))));
end


parfor (i=1:nb_exp,30)                                                    
   
   index_elec_A = matrixIndex(i,1); 
   index_elec_B = matrixIndex(i,2);

   position_elec_xA = configx(i,1); position_elec_yA=configy(i,1);
   position_elec_xB = configx(i,2); position_elec_yB=configy(i,2);
   position_elec_xM = configx(i,3); position_elec_yM=configy(i,3);
   position_elec_xN = configx(i,4); position_elec_yN=configy(i,4);

   
   % Potential distributions in Fourier domain for an injection at electrodes A and B
   Fourier_potential_A_DFN = AllResultsDFN(:,:,index_elec_A);
   Fourier_potential_B_DFN = AllResultsDFN(:,:,index_elec_B);
   
   % Difference of potential VMN for injection in A and extraction in B
   Fourier_pot_AB_DFN = Fourier_potential_A_DFN-Fourier_potential_B_DFN;
   
   % Inversion of the potential distribution in the real domain
   [x,z,Potential_matrix_AB_DFN] = InverseFourierPotential(Fourier_pot_AB_DFN,Nx,Nz,Lx,Lz,position_elec_xA,position_elec_xB,position_elec_yA,position_elec_yB);
   [x,z,Potential_matrix_BA_DFN] = InverseFourierPotential(Fourier_pot_AB_DFN,Nx,Nz,Lx,Lz,position_elec_xB,position_elec_xA,position_elec_yB,position_elec_yA);
   Potential_matrix_AB_DFN = (Potential_matrix_AB_DFN+Potential_matrix_BA_DFN)/2;
  
   V_MN_DFN = Potential_matrix_AB_DFN(ceil(position_elec_yM/delta_z),ceil(position_elec_xM/delta_x))-Potential_matrix_AB_DFN(ceil(position_elec_yN/delta_z),ceil(position_elec_xN/delta_x));
   V_MN_DFN_inv = Potential_matrix_BA_DFN(ceil(position_elec_yM/delta_z),ceil(position_elec_xM/delta_x))-Potential_matrix_BA_DFN(ceil(position_elec_yN/delta_z),ceil(position_elec_xN/delta_x));
   V_MN_DFN = (V_MN_DFN+V_MN_DFN_inv)/2;
   
   % Geometric factor
   AM = sqrt((position_elec_xM-position_elec_xA)^2+(position_elec_yM-position_elec_yA)^2);
   AMinv=1/AM;
   AN = sqrt((position_elec_xN-position_elec_xA)^2+(position_elec_yN-position_elec_yA)^2);
   ANinv=1/AN;
   BM = sqrt((position_elec_xM-position_elec_xB)^2+(position_elec_yM-position_elec_yB)^2);
   BMinv=1/BM;
   BN = sqrt((position_elec_xN-position_elec_xB)^2+(position_elec_yN-position_elec_yB)^2);
   BNinv=1/BN;

   k_fact = 4*pi/(AMinv-ANinv-BMinv+BNinv);
   
   % Apparent resistivity
   rho_a_DFN(i) = V_MN_DFN*k_fact;
 
    
end

end

