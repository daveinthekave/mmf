function  tmp = symmetric_zero_padding(picture,numberofzeros)
%% tries to symmetrically pad input with specified numbers of zeros
%if numberofzeros is uneven, "left" gets less zeros

dims = ndims(picture);

if dims ==1;
    picture = picture(:);
end

if length(numberofzeros) < dims
%     display('dimension of zeros vector too small, assuming value one counts for all');
    numberofzeros = ones(dims,1)*numberofzeros(1);
end

if dims >1
    tmp = zeros(size(picture)+transpose(numberofzeros(:)));
else tmp = zeros(length(picture)+numberofzeros,1)
end

% now, we build a nice string to make the indexing

string = 'tmp(';
for n = 1:dims
    string = horzcat(string,num2str(floor(numberofzeros(n)/2)+1),':',num2str(size(picture,n)+floor(numberofzeros(n)/2)),',');
end

string(end) = [];

string = horzcat(string,') = picture;');

eval(string);

% tmp(floor(numberofzeros/2)+1:size(picture)+floor(numberofzeros/2)) = picture;

end
    