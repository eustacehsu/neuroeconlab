

Down = -60;
Up = 70;
alpha = .5;

lamda = 1.1;

bet = 1:100;

pGain=(((Up*bet)/100).^alpha);

pLoss= lamda*((abs(Down*bet)/100)).^alpha;

U = (.5*(((Up*bet)/100).^alpha) - .5*lamda*((abs(Down*bet)/100)).^alpha);

Y = 1/100*alpha*Down*(100 + (bet*Down)/100).^(-1 + alpha) +  1/100*alpha*Up*(100 + (bet*Up)/100).^(-1 + alpha);

plot(pGain);
hold on
plot(pLoss);
plot(U);
hold off
% figure
% plot(Y);






