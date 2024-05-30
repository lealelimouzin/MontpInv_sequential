%-------------------------------------------------------------------------%
%                               FARUM                                     %
%                DEFINE THE CONFIGURATIONS OF THE ELECTRODES              %
%-------------------------------------------------------------------------%


% File for inverting 2.5D electrical resistivity data acquired with 
% cross-borehole ERT in a context of aquifer remediation.
% This is a specific file of the studied site. - L. Lelimouzin
% January 2024


function [elec_configx,elec_configy] = Farum_elecConfig(datafile)


% Initialization
    elecPos = readmatrix(datafile);
    nrows = size(elecPos,1);
    elec_configx = zeros(nrows,4);
    elec_configy = zeros(nrows,4);

% Fill the matrix up
    for j=1:nrows
        elec_configx(j,1:4) = elecPos(j,1:4) + 3;                          % matrix of x coordinates: xA, xB, xM, xN (offset by 3m)
        elec_configy(j,1:4) = -elecPos(j,5:8);                             % matrix of y coordinnates: yA, yB, yM, yN (take positive values)
    end
   
    
end
