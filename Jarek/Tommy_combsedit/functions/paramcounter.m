function [totpar,npar]=paramcounter(pmod,names)
lastpar=length(pmod);
for n=1:lastpar
    npar(n)=length(pmod(n).param);
end
totpar=sum(npar);
end
