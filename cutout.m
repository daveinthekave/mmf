function [M_Id,M_Id1] = cutout(Id, Id1,circle_cut)

M=Id.*circle_cut;
M1=Id1.*circle_cut;

[m,n]=find(M~=0);

oben=min(m);unten=max(m);links=min(n);rechts=max(n);

if unten-oben>rechts-links
    diff=(unten-oben)-(rechts-links);
    if rechts+diff>size(M,2);
        diff1=size(M,2)-rechts;
        rechts=size(M,2);
        diff2=diff-diff1;
        links=links-diff2;
    else
         rechts=rechts+diff;
    end
elseif unten-oben<rechts-links
    diff=(rechts-links)-(unten-oben);
    if unten+diff>size(M,1);
        diff1=size(M,1)-unten;
        unten=size(M,2);
        diff2=diff-diff1;
        oben=oben-diff2;
    else
         unten=unten+diff;
    end
end

M_Id=M(oben:unten,links:rechts);
M_Id1=M1(oben:unten,links:rechts);




