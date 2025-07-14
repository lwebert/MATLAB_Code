
%This script is meant to read in the *_INFO.dat file of the segmented MRIs...
%from your C: drive, and to collect the subject's URSI, study description...
%(e.g., "twilson^devcogb_50315ep"), and image date month/day/year.

%Take the output from this script (the structure "All") and compare the...
%output to the "all studies MRI mastersheet" excel to confirm the MRI's specific
%study protocol (e.g., 2.0 versus 3.0 based on the date).
%Then make an excel with a list of the MRI folder names per study protocol.

%NEXT - use the script "Copy_MRIfolder_C2HumanNeuro_StudyProtocol.m" to
%COPY (not move) the segmented MRIs based on that excel you made.

%% Read in your C: project folder
clear
close all
clc

%Select your C: drive project folder with all the segmented MRIs
% mainCdir = 'C:\Users\Public\Documents\BESA MRI\Projects';
mainCdir = uigetdir();

%Get a table of ALL the subject folders that exist under the specific MRI directory study (mainCdir)
subs = struct2table(dir(mainCdir));


%% All MRIs - MRIs that have an URSI (M68*), and MRIs that don't have an URSI (e.g., "unmc_mind_XXX")

clear i ii
p=1;
n=1;
for i = 1:height(subs)  %loop through all C: dir segmented MRI folders
    clear temppath tempdir tempfile
    %for each MRI folder, path into their Intermediate files folder
    temppath = [subs.folder{i} '\' subs.name{i} '\MRIFiles\IntermediateFiles\'];
    try cd(temppath);
        
        %create a temp directory for that person and find the # of RAW_INFO.dat files (a.k.a. the # of segmentations for that MRI)
        tempdir = struct2table(dir(temppath));
        
        tempfile = tempdir.name(contains(tempdir.name, 'RAW_INFO.dat'));
        tempfile = string(tempfile);
        
        for ii = 1:length(tempfile)
            clear temp_info tempmonth tempday tempyear
            temp_info = readtable(tempfile(ii), 'ReadVariableNames',0);
            
            All{p,1} = subs.name{i};                                                    %MRI folder name
            All{p,2} = tempfile(ii);                                                    %*RAW_INFO.dat file name
            All{p,3} = temp_info.Var2(contains(temp_info.Var1,'Patient ID')==1);        %URSI - from the info file
            All{p,4} = temp_info.Var2(contains(temp_info.Var1,'Study description')==1); %Study Protocol - from the info file
            tempmonth = string(temp_info.Var2(contains(temp_info.Var1,'Image date month')==1));
            tempday = temp_info.Var2(contains(temp_info.Var1,'Image date day')==1);
            tempyear = temp_info.Var2(contains(temp_info.Var1,'Image date year')==1);
            All{p,5} = strcat(tempmonth, '\', tempday, '\', tempyear);                  %Image date - from the info file
            
            p=p+1;
        end
    catch %If they don't have the path containing the info file - check what is going on with their segmentation individually
        no_tempdir{n} = subs.name{i};
        n=n+1;
    end
    
end


%% OPTIONAL - For M68 MRIs only (same as above, but for a subset of the C: drive segmented MRIs)

% -- UNCOMMENT (ctrl+T) EVERYTHING BELOW THIS LINE --

subsM68 = subs(contains(subs.name,'M68'),:);

clear i ii
p=1;
n=1;
for i = 1:height(subsM68)
    clear temppath tempdir tempfile
    temppath = [subsM68.folder{i} '\' subsM68.name{i} '\MRIFiles\IntermediateFiles\'];
    try cd(temppath);

        tempdir = struct2table(dir(temppath));

        tempfile = tempdir.name(contains(tempdir.name, 'RAW_INFO.dat'));
        tempfile = string(tempfile);
        for ii = 1:length(tempfile)
            clear temp_info tempmonth tempday tempyear
            temp_info = readtable(tempfile(ii), 'ReadVariableNames',0);

            All{p,1} = subsM68.name{i};
            All{p,2} = tempfile(ii);
            All{p,3} = temp_info.Var2(contains(temp_info.Var1,'Patient ID')==1);
            All{p,4} = temp_info.Var2(contains(temp_info.Var1,'Study description')==1);
            tempmonth = string(temp_info.Var2(contains(temp_info.Var1,'Image date month')==1));
            tempday = temp_info.Var2(contains(temp_info.Var1,'Image date day')==1);
            tempyear = temp_info.Var2(contains(temp_info.Var1,'Image date year')==1);
            All{p,5} = strcat(tempmonth, '/', tempday, '/', tempyear);

            p=p+1;
        end
    catch
        no_tempdir{n} = subsM68.name{i};
        n=n+1;
    end

end



%% OPTIONAL - Nonsegmented MRI files
% For M68 MRIs only

% -- UNCOMMENT (ctrl+T) EVERYTHING BELOW THIS LINE --

subsM68 = subs(contains(subs.name,'M68'),:);

clear i ii
p=1;
n=1;
for i = 1:height(subsM68)
    clear temppath tempdir tempfile
    temppath = [subsM68.folder{i} '\' subsM68.name{i} '\'];
    try cd(temppath);

        tempdir = struct2table(dir(temppath));

        tempfile = tempdir.name(contains(tempdir.name, '0001-1.dcm'));
        tempfile = string(tempfile);
        for ii = 1:length(tempfile)
            clear temp_info tempmonth tempday tempyear
            temp_info = dicominfo(tempfile(ii));

            All{p,1} = subsM68.name{i};
            All{p,2} = tempfile(ii);
            All{p,3} = temp_info.PatientID;
            All{p,4} = temp_info.StudyDescription;

            tempdate = temp_info.AcquisitionDate;
            All{p,5} = strcat(tempdate(5:6), '/', tempdate(7:end), '/', tempdate(1:4));

            p=p+1;
        end
    catch
        no_tempdir{n} = subsM68.name{i};
        n=n+1;
    end

end


%% Loop through C: drive. Save details if it is the same URSI as someone in my list.

% clear t
% t = readtable('D:\SCAN_OneDotGamma\Derivatives\Excels\General\Visentrain_SampleSizes_Demographics.xlsx', 'Sheet', 'ALL_ScanPescah_n344_compiled');
% URSIs = t.URSI;
% 
% clear i ii no_tempdir
% p=1;
% n=1;
% 
% subs = struct2table(dir(mainCdir));
% subs = subs(6:end,:);
% 
% for i = 1:height(subs)  %loop through all C: dir segmented MRI folders
%     clear temppath tempdir tempfile
%     %for each MRI folder, path into their Intermediate files folder
%     temppath = [subs.folder{i} '\' subs.name{i} '\MRIFiles\IntermediateFiles\'];
%     try cd(temppath);
%         
%         %create a temp directory for that person and find the # of RAW_INFO.dat files (a.k.a. the # of segmentations for that MRI)
%         tempdir = struct2table(dir(temppath));
%         
%         tempfile = tempdir.name(contains(tempdir.name, 'RAW_INFO.dat'));
%         tempfile = string(tempfile);
%         
%         for ii = 1:length(tempfile)
%             clear temp_info temp_MRIUrsi tempmonth tempday tempyear tempCoreg idx*
%             temp_info = readtable(tempfile(ii), 'ReadVariableNames',0);
%             
%             temp_MRIUrsi = temp_info.Var2(contains(temp_info.Var1,'Patient ID')==1);
%             temp_MRIUrsi = temp_MRIUrsi{1};
%             
%             if nnz(strcmp(temp_MRIUrsi, URSIs)) == 1
%                 
%                 All{p,1} = subs.name{i};                                                    %MRI folder name
%                 All{p,2} = tempfile(ii);                                                    %*RAW_INFO.dat file name
%                 All{p,3} = temp_MRIUrsi;                                                    %URSI - from the info file
%                 All{p,4} = temp_info.Var2(contains(temp_info.Var1,'Study description')==1); %Study Protocol - from the info file
%                 tempmonth = string(temp_info.Var2(contains(temp_info.Var1,'Image date month')==1));
%                 tempday = temp_info.Var2(contains(temp_info.Var1,'Image date day')==1);
%                 tempyear = temp_info.Var2(contains(temp_info.Var1,'Image date year')==1);
%                 All{p,5} = strcat(tempmonth, '/', tempday, '/', tempyear);                  %Image date - from the info file
%                 
%                                 CoregPath = [subs.folder{i} '\' subs.name{i} '\MRIFiles\ProjectFiles\'];
%                                 coregDir = struct2table(dir(CoregPath));
%                                 coregDir = coregDir(~coregDir.isdir, :);
%                 
%                                 tempCoreg = "";
%                                 idx1 = contains(coregDir.name, 'visentrain');
%                                 idx2 = contains(coregDir.name, 'LKW');
%                 
%                                 if any(idx1)
%                                     tempCoreg = string(coregDir.name(find(idx1, 1)));
%                                 elseif any(idx2)
%                                     tempCoreg = string(coregDir.name(find(idx2, 1)));
%                                     %                 elseif ~isempty(coregDir)
%                                     %                     tempCoreg = string(coregDir.name(1));  % fallback: take first file
%                                 else
%                                     tempCoreg = "No visentrain coregistration"; % or leave empty
%                                 end
%                 
%                             All{p,6} = tempCoreg;
%                 
%                 
%                 p=p+1;
%             end
%         end
%     catch %If they don't have the path containing the info file - check what is going on with their segmentation individually
%         no_tempdir{n} = subs.name{i};
%         n=n+1;
%     end
%     
% end

