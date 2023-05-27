function minusLL = twostage_fitsrir(paras,Out)

% parameters
a_SR = (tanh(paras(1:3))+1)/2;
a_IR = (tanh(paras(4:5))+1)/2;
b = paras(6);
g = 1;

%
choices = Out.choices;
rewards = Out.rewards;
num_trial = length(rewards);

%
tr = [0.7 0.3; 0.3 0.7];
SRM = [
    1 0 g*tr(1,1)*0.5 g*tr(1,1)*0.5 g*tr(1,2)*0.5 g*tr(1,2)*0.5;
    0 1 g*tr(2,1)*0.5 g*tr(2,1)*0.5 g*tr(2,2)*0.5 g*tr(2,2)*0.5;
    0 0 1 0 0 0;
    0 0 0 1 0 0;
    0 0 0 0 1 0;
    0 0 0 0 0 1];
w = zeros(6,1);
Vsr = SRM * w;
Vir = zeros(6,1);
Vint = (Vsr + Vir)/2;

%
LLeach = NaN(num_trial,2); % log-likelihood of choices at [first second] stages at each trial; initialization
for k_trial = 1:num_trial
    
    % choice at the first stage
    tmp_prob1 = exp(b*Vint(1)) / sum(exp(b*Vint(1:2)));
    if choices(k_trial,1) == 1
        LLeach(k_trial,1) = log(tmp_prob1);
    else
        LLeach(k_trial,1) = log(1-tmp_prob1);
    end
    
    % stage transition
    if choices(k_trial,2) < 4.5
        options = [3 4];
    else
        options = [5 6];
    end
    
    % choice at the second stage
    tmp_prob2 = exp(b*Vint(options(1))) / sum(exp(b*Vint(options)));
    if  choices(k_trial,2) == options(1)
        LLeach(k_trial,2) = log(tmp_prob2);
    else
        LLeach(k_trial,2) = log(1-tmp_prob2);
    end
    
    % reward
    R = rewards(k_trial);
    
    % TD RPE for the first stage, and recalculate the values
    TDE1 = 0 + g*Vint(choices(k_trial,2)) - Vint(choices(k_trial,1));
    Vir(choices(k_trial,1)) = Vir(choices(k_trial,1)) + a_IR(2-(TDE1>=0))*TDE1;
    w = w + a_SR(2-(TDE1>=0))*SRM(choices(k_trial,1),:)'*TDE1;
    Vsr = SRM * w;
    Vint = (Vsr + Vir)/2;
    
    % TD error for SR features
    tmp_state_vector = zeros(1,6);
    tmp_state_vector(choices(k_trial,2)) = 1;
    TDEsr = tmp_state_vector + 0 - SRM(choices(k_trial,1),:);
    SRM(choices(k_trial,1),:) = SRM(choices(k_trial,1),:) + a_SR(3)*TDEsr;
    
    % TD RPE for the second stage, and recalculate the values
    TDE2 = R + 0 - Vint(choices(k_trial,2));
    Vir(choices(k_trial,2)) = Vir(choices(k_trial,2)) + a_IR(2-(TDE2>=0))*TDE2;
    w = w + a_SR(2-(TDE2>=0))*SRM(choices(k_trial,2),:)'*TDE2;
    Vsr = SRM * w;
    Vint = (Vsr + Vir)/2;
    
end

% output
minusLL = -sum(sum(LLeach)); % minus log-likelihood for all the first-stage and second-stage choices
