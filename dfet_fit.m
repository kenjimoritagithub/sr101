function minusLL = dfet_fit(paras,his)

% parameters
lr = (tanh(paras(1))+1)/2;
b = paras(2);
nyu_p = (tanh(paras(3))+1)/2;
nyu_n = (tanh(paras(4))+1)/2;

%
states = his.SSs;
actions = his.SSa;
rewards = his.r;
num_trial = length(rewards);

%
Q = zeros(32,1); % action values; initialization
action_trace_p = zeros(32,1); % eligibility trace for positive RPE; initialization
action_trace_n = zeros(32,1); % eligibility trace for negative RPE; initialization

%
LLeach = NaN(num_trial,1); % log-likelihood of choices at each trial; initialization

for k = 1:num_trial
    
    tmp_prob = exp(b*Q(2*states(k)-1)) / sum(exp(b*Q(2*states(k)-1:2*states(k))));
    if actions(k) == 2*states(k)-1
        LLeach(k) = log(tmp_prob);
    else
        LLeach(k) = log(1-tmp_prob);
    end
    action_trace_p = nyu_p * action_trace_p;
    action_trace_n = nyu_n * action_trace_n;
    action_trace_p(actions(k)) = action_trace_p(actions(k)) + 1;
    action_trace_n(actions(k)) = action_trace_n(actions(k)) + 1;
    rpe = rewards(k) - sum(Q(2*states(k)-1:2*states(k)));
    if rpe >= 0
        Q = Q + lr*action_trace_p*rpe;
    else
        Q = Q + lr*action_trace_n*rpe;
    end
    
end

% output
minusLL = -sum(LLeach);
