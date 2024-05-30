%-------------------------------------------------------------------------%
%                           INVERSE POTENTIAL                             %
%-------------------------------------------------------------------------%


% This function is part of ERT_DDP_2.5D software (Caballero-Sanz et al., 2017).
% It calculates the inverse potential from a matrix using N wavenumbers to 
% do it. - Victor Caballero
% Creado: agosto de 2014, ultima modificacion enero 2015


function Potential = Inverse_Pot(F_Pot,Nz,Nx,N,c1x,g)


if N > 20; % more than the optimized number
    %% Typical inverse potential using at least 1000 wavenumbers
    T = 100;
    F = ndims(F_Pot);
    if F ~= 2
        %Transformation vector between both transforms
        %(see base_discretization_idct)
        trans = ones(Nz,Nx,N);
        
        trans(:,:,1) = trans(:,:,1)*sqrt(N);
        trans(:,:,2:N) = trans(:,:,2:N)*sqrt(N/2);
        F_Pot = F_Pot.*trans;
        
        %Multiplying the transformation vector by the transform potential, we can
        %avoid the addition of the idct constant in the next step
        %We have to do the transform in each vector of the third dimension, that
        %is, taking the vectors in depth
        tic;
        Potential = zeros(Nz,Nx,N);
        for i = 1:Nz
            for j = 1:Nx
                c = idct(F_Pot(i,j,:));
                for h = 1:N
                    Potential(i,j,h) = Potential(i,j,h) + c(1,h);
                end
            end
        end
        toc;
        %In order to normalize the idct with the analytical solution, we have to
        %multiply by 2/T.
        Potential = Potential*2/T;
    else
        trans = ones(N,Nx);
        trans(1,:) = trans(1,:)*sqrt(N);
        trans(2:N,:) = trans(2:N,:)*sqrt(N/2);
        F_Pot = F_Pot.*trans;
        tic;
        Potential = zeros(N,Nx);
        for i = 1:Nx
            c = idct(F_Pot(:,i));
            Potential(:,i) = Potential(:,i) + c;
        end
        toc;
        Potential = Potential.*2/T;
    end


else         
    %% Optimized inverse potential%%
    % We are going to develop the inversion using either the Xu,Duan and Zhang or 
    % Pidlisecky optimized wavenumbers and Fourier weights. This inverse potential 
    % is suitable just when we have an injection point, if not, we need to use the
    % standard one
    
    % Potential is a 4-D Matrix for inverting matrix potential with lots of
    % experiments, and it is a 3-D Matrix for inverting matrix potential with just one
    % experiment
    
    F = ndims(F_Pot);
    if F == 2
        Potential = zeros(1,size(F_Pot,2));
        for k = 1:N
            Potential(1,:) = Potential(1,:) + F_Pot(k,:);
        end
    else
        p = 1:length(c1x);
        Potential = zeros(Nz,Nx,1,length(c1x));
        for k = 1:N
            Potential(:,:,1,p) = Potential(:,:,1,p) + F_Pot(:,:,k,p).*g(k);
        end
    end
        
    % This inversion just takes into account the first plane of the 2.5D
    % solution in the spatial domain, not the whole 3D domain (cube).
end
end