%-------------------------------------------------------------------------%
%                    ADD FRACTURE TO THE TEXT FILE                        %
%-------------------------------------------------------------------------%


% File for inverting 2.5D electrical resistivity data acquired with
% cross-borehole ERT in a context of aquifer remediation. 
% Function for adding a new fracture to the DFN.txt file - L. Lelimouzin
% January 2024


%% Function


function [] = addFracture(test0,nameDFN)


%% Create a new file

[~] = cd(strcat('../Input/',nameDFN));

copyfile('DFN.txt', 'DFN_tempo.txt');                                      % Save the old settings in a temporary text file

old = fopen('DFN_tempo.txt','r+');                                   
new = fopen('DFN.txt', 'w');                                               % Over-write the old DFN.txt file                                      

% Fill up the file

line1 = fgetl(old);
fprintf(new, strcat(line1, '\n'));                                         % Copy the first line from DFN_tempo.txt to DFN.txt   

line2 = fgetl(old);
nb_fractures = str2num(line2);                                             % Keep the former number of fractures
new_nb_fractures = nb_fractures + 1;                                       % Add a new fracture
fprintf(new, strcat(num2str(new_nb_fractures),'\n'));                      % Copy the new number of fractures


%% Copy the existing fractures in the new file

if (new_nb_fractures > 1)
    for i=1:nb_fractures                                                      
        rest = fgetl(old);
        fprintf(new,strcat(rest,'\n'));
    end
end


%% Add the new fracture

% Prepare the parameters
x = test0(1);
y = test0(2);
length = test0(3);
x1 = x - length/2;                                                         % Edge on the left
x2 = x + length/2;                                                         % Edge on the right

% Check the fracture edge values
if x1 < 1.5                                                                % Left-hand limit of the domain size                                  
    length = length - (abs( 1.5 - abs(x1) ));                              % Adapt the length size to meet the domain conditions
    x1 = 1.5;                                                              % Fracture edge takes the value of the domain boundary
end
if x2 > 12.5                                                               % Right-hand limit of the domain size
    length = length - (x2 - 12.5);                                         % Adapt the length size to meet the domain condition
    x2 = 12.5;                                                             % Fracture edge takes the value of the domain boundary
end

% Add the new fracture
C(1) = x1;                                                                 % [m] left-hand edge of the fracture          
C(2) = y;                                                                  % [m] depth of the left-hand edge of the fracture
C(3) = x2;                                                                 % [m] right-hand edge of the fracture
C(4) = y;                                                                  % [m] depth of right-hand edge of the fracture
C(5) = 0.03;                                                               % [m] aperture of the fracture
C(6) = 2;                                                                  % [S/m] conductivity of the fracture
newline = num2str(C);                                                      
fprintf(new,strcat(newline,'\n'));

% Close the .txt file and clean up
fclose(old);
fclose(new);
delete('DFN_tempo.txt');

cd ../../Inversion                                                


end



