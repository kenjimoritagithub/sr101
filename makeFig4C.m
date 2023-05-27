clear all;
rand('twister',23030601);

% input parameters
type_of_learning = 1;
IR1_ap = 0.09;
IR1_an = 0.01;
IR2_ap = 0.01;
IR2_an = 0.09;
b = 10;
n = 50000;

% fixed parameters
gm = 0.5; % time discount factor (gamma)
c = -0.01; % cost of "compulsion"
punish = -1; % punishment for stay at the obsession state
p_obs = [0.5 0.9 1 0]; % probability of transition to the obsessive state for each action

% history of state, action, reward, value, and moving-average proportion of the obsessive state
state_t = zeros(1,n+1);
act_t = zeros(1,n);
r_t = zeros(1,n);
V_t = zeros(4,n);
IR1_Q_t = zeros(4,n);
IR2_Q_t = zeros(4,n);
ma_obs = NaN(1,n);

% count of "obsession state", "abnormal reaction", "compulsion"
count_obs = 0;
count_abn = 0;
count_com = 0;

% initialization of IR1-value and IR2-value
IR1_Q = zeros(1,4);
IR2_Q = zeros(1,4);

% initial state
state_t(1) = 2;

for t = 1:n
    
    % value
    V = (IR1_Q + IR2_Q)/2;
    V_t(:,t) = V';
    IR1_Q_t(:,t) = IR1_Q';
    IR2_Q_t(:,t) = IR2_Q';
    
    % action selection
    u = rand;
    epa = zeros(1,4);
    if state_t(t) == 1
        epa(1) = exp(b*V(1));
        epa(2) = exp(b*V(2));
        count_obs = count_obs + 1;
    else
        epa(3) = exp(b*V(3));
        epa(4) = exp(b*V(4));
    end
    pa = epa/sum(epa);
    if u <= pa(1)
        act_t(t) = 1;
        r_t(t) = c;
        count_com = count_com + 1;
    elseif u <= pa(1) + pa(2)
        act_t(t) = 2;
    elseif u <= pa(1) + pa(2) + pa(3)
        act_t(t) = 3;
        count_abn = count_abn + 1;
    else
        act_t(t) = 4;
    end
    
    % state transition and punishment for stay at the obsession state
    u = rand;
    if u <= p_obs(act_t(t))
        state_t(t+1) = 1;
        if state_t(t) == 1
            r_t(t) = r_t(t) + punish;
        end
    else
        state_t(t+1) = 2;
    end
    
    % update of values
    if t >= 2
        
        % update of values
        if type_of_learning == 1 % SARSA
            RPE = r_t(t-1) + gm*V(act_t(t)) - V(act_t(t-1));
        elseif type_of_learning == 2 % Q-learning
            RPE = r_t(t-1) + gm*max(V(state_t(t)*2-[1 0])) - V(act_t(t-1));
        end
        if RPE >= 0
            IR1_Q(act_t(t-1)) = IR1_Q(act_t(t-1)) + IR1_ap*RPE;
            IR2_Q(act_t(t-1)) = IR2_Q(act_t(t-1)) + IR2_ap*RPE;
        else
            IR1_Q(act_t(t-1)) = IR1_Q(act_t(t-1)) + IR1_an*RPE;
            IR2_Q(act_t(t-1)) = IR2_Q(act_t(t-1)) + IR2_an*RPE;
        end
        
    end
    
    % moving-average proportion of the obsessive state
    if t >= 100
        ma_obs(t) = sum(2 - state_t(t-99:t))/100;
    end
    
end

% output
out.state_t = state_t;
out.act_t = act_t;
out.r_t = r_t;
out.V_t = V_t;
out.IR1_Q_t = IR1_Q_t;
out.IR2_Q_t = IR2_Q_t;
out.ma_obs = ma_obs;
out.count_obs = count_obs;
out.count_abn = count_abn;
out.count_com = count_com;

% figure
%
F = figure;
A = axes;
hold on
set(A,'PlotBoxAspectRatio',[2 1 1]);
axis([0 n 0 1]);
P = plot([1:n],out.ma_obs,'k');
set(A,'xtick',[0:10000:n],'xticklabel',[0:10000:n],'FontSize',28);
set(A,'ytick',[0:0.1:1],'yticklabel',[0:0.1:1],'FontSize',28);
print(F,'-depsc','Figure4Ctop');
%
F = figure;
A = axes;
hold on
set(A,'PlotBoxAspectRatio',[2 1 1]);
axis([0 n -100 100]);
P = plot([0 n],[0 0],'k:');
tmp_color = 'rkbg';
P = plot([1:n],out.IR1_Q_t(1,:),'r');
P = plot([1:n],out.IR2_Q_t(1,:),'b');
set(A,'xtick',[0:10000:n],'xticklabel',[0:10000:n],'FontSize',28);
set(A,'ytick',[-100:20:100],'yticklabel',[-100:20:100],'FontSize',28);
print(F,'-depsc','Figure4Cbottom');
