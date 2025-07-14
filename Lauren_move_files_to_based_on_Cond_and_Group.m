%Lauren_move_files_based_on_Cond_and_Group%
%Created to move a subset of DICS NII files based on their participant group
%(URSI list) and entrainment condition (32, 40, 48Hz)%

clear all
clc

%%
%%% SET UP - EXCEL %%%
%read in excel with the URSI list
[files_excel,path_excel] = uigetfile('*','Select the excel with group status','Multiselect','on');
cd(path_excel)

GroupURSIList = readtable(files_excel);


%%
%%% SET UP - read through excel & make lists based on group label %%%

GroupLabel = GroupURSIList.Group_Label;

uniqueGroupLabel = unique(GroupLabel);

clear i list_group_names temp
for i = 1:length(uniqueGroupLabel)
    
    temp = GroupURSIList.URSI(strcmp(GroupURSIList.Group_Label, uniqueGroupLabel{i}));
    eval([uniqueGroupLabel{i} '_List = temp; '])
    
    clear temp
    
end

clear i


%%
%%% Read in files to move -- Start here each time!! %%%

%read in files
clear files path
[files,path] = uigetfile('*','Select files to be moved','Multiselect','on');
cd(path)

clear URSI_files
%extract all URSIs from files
for i = 1:length(files)
    
    URSI_files = files(i);
    URSI_files = URSI_files{1};
    URSI_vector_files(i) = str2num(URSI_files(2:9));
    
end
clear i URSI_files

%list of unique URSIs from NII files - if there were duplicates (i.e., multiple entrainment conditions)
unique_URSI_files = unique(URSI_vector_files);


%%
%%%  %%%
cd(path)

clear i
%read through each unique file ursi
for i = 1:length(unique_URSI_files)
    
    clear UniqueFileURSItemp
    UniqueFileURSItemp = unique_URSI_files(i);
    
    for ii = 1:length(uniqueGroupLabel)
        
        clear temp temp_folder_32 temp_folder_40 temp_folder_48
        
        eval([' temp = ' uniqueGroupLabel{ii} '_List;']);
        
        temp_folder_32 = dir([path '\*' uniqueGroupLabel{ii}(9:end) '*32*']);
        temp_folder_32 = [temp_folder_32.folder '\' temp_folder_32.name];

        temp_folder_40 = dir([path '\*' uniqueGroupLabel{ii}(9:end) '*40*']);
        temp_folder_40 = [temp_folder_40.folder '\' temp_folder_40.name];
        
        temp_folder_48 = dir([path '\*' uniqueGroupLabel{ii}(9:end) '*48*']);
        temp_folder_48 = [temp_folder_48.folder '\' temp_folder_48.name];
        
        %check that list (aka group) contains the temp ursi
        if any(contains(temp, num2str(UniqueFileURSItemp)))
            
            for iii = 1:length(files)
                %get full file name as a string - check what condition it is & prepare to move it
                clear file_name_temp
                file_name_temp = files(iii);
                file_name_temp = string(file_name_temp);
                
                %Make sure that full file name contains the correct URSI
                if any(contains(file_name_temp, num2str(UniqueFileURSItemp)))
                    
                    %check what condition that file is & move it
                    if contains(file_name_temp, "Low32") == 1
                        movefile(file_name_temp,temp_folder_32);
                        
                    elseif contains(file_name_temp, "Mid40") == 1
                        movefile(file_name_temp,temp_folder_40);
                        
                    elseif contains(file_name_temp, "High48") == 1
                        movefile(file_name_temp,temp_folder_48);
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end


