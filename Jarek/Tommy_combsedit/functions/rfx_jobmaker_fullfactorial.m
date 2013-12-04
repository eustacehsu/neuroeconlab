function rfx_jobmaker_fullfactorial(name_array,statdir)
%%
ncont=length(name_array);
% Make jobs
%--------------------------------------------------------------------------
dSPM  = fullfile(statdir, 'RFX','FFactorial');
dFX   = fullfile(statdir, 'FFX');

% Create SPM directory if it doesn't exist
if ~exist(dSPM, 'dir')
    mkdir(dSPM);
end
%%

% matlabbatch{1}.spm.stats.factorial_design.dir{1} = dSPM;
% matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(strcat(fCon, ',1'));
% matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = name_array{i};



% matlabbatch{1}.spm.stats.factorial_design.dir = {};
matlabbatch{1}.spm.stats.factorial_design.dir{1} = dSPM; % folder where to save
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name ='FFactorial'; %name of the Factor
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = ncont;  %number of contrasts
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0; %dependence check whether its supposed to be 0 or 1
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1; % different or equal variance?
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0; 
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;


%% cells definition need one for each contrast I guess
for i=1:ncont
if i>9
    contrast=['con_00',num2str(i)];%name_array{i};
else
contrast=['con_000',num2str(i)];%name_array{i};
end
fCon = spm_select('FPListRec', dFX, sprintf('^%s.*\\.img$', contrast)); % Read Con files


matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(i).levels = i; % why are there two ones???   ->> one for the factors and one for the levels the first element is the factor and the second is the level (guess)
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(i).scans = fCon;
end
%%
% matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
% matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
% matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
% matlabbatch{1}.spm.stats.factorial_design.masking.em = {};
% matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
% matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
% matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname = 'Factorial design specification: SPM.mat File';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
%% Save batch
% %--------------------------------------------------------------------------
fbs = fullfile(dSPM, 'batch_RFX');
save(fbs', 'matlabbatch');
%% Run batch
 spm('defaults', 'FMRI');
 spm_jobman('run', matlabbatch);
