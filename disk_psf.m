function [h] = disk_psf(rk,fil,col)
% Crea una función disco distribuida en los bordes de la imagen
% Parámetros: 
%       rk: radio del disco
%       fil: filas de la imagen de entrada
%       col: columnas de la imagen de entrada

    [j,k] = ndgrid(1:fil,1:col);
    h=1/(pi*rk.^2)*((j-fil/2).^2+(k-col/2).^2<=rk.^2);
    h=circshift(h,[-fil/2,-col/2]);
end