clear
close all
clc

%% Excel with URSI assignments

%Select excel with URSI assignments by preprocessor
path_excel = '\\bt139009\D\DevMIND_EOR_Longitudinal\Excels\2times_n50';
cd(path_excel)
t = readtable([path_excel '\DevMIND_EOR_Long_2yearsMEG_Preprocessing.xlsx'], 'Sheet', 'n50_Files');
sublist = t.URSI;


preprocessor = t.Preprocessor;
u_preproc = unique(preprocessor);

clear i
for i = 1:length(u_preproc)
    
    temp_preproc = u_preproc(i);
    temp_URSIlist = t.URSI(strcmp(t.Preprocessor, temp_preproc));
    
    eval([temp_preproc{1} '_list = temp_URSIlist; ']); %Create individual URSI lists per preprocessor
    
    preproc_list{i} = [temp_preproc{1} '_list']; %list of the lists :)
    preproc_outdir_MRI{i} = [temp_preproc{1} '_outdirMRI']; %list of the MRI outdir names
    preproc_outdir_MEG{i} = [temp_preproc{1} '_outdirMEG']; %list of the MEG outdir names
    
end

clear i temp_preproc temp_URSIlist



%% Output directories

%Put in your general MRI and MEG outdirectories here. (note - the script specifies 2.0, 3.0 4.0) 
%Comment out the other preprocessor's outdirs.

Lauren_outdirMRI = '\\bt139009\D\DevMIND_EOR_Longitudinal\MRIs_MEG2years\Lauren';
% Nate_outdirMRI =
% Drake_outdirMRI =
% Jesse_outdirMRI =

Lauren_outdirMEG = '\\bt139009\D\\DevMIND_EOR_Longitudinal\FIFs_2years\Lauren';
% Nate_outdirMEG =
% Drake_outdirMEG =
% Jesse_outdirMEG =


% ---- REPLACE YOUR NAME HERE: ----
preproc_current = find(contains(preproc_list, 'Lauren'));



%% MRI and MRI base directories (on Lauren's D: drive currently)
MRIdir_2 = struct2table(dir('\\bt139009\D\DevMIND_EOR_Longitudinal\MRIs_MEG2years\2\M68*'));
MRIdir_3 = struct2table(dir('\\bt139009\D\DevMIND_EOR_Longitudinal\MRIs_MEG2years\3\M68*'));
MRIdir_4 = struct2table(dir('\\bt139009\D\DevMIND_EOR_Longitudinal\MRIs_MEG2years\4\M68*'));

MEGdir_2 = struct2table(dir('\\bt139009\D\DevMIND_EOR_Longitudinal\FIFs_2years\2\M68*'));
MEGdir_3 = struct2table(dir('\\bt139009\D\DevMIND_EOR_Longitudinal\FIFs_2years\3\M68*'));
MEGdir_4 = struct2table(dir('\\bt139009\D\DevMIND_EOR_Longitudinal\FIFs_2years\4\M68*'));




%% Copy MRIs

clear i p ii

for i= 2:4
    
    clear temp_MRIdir
    eval(['temp_MRIdir = MRIdir_' num2str(i)]);
    
    cd(temp_MRIdir.folder{1})
    
    
    for p = preproc_current %1:length(preproc_list) %for each preprocessor
        
        clear temp_list temp_outdir ii
        eval([' temp_list = ' preproc_list{p} ';']); %Grab that preprocessor's URSI list
        
        eval([' temp_outdir = ' preproc_outdir_MRI{p} ';']); %Get that preprocessor's MRI outdir
        temp_outdir = [temp_outdir  '\' num2str(i)]; %specify the outdir for the correct protocol (e.g., 2.0)
        
        
        if ~isdir(temp_outdir) %if that outdir doesn't exist, make it
            mkdir(temp_outdir)
        end
        
        
        for ii = 1:length(temp_list) %for the participants in that preprocessor's list
            clear tempURSI MRIindx temp_MRI_name
            tempURSI = temp_list(ii); %get URSI from excel list
            
            MRIindx = find(contains(temp_MRIdir.name, tempURSI)); %find where that URSI is in folder directory
            
            if ~isempty(MRIindx) %if it found an MRI (aka that person has an MRI in this protocol)
                
                temp_MRI_name = temp_MRIdir.name{MRIindx}; %get that MRI folder name
                new_MRI_name = [tempURSI{1} '_' num2str(i)];
                
                %copy the MRI from Lauren's D: drive to the outdir (specific to preprocessor & protocol)
                copyfile([temp_MRIdir.folder{1} '\' temp_MRI_name],[temp_outdir '\' new_MRI_name]);
                
            end
        end
    end
end

clear temp_MRIdir temp_list temp_outdir tempURSI MRIindx temp_MRI_name




%% Copy MEGs

clear i p ii

for i= 2:4
    
    clear temp_MEGdir
    eval(['temp_MEGdir = MEGdir_' num2str(i)]);
    
    cd(temp_MEGdir.folder{1})
    
    
    for p = preproc_current %1:length(preproc_list) %for each preprocessor
        
        clear temp_list temp_outdir ii
        eval([' temp_list = ' preproc_list{p} ';']); %Grab that preprocessor's URSI list
        
        eval([' temp_outdir = ' preproc_outdir_MEG{p} ';']); %Get that preprocessor's MRI outdir
        temp_outdir = [temp_outdir  '\' num2str(i)]; %specify the outdir for the correct protocol (e.g., 2.0)
        
        
        if ~isdir(temp_outdir) %if that outdir doesn't exist, make it
            mkdir(temp_outdir)
        end
        
        
        for ii = 1:length(temp_list) %for the participants in that preprocessor's list
            clear tempURSI MEGindx temp_MEG_name
            tempURSI = temp_list(ii); %get URSI from excel list
            
            MEGindx = find(contains(temp_MEGdir.name, tempURSI)); %find where that URSI is in folder directory
            
            
            if ~isempty(MEGindx) %if it found a MEG (aka that person has an MEG in this protocol)
                
                for m = 1:length(MEGindx) %loop through the files (.fif, .txt)
                    tempindx = MEGindx(m);
                    temp_MEG_file = temp_MEGdir.name{tempindx}; %get that MEG file name
                    
                    %copy the MEG from Lauren's D: drive to the outdir
                    copyfile([temp_MEGdir.folder{1} '\' temp_MEG_file],temp_outdir);
                    
                end
                
            end
        end
    end
end

