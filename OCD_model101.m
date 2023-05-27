function out = OCD_model101(type_of_learning,SR_ap,SR_an,IR_ap,IR_an,b,n,n_act,decay_rate)

% state: 1:obsessive, 2:relief
% action: 1;compulsion, 2:n_act:other@obsessive, n_act+1:abnormal reaction n_act+2:2*n_act:other@relief

% fixed parameters
gm = 0.5; % time discount factor (gamma)
M_a = 0.01; % learning rate for SR features
c = -0.01; % cost of "compulsion"
punish = -1; % punishment for stay at the obsession state
p_obs = zeros(1,2*n_act); % probability of transition to the obsessive state for each action
p_obs(1) = 0.5;
p_obs(2:n_act) = 0.9;
p_obs(n_act+1) = 1;

% history of state, action, reward, value, SR-matrix, and moving-average proportion of the obsessive state
state_t = zeros(1,n+1);
act_t = zeros(1,n);
r_t = zeros(1,n);
V_t = zeros(2*n_act,n);
IR_Q_t = zeros(2*n_act,n);
w_t = zeros(2*n_act,n);
M_t = NaN(2*n_act,2*n_act,n);
ma_obs = NaN(1,n);

% count of "obsession state", "abnormal reaction", "compulsion"
count_obs = 0;
count_abn = 0;
count_com = 0;

% initialization of IR-value, SR-weight, and SR matrix
IR_Q = zeros(1,2*n_act);
w = zeros(1,2*n_act);
SR_M  = eye(2*n_act);

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
    epa = zeros(1,2*n_act);
    if state_t(t) == 1
        epa(1:n_act) = exp(b*V(1:n_act));
        count_obs = count_obs + 1;
    else
        epa(n_act+1:n_act*2) = exp(b*V(n_act+1:n_act*2));
    end
    pa = epa/sum(epa);
    act_t(t) = find(u<=cumsum(pa),1);
    if act_t(t) == 1
        r_t(t) = c;
        count_com = count_com + 1;
    elseif act_t(t) == n_act+1
        count_abn = count_abn + 1;
    end
    
    % state transition and reward for the cases other than the stay at the obsession state
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
            
            RPE = r_t(t-1) + gm*max(V((state_t(t)-1)*n_act+[1:n_act])) - V(act_t(t-1));
        end
        if RPE >= 0
            IR_Q(act_t(t-1)) = IR_Q(act_t(t-1)) + IR_ap*RPE;
            w = w + SR_ap*SR_M(act_t(t-1),:)*RPE;
        else
            IR_Q(act_t(t-1)) = IR_Q(act_t(t-1)) + IR_an*RPE;
            w = w + SR_an*SR_M(act_t(t-1),:)*RPE;
        end
        
        % update of SR matrix
        SPE = zeros(1,2*n_act);
        SPE(act_t(t-1)) = 1;
        SPE = SPE + gm*SR_M(act_t(t),:) - SR_M(act_t(t-1),:);
        SR_M(act_t(t-1),:) = SR_M(act_t(t-1),:) + M_a*SPE;
        M_t(:,:,t) = SR_M;
        
    end
    
    % decay
    IR_Q = IR_Q * (1 - decay_rate);
    w = w * (1 - decay_rate);
    
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
