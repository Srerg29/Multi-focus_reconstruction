% clear all
 
%Leer imágenes
% a=(im2double(imread('mac1.png')));
% a=(im2double(imread('dinero_95mm.jpg')));
% a=(im2double(imread('nu_0.png')));
a=(im2double(imread('moneda 145mm.png')));
a=imresize(a,[512,640]);
% a=imresize(a,[500,500]);

% b=(im2double(imread('mac2.png')));
% b=(im2double(imread('dinero_170mm.jpg')));
b=(im2double(imread('moneda 185mm.png')));
% b=(im2double(imread('nu_6.png')));
b=imresize(b,[512,640]);
% b=imresize(b,[500,500]);


%Distancias de los objetos enfocados
% zk1=170e-3;
% zk2=280e-3;
%--------
zk1=145e-3;
zk2=180e-3;

%Parámetros de la cámara
R=13.5e-3/4;
d=16e-3;
p=5.65e-6;

%Radio del círculo
rk=R*d/p*abs(1/zk1-1/zk2); 
[fil,col,color]=size(a);

%se genera la PSF
[j,k] = ndgrid(1:fil,1:col);

% rk=;
h1=1/(pi*rk.^2)*((j-fil/2).^2+(k-col/2).^2<=rk.^2);
% h1=fspecial('gaussian',[fil,col],13);
h1=circshift(h1,[-fil/2,-col/2]);
H1=fft2(h1);

% rk=2*rk;
h2=1/(pi*rk.^2)*((j-fil/2).^2+(k-col/2).^2<=rk.^2);
% h2=fspecial('gaussian',[fil,col],13);
h2=circshift(h2,[-fil/2,-col/2]);
H2=fft2(h2);


%%
earth=(im2double(imread('cub.png')));
mars=(im2double(imread('tri.png')));
% earth=imresize(earth,[500,500]);
% mars=imresize(mars,[500,500]);
EA=fft2(earth);
MA=fft2(mars);
A(:,:,1)=(EA(:,:,1)+H1.*MA(:,:,1));
A(:,:,2)=(EA(:,:,2)+H1.*MA(:,:,2));
A(:,:,3)=(EA(:,:,3)+H1.*MA(:,:,3));
B(:,:,1)=(EA(:,:,1).*H1+MA(:,:,1));
B(:,:,2)=(EA(:,:,2).*H1+MA(:,:,2));
B(:,:,3)=(EA(:,:,3).*H1+MA(:,:,3));
a=real(ifft2(A));
b=real(ifft2(B));


%%
%TF de a y b
A=fft2(a);
B=fft2(b);

%%


by=0.4e-3*0;  %JULIA: el desplazamiento de 5e-3 es muy grande, probé con (+y-)0.5e-3 y funciona!!!       
bx=0.5e-3*0;

% Método 1
[Y,X]=meshgrid([1:fil],[1:col]);

ex1=exp(-1i*2*pi*d/zk1*(by/p*(Y-fil/2)/fil+bx/p*(X-col/2)/col))';
ex1=circshift(ex1,[-fil/2 -col/2]);

%JULIA: Para barrer las frecuencias
%negativas también y debemos dividir entre p para tener desplazamiento por unidad de pixel
%ex1=fftshift(ex1);%JULIA: No ejecutar esta línea.
ex2=exp(-1i*2*pi*d/zk2*(by/p*(Y-fil/2)/fil + bx/p*(X-col/2)/col))';
ex2=circshift(ex2,[-fil/2 -col/2]);

tic;
for color=1:3
for i=1:fil
    for j=1:col
        H=[1 H1(i,j);H2(i,j) 1];        %Matriz H 2x2        
        
%         Ht=(inv(H));                   %Pseudoinversa de H
        ex=[ex1(i,j);ex2(i,j)];         %Vector exponencial 2x1
        I=[A(i,j,color);B(i,j,color)];  %Vector I 2x1      
        
%         FF=(Ht*I);
        if(i==1&j==1)
            x=I/2;
        else
            [L,U]=lu(H); %Factorización LU
            z=L\I;
            x=U\z;       
        end
        
        FF=ex.*x;
%         FF=ex.*(H\I);
        F1(i,j,color)=FF(1);
        F2(i,j,color)=FF(2);                           
        
        F(i,j,color)=ex'*x; 
                                                
    end
end 
end


%Transformada inversa de Fourier
f=real(ifft2(F));
figure; imshow(f)

toc
% figure, plot(f(450,:,1))
% title(strcat('linea 450'))

%imwrite(f,strcat('dinero_bx_',num2str(bx),'_by_',num2str(by),'.png'))
%%JULIA: esta última línea la agregué para guardar automáticamente las distintas
%%perspectivas.

%% Mascara
f1=real(ifft2(F1));
f2=real(ifft2(F2));
figure, imshow(f1)
figure, imshow(f2)
% for i=1:fil
% for j=1:col
% if(f1(i,j,1)>f2(i,j,1))
% mask(i,j)=1;
% else
% mask(i,j)=0;
% end
% end
% end
% figure, imshow(mask)
% figure, imshow(mask.*b(:,:,1)+(1-mask).*a(:,:,1))