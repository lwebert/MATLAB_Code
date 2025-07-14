%Script made for MAMMOA/ASTART HIV Cannabis Motor Flanker project to find
%all of my participant text files and read the date.

clear
close all
clc

%%

mainFIFdir = uigetdir('D:\', 'Select the directory with all of your participant FIF files');
subs = struct2table(dir(mainFIFdir));
subs = subs(3:end, :);


fileList = table2array(readtable('D:\Flanker_HIV_Cannabis\Codes\FileList_HIVCannabis.txt','ReadVariableNames',false));


%%
clear i

t = [];

for i = 1:length(fileList)
    clear idIndx fifIndx
    
    
    idIndx = strfind(fileList{i},'Files\') + 6;
    t.id{i,1} = fileList{i}(idIndx:(idIndx+3));
    
    
    fifIndx = strfind(fileList{i},string(t.id{i}));
    t.fif{i,1} = fileList{i}(fifIndx(2):end);
end


%%

cd(mainFIFdir)

clear i outlier o p

outlier = [];
o = 1;
p=1;

for i = 1:height(subs)
    
    if ismember(subs.name(i), t.id)
        clear temp*
        
        temppath = [subs.folder{i} '\' subs.name{i}];
        
        cd(temppath)
        tempdir = struct2table(dir(temppath));
        
        tempLogFile = tempdir.name(contains(tempdir.name, '_logfile.txt'));
        tempLogFile = string(tempLogFile);
        
        
        temp_info = readtable(tempLogFile, 'ReadVariableNames',0);
        
        tempDate = temp_info.Var1(contains(temp_info.Var1,'Date:')==1);
        tempDate = strrep(tempDate, 'Date: ', '');
        tempDate = datetime(tempDate, 'InputFormat', 'eee MMM dd HH:mm:ss yyyy');
        tempDate = datestr(tempDate, 'mm/dd/yyyy');
        
        t.logFile{p,1} = tempLogFile;
        t.date{p,1} = tempDate;
        
        p = p+1;
    else
        outlier{o} = subs.name{i};
        o = o+1;
    end
end


t2 = struct2table(t);

writetable(t2, 'D:\Flanker_HIV_Cannabis\Codes\FileDates_Year.xlsx');
