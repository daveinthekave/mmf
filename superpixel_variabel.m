function [inputSuper] = superpixel_variabel(input, superPixelSize, bitDepthSLM, max, sp_count)
% input is matrix of complex values
%%
% clear all
% superPixelSize=4;
% max=10;
% bitDepthSLM=8;
% input=[zeros(100,100) ones(100,100).*exp(1i*pi/2)];

%% initialisation

[m,n]=size(input);

inputSuper=zeros(m*superPixelSize,n*superPixelSize); % prepare target image

%% build scale mapping Amplitude <-> Phase
valsAmp=round(linspace(0,max/2,2^(bitDepthSLM)),4);
ampStep=abs(valsAmp(1)-valsAmp(2));

if bitDepthSLM == 1
    scalePhase=round(linspace(0,pi,2^(bitDepthSLM)),3);
else
scalePhase=round(linspace(0,2*pi,2^(bitDepthSLM)),3);
end
phaseStep=abs(scalePhase(1)-scalePhase(2));
%% correct phase
PhaseCorrected=angle(input);
PhaseCorrected(PhaseCorrected<0)=PhaseCorrected(PhaseCorrected<0)+2*pi;
%% Loop
for i=1:m
    for j=1:n
        phaseMean=PhaseCorrected(i,j);
        
        if isempty(max)
            Amp=abs(input(i,j));
        else
            Amp=abs(input(i,j))/max;
        end
        
        if Amp > 1
            warning('Amplitudes are above |1|!');
        end
        Amp=Amp*2;                          % Durch konstruktive Interferenz 
                                            % ergeben sich auf dem 
                                            % Einheitskreis Zeiger mit der 
                                            % Amplitude 2. Deshalb Skalierung 
                                            % des Eingangsbereichs von 0 bis 2
        amp_half=Amp/2;
        
        angle1=asin(amp_half);
        angle2=pi-angle1;
        
        % Schiebe beide Phasenzeiger um den Phasenoffset
        diff=phaseMean-pi/2;
        angle1=angle1+diff;
        angle2=angle2+diff;
        
        % ersten Zeiger in richtigen Bereich schieben
        if angle1 < 0
            angle1 = 2*pi+angle1;
        elseif angle1 > 2*pi
            angle1=angle1-2*pi;
        end
        
        % zweiten Zeiger in richtigen Bereich schieben
        if angle2 < 0
            angle2 = 2*pi+angle2;
        elseif angle2 > 2*pi
            angle2=angle2-2*pi;
        end
        
        % Runde phasenWert2 auf 1/8Bit Schritte
        a=scalePhase-angle2;
        b=a>0;
        if isempty(find(b, 1))
            phasenWert2=scalePhase(2^bitDepthSLM);
        else
            [m1,n1]=find(b);

            if a(n1(1))<0.5*phaseStep
                phasenWert2=scalePhase(n1(1));
            else
                phasenWert2=scalePhase(n1(1)-1);
            end
        end
        
        % Runde phasenWert1 auf 1/8Bit Schritte
        a=scalePhase-angle1;
        b=a>0;
        if isempty(find(b, 1))
            phasenWert1=scalePhase(2^bitDepthSLM);
        else
            [m1,n1]=find(b);
            if a(n1(1))<0.5*phaseStep
                phasenWert1=scalePhase(n1(1));
            else
                phasenWert1=scalePhase(n1(1)-1);
            end
        end
        
        % baue Superpixel
        
        switch sp_count
        
            case 2 
                Superpixel=[repmat(phasenWert1,superPixelSize/2),repmat(phasenWert2,superPixelSize/2);
                    repmat(phasenWert2,superPixelSize/2),repmat(phasenWert1,superPixelSize/2)];
        
            case 3
        
                Superpixel=[repmat(phasenWert1,superPixelSize/3),repmat(phasenWert2,superPixelSize/3),repmat(phasenWert1,superPixelSize/3);
                            repmat(phasenWert2,superPixelSize/3),repmat(phasenWert1,superPixelSize/3),repmat(phasenWert2,superPixelSize/3);
                            repmat(phasenWert1,superPixelSize/3),repmat(phasenWert2,superPixelSize/3),repmat(phasenWert1,superPixelSize/3)];

            case 4
                        
                Superpixel=[repmat(phasenWert1,superPixelSize/4),repmat(phasenWert2,superPixelSize/4),repmat(phasenWert1,superPixelSize/4),repmat(phasenWert2,superPixelSize/4);
                    repmat(phasenWert2,superPixelSize/4),repmat(phasenWert1,superPixelSize/4),repmat(phasenWert2,superPixelSize/4),repmat(phasenWert1,superPixelSize/4);
                    repmat(phasenWert1,superPixelSize/4),repmat(phasenWert2,superPixelSize/4),repmat(phasenWert1,superPixelSize/4),repmat(phasenWert2,superPixelSize/4);
                    repmat(phasenWert2,superPixelSize/4),repmat(phasenWert1,superPixelSize/4),repmat(phasenWert2,superPixelSize/4),repmat(phasenWert1,superPixelSize/4);];

            case 5
                
                Superpixel=[repmat(phasenWert1,superPixelSize/5), repmat(phasenWert2,superPixelSize/5), repmat(phasenWert1,superPixelSize/5),repmat(phasenWert2,superPixelSize/5), repmat(phasenWert1,superPixelSize/5);
                    repmat(phasenWert2,superPixelSize/5),repmat(phasenWert1,superPixelSize/5), repmat(phasenWert2,superPixelSize/5),repmat(phasenWert1,superPixelSize/5), repmat(phasenWert2,superPixelSize/5);
                    repmat(phasenWert1,superPixelSize/5), repmat(phasenWert2,superPixelSize/5), repmat(phasenWert1,superPixelSize/5),repmat(phasenWert2,superPixelSize/5), repmat(phasenWert1,superPixelSize/5);
                    repmat(phasenWert2,superPixelSize/5),repmat(phasenWert1,superPixelSize/5), repmat(phasenWert2,superPixelSize/5),repmat(phasenWert1,superPixelSize/5), repmat(phasenWert2,superPixelSize/5);
                    repmat(phasenWert1,superPixelSize/5), repmat(phasenWert2,superPixelSize/5), repmat(phasenWert1,superPixelSize/5),repmat(phasenWert2,superPixelSize/5), repmat(phasenWert1,superPixelSize/5);];
                    
                    
            case 6
                
                Superpixel=[repmat(phasenWert1,superPixelSize/6), repmat(phasenWert2,superPixelSize/6), repmat(phasenWert1,superPixelSize/6),repmat(phasenWert2,superPixelSize/6), repmat(phasenWert1,superPixelSize/6),repmat(phasenWert2,superPixelSize/6);
                    repmat(phasenWert2,superPixelSize/6),repmat(phasenWert1,superPixelSize/6), repmat(phasenWert2,superPixelSize/6),repmat(phasenWert1,superPixelSize/6), repmat(phasenWert2,superPixelSize/6),repmat(phasenWert1,superPixelSize/6);
                    repmat(phasenWert1,superPixelSize/6),repmat(phasenWert2,superPixelSize/6), repmat(phasenWert1,superPixelSize/6),repmat(phasenWert2,superPixelSize/6), repmat(phasenWert1,superPixelSize/6),repmat(phasenWert2,superPixelSize/6);
                    repmat(phasenWert2,superPixelSize/6),repmat(phasenWert1,superPixelSize/6), repmat(phasenWert2,superPixelSize/6),repmat(phasenWert1,superPixelSize/6), repmat(phasenWert2,superPixelSize/6),repmat(phasenWert1,superPixelSize/6);
                    repmat(phasenWert1,superPixelSize/6),repmat(phasenWert2,superPixelSize/6), repmat(phasenWert1,superPixelSize/6),repmat(phasenWert2,superPixelSize/6), repmat(phasenWert1,superPixelSize/6),repmat(phasenWert2,superPixelSize/6);
                    repmat(phasenWert2,superPixelSize/6),repmat(phasenWert1,superPixelSize/6), repmat(phasenWert2,superPixelSize/6),repmat(phasenWert1,superPixelSize/6), repmat(phasenWert2,superPixelSize/6),repmat(phasenWert1,superPixelSize/6);];                

            case 7
                
                Superpixel=[repmat(phasenWert1,superPixelSize/7), repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7);
                    repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7), repmat(phasenWert2,superPixelSize/7);
                    repmat(phasenWert1,superPixelSize/7), repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7);
                    repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7), repmat(phasenWert2,superPixelSize/7);
                    repmat(phasenWert1,superPixelSize/7), repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7);
                    repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7), repmat(phasenWert2,superPixelSize/7);
                    repmat(phasenWert1,superPixelSize/7), repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7),repmat(phasenWert2,superPixelSize/7), repmat(phasenWert1,superPixelSize/7);];

            case 8
                
                Superpixel=[repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8);
                repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8);
                repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8);
                repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8);
                repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8);
                repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8);
                repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8), repmat(phasenWert1,superPixelSize/8),repmat(phasenWert2,superPixelSize/8);
                repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8), repmat(phasenWert2,superPixelSize/8),repmat(phasenWert1,superPixelSize/8);];

            otherwise
                Superpixel=[repmat(phasenWert1,superPixelSize/2),repmat(phasenWert2,superPixelSize/2);
                    repmat(phasenWert2,superPixelSize/2),repmat(phasenWert1,superPixelSize/2)];
            
        end

        inputSuper((i-1)*superPixelSize+1:((i-1)*superPixelSize+1)+superPixelSize-1,...
            (j-1)*superPixelSize+1:((j-1)*superPixelSize+1)+superPixelSize-1)...
            = Superpixel;
    end
end
% figure;imagesc(inputSuper)