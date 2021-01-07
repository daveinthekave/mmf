function [fidelity]=calcFidelity(Mode_numeric,Mode_measured)
%% fidelity 
% Mode_numeric und Mode_measured sind komplexwertige unnormierte Felder



% Mode_numeric=ModeReconstructionComplex1;
% Mode_numeric=squeeze(modesDecompose(3,:,:)); 
% m=size(find(Mode_numeric>0));
Mode_numeric=sqrt(Mode_numeric./sum(sum(abs(Mode_numeric))));

% Mode_measured=squeeze(modesDecompose(3,:,:)); 
% Mode_measured=ModeReconstructionComplex1; 
% n=size(find(Mode_measured>0));
Mode_measured=sqrt(Mode_measured./sum(sum(abs(Mode_measured))));
fidelity=(abs(sum(sum(conj(Mode_numeric).*Mode_measured))))^2;