clearvars


cd \\bt137964\d\Brainstorm_db\DevMIND_3p0_EOR_SMU\data\

d = dir('M6*');





%%

for i = 1:length(d)
    
    cd([d(i).folder '\' d(i).name]);
    
    d2 = dir('M*_notch_band');
    
    temp = load([d2.folder '\' d2.name '\brainstormstudy.mat']);
    
    numBadTrials(i,1) = length(temp.BadTrials);
    ursi{i,1} = d(i).name;
    clear temp d2
    
    cd \\bt137964\d\Brainstorm_db\DevMIND_3p0_EOR_SMU\data\

    
end

%%
clear d
cd D:\\Brainstorm_db\DevMIND_3p0_EOR_SMU\data\

d = dir('M6*');


for i = 1:length(d)
    
    cd([d(i).folder '\' d(i).name]);
    
    d2 = dir('M*_notch_band');
    
    temp = load([d2.folder '\' d2.name '\brainstormstudy.mat']);
    
    numBadTrials2(i,1) = length(temp.BadTrials);
    ursi2{i,1} = d(i).name; 
    clear temp d2
    
cd D:\\Brainstorm_db\DevMIND_3p0_EOR_SMU\data\

    
end

t.ursi = cat(1, ursi, ursi2);
t.numBadTrials = cat(1, numBadTrials, numBadTrials2);

t = struct2table(t);



