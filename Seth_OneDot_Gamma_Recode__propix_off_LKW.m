function Seth_OneDot_Gamma_Recode__propix_off_LKW

%PURPOSE:           Recode triggers for SCAN 2.0 one-dot gamma (also called visentrain) (PESCAH and SCAN) who didn't have a propix turned on.
%
%REQUIRED INPUTS:   EVT files for recoding triggers.
%
%
%
%NOTES:             Whenever you are writing recodes for these entrainment tasks with a propixx dot,
%                   there are several trigger sequences that you have to prepare for (example trigger = 20):
%                   1. 20 followed by 20+4096 (the 20+4096 is the propixx dot, lock to this) - MOST COMMON
%                   2. Only 20+4096
%                   3. 20+4096 followed by 20+4096 - UNCOMMON, MOST DANGEROUS; Only lock to the second 20+4096
%
%
%AUTHOR:            (original) Seth D. Springer, DICoN Lab, Boys Town National Research Hospital
%                   (edited by) Lauren K. Webert, DICoN Lab, BTNRH
%VERSION HISTORY:   12/08/2023  v2: Fixed fatal flaws with v1.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%-Recoded Trigger Legend-%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ORIGINAL TRIGGERS:
% 31 - 32Hz
% 33 - 40Hz
% 35 - 48Hz
% 37 - Oddball
%
%
%RECODED TRIGGERS:
% 20 - 32Hz
% 21 - 40Hz
% 22 - 48Hz
% 23 - Oddball
%

[files,path,~] = uigetfile('*.evt','Please Select EVTs','Multiselect','on');        %select evt files%
evt_header = 'Tmu         Code     TriNo';                                         %create header for evt files%
cd(path);



%SD cutoff for subject-wise RT culling
inputs = {'SD Cutoff'};
defaults = {'2.5'};
answer = inputdlg(inputs, 'What SD Cutoff should be used for RT outlier exclusions', 2, defaults, 'on');
sd_cutoff = str2double(answer);


if isnan(sd_cutoff)
    error("You suck, enter a number...")
end


%Ensure that the variable "files" is a cell (it only isn't if you read in only one subject
if ~iscell(files)
    files = {files};
end


%set # of interactions based on # of EVTs read in
iter = size(files,2);


%Creating the output .csv
DefaultName = 'Gamma_Entrainment_Data';
[FileName,PathName,~] = uiputfile('*.csv','Please select path for output behavioral file',DefaultName);



output_table = [];

disp('Processing...');

progress_bar = waitbar(0,'Performing Calculations...');



for i = 1:iter                        %loop throught participants
    
    waitbar(i/iter)
    
    cd(path);
    
    %read evt data for file i%
    data = readBESAevt(files{i});
    %Separate the triggers and time into vectors that are easier to work on
    triggers = data(:,3);
    time = data(:,1);
    
    
    %Delete nonsense triggers 12303 and 12302 from data%
    %time(triggers==4096) = [];
    %triggers(triggers==4096) = [];
    
    trial_counter_cond1 = 0;
    trial_counter_cond2 = 0;
    trial_counter_cond3 = 0;
    trial_counter_cond4 = 0;
    trial_counter_cond5 = 0;
    
    %RT array
    RT = nan(24,1); %24 possible correct oddball trials
    RT_index = 0;
    
    %Loop through the EVT again (stop two from the end, otherwise EVTs ending with fixation codes [12297 or 12298] will have indexing issues)
    for ii = 1:length(triggers)
        %Cond1 - 32Hz
        if triggers(ii) == 31
            
            triggers(ii) = 20;
            trial_counter_cond1 = trial_counter_cond1+1;
            
            
            %Cond2 -  40Hz
        elseif triggers(ii) == 33
            
            triggers(ii) = 21;
            trial_counter_cond2 = trial_counter_cond2+1;
            
            
            %Cond3 - 48Hz
        elseif triggers(ii) == 35
            
            triggers(ii) = 22;
            trial_counter_cond3 = trial_counter_cond3+1;
            
            
            %Cond4 - Oddball
        elseif triggers(ii) == 37
            
            
            
            triggers(ii) = 23;
            trial_counter_cond4 = trial_counter_cond4+1;
            
            
            
        end %end of ifs and elseifs
    end %end of for loop for the EVTs
    
    
    %Need to reloop through the EVT for the responses, because you need to
    %find the oddball response and insert a "propix trigger" ~1.5 seconds after the
    %previous trigger
    for ii = 1:length(triggers)
        %Cond5 - Response
        if triggers(ii) == 23
            
            for neg_i = 1:3
                
                backwords_looking_index = ii-neg_i;
                
                if triggers(backwords_looking_index) >= 20 && triggers(backwords_looking_index) <= 22
                    
                    for iii = 1:3
                        
                        if triggers(backwords_looking_index+iii) == 256 %now we found the last trial and the response
                            
                            RT_index = RT_index + 1;
                            
                            if RT_index == 25
                                error('The code has counted more RT values than there should be, please look into this')
                            end
                            
                            
                            RT(RT_index,1) = (time(backwords_looking_index+iii)-time(backwords_looking_index))/1000;
                            
                            RT(RT_index,1) = RT(RT_index,1) - 1500; %accounting for the previous trial length
                            
                            break
                            
                        end
                        
                    end
                    
                    break
                    
                end
                
            end
            
            
        end
    end
    

    
    %Counting the number of total button presses
    total_motor = nnz(triggers==256);
    
    
    %Removing extra RTs (since we preallocated)
    RT(isnan(RT)) = [];
    
    %remove RT values if they are outliers for the subject
    RT_mean = mean(RT);
    RT_SD   = std(RT);
    
    RT_upper_cutoff = RT_mean+sd_cutoff*RT_SD;
    RT_lower_cutoff = RT_mean-sd_cutoff*RT_SD;
    
    RT_OE = RT(RT<RT_upper_cutoff & RT>RT_lower_cutoff);
    
    RT_mean_all(i) = RT_mean;
    RT_mean_OE(i)  = mean(RT_OE);
    
    percent_oddball_correct = length(RT)/24;
    
    
    
     
    cd(PathName);
    
    headers = {'ParID' 'number_32Hz_trials' 'number_40Hz_trials' 'number_48Hz_trials' 'number_Oddball_trials'...
        'number_correct_responses' 'total_responses' 'percent_correct' 'RT_mean_all' 'RT_mean_OE'...
        %'number_correct_responses_with_slow' 'percent_correct_with_slow' 'RT_mean_all_with_slow' 'RT_mean_OE_with_slow'
        };
    
    output_table = vertcat(output_table,...
        horzcat(files{i}(1,1:9), ...
        num2cell([trial_counter_cond1 ...
        trial_counter_cond2 ...
        trial_counter_cond3 ...
        trial_counter_cond4 ...
        length(RT) ...
        total_motor ...
        percent_oddball_correct ...
        RT_mean_all(i) ...
        RT_mean_OE(i) ...
        %length(RT_with_slow) ...
        %percent_oddball_correct_with_slow ...
        %RT_mean_all_with_slow(i) ...
        %RT_mean_OE_with_slow(i)
        ])));
    
    writetable(cell2table(output_table, 'VariableNames', headers), fullfile(PathName, FileName));
    
    %Writing new EVT file
    evt_info = [time,ones(size(time,1),1),triggers];
    filename = strcat(files{i}(1,1:end-4),'_recoded.evt');
    fid = fopen(filename,'wt');
    fprintf(fid,'%s\n',evt_header);
    fclose(fid);
    dlmwrite(filename,evt_info,'delimiter','\t','-append','precision','%.0f');
    
end %end of subject for loop

close(progress_bar)


fprintf('\nDone!\n\n')


end %end of function
