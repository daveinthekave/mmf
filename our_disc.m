function disc_phase = our_disc(phase, resolution)
% phase: phasenwerte matrix
[rows, cols] = size(phase);
disc_phase = zeros(rows, cols);
if resolution > 1
    scalePhase=round(linspace(0,2*pi,2^resolution),3);
else
    scalePhase=round([0, pi], 3);
end
phaseStep=abs(scalePhase(1)-scalePhase(2));

for i=1:rows
    for j=1:cols
    phase_val = phase(i, j);
    a=scalePhase - phase_val;
        b=a>0;
        if isempty(find(b, 1))
            phasenWert=scalePhase(end);
        else
            [m1,n1]=find(b);

            if a(n1(1))<0.5*phaseStep
                phasenWert=scalePhase(n1(1));
            else
                phasenWert=scalePhase(n1(1)-1);
            end
        end
        % schreibe diskretisierte phase in matrix
        disc_phase(i, j) = phasenWert;
    end
end
end

