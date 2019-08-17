function [s] = multi_focus_rec2(im1,im2,zk1,zk2,bx,by) 
% Realiza la fusión multi-foco y el desplazamiento de perspectiva
% de dos imágenes en el dominio de Fourier
%
% Parámetros: 
%       im1, im2: imágenes de entrada
%       zk1, zk2: distancias de la cámara a los objetos enfocados
%       bx, by: disparidad en el eje 'x' y 'y', valor entre [-1,1]


    %Parámetros de la cámara
    R=13.5e-3/4;
    d=16e-3;
    p=5.65e-6;

    %Radio del círculo
    rk=R*d/p*abs(1/zk1-1/zk2); 
    [fil,col,color]=size(im1);

    %se genera la PSF
    
    h1 = disk_psf(rk,fil,col);
    H1 = fft2(h1);

    h2 = disk_psf(rk,fil,col); %Se puede intentar con un valor diferente a rk
    H2 = fft2(h2);

    IM1 = fft2(im1);
    IM2 = fft2(im2);
    
    %%

    ex1 = desplazamiento_fase(fil,col,d,zk1,bx,by,p);
    ex2 = desplazamiento_fase(fil,col,d,zk2,bx,by,p);
    
    for color=1:3
    for i=1:fil
        for j=1:col
            H=[1 H1(i,j);H2(i,j) 1];        %Matriz H 2x2        
            ex=[ex1(i,j);ex2(i,j)];         %Vector exponencial 2x1
            I=[IM1(i,j,color);IM2(i,j,color)];  %Vector I 2x1      
            if(i==1&&j==1)
                x=I/2;
            else
                [L,U]=lu(H); %Factorización LU
                z=L\I;
                x=U\z;       
            end
                        
            F(i,j,color)=ex'*x; 
        end
    end 
    end

    %Transformada inversa de Fourier
    s=real(ifft2(F));
    figure; imshow(s), title('Imagen reconstruida')
    
end