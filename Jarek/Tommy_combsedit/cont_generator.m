%%

function matlabbatch=cont_generator(name_array,convec)
ncont=leng(name_array);
for i=1:ncont
matlabbatch{1,1}.spm.stats.con.consess{1,i}.tcon.name = name_array{i} ;%string
matlabbatch{1,1}.spm.stats.con.consess{1,i}.tcon.convec = convec{i}; % horizontal array
matlabbatch{1,1}.spm.stats.con.consess{1,i}.tcon.sessrep = 'repl';
end