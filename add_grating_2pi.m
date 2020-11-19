function [output]= add_grating_2pi(Input)
B=Input;
G0=double(imread('grating.bmp'));
G=pi*G0(1:size(B,1),1:size(B,2));
B=B+G;
B(B>2*pi)=B(B>2*pi)-2*pi;

output=B;