%-------------------------------------------------------------------------%
%                       EPM FORWARD SIMULATION                            %
%-------------------------------------------------------------------------%


% File for inverting 2.5D electrical resistivity data acquired with
% cross-borehole ERT in a context of aquifer remediation. 
% Function for computing the EPM forward simulation - L. Lelimouzin
% January 2024


function [rho_a_EPM] = fwdEPM(tabVar)

disp('EPM forward model')

nameEPM = tabVar{2};

[~] = cd('../Input');                                                      
simuID = fopen('SimuType.txt','w');                                        % Change the name in SimuType.txt for an EPM configuration                                      
fprintf(simuID,nameEPM);                                                   
fclose(simuID);
cd ../Inversion                                                            

cd '../ElectricalResistivity/Release';
[status,cmdout]= unix('./ElectricalResistivity');                          % Execute the C++ code                   
cd '../../Inversion';

cd ../PostProcessing
rho_a_EPM = mainEPM(tabVar);                                               % [Ohm m] simulated apparent electrical resistivity vector
cd ../Inversion

end
