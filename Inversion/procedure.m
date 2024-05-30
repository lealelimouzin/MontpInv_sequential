%-------------------------------------------------------------------------%
%                          INVERSION PROCEDURE                            %
%-------------------------------------------------------------------------%


% File for inverting 2.5D electrical resistivity data acquired with
% cross-borehole ERT in a context of aquifer remediation. 
% Function to be minimized by patternsearch - L. Lelimouzin
% January 2024



function [misfit] = procedure(test,tabVar)


disp('Search for a new fracture')


%% Fracture to be tested

changeFracture(test,tabVar{1}); 					    % Change the parameters of the fracture at each iteration of patternsearch


%% Compute the misfit

% Names of the parameters for the forward simulation
expt_name = tabVar{1};
nb_electrodes = tabVar{4};
R3 = tabVar{5};
R4 = tabVar{6};
ratioObs = tabVar{8};
rho_a_EPM = tabVar{9};
configx = tabVar{10};
configy = tabVar{11};
matrixIndex = tabVar{12};
Nx = tabVar{13};
Nz = tabVar{14};
delta_x = tabVar{15};
delta_z = tabVar{16};


% Run the formard model
cd '../ElectricalResistivity/Release';
[status,cmdout]= unix('./ElectricalResistivity');                          % Execute the C++ code                      
cd '../../Inversion'


% Post procesing of the outputs from the C++ code
cd ../PostProcessing
rho_a_DFN = mainDFN(configx, configy, matrixIndex,Nx,Nz,delta_x,delta_z,nb_electrodes,expt_name); 
cd ../Inversion


% Compute the anomaly before filtering
ratioSimu = (rho_a_DFN - rho_a_EPM) ./ rho_a_EPM;                          
anomaly_bf = ratioSimu - ratioObs;                                          


% 1st filter: removes rho<0
anomaly = anomaly_bf;
for k=1:size(rho_a_DFN,1)
    if (rho_a_DFN(k)<0 || rho_a_EPM(k)<0)                                  
        anomaly(k) = NaN;
    end
end
anomaly = anomaly(not(isnan(anomaly)));                                    


% 2nd filter: select anomaly values only if R4<R3
index =(R4(:,22)<R3(:,22));                                                
index = index(not(isnan(anomaly)));                                         

% Final misfit
misfit = sum( anomaly(index).^2 ) / numel( anomaly(index) );



end
