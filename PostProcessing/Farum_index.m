%-------------------------------------------------------------------------%
%                               FARUM                                     %
%       INDEXING THE ELECTRODES ACCORDING TO THEIR CONFIGURATION          %
%-------------------------------------------------------------------------%


% File for inverting 2.5D electrical resistivity data acquired with 
% cross-borehole ERT in a context of aquifer remediation.
% This is a specific file of the studied site. - L. Lelimouzin
% January 2024


function matrixIndex = Farum_index(fileNameElecPos, fileNameElecConfig, Lz)

% Initialization 
    matrix_position = readmatrix(fileNameElecPos);
    matrix_config = readmatrix(fileNameElecConfig);
    
    matrix_config(:,1:4) = matrix_config(:,1:4) + 3;                       % x coordinates (xA, xB, xM, xN)
    matrix_config(:,5:8) = Lz - abs( -matrix_config(:,5:8) );              % y coordinates (yA yB yM yN)
    
    all_elecConfig = cell(1,4);
    nb_rows = size(matrix_config,1);                                       
    matrixIndex = NaN(nb_rows,4);

% Fill up
    for col=1:4
        all_elecConfig{col} = [matrix_config(:,col), matrix_config(:,col+4)]; % [x,y]
    end
    for col=1:4
        vect_conf = round(all_elecConfig{col}*10^5)/10^5;                    % Extraction
        [bool,indexCol] = ismember(vect_conf,matrix_position(:,2:3),'rows'); % Delete duplications
        matrixIndex(:,col) = indexCol;                                       % Associate an index to each couple of coordinates (to one electrode)
    end
    
end
