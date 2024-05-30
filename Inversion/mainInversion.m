%-------------------------------------------------------------------------%
%                              MAIN INVERSION                             %
%-------------------------------------------------------------------------%


% Main file for inverting 2.5D electrical resistivity data acquired with
% cross-borehole ERT in a context of aquifer remediation. - L. Lelimouzin
% January 2024


function [] = mainInversion(tabVar)


%% Observed ratio

R3 =  tabVar{5};                      
R4 =  tabVar{6}; 

disp('Compute ratio of observed data')
ratioObs = (R4(:,22) - R3(:,22)) ./ R3(:,22); 

tabVar{8} = ratioObs;


%% EPM

rho_a_EPM = fwdEPM(tabVar);                                                % Compute EPM forward model

tabVar{9} = rho_a_EPM;


%% DFN

[~] = cd('../Input');                                                      % Go in the Input folder
simuID = fopen('SimuType.txt','w');                                        % Change the name of the SimuType.txt file                                                      
fprintf(simuID,tabVar{1});                                                 % Switch to the DFN configuration
fclose(simuID);
cd ../Inversion

cd ../PostProcessing
[configx,configy,matrixIndex,Nx,Nz,delta_x,delta_z] = pre_mainDFN(tabVar); % Compute constant parameters for the DFN forward simulator
cd ../Inversion

% Store the parameters
tabVar{10} = configx;
tabVar{11} = configy;
tabVar{12} = matrixIndex;
tabVar{13} = Nx;
tabVar{14} = Nz;
tabVar{15} = delta_x;
tabVar{16} = delta_z;


%% Inversion

disp('Start inversion')

opt = optimoptions("patternsearch",'StepTolerance',1e-2,'MeshTolerance',1e-2); % Set patternsearch options

misfit_ref = 1;								   % Initialize a reference value for the misfit 

for i=1:40 								   % Iterate on a given number of potential fractures
      
    % Starting point
    x0 = rand*13.72;                                                       % x-centre
    y0 = rand*16.6;                                                        % y-depth
    l0 = rand*12.5;                                                        % length
    test0 = [x0 y0 l0];
    
    disp('Initial position: ');
    disp(test0);
    
    addFracture(test0,tabVar{1});                                          % Add a fracture in DFN.txt file
    
    
    t_pattern = tic;                                                       % Start timer
    
    [valInv,misfit] = patternsearch(@(test)procedure(test,tabVar),test0,[],[],[],[],[1.5 6 0],[12.5 16.6 12.5],opt);
    
    t_endpattern = toc(t_pattern);                                         % Stop timer

    if misfit > misfit_ref
        deleteFracture(tabVar{1});                                         % Delete the fracture that do not improve the misfit
        disp('Delete iteration : ')
        disp(i)
        
        filename = [tabVar{7},'/deletedFrac.txt'];                         
        fileID = fopen(filename,'a'); 
        fprintf(fileID, [num2str(i),'\n']); 				   % Save the index of the deleted fracture
        fclose(fileID);    
    else
        misfit_ref = misfit;                                               % Set a new reference
    end
    
    % Save patternsearch output (including deleted fractures)
    results = cat(2,i,valInv,misfit,t_endpattern); 
    disp('Resultat inversion horizontal : ')
    disp(results)

    filename = [tabVar{7},'/tabResults.txt'];                         	   % Save the properties of the fracture
    fileID = fopen(filename,'a'); 
    fprintf(fileID, [num2str(results),'\n']);
    fclose(fileID);
    
end

end

