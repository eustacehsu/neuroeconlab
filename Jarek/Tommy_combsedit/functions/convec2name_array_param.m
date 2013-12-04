function name_array=convec2name_array_param(convec,names,npar,pmod)
ncontr=length(convec(:,1));
nregr=length(names);
lastpar=length(pmod);
n=1;
for i=1:nregr
if i<= lastpar    
    if npar(i)==0
    name_array{n}=names{i};
    n=n+1;
    else
        name_array{n}=names{i};
        n=n+1;
        for p=1:npar(i)
              name_array{n}=[names{i},'_',pmod(i).name{p}];
              n=n+1;
        end
    end
else
    name_array{n}=names{i};
    n=n+1;
end
end
      
        
        