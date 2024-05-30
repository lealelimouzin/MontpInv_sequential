%-------------------------------------------------------------------------%
%                      INVERSE FOURIER POTENTIAL                          %
%-------------------------------------------------------------------------%


% This function is part of ERT_DDP_2.5D software (Caballero-Sanz et al., 2017).
% It calculates the inverse potential from a matrix using N wavenumbers to 
% do it. - Victor Caballero
% Creado: agosto de 2014, ultima modificacion enero 2015


%c_1 : Position for a lot of experiments
%c_2 : Position of the second source for each experiment

function [x,z,Pot_Matrix]=InverseFourierPotential(SM,Nx,Nz,Lx,Lz,c1x,c2x,c1z,c2z)


dx = Lx/Nx;
dz = Lz/Nz;

% Matrix block axis
x = linspace(0,Lx-dx,Nx) + dx/2;
z = linspace(0,Lz-dz,Nz) + dz/2;

% Xu et al. (2000) coefficients
wk = [0.0217102 0.2161121 1.0608400 5.0765870];
g = [0.0463660 0.2365931 1.0382080 5.3648010];

N = length(wk);
% Bubble method to order wk and g vectors, because in the C++ Code we have
% them in increasing order
for i = 1:N
    for j = i+1:N
        if wk(j) < wk(i)
            temp_wk = wk(i);
            wk(i) = wk(j);
            wk(j) = temp_wk;
            
            temp_g = g(i);
            g(i) = g(j);
            g(j) = temp_g;
        end
    end
end

% Optimization method in order to take into account the position of the
% first and second sources as the same as the x vector, avoiding then changes in
% resistivity values
for r = 1:length(c1x)
    [a,index_c1x] = min(abs(c1x(r)-x));
    [b,index_c2x] = min(abs(c2x(r)-x));
    
    [a,index_c1z] = min(abs(c1z(r)-z));
    [b,index_c2z] = min(abs(c2z(r)-z));
    
    c1x(r) = x(index_c1x);
    c2x(r) = x(index_c2x);
    c1z(r) = z(index_c1z);
    c2z(r) = z(index_c2z);
    
end

s=[0];
i_Matrix = 1:Nz;
j = 1:Nx;
q = 1:length(s);

F_Pot_Matrix = zeros(Nz,Nx,N,length(s));

for p = 1:length(s)
    count = 0; % in order to change the sign of the simulation for the second source
    %% ----- Fourier Potential ----- %%
    F_Pot_Matrix1 = zeros(Nz,Nx,N);

    for k = 0:N-1
        % F_Pot_Matrix: first row is the left border of the domain
        F_Pot_Matrix1(i_Matrix,j,k+1) = F_Pot_Matrix1(i_Matrix,j,k+1) +...
            SM(i_Matrix+k*Nz,j);
        
    end
    % Replacing NaNs and negative and small values for 0s
    F_Pot_Matrix1(isnan(F_Pot_Matrix1)) = 0;

    if count == 0 %% that means this is the left source
        F_Pot_Matrix(:,:,:,p) = F_Pot_Matrix(:,:,:,p) + F_Pot_Matrix1;
    elseif count == 1 %% that means this is the right source
        F_Pot_Matrix(:,:,:,p) = F_Pot_Matrix(:,:,:,p) - F_Pot_Matrix1;
    end
    count = count + 1;
end


%% ----- Inverse Potential ----- %%
Pot_Matrix = Inverse_Pot(F_Pot_Matrix,Nz,Nx,N,c1x,g); %% Maximun at the top

end













