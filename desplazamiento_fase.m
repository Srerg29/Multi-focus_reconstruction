function [ex] = desplazamiento_fase(fil,col,d,zk,bx,by,p)
% Realiza un desplazamiento de fase en el dominio de Fourier
% Parámetros: 
%       fil: filas de la imagen de entrada
%       col: columnas de la imagen de entrada
%       d: distancia del sensor a la lente en la cámara
%       zk: distancia de la cámara al objeto enfocado
%       bx, by: disparidad en el eje 'x' y 'y', valor entre [-1,1]
%       p: pixel pitch

    [Y,X]=meshgrid([1:fil],[1:col]);
    ex=exp(-1i*2*pi*d/zk*(by/p*(Y-fil/2)/fil+bx/p*(X-col/2)/col))';
    ex=circshift(ex,[-fil/2 -col/2]);
end