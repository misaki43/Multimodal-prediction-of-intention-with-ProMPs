function [train, test] = partitionTrajectory(t, percent, percentData, refTime,varargin)
%PARTITIONTRAJECTORY allows to partition the trajectories sample for training and
%test
%INPUT:
%t: trajectories object
%percent: number of percent of the training data set; 
%or if percent==1: only one test
%percentData: number of data that will be used as "observed data" for the inference
%refTime : s_bar: the reference total number of sample for a trajectory
%varargin: use only if percent=1: you can precise the index of the trajectory test.
    ind = ceil(rand(1)*t.nbTraj);
    flag_tmp = 0;
    if(~isempty(varargin))
        for cpt=1:1:length(varargin)    
            
            if(flag_tmp ==1)
                flag_tmp =0;
                continue;
            end
            if(isnumeric(varargin{cpt}))
                ind = varargin{cpt};
            elseif(strcmp(varargin{cpt},'Interval') ==1)
                cpt = cpt+1;
                interval = varargin{cpt};
                flag_tmp =1;
            end
        end
    end
    if(~exist ('interval', 'var'))
        interval = [1:t.nbInput(1)];% [1:ceil((percentData/100)*t.totTime(ind))];
    end
if(percent==1)%want only one test 
    test{1}.y = t.y{ind};
    test{1}.yMat = t.yMat{ind};
    test{1}.totTime = t.totTime(ind);
    test{1}.alpha = refTime / test{1}.totTime;
    test{1}.partialTraj = [];
    test{1}.nbData = ceil((percentData/100)*t.totTime(ind));
    if (isfield(t, 'realTime'))
        test{1}.realTime = t.realTime{ind};
    end
    if(isfield(t, 'interval'))
        test{1}.interval = t.interval(ind);
    end
    
    for i=interval
       test{1}.partialTraj = [test{1}.partialTraj; t.yMat{ind}(1:test{1}.nbData,i)];
    end
    train.nbTraj = t.nbTraj -1;
    train.nbInput = t.nbInput;
    train.label = t.label;
    for i=1:ind-1
            train.alpha(i) = t.alpha(i);
            train.y{i} =  t.y{i};
            train.yMat{i} = t.yMat{i};
            train.totTime(i) = t.totTime(i);
            if(isfield(t, 'interval'))
                train.interval(i) = t.interval(i);
            end
            if(isfield(t, 'realTime'))
                train.realTime{i} = t.realTime{i};
            end
    
    end
    for i=ind+1:t.nbTraj
            train.alpha(i-1) = t.alpha(i);
            train.y{i-1} =  t.y{i};
            train.yMat{i-1} = t.yMat{i};
            train.totTime(i-1) = t.totTime(i);
            
            if(isfield(t, 'realTime'))
                train.realTime{i-1} = t.realTime{i};
            end
            if(isfield(t, 'interval'))
                train.interval(i-1) = t.interval(i);
            end
    end
    
else
     nbTrain = ceil((percent/100)*t.nbTraj);
     nbTest = t.nbTraj - nbTrain;
     train.nbTraj = nbTrain;
     train.nbInput = t.nbInput;
     train.label = t.label;
     list = zeros(nbTest,1);
    test = cell(nbTest,1);
    for i=1:nbTest
        ind = ceil(nbTrain*rand(1));
        while(ismember(ind, list))
            ind = nbTrain*rand(1);
        end
        list(i) = ind;
        test{i}.label = t.label;
        test{i}.nbInput = t.nbInput;
        test{i}.nbTraj = nbTest;
        test{i}.y = t.y{ind};
        test{i}.yMat = t.yMat{ind};
        test{i}.totTime = t.totTime(ind);
        test{i}.alpha = t.alpha(ind);
 %       test{i}.realTime = t.realTime(ind);
        test{i}.nbData = ceil((percentData/100)*t.totTime(ind));
        test{i}.interval = t.interval(ind);

        test{i}.partialTraj = [];
        for j=interval
            test{i}.partialTraj = [test{i}.partialTraj; t.yMat{ind}(1:test{i}.nbData,j)];
        end
    end
    cpt=1;
    for i=1:t.nbTraj
        if(~ismember(i,list))
            train.y{cpt} = t.y{i};
            train.yMat{cpt} = t.yMat{i};
            train.totTime(cpt) = t.totTime(i);
            train.alpha(cpt) = t.alpha(i);
            train.interval(cpt) = t.interval(i);
        %    train.realTime(cpt) = t.realTime(i);
            cpt = cpt+1;
        end
    end
end
     
end