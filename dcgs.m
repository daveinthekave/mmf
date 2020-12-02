function [slm_phase_mask] = dcgs(input, target, bit_res)
% double constraint gerchbergs-saxton

N_it = 600;
input_amp = abs(input); % Intensität eines Gaußstrahls
input_phase = rand(size(input)); % Startwert für Phi (Zufallsverteilung)
target_amp = abs(target); % Amplitude des Targets
target_phase = angle(target);

[image_plane_size, ~] = size(input);
[signal_size, ~] = size(target);
input = input_amp .* exp(1i*input_phase);

start = fix(image_plane_size / 2) - fix(signal_size / 2);
stop = fix(image_plane_size / 2) + fix(signal_size / 2 - 1);

for i=1:N_it
    input_fft = fftshift(fft2(input));

    input_fft_amp = abs(input_fft);
    input_fft_phase = angle(input_fft);
    
    % indirekte indizierung ausprobieren
    input_fft_amp(start:stop, start:stop) = target_amp;
    input_fft_phase(start:stop, start:stop) = target_phase;

    input_fft_combined = input_fft_amp .* exp(1i*input_fft_phase);

    target = ifft2(ifftshift(input_fft_combined));

    input = input_amp .* exp(1i*angle(target));
end
desired_phase = angle(target);
% discretizes the phase
scalePhase = round(linspace(0, 2*pi, 2^bit_res), 3);
phaseStep = abs(scalePhase(1) - scalePhase(2));

descrete_phase = zeros(image_plane_size);
for i=1:1:image_plane_size
    for j=1:1:image_plane_size
        % Runde phasenWert1 auf 1/8Bit Schritte
        % abs für negative winkel
        a = scalePhase - abs(desired_phase(i, j));
        b = a > 0;
        if isempty(find(b, 1))
            descrete_phase(i, j) = scalePhase(256);
        else
            [~, n] = find(b);
            if a(n(1)) < 0.5 * phaseStep
                descrete_phase(i, j) = scalePhase(n(1));
            else
                descrete_phase(i, j) = scalePhase(n(1)-1);
            end
        end
    end
end
% multipliziere mit sign damit vorzeichen wieder stimmen
slm_phase_mask = descrete_phase .* sign(desired_phase);
end

