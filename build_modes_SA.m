function [modes1,map,map1] = build_modes_SA(nCore,nCladding,wavelength,coreRadius,r, plot_distance)

[modes,map, map1] = LP_modes(nCore,nCladding,wavelength,coreRadius,r,plot_distance);
mat=[];
modes1=zeros(size(modes,1),size(modes,2),size(modes,3));
for i=1:size(modes,1)
    mat=squeeze(modes(i,:,:));
    mat(abs(mat)<=0)=mat(abs(mat)<=0).*exp(1i*3*pi/2);
    mat(abs(mat)>0)=mat(abs(mat)>0).*exp(1i*pi/2);
    mat=mat./sum(sum(abs(mat)));
    modes1(i,:,:)=mat;
end
