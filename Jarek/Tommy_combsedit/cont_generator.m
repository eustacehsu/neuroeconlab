%%

nameOfConrats = ['con1'; 'con2'; 'con3'];

contrasts = [ -1  1  0  0
               1  0  0  0
               1 -1  0  0];

numberOfContrasts = size(contrasts,1);

for i=1:numberOfContrasts
matlabbatch{1,1}.spm.stats.con.consess{1,i}.tcon.name = nameOfConrats(i,:);%string
matlabbatch{1,1}.spm.stats.con.consess{1,i}.tcon.convec = contrasts(i,:); % horizontal array
matlabbatch{1,1}.spm.stats.con.consess{1,i}.tcon.sessrep = 'repl';
end