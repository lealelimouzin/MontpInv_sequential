%-------------------------------------------------------------------------%
%                    DELETE THE LAST FRACTURE TESTED                      %
%-------------------------------------------------------------------------%


% File for inverting 2.5D electrical resistivity data acquired with
% cross-borehole ERT in a context of aquifer remediation. 
% Function for deleting a fracture in DFN.txt if it does not improve the
% misfit - L. Lelimouzin
% January 2024


function [] = deleteFracture(nameDFN)                                   

[~] = cd(strcat('../Input/',nameDFN));

copyfile('DFN.txt', 'DFN_tempo.txt');                                 
old = fopen('DFN_tempo.txt','r+');                                    
new = fopen('DFN.txt', 'w');                            

line1 = fgetl(old);
fprintf(new, strcat(line1, '\n'));                                        

line2 = fgetl(old);
nb_fractures = str2num(line2);
new_nb_fractures = nb_fractures - 1;
fprintf(new, strcat(num2str(new_nb_fractures),'\n'));


% Copy the fractures that already exist except the last one
if (nb_fractures > 1)
    for i=1:new_nb_fractures                                                     
        rest = fgetl(old); 
        fprintf(new,strcat(rest,'\n'));
    end
end


% Close the .txt file and clean up
fclose(old);
fclose(new);

delete('DFN_tempo.txt');

cd ../../Inversion                                                        


end
