%Lauren_move_files_to_new_folder_based_on_URSI_list%
%Created to move a subset of DICS NII files based on if they are an outlier per condition (URSI list)%
%Using 1 excel with multiple tabs per condition, each with different outlier lists%

%Set up for WB LME analysis

clear all
clc

%%
%Manually set folder name to move DICS NII outliers into
outlier_folder_name = 'Outlier_LME';

%%
%%% SET UP - DICS Files Directory %%%
%read in directory with the DICS file subfolders (each subfolder is a diff DICS condition...)
DICS_Dir = uigetdir('D:\SCAN_OneDotGamma\Derivatives\SourceSpace\Beamforming\Cannabis_n177\p5Hz_100ms_2-120Hz_beamform\NIIs\DICS\','Select folder with DICS NII subfolders');

cd(DICS_Dir)

parent_folders = dir(DICS_Dir);
folders_dir = [parent_folders.isdir]; %array of files that are directories within the parent folder
subfolders = parent_folders([parent_folders.isdir]);
subfolderNames = {subfolders(3:end).name};

clear DICS_Cond_Folder DICScond_folder_vector count
count = 1;
%extract each DICS condition from subfolder names
for i = 1:length(subfolderNames)
    
    DICS_Cond_Folder = subfolderNames(i);
    DICS_Cond_Folder = DICS_Cond_Folder{1};
    
    if contains(DICS_Cond_Folder, 'TEST') == 0
        DICScond_folder_vector{count} = DICS_Cond_Folder;
        count = count+1;
    end
    
end
clear i count DICS_Cond_Folder folders_dir parent_folders subfolders subfolderNames

%Have vector of the DICS condition folder names...
DICScond_folder_vector = DICScond_folder_vector';



%%
%%% SET UP - EXCEL %%%
%read in excel with the URSI list
[files_excel,path_excel] = uigetfile('*','Select the excel','Multiselect','on');
cd(path_excel)

[~,sheet_name] = xlsfinfo(fullfile(path_excel,files_excel));

% UrsiGroupList = readtable(files_excel,'Sheet',temp_cond)
% Outlier_Excel = xlsread(files_excel);

DICScond_sheet_name = sheet_name';





%%
%%% READ IN DICS FILES - THIS IS WHERE YOU START EACH TO RE-RUN SCRIPT %%%
clear files path
[files,path] = uigetfile('*','Multiselect','on');
cd(path)

clear temp_file_path
temp_file_path = string(path);


clear URSI_files URSI_vector_files
%extract all URSIs from DICS files
for i = 1:length(files)
    
    URSI_files = files(i);
    URSI_files = URSI_files{1};
    URSI_vector_files(i) = str2num(URSI_files(2:9));
    
end
clear i URSI_files unique_URSI_files unique_URSI_vector_files

%list of unique URSIs from NII files - if there were duplicates for some reason
unique_URSI_vector_files = unique(URSI_vector_files);


%%
%%% BASED ON THAT FOLDER YOU JUST READ IN, FIND IT IN THE LIST OF DICS
%%% CONDITION SUBFOLDERS, THEN FIND THE MATCHING EXCEL SHEET NAME AND GRAB
%%% THOSE OUTLIER URSIs
clear temp_Outlier_Excel temp_Outlier_URSIs

for i = 1:length(DICScond_folder_vector)
    
    clear temp_DICScond_folder
    %go through the list of DICS condition subfolders
    temp_DICScond_folder = string(DICScond_folder_vector(i));
    
    %Find the specific DICS condition subfolder name that matches the current NII path
    if contains(temp_file_path, temp_DICScond_folder) == 1
        
        
        %go through the outlier excel sheet names & find the one that
        %matches the current DICS NII subfolder
        for ii = 1:length(DICScond_sheet_name)
            clear temp_DICScond_sheet_name
            temp_DICScond_sheet_name = DICScond_sheet_name(ii);
            temp_DICScond_sheet_name = string(temp_DICScond_sheet_name);
            
            if (temp_DICScond_sheet_name == temp_DICScond_folder) == 1
                cd(path_excel)
                temp_Outlier_Excel = readtable(files_excel, 'Sheet', temp_DICScond_sheet_name);
                temp_Outlier_URSIs = temp_Outlier_Excel.URSI;
                sheet_that_got_outliers_ = temp_DICScond_sheet_name;
            end
            
        end
        
        
    end
end

sheet_that_got_outliers_
clear i ii

%You get out of this the temp_Outlier_URSIs cell with the outliers specific
%to the DICS NII file's condition (that you just selected above)

cd(path)

clear URSI_excel URSI_vector_excel
%extract all URSIs from temp excel outlier list
for i = 1:length(temp_Outlier_URSIs)
    
    URSI_excel = temp_Outlier_URSIs(i);
    URSI_excel = URSI_excel{1};
    URSI_vector_excel(i) = str2num(URSI_excel(2:9));
    
end

clear i URSI_excel temp_DICScond_folder temp_DICScond_sheet_name


%%
%%% DICScond_folder_vector = cell of DICS file subfolders (per DICS condition)
%%% DICScond_sheet_name = cell of excel sheet names (which contain outlier URSIs, per DICS condition)

%%% temp_file_path = path of the current DICS NII files you read in
%%% URSI_vector_files = double of all DICS NII file URSIs (without M68)
%%% unique_URSI_vector_files = double of all DICS NII file URSIs (without M68) - unique

%%% temp_Outlier_Excel = the excel sheet (table) based on the current DICS condition
%%% temp_Outlier_URSIs = cell of outlier URSIs from the temp excel sheet
%%% URSI_vector_excel = double of outlier URSIs (without M68) from the excel sheet


%COMPARE 'URSI_vector_excel' and 'unique_URSI_vector_files'

%loop through the list of unique DICS NII file URSIs unique_URSI_vector_files)
for i = 1:length(unique_URSI_vector_files)
    
    clear temp_unique_fileURSI_name
    temp_unique_fileURSI_name = unique_URSI_vector_files(i);
    
    %if current unique file URSI exists within the list of outliers (URSI_vector_excel)
    if nnz(temp_unique_fileURSI_name==URSI_vector_excel) == 1
%         any(temp_unique_fileURSI_name==URSI_vector_excel)
        for ii = 1:length(files)
            %get full file name as a string - prepare to move it
            clear file_name_temp
            file_name_temp = files(ii);
            file_name_temp = string(file_name_temp);
            
            %make sure you move the correct file over
            if URSI_vector_files(ii)==temp_unique_fileURSI_name
                                
                if isfolder(outlier_folder_name) == 0
                    mkdir(outlier_folder_name)
                end
                
                movefile(file_name_temp,outlier_folder_name);
                
            end
            
        end
        
        
    end
    
end


