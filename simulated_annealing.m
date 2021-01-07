function [slm_phase_mask, fidelity_vals] = simulated_annealing(input, target,mask)

% Berechnung der Phasenmaske, um target aus input zu erzeugen

T_start = 200;                                              % Starttemperatur
scaleFactor = 10e8;                                         % Skalierungsfaktor, da delta_E sehr klein (fidelity ändert sich wenig bei Änderung eines Pixels)
n_it = 400000;                                               % Anzahl der Iterationen


dx=8e-6;dy=dx;      % pixel size SLM [m]
lambda=532e-9;      % wavelength [m]
dist=0.5;           % propagation distance [m]

% start_phase = angle(fftshift(ifft2(target)));
% input_amp = abs(input);
% input = input_amp .* exp(1i*start_phase);

num_pixel = 1;                                              % Anzahl der Pixel, die (im Mittel) pro Iteration verändert werden
probability_threshold = 1 - (num_pixel ./ size(input).^2);  % Variation der Pixeländerungsanzahl


fidelity_vals=zeros(1,n_it);
index=1;

% calcs inital mode result
previous_result = prop(input,dx,dy,lambda,dist);                            % Startwert
% previous_fidelity = abs(innerProduct(target, previous_result))^2;   % Startfidelity
% previous_corr2=corr2(target.*conj(target), previous_result.*conj(previous_result));
previous_fidelity = calcFidelity(target.*mask, previous_result.*mask);   % Startfidelity

for T=linspace(T_start, 0, n_it)                                    % Temperatur wird schrittweise von T_start auf 0 erniedrigt
    current_input = input;
    index_mat = rand(size(input)) > (probability_threshold(1));       % Matrix (bei Pixel P1 =1 --> P1 wird in dieser Iteration verändert)
    num_rand_pixel = sum(index_mat, 'all');                         % Anzahl der Pixel, die in dieser Iteration geändert werden
    
    current_input(index_mat) = current_input(index_mat) .* exp(1i*rand(num_rand_pixel, 1)* 2*pi);   % Veränderung der Pixel
    
    
    % rindex = fix(rand(1, 2) .* size(input)) + 1;
    % current_input(rindex(1), rindex(2)) = current_input(rindex(1), rindex(2)) * exp(1i*rand() * 2 * pi);
    
    current_result = prop(current_input,dx,dy,lambda,dist);                % Berechnung des Ergebnisses mittels FFT
%     current_fidelity = abs(innerProduct(target, current_result))^2; % Berechnung der Fidelity
    current_fidelity = calcFidelity(target.*mask, current_result.*mask);
%     current_corr2=corr2(target.*conj(target), current_result.*conj(current_result));
    
    fidelity_vals(index)=current_fidelity;
    index=index+1;
%     if T<100
%         pause(0.3)
%     end
    if current_fidelity > previous_fidelity                         % Ergebnis hat sich gebessert
        input = current_input; %fftshift(current_input);                                      % setze die neuen Werte
        previous_fidelity = current_fidelity;
    else                                                            % Ergebnis hat sich nicht verbessert
% Ergebnis hat sich nicht verbessert
        delta_E = previous_fidelity - current_fidelity;             % Berechnung der Differenz
        P = exp(-delta_E*scaleFactor/T);                            % Boltzmann-Verteilung
        R = rand();                                                 % zufällige Referenzwahrscheinlichkeit
        if R < P                                                    % Schwelle wird überschritten
            input = current_input;                                  % setze die neuen Werte
            previous_fidelity = current_fidelity;
        end
    end 
%     if current_corr2 > previous_corr2                         % Ergebnis hat sich gebessert
%         input = current_input; %fftshift(current_input);                                      % setze die neuen Werte
%         previous_corr2 = current_corr2;
%     else                                                            % Ergebnis hat sich nicht verbessert
% % Ergebnis hat sich nicht verbessert
%         delta_E = previous_corr2 - current_corr2;             % Berechnung der Differenz
%         P = exp(-delta_E*scaleFactor/T);                            % Boltzmann-Verteilung
%         R = rand();                                                 % zufällige Referenzwahrscheinlichkeit
%         if R < P                                                    % Schwelle wird überschritten
%             input = current_input;                                  % setze die neuen Werte
%             previous_corr2 = current_corr2;
%         end
%     end
end
slm_phase_mask = input;                              % Rückgabe des Ergebnisses
end

