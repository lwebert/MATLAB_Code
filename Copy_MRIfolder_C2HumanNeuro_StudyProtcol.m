
%This script is meant to COPY (not move) the segmented MRIs from your C:
%drive project folder to your human neuro folder. It reads in lists of the
%MRI folder names from an excel (you have to make)

%FIRST - Use the script "MRIs_Cdrive_Organization.m" to collect the MRI's URSI,
%image date, and study protocol description. Compare that info to the MRI
%mastersheet excel, and create an excel with a list of the MRI folder names per
%study procol (each protocol has its own tab).
%   Example excel "FinalLists_SegMRIs_C2HumanNeuro.xlsx"



%% read in excel with the MRI folder names per study/protocol
clear
close all
clc

[files_excel,path_excel] = uigetfile('*','Select the excel','Multiselect','on');
cd(path_excel);

[~,sheet_name] = xlsfinfo(fullfile(path_excel,files_excel));
StudyProtocol_sheet_name = sheet_name';


%% set up Directories

%C: dir - read in MRI folders
Cdir_MRI = 'C:\Users\Public\Documents\BESA MRI\Projects';
cd(Cdir_MRI);

Cdir = struct2table(dir(Cdir_MRI));
Cdir = Cdir(Cdir.isdir == 1, :);
Cdir = Cdir(~contains(Cdir.name, '.'),:);


%Human Neuro folder where you'll be copying those MRIs
HNeurodir_MRI = '\\btusa.boystown.org\btnrh\HumanNeuroscience\MRI_Database\DICoN Lab\BESA Segmented\Lauren';
HNeurodir = struct2table(dir(HNeurodir_MRI));
HNeurodir = HNeurodir(HNeurodir.isdir == 1, :);
HNeurodir = HNeurodir(~contains(HNeurodir.name, '.'),:);


%%

for i = 1:length(StudyProtocol_sheet_name)   %loop through each excel tab
    clear temp_study_sheet temp_t MRIFolderNames_excel
    temp_study_sheet = StudyProtocol_sheet_name{i};
    
    %read in that excel tab & the MRI folder names
    temp_t = readtable([path_excel files_excel], 'Sheet', temp_study_sheet);
    MRIFolderNames_excel = unique(temp_t.C_Folder);
    
    for ii = 1:length(HNeurodir.name)   %loop through HN subfolders ...
        clear temp_HNfolder
        temp_HNfolder = HNeurodir.name{ii};
        
        if strcmp(temp_study_sheet, temp_HNfolder) == 1     %... to find the same study/protocol as the current excel tab
            outdir = [HNeurodir.folder{ii} '\' temp_HNfolder];
            
            Waitbar = waitbar(0,['Looping through MRI folders in ' temp_study_sheet]);
            
            for iii = 1:length(MRIFolderNames_excel)    %loop through each MRI folder name (from the excel) to be copied
                waitbar(iii/length(MRIFolderNames_excel));
                clear temp_MRIfolder n temp_copyfileC 
                
                temp_MRIfolder = MRIFolderNames_excel{iii};
                
                %... find the same MRI folder name in the C drive...
                n = find(strcmp(Cdir.name,temp_MRIfolder)==1);
                temp_copyfileC = [Cdir.folder{n} '\' Cdir.name{n}];
                
                if ~exist([outdir '\' temp_MRIfolder])
                    %... and copy it to the correct HN subfolder
                    copyfile(temp_copyfileC, [outdir '\' temp_MRIfolder]);
                end
                
            end
            delete(Waitbar);
        else
            %HN folder doesn't match the current excel tab you are on. Check the next HN folder.
        end
    end
end

