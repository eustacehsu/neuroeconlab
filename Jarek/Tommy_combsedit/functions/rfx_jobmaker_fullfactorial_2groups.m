function rfx_jobmaker_fullfactorial_2groups(name_array,statdir)
%%
ncont=length(name_array);
% Make jobs
%--------------------------------------------------------------------------
dSPM  = fullfile(statdir, 'RFX','FFactorial');
dFX   = fullfile(statdir, 'FFX');
dFX_1   = fullfile(statdir, 'FFX','group1');
dFX_2   = fullfile(statdir, 'FFX','group2');
% Create SPM directory if it doesn't exist
if ~exist(dSPM, 'dir')
    mkdir(dSPM);
end
%%

% matlabbatch{1}.spm.stats.factorial_design.dir{1} = dSPM;
% matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(strcat(fCon, ',1'));
% matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = name_array{i};


%% factor 1 (regressors)
% matlabbatch{1}.spm.stats.factorial_design.dir = {};
matlabbatch{1}.spm.stats.factorial_design.dir{1} = dSPM; % folder where to save
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name ='Regressors'; %name of the Factor
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = ncont-1;  %number of contrasts
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0; %dependence check whether its supposed to be 0 or 1
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1; % different or equal variance?
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0; 
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
%% factor 2 (groups)
matlabbatch{1}.spm.stats.factorial_design.dir{1} = dSPM; % folder where to save
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name ='Groups'; %name of the Factor
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;  %number of contrasts
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 0; %dependence check whether its supposed to be 0 or 1
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 1; % different or equal variance?
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0; 
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
%% cells definition need one for each contrast I guess
for i=1:ncont-1
if i>9
    contrast=['con_00',num2str(i)];%name_array{i};
else
contrast=['con_000',num2str(i)];%name_array{i};
end
fCon = spm_select('FPListRec', dFX_1, sprintf('^%s.*\\.img$', contrast)); % Read Con files


matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(i).levels = [i 1]; % why are there two ones???   ->> one for the factors and one for the levels the first element is the factor and the second is the level (guess)
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(i).scans = fCon;
end

for i=ncont:(2*(ncont-1))
if (i-(ncont-1))>9
    contrast=['con_00',num2str(i-(ncont-1))];%name_array{i};
else
contrast=['con_000',num2str(i-(ncont-1))];%name_array{i};
end
fCon = spm_select('FPListRec', dFX_2, sprintf('^%s.*\\.img$', contrast)); % Read Con files


matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(i).levels = [i-(ncont-1) 2]; % why are there two ones???   ->> one for the factors and one for the levels the first element is the factor and the second is the level (guess)
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(i).scans = fCon;
end

% i=ncont;
% if i>9
%     contrast=['con_00',num2str(i)];%name_array{i};
% else
% contrast=['con_000',num2str(i)];%name_array{i};
% end
% fCon1 = spm_select('FPListRec', dFX_1, sprintf('^%s.*\\.img$', contrast)); % Read Con files
% 
% fCon2 = spm_select('FPListRec', dFX_2, sprintf('^%s.*\\.img$', contrast)); % Read Con files
% 
% matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(i).levels = [0 1]; % why are there two ones???   ->> one for the factors and one for the levels the first element is the factor and the second is the level (guess)
% matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(i).scans = fCon1;
% matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(i+1).levels =[0 2]; % why are there two ones???   ->> one for the factors and one for the levels the first element is the factor and the second is the level (guess)
% matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(i+1).scans = fCon2;
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
