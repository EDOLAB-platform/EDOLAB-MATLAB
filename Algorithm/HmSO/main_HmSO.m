%*********************************HmSO*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Nov 7, 2021
%
% ------------
% Reference:
% ------------
%
%  M. Kamosi, A. B. Hashemi, and M. R. Meybodi, 
%  "A hibernating multi-swarm optimization algorithm for dynamic environments," 
%  in Proc. World Congr. Nat. Biol. Inspir. Comput. (NaBIC), Fukuoka, Japan, 2010, pp. 363-369.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Problem,E_bbc,E_o,CurrentError,VisualizationInfo,Iteration] = main_HmSO(VisualizationOverOptimization,PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,RunNumber,BenchmarkName)
BestErrorBeforeChange = NaN(1,RunNumber);
OfflineError = NaN(1,RunNumber);
CurrentError = NaN (RunNumber,ChangeFrequency*EnvironmentNumber);
for RunCounter=1 : RunNumber
    if VisualizationOverOptimization ~= 1
        rng(RunCounter);%This random seed setting is used to initialize the Problem
    end
    Problem = BenchmarkGenerator(PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,BenchmarkName);
    rng('shuffle');%Set a random seed for the optimizer
    %% Initialiing Optimizer
    clear Optimizer;
    Optimizer.Dimension = Problem.Dimension;
%     Optimizer.initPopulationSize = 100;
    Optimizer.ParentSize = 5;
    Optimizer.ChildSize = 10;
    Optimizer.Rpc = 10;
    Optimizer.Rexcl = 10;
    Optimizer.Rconv = 0.01;
    Optimizer.Rsearch = 0.5;
    Optimizer.Margin = 5;
    Optimizer.MaxCoordinate = Problem.MaxCoordinate;
    Optimizer.MinCoordinate = Problem.MinCoordinate;
    Optimizer.w = 0.729844;
    Optimizer.c1 = 2.05;
    Optimizer.c2 = 2.05;
    Optimizer.ShiftSeverity = 1;%initial shift severity
    Optimizer.SwarmNumber = 0;
%     [Optimizer.ParentPop,Problem] = SubPopulationGeneratorParent_HmSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.ParentSize,Problem);
    [Optimizer,Problem] = SubPopulationGenerator_HmSO(Optimizer,Problem,'parent');
    Optimizer.ChildPop = [];
    Optimizer.pop = [Optimizer.ParentPop;Optimizer.ChildPop];
    Optimizer.PreGbestValue = Optimizer.ParentPop.GbestValue;
    Optimizer.CurGbestValue = Optimizer.ParentPop.GbestValue;
%     [Optimizer.ChildPop,Problem] = InitializingChild_HmSO_MPB(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.ParentSize,Optimizer.ChildSize,Optimizer.ParentPop,Optimizer.Rpc,Problem);
%     Optimizer.ChildNumber = length(Optimizer.ChildPop);
    VisualizationFlag=0;
    Iteration=0;
    if VisualizationOverOptimization==1
        VisualizationInfo = cell(1,Problem.MaxEvals);
    else
        VisualizationInfo = [];
    end
    %% main loop
    while 1
        Iteration = Iteration + 1;
        %% Visualization for education module
        if (VisualizationOverOptimization==1 && Dimension == 2)
            if VisualizationFlag==0
                VisualizationFlag=1;
                T = Problem.MinCoordinate : ( Problem.MaxCoordinate-Problem.MinCoordinate)/100 :  Problem.MaxCoordinate;
                L=length(T);
                F=zeros(L);
                for i=1:L
                    for j=1:L
                        F(i,j) = EnvironmentVisualization([T(i), T(j)],Problem);
                    end
                end
            end
            VisualizationInfo{Iteration}.T=T;
            VisualizationInfo{Iteration}.F=F;
            VisualizationInfo{Iteration}.Problem.PeakVisibility = Problem.PeakVisibility(Problem.Environmentcounter,:);
            VisualizationInfo{Iteration}.Problem.OptimumID = Problem.OptimumID(Problem.Environmentcounter);
            VisualizationInfo{Iteration}.Problem.PeaksPosition = Problem.PeaksPosition(:,:,Problem.Environmentcounter);
            VisualizationInfo{Iteration}.CurrentEnvironment = Problem.Environmentcounter;
            counter = 0;
            for ii=1 : length(Optimizer.pop)
                for jj=1 :size(Optimizer.pop(ii).X,1)
                    counter = counter + 1;
                    VisualizationInfo{Iteration}.Individuals(counter,:) = Optimizer.pop(ii).X(jj,:);
                end
            end
            VisualizationInfo{Iteration}.IndividualNumber = counter;
            VisualizationInfo{Iteration}.FE = Problem.FE;
        end
        %% Optimization
        [Optimizer,Problem] = IterativeComponents_HmSO(Optimizer,Problem);
        if Problem.RecentChange == 1%When an environmental change has happened
            Problem.RecentChange = 0;
            [Optimizer,Problem] = ChangeReaction_HmSO(Optimizer,Problem);
            VisualizationFlag = 0;
            clc; disp(['Run number: ',num2str(RunCounter),'   Environment number: ',num2str(Problem.Environmentcounter)]);
        end
        if  Problem.FE >= Problem.MaxEvals%When termination criteria has been met
            break;
        end
    end
    %% Performance indicator calculation
    BestErrorBeforeChange(1,RunCounter) = mean(Problem.Ebbc);
    OfflineError(1,RunCounter) = mean(Problem.CurrentError);
    CurrentError(RunCounter,:) = Problem.CurrentError;
end
%% Output preparation
E_bbc.mean = mean(BestErrorBeforeChange);
E_bbc.median = median(BestErrorBeforeChange);
E_bbc.StdErr = std(BestErrorBeforeChange)/sqrt(RunNumber);
E_bbc.AllResults = BestErrorBeforeChange;
E_o.mean = mean(OfflineError);
E_o.median = median(OfflineError);
E_o.StdErr = std(OfflineError)/sqrt(RunNumber);
E_o.AllResults =OfflineError;
if VisualizationOverOptimization==1
    tmp = cell(1, Iteration);
    for ii=1 : Iteration
        tmp{ii} = VisualizationInfo{ii};
    end
    VisualizationInfo = tmp;
end