function [ error ] = OptimalProspectGainandLoss(Up,Down,Bet,alpha,lamda)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% 
% upside = (Up.*Bet)/100 + 100;
% 
% downside=(Down.*Bet)/100 + 100;

% utilityFunc = .5*((upside).^alpha) + .5*((downside).^alpha);

for i = 1:length(Up)
    %% Utility Function 2
    % upside = (Up.*Bet)/100;
    % downside=(Down.*Bet)/100;
    % utilityFunc = .5*((upside).^alpha) - .5*((abs(downside)).^alpha);
    bet = fminbnd(@(Obet)-(.5*(((Up(i)*Obet)/100).^alpha) - .5*lamda*((abs(Down(i)*Obet)/100)).^alpha),0,100);
    
    optimalBet(i) = bet;
end

error = sum(abs(Bet-optimalBet'));

end

