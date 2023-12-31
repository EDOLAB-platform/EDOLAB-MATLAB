%********************************ImQSO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: October 2, 2022
%
% ------------
% Reference:
% ------------
%
%  Javidan Kazemi Kordestani et al.,
%            "A note on the exclusion operator in multi-swarm PSO algorithms for dynamic environments"
%            Connection Science, pp. 1�25, 2019.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = ChangeReaction_ImQSO(Optimizer,Problem)
%% Updating Shift Severity
dummy = NaN(Optimizer.SwarmNumber,Problem.EnvironmentNumber);
for jj=1 : Optimizer.SwarmNumber
    if sum(isnan(Optimizer.pop(jj).Gbest_past_environment))==0
        Optimizer.pop(jj).Shifts = [Optimizer.pop(jj).Shifts , pdist2(Optimizer.pop(jj).Gbest_past_environment,Optimizer.pop(jj).BestPosition)];
    end
    dummy(jj,1:length(Optimizer.pop(jj).Shifts)) = Optimizer.pop(jj).Shifts;
end
dummy = dummy(~isnan(dummy(:)));
if ~isempty(dummy)
    Optimizer.ShiftSeverity = mean(dummy);
end
Optimizer.QuantumRadius = Optimizer.ShiftSeverity;
%% Updating memory
for jj=1 : Optimizer.SwarmNumber
    [Optimizer.pop(jj).PbestValue,Problem] = fitness(Optimizer.pop(jj).PbestPosition , Problem);
    Optimizer.pop(jj).Gbest_past_environment = Optimizer.pop(jj).BestPosition;
    [Optimizer.pop(jj).BestValue,BestPbestID] = max(Optimizer.pop(jj).PbestValue);
    Optimizer.pop(jj).BestPosition = Optimizer.pop(jj).PbestPosition(BestPbestID,:);
    Optimizer.pop(jj).IsConverged = 0;
end
end