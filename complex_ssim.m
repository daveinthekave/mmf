function ssim_val = complex_ssim(modulated, ref)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

mod_amp = abs(modulated);
mod_phase = angle(modulated);

ref_amp = abs(ref);
ref_phase = angle(ref);

[mod_amp_cut, mod_phase_cut]=cutout(mod_amp, mod_phase, area_analysis);

zero_padding=size(target,1) - size(mod_amp_cut,1);          
mod_amp_padded = symmetric_zero_padding(mod_amp_cut, zero_padding);
mod_phase_padded = symmetric_zero_padding(mod_phase_cut, zero_padding);

ssim_amp = ssim(mod_amp_padded, ref_amp);
ssim_phase = ssim(mod_phase_padded, ref_phase);

ssim_val = 0.5 * (ssim_amp + ssim_phase);

end

