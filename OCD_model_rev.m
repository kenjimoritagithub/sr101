function out = OCD_model_rev(type_of_learning,SR_ap,SR_an,IR_ap,IR_an,b,n)

% state: 1:obsessive, 2:relief
% action: 1;compulsion, 2:other@obsessive, 3:abnormal reaction 4:other@relief

% fixed parameters
gm = 0.5; % time discount factor (gamma)
M_a = 0.01; % learning rate for SR features
c = -0.01; % cost of "compulsion"
punish = -1; % punishment for stay at the obsession state
p_obs = [0.5 0.9 1 0]; % probability of transition to the obsessive state for each action

% history of state, action, reward, value, SR-matrix, and moving-average proportion of the obsessive state
state_t = zeros(1,n+1);
act_t = zeros(1,n);
r_t = zeros(1,n);
V_t = zeros(4,n);
IR_Q_t = zeros(4,n);
w_t = zeros(4,n);
M_t = NaN(4,4,n);
ma_obs = NaN(1,n);

% count of "obsession state", "abnormal reaction", "compulsion"
count_obs = 0;
count_abn = 0;
count_com = 0;

% initialization of IR-value, SR-weight, and SR matrix
IR_Q = zeros(1,4);
w = zeros(1,4);
SR_M  = eye(4);

% initial state
state_t(1) = 2;

for t = 1:n
    
    % value
    SR_Q = (SR_M * w')';
    V = (SR_Q + IR_Q)/2;
    V_t(:,t) = V';
    IR_Q_t(:,t) = IR_Q';
    w_t(:,t) = w';
    
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
    
    % update of value/weight and SR matrix
    if t >= 2
        
        % update of value/weight
        if type_of_learning == 1 % SARSA
            RPE = r_t(t-1) + gm*V(act_t(t)) - V(act_t(t-1));
        elseif type_of_learning == 2 % Q-learning
            RPE = r_t(t-1) + gm*max(V(state_t(t)*2-[1 0])) - V(act_t(t-1));
        end
        if RPE >= 0
            IR_Q(act_t(t-1)) = IR_Q(act_t(t-1)) + IR_ap*RPE;
            w = w + SR_ap*SR_M(act_t(t-1),:)*RPE;
        else
            IR_Q(act_t(t-1)) = IR_Q(act_t(t-1)) + IR_an*RPE;
            w = w + SR_an*SR_M(act_t(t-1),:)*RPE;
        end
        
        % update of SR matrix
        SPE = zeros(1,4);
        SPE(act_t(t-1)) = 1;
        SPE = SPE + gm*SR_M(act_t(t),:) - SR_M(act_t(t-1),:);
        SR_M(act_t(t-1),:) = SR_M(act_t(t-1),:) + M_a*SPE;
        M_t(:,:,t) = SR_M;
        
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
out.IR_Q_t = IR_Q_t;
out.w_t = w_t;
out.M_t = M_t;
out.ma_obs = ma_obs;
out.count_obs = count_obs;
out.count_abn = count_abn;
out.count_com = count_com;
