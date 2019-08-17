function [s] = multi_focus_rec3(im1,im2,im3,zk1,zk2,zk3,bx,by)
% Realiza la fusión multi-foco y el desplazamiento de perspectiva
% de tres imágenes en el dominio de Fourier
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
    rk12=R*d/p*abs(1/zk1-1/zk2); %Radio del círculo
    rk13=R*d/p*abs(1/zk1-1/zk3); %Radio del círculo
    rk23=R*d/p*abs(1/zk2-1/zk3); %Radio del círculo

    [fil,col,color]=size(im2);

    %se genera la PSF
    h12 = disk_psf(rk12,fil,col);
    H12=fft2(h12);
    
    h13 = disk_psf(rk13,fil,col);
    H13=fft2(h13);
    
    h23 = disk_psf(rk23,fil,col);
    H23=fft2(h23);
    
    %%
    %TF de 
    IM1=fft2(im1);
    IM2=fft2(im2);
    IM3=fft2(im3);
    %%
    %Desplazamientos bx y by
    %bx=10e-2; %<< Si bx=0 es recostrucción todo en foco simple 

    e=[1;1;1];

    ex1 = desplazamiento_fase(fil,col,d,zk1,bx,by,p);
    ex2 = desplazamiento_fase(fil,col,d,zk2,bx,by,p);
    ex3 = desplazamiento_fase(fil,col,d,zk3,bx,by,p);

    for color=1:3
    for i=1:fil
        for j=1:col
            H=[1 H12(i,j) H13(i,j);...
            H12(i,j) 1 H23(i,j);...
            H13(i,j) H23(i,j) 1];

            I=[IM1(i,j,color);IM2(i,j,color);IM3(i,j,color)];  %Vector I 2x1      
            ex=[ex1(i,j);ex2(i,j);ex3(i,j)];         %Vector exponencial 2x1

            if(i==1&j==1)
                x=I/3;
            else
                [L,U]=lu(H); %Factorización LU
                z=L\I;
                x=U\z;       
            end
            FF=ex.*x;
            F(i,j,color)=dot(e,FF); 

        end
    end        
    end

    %Transformada inversa de Fourier
    s=real(ifft2(F));
    figure; imshow(s), title('imagen reconstruida')
end