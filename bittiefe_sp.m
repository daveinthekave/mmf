clear all;
for bt=1:1:16
%% main

% Parameter Multimodefibre
NA=0.1;
nCore = 1.4607;                 % at 20 deg C -> Pure Silica/ fused Silica
nCladding = sqrt(nCore^2-NA^2); % 1.4440375;      % at 20 deg C -> Fluorine-Doped Silica  
wavelength = 0.532;             % in um
coreRadius = 25/2;              % in um

% Modesolver parameters -> build modes
gridSize = 80;             % gridsize for modesolver; Wert am:06.04: 50
modes=build_modes(nCore,nCladding,wavelength,coreRadius,gridSize);
mode_target=55;             % which mode should be generated by SLM?

% SLM & Superpixel parameters  
bitDepthSLM = bt;            % Bit
superPixel=6;               % Size of one superpixel
m_SLM=800;      % Y-axis
n_SLM=800;      % X-axis    -> number SLM pixel
                %           -> Phasemask will be put into center of SLM

%% Preparation of Phasemask on SLM
ref_background=zeros(m_SLM/2,n_SLM/2);  % background image will be transferred
                                        % into 2x2 superpixel mask
                                    
ref_background_Superpixel=superpixel_variabel(ref_background,2,bitDepthSLM,1);

mode_target_distribution=squeeze(modes(mode_target,:,:)); % select mode generated by SLM

maximum=max(max(squeeze(abs(mode_target_distribution))));   % maximum amplitude value
                                                            % for normalization @ Superpixel

% mode_target_distribution_superpixel = superpixel(mode_target_distribution,superPixel,bitDepthSLM,maximum);
mode_target_distribution_superpixel = superpixel_variabel(mode_target_distribution,superPixel,bitDepthSLM,maximum);


[m_superpixel,n_superpixel]=size(mode_target_distribution_superpixel);    %Größe der Superpixelverteilung auf dem SLM 

% now, insert mode_target_distribution_superpixel in superpixel background
ref_background_Superpixel(m_SLM/2-(superPixel/2)*gridSize:m_SLM/2+(superPixel/2)*gridSize-1,...
    n_SLM/2-(superPixel/2)*gridSize:n_SLM/2+(superPixel/2)*gridSize-1)=mode_target_distribution_superpixel;

superpixel_mask=ref_background_Superpixel;  % die finale Superpixelmaske 
                                            % entspricht dem
                                            % Referenzhintergund, in den
                                            % die Superpixelmodenverteilung
                                            % eingesetzt wurde

% area in which the generated field quality will be analyzed 
[X,Y]=meshgrid(1:n_SLM,1:m_SLM);
area_analysis=false(n_SLM,m_SLM);
area_analysis((X-m_SLM/2).^2+(Y-n_SLM/2).^2<=(m_superpixel/2-1)^2)=true;

%Im nächsten Schritt wird der Superpixel-Phasenamske ein Beugungsgitter
%aufgeprägt, sodass das modulierte Lichtfeld in der Fourierebene hinter der
%Linse in der 1. (bzw. -1.) Beugungsordnung liegt und räumlich vom störenden
%DC-Anteil separierbar ist. In der Fourierebeene platziert man deshalb eine
%kleine Blende. Im Folgenden wird daher der Blendenradius und das Zentrum
%der Blende variiert

superpixel_mask=add_grating_2pi(superpixel_mask);  
% -> preparation finished

%% Start modulation
load('optical_beam');   %simuliere einen Gaußschen Laserstrahl

modulated_beam=optical_beam.*exp(1i*superpixel_mask);   %der Laserstrahl trifft auf die SLM Oberfläche

% modulierter Laserstrahl propagiert durch Linse -> FFT
modulated_beam_fft=fftshift(fft2(modulated_beam));
% figure;imagesc(abs(modulated_beam_fft));

%% for optimized modulation, vary pinhole position and size
% for analyzis, generate target mode in sze of image on camera
% modes_analyzis=build_modes(nCore,nCladding,wavelength,coreRadius,m_superpixel);

%load('modes_analyzis');

modes_analyzis = build_modes(nCore,nCladding,wavelength,coreRadius,gridSize*superPixel);

mode_target_distribution_analyzis=squeeze(modes_analyzis(mode_target,:,:));

xo_pinhole=600;yo_pinhole=400;r_pinhole=19;

step_var=1; %Stufenbreite bei der Variation des Zentrums
edge_var=4; %Grenze bei der Variation des Zentrums

xo_pinhole_var=xo_pinhole;%-edge_var:step_var:xo_pinhole+edge_var;
yo_pinhole_var=yo_pinhole;%-edge_var:step_var:yo_pinhole+edge_var;
r_pinhole_var=r_pinhole-edge_var:step_var:r_pinhole+edge_var;

% xo_pinhole_var=xo_pinhole; 
% yo_pinhole_var=yo_pinhole;
% r_pinhole_var=r_pinhole;

index=1;
N=size(xo_pinhole_var,2)*size(yo_pinhole_var,2)*size(r_pinhole_var,2);

fidelity_vals = zeros(1,N);

for i=1:size(r_pinhole_var,2)
    for j=1:size(xo_pinhole_var,2)
        for k=1:size(yo_pinhole_var,2)
            xo_pinhole_loop=xo_pinhole_var(j);
            yo_pinhole_loop=yo_pinhole_var(k);
            r_pinhole_loop=r_pinhole_var(i);
            
            % erstelle Pinhole für Fourierebene
            fourier_mask=(X-xo_pinhole_loop).^2+(Y-yo_pinhole_loop).^2<(r_pinhole_loop)^2;
            
            % örtliche Filterung der Fourierebene mittels Pinhole
            % zur Erklärung: man kann sich ein Pinhole (eine Blende) als "D
            % örtlicher Tiefpass vorstellen. Örtliche Frequenzen, welche 
            % außerhalb des Tiefpasses liegen, werden unterdrückt.
            modulated_beam_fft_filtered=modulated_beam_fft.*fourier_mask;
            
            modulated_beam_fft_shift=circshift(modulated_beam_fft_filtered,[(n_SLM)/2-yo_pinhole_loop (m_SLM)/2-xo_pinhole_loop]);
            
            % rekonstruiere den Modulierten Teil mittels einer weiteren
            % Linse -> IFFT
            modulated_beam_fft_reconstruct = ifft2(ifftshift(modulated_beam_fft_shift));
            
            % Teile nun das sich ergebene Feld in Betrag und Phase auf und
            % schneide die Felder an der relevanten Stelle aus, um später
            % die Qualität der Modulierung zu bestimmen
            modulated_beam_fft_reconstruct_abs=abs(modulated_beam_fft_reconstruct);
            modulated_beam_fft_reconstruct_phase=angle(modulated_beam_fft_reconstruct);
            
            [modulated_beam_fft_reconstruct_abs_cut,modulated_beam_fft_reconstruct_phase_cut]=cutout(modulated_beam_fft_reconstruct_abs,modulated_beam_fft_reconstruct_phase,area_analysis);

            zero_padding=size(mode_target_distribution_analyzis,1)-size(modulated_beam_fft_reconstruct_abs_cut,1);          
            modulated_beam_fft_reconstruct_abs_cut_padded=symmetric_zero_padding(modulated_beam_fft_reconstruct_abs_cut,zero_padding);
            modulated_beam_fft_reconstruct_phase_cut_padded=symmetric_zero_padding(modulated_beam_fft_reconstruct_phase_cut,zero_padding);
            
%             figure;imagesc(abs(modulated_beam_fft_reconstruct_abs_cut_padded));     
%             figure;imagesc(abs(modulated_beam_fft_reconstruct_phase_cut_padded));    
%             figure;imagesc(abs(fourier_mask));            
%             figure;imagesc(abs(fft_DMD_filtered));
%             figure;imagesc(abs(Bereich_analysis));
%             figure;imagesc(field_reconstruct_abs_cut);
%             figure;imagesc(field_reconstruct_phase_cut);
%             figure;imagesc(abs(mode_target_distribution));
%             figure;imagesc(abs(field_reconstruct_abs_cut.*exp(1i*field_reconstruct_phase_cut)));
            
            reconstructed_mode_distribution=modulated_beam_fft_reconstruct_abs_cut_padded.*exp(1i*modulated_beam_fft_reconstruct_phase_cut_padded);
            
            % compute fidelity -> quality analyzis
            g=innerProduct(mode_target_distribution_analyzis,reconstructed_mode_distribution);
            fidelity_vals(index)=abs(g)^2;
            
            %fidelity_vals(index)=calcFidelity(field,field_reconstruct_abs_cut.*exp(1i*field_reconstruct_phase_cut);
                
            vals(1,index)=xo_pinhole_loop;
            vals(2,index)=yo_pinhole_loop;
            vals(3,index)=r_pinhole_loop;
            index/N;
            index=index+1;
        end
    end
end

%% select best parameters
iteration_best_parameter_combination=find(fidelity_vals==max(fidelity_vals));
x_best=vals(1,iteration_best_parameter_combination);
y_best=vals(2,iteration_best_parameter_combination);
r_best=vals(3,iteration_best_parameter_combination);

fourier_mask_best=(X-x_best).^2+(Y-y_best).^2<(r_best)^2;
modulated_beam_fft_filtered_best=modulated_beam_fft.*fourier_mask_best;
modulated_beam_fft_shift_best=circshift(modulated_beam_fft_filtered_best,[(n_SLM)/2-y_best (m_SLM)/2-x_best]);
modulated_beam_fft_reconstruct_best = ifft2(ifftshift(modulated_beam_fft_shift_best));

fidelity_sp_bt(bt) = max(fidelity_vals)
bt_nums(bt) = bt
end
figure;
plot(bt_nums, fidelity_sp_bt); title('Fidelity in Abhänigigkeit von der Bittiefe des SLM');
xlabel('Mode'); ylabel('Fidelity');
