function his = df2(lr,b,g,decay_rate,plot_yn)

% actions
% 1: immediate reward 40
% 2: immediate reward 10
% 3: immediate punishment -10
% 4: immeidate punishment -40
% 5: delayed reward 40
% 6: delayed reward 10
% 7: delayed punishment -10
% 8: delayed punishment -40
%
% states
% 1: total feedback 80
% 2: total feedback 50 or 40 or 30
% 3: total feedback 20 or 10
% 4: total feedback 0
% 5: total feedback -10 or -20
% 6: total feedback -30 or -40 or -50
% 7: total feedback -80

%
SSallstates = [1 2; 5 6; 3 4; 7 8; 2 5; 3 8; 1 5; 2 6; 3 7; 4 8; 1 6; 4 7; 2 3; 1 4; 6 7; 5 8];

% presented pairs of stimuli
tmp1 = [
    ones(10,1)*[1 2];
    ones(10,1)*[5 6];
    ones(10,1)*[3 4];
    ones(10,1)*[7 8];
    ones(10,1)*[2 5];
    ones(10,1)*[3 8];
    ones(5,1)*[1 5];
    ones(5,1)*[2 6];
    ones(5,1)*[3 7];
    ones(5,1)*[4 8];
    ones(5,1)*[1 6];
    ones(5,1)*[4 7];
    ones(5,1)*[2 3];
    ones(5,1)*[1 4];
    ones(5,1)*[6 7];
    ones(5,1)*[5 8]];
stimseq = [
    tmp1(randperm(110),:);
    tmp1(randperm(110),:);
    tmp1(randperm(110),:);
    tmp1(randperm(110),:);
    tmp1(randperm(110),:);
    tmp1(randperm(110),:)];
n = size(stimseq,1);

% immediate and delayed feedback for each stimulus
Rim = [40 10 -10 -40 0 0 0 0]';
Rde = [0 0 0 0 40 10 -10 -40]';

% histories of variables to save, initialization
his.a = NaN(1,n);
his.r = NaN(1,n);
hist.rewstate = NaN(1,n);
his.rim = NaN(1,n);
his.rde = NaN(1,n);
his.rpe = NaN(1,n);
his.Qir = NaN(8,n);
his.Qsr = NaN(8,n);
his.Qint = NaN(8,n);
his.w = NaN(7,n);
his.M = NaN(8,7,n);
his.SSs = NaN(1,n);
his.SSa = NaN(1,n);

% initialization of variables
Qir = zeros(8,1);
M = zeros(8,7);
w = zeros(7,1);
action_trace = zeros(8,1);

% initialization of figure
if plot_yn
    F = figure;
    A = axes;
    hold on;
    axis([0.5 8.5 0.5 7.5]);
    P = image(M*30);
end

% main loop
for k = 1:n
    
    % values
    Qsr = M * w;
    Qint = (Qir + Qsr)/2;
    his.M(:,:,k) = M;
    his.w(:,k) = w;
    his.Qir(:,k) = Qir;
    his.Qsr(:,k) = Qsr;
    his.Qint(:,k) = Qint;
    
    % stimulus presentation and action selection
    presented = stimseq(k,:);
    SSs = find(sum(ones(16,1)*presented == SSallstates, 2) == 2);
    his.SSs(k) = SSs;
    tmp_prob = exp(b*Qint(presented(1))) / sum(exp(b*Qint(presented)));
    tmp_rand = rand;
    if tmp_rand <= tmp_prob
        a = presented(1);
        SSa = 2*SSs - 1;
    else
        a = presented(2);
        SSa = 2*SSs;
    end
    his.a(k) = a;
    his.SSa(k) = SSa;
    action_trace = g * action_trace;
    action_trace(a) = action_trace(a) + 1;
    
    % feedback
    r = Rim(a);
    his.rim(k) = r;
    his.rde(k) = 0;
    if k >= 4
        r = r + Rde(his.a(k-3));
        his.rde(k) = Rde(his.a(k-3));
    end
    his.r(k) = r;
    his.rewstate(k) = find(r>=[80 30 10 0 -20 -50 -80],1,'first');
    
    % RPE and update of value/weight/SR
    rpe = his.r(k) - Qint(his.a(k));
    his.rpe(k) = rpe;
    if rpe >= 0
        w = w + lr(1)*M(his.a(k),:)'*rpe;
        Qir(his.a(k)) = Qir(his.a(k)) + lr(3)*rpe;
    else
        w = w + lr(2)*M(his.a(k),:)'*rpe;
        Qir(his.a(k)) = Qir(his.a(k)) + lr(4)*rpe;
    end
    M(:,his.rewstate(k)) = action_trace;
    
    % decay of value/weight
    Qir = Qir * (1 - decay_rate);
    w = w * (1 - decay_rate);
    
    % image of SR matrix
    if plot_yn
        hold off;
        P = image(his.M(:,:,k)*30);
        hold on;
        drawnow;
    end
    
end
