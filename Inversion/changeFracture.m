%-------------------------------------------------------------------------%
%                   CHANGE TESTED PARAMETERS (POSITION)                   %
%-------------------------------------------------------------------------%


% File for inverting 2.5D electrical resistivity data acquired with
% cross-borehole ERT in a context of aquifer remediation. 
% Function for changing the parameters of the fracture at each iteration of
% patternsearch. - L. Lelimouzin
% January 2024



%% Function


function [] = changeFracture(test,nameDFN)                                   


% Prepare the values
x = test(1);
y = test(2);
length = test(3);
x1 = x - length/2;                                                         
x2 = x + length/2;                                                         


% Check the fracture edge values
if x1 < 1.5                                                                          
    length = length - abs( 1.5 - abs(x1));                                 
    x1 = 1.5;                                                              
end
if x2 > 12.5                                                               
    length = length - (x2 - 12.5);                                         
    x2 = 12.5;                                                             
end


% Fill up the .txt file
[~] = cd(strcat('../Input/',nameDFN));
copyfile('DFN.txt', 'DFN_tempo.txt');                                 
old = fopen('DFN_tempo.txt','r+');                                    
new = fopen('DFN.txt', 'w');                                               

line1 = fgetl(old);
fprintf(new, strcat(line1, '\n'));                                         

line2 = fgetl(old);
fprintf(new, strcat(line2,'\n'));                                          
nb_fractures = str2num(line2);


% Copy fractures that already exist
if (nb_fractures>1)
    for i=1:(nb_fractures-1)                                                    
        rest = fgetl(old); 
        fprintf(new,strcat(rest,'\n'));
    end
end


% Modify the last fracture
line = fgetl(old);                                                         
C = textscan(line, '%f', 'Delimiter', '\t');                               
C = (transpose(C{:}));                                                      
                                                                            
C(1) = x1;              
C(2) = y;
C(3) = x2;
C(4) = y;
    
newline=num2str(C);                                                        
fprintf(new,strcat(newline,'\n'));


% Close the .txt file and clean up
fclose(old);
fclose(new);
delete('DFN_tempo.txt');

cd ../../Inversion                                                         


end
