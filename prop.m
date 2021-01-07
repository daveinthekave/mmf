function [Id,Id1] = prop(H,dx,dy,lambda,dist)

[Ny,Nx]=size(H);

fft_H=fftshift(fft2(H)); clear H UR;

[x,y]=meshgrid(1-Nx/2:Nx/2,1-Ny/2:Ny/2);
r=(2*pi*x./(dx*Nx)).^2+(2*pi*y./(dy*Ny)).^2;

k=2*pi/lambda ;
kernel=exp(-1i*sqrt(k^2-r)*dist);   % ang spec kernel

fft_HH=fft_H(:,:).*kernel;
fft_HH=fftshift(fft_HH);

Ud=ifft2(fft_HH);

Id=Ud;
Id1=angle(Ud);