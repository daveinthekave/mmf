load('optical_beam');
test = rand(100)*10;
no_shift = fft2(test);
shifted = fftshift(no_shift);

invers = ifft2(no_shift);
shifted_invers = ifft2(shifted);
invers_shifted = ifft2(ifftshift(no_shift));
double_shifted_invers = ifft2(ifftshift(shifted));
max(max(shifted_invers - invers))
max(max(invers_shifted - invers))
max(max(double_shifted_invers - invers))
figure;imagesc(abs(invers));title('no shift, no shift');
figure;imagesc(abs(shifted_invers));title('shift, no shift');
figure;imagesc(abs(invers_shifted));title('no shift, shift');
figure;imagesc(abs(invers));title('shift, shift');