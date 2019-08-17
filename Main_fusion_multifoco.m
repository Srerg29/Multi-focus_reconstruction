clear all
close all

%% Dos im�genes 
% Esta secci�n realiza la fusi�n multi-foco de dos im�genes 
% con diferente distancia focal 

%Cargan las im�genes de entrada y las distancias de enfoque
load 'set_dinero.mat' 
figure; imshow(im1), title('Imagen 1')
figure; imshow(im2), title('Imagen 2')

disp('Fusi�n multifoco n = 2');
disp('Procesando...');
s = multi_focus_rec2(im1,im2,zk1,zk2,0,0);

disp('Presiona una tecla para continuar...');
pause; 
%% Tres im�genes
% Esta secci�n realiza la fusi�n multi-foco de dos im�genes

clear all

load 'set_llamas.mat'
figure; imshow(im1), title('Imagen 1')
figure; imshow(im2), title('Imagen 2')
figure; imshow(im3), title('Imagen 3')

disp('Fusi�n multifoco n = 3');
disp('Procesando...');
s = multi_focus_rec3(im1,im2,im3,zk1,zk2,zk3,0,0);

