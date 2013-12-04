function name_array=convec2name_array(convec,names)
%contrast cycle
for c=1:length(convec(:,1))
%regressors cycle
k=0;
    for e=1:length(convec(c,:)) %
        if convec(c,e) ~= 0 && k== 0
            if convec(c,e)==1
             name_array{c}=[names{e},'_up;'];
            else 
                name_array{c}=[names{e},'_down;'];
            end
            k=k+1;
        elseif convec(c,e) ~= 0 && k> 0
            if convec(c,e)==1
               name_array{c}=horzcat(name_array{c},[names{e},'_up;']);
            else
               name_array{c}=horzcat(name_array{c},[names{e},'_down;']);
            end
        end
    end
end