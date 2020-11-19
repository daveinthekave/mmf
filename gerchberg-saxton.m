function [input_modulated] = gerchberg_saxton(input, target)

N_it = 10; % Anzahl der Iterationen
I_H = abs(input); % Intensität eines Gaußstrahls
Phi_H_n = angle(input); % Startwert für Phi (Zufallsverteilung)
I_T = abs(target);

% Source = exp(-1/2*(xx0.^2+yy0.^2)/sigma^2);
A = fftshift(ifft2(fftshift(target)));

for i=1:N_it
    
%   u_H_n = sqrt(I_H) .* exp(1i*Phi_H_n);
%   Phi_T_n = angle(fft2(u_H_n));
%   u_T_n = sqrt(I_T) .* exp(1i*Phi_T_n);
%   Phi_H_n = angle(ifft2(u_T_n));
  B = I_H .* exp(1i*angle(A));
  C = fftshift(fft2(fftshift(B)));
  D = abs(target) .* exp(1i*angle(C));
  A = fftshift(ifft2(fftshift(D)));
  
end

input_modulated = C;