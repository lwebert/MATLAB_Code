clear
close all
clc

%set up directory folders
maindir_MRI = 'D:\DevMIND_EOR_Longitudinal\MRIs\4\';
newDdir_MRI = 'D:\DevMIND_EOR_Longitudinal\MRIs\Drake\';

maindir_MEG = 'D:\DevMIND_EOR_Longitudinal\FIFs\4\';
newDdir_MEG = 'D:\DevMIND_EOR_Longitudinal\FIFs\Lauren\';

%Get table of the subject folders "M68" that exist under the specific file directory study (maindir)
subs_MRI = struct2table(dir(maindir_MRI));
subs_MRI = subs_MRI(contains(subs_MRI.name,'M68'),:); %only include directories that start with M68

subs_MEG = struct2table(dir(maindir_MEG));
subs_MEG = subs_MEG(subs_MEG.isdir == 0,:); %only include files, not directories

%select excel with list of URSIs
[files_excel,path_excel] = uigetfile('*','Select the excel the list of URSIs','Multiselect','on');
cd(path_excel)

sublist = readtable(files_excel, 'Sheet', 'Drake');
sublist = sublist.URSI;


%% Copy over MRIs - better code, use this
clear i
cd(maindir_MRI)

Waitbar = waitbar(0,['Looping through MRI directory']);


%loop through the MRI subject folder names
for i = 1:length(sublist)
    waitbar(i/length(sublist));
    
    if any(contains(subs_MRI.name, sublist{i})) %Check if that subject folder name exists in the sublist of URSIs
        %Go into that person's MRI/MEG folder, and see how many study files exist (how many MRIs they got)
        clear temp_studyfile temp_studyfile_name temp_studyfile_protocol outdir n
        n = find(contains(subs_MRI.name, sublist{i}));

        temp_studyfile = subs_MRI.name{n};
        temp_studyfile_name = subs_MRI.name{n}(1:9);
        temp_studyfile_protocol = subs_MRI.folder{n}(end);
        
        outdir = [newDdir_MRI temp_studyfile_name '_' temp_studyfile_protocol];
        if ~exist(outdir)
            mkdir(outdir);
        end
        
        status = copyfile(temp_studyfile, outdir);
        
    end
end

delete(Waitbar);


%%

%% Copy over MRIs - SLOW...
clear i
cd(maindir_MRI)

Waitbar = waitbar(0,['Looping through MRI directory']);
%loop through the MRI subject folder names
for i = 1:height(subs_MRI)
    waitbar(i/height(subs_MRI));
    
    if any(contains(sublist, subs_MRI.name{i}(1:9))) %Check if that subject folder name exists in the sublist of URSIs
        %Go into that person's MRI/MEG folder, and see how many study files exist (how many MRIs they got)
        clear temp_studyfile temp_studyfile_name temp_studyfile_protocol outdir

        temp_studyfile = subs_MRI.name{i};
        temp_studyfile_name = subs_MRI.name{i}(1:9);
        temp_studyfile_protocol = subs_MRI.folder{i}(end);
        
        outdir = [newDdir_MRI temp_studyfile_name '_' temp_studyfile_protocol];
        if ~exist(outdir)
            mkdir(outdir);
        end
        
        status = copyfile(temp_studyfile, outdir);
        
    end
end

delete(Waitbar);


%% Copy over MEGs
clear i
cd(maindir_MEG)

Waitbar = waitbar(0,['Looping through MEG files']);
%loop through the MRI subject folder names
for i = 1:height(subs_MEG)
    waitbar(i/height(subs_MEG));
    
    if any(contains(sublist, subs_MEG.name{i}(1:9))) %Check if that subject folder name exists in the sublist of URSIs
        %Go into that person's MRI/MEG folder, and see how many study files exist (how many MRIs they got)
        clear temp_studyfile temp_studyfile_name temp_studyfile_protocol outdir
        
        temp_studyfile = subs_MEG.name{i};
        temp_studyfile_name = subs_MEG.name{i}(1:9);
        temp_studyfile_protocol = subs_MEG.folder{i}(end);
        
        outdir = [newDdir_MEG temp_studyfile_protocol];
        if ~exist(outdir)
            mkdir(outdir);
        end
        
        status = copyfile(temp_studyfile, outdir);
        
    end
end

delete(Waitbar);



