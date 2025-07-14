function T1_dicom2nii_LKW__Function

%This script was written to help convert non-segmented T1 MRI dicom files into NII files.

%Written by Lauren Webert.
%5/23/2025.


%%
clear all
clc
close all

% mainDdir = 'D:\DevMIND_EOR_Longitudinal\MRIs_MEG2years\2';
mainDdir = uigetdir('D:\', 'Select your local directory containing non-segmented T1 files.');



%% Convert T1 DCM to Nii

cd(mainDdir)
d = struct2table(dir(mainDdir));
d = d(contains(d.name, 'M68'),:);

clear i t
t = 1;

for i = 1:height(d) %loop through each file
    clear tempsub
    tempsub = d.name{i};
    
    cd([mainDdir '\' tempsub]) %go into that file/participant folder
    
    clear t1
    t1.dir = dir('t1w_32ch_mpr_1mm_*'); %How many T1 folders do they have?    
    
    if numel(t1.dir)>1 %If there are multiple T1...
        warning(['Multiple t1 for ' tempsub])
        check_t1{t,:} = tempsub;
        t = t+1;
        
    elseif numel(t1.dir) == 0 %If there are 0 T1...
        warning([tempsub ' has no T1'])
        check_t1{t,:} = tempsub;
        t = t+1;
        return
    end
    
    
    clear ii
    for ii = 1:numel(t1.dir) %for each T1 folder/file
        
        % ---- DO NOT CHANGE THIS ----
        clear bb
        bb = 	cellstr(spm_select('FPList',[mainDdir '\' tempsub '\' t1.dir.name],['Serie.*']));
        clear matlabbatch
        matlabbatch{1}.spm.util.import.dicom.data = {bb{:}}';
        matlabbatch{1}.spm.util.import.dicom.root = 'flat';
        matlabbatch{1}.spm.util.import.dicom.outdir = {[mainDdir '\' tempsub]};
        matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
        matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
        matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;
        matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;
        % Runs the steps described above
        spm_jobman('initcfg')
        spm('defaults', 'FMRI');
        spm_jobman('run', matlabbatch); %This saves a T1.nii file based off your t1w_32ch... folder (dicom files)
        
        
        clear t1_nii
        t1_nii = 	cellstr(spm_select('FPList',[mainDdir '\' tempsub],['sM68*.*nii']));
        T1_count = num2str(t1.dir(ii).name(end-3:end));
        
        
        % --- SPECIFY new T1 name here! ---
        new_name = [mainDdir '\' tempsub '\t1_' tempsub '_' T1_count '.nii'];
        movefile(t1_nii{:},new_name); %this "moves" the t1.nii in order to re-name it.
        
    end
    
end

if exist('check_t1','var')
    check_t1 = table(check_t1);
    writetable(check_t1, [mainDdir '\check_t1.xlsx']);
end

end