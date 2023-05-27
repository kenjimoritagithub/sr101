function minusLL = twostage_fit7(paras,Out)

% parameters
a = (tanh(paras(1:2))+1)/2;
b = paras(3:4);
lamda = (tanh(paras(5))+1)/2;
rho = paras(6);
w = (tanh(paras(7))+1)/2;

%
choices = Out.choices;
rewards = Out.rewards;
num_trial = length(rewards);

%
Qmf = zeros(6,1); % model-free values of options (1 2 3 4 5 6); initialization
Qmb = zeros(2,1); % model-based values of options (1 2)

%
tr = [0.7 0.3]; % probabilities of transition to the second-stage with options 3&4 when choosing [1 2] at the first-stage
tr_freq_rare = NaN(num_trial,1); % whether the stage transition is the frequent-type (0.7) or the rare-type (0.3)

%
LLeach = NaN(num_trial,2); % log-likelihood of choices at [first second] stages at each trial; initialization

for k_trial = 1:num_trial
    
    % estimated state-transition probabilities for model-based value calculation
    if k_trial == 1
    	mb_tr = [0.5 0.5];
    else
        if sum(tr_freq_rare(1:k_trial-1)) > (k_trial-1)/2 % if the frequent-type was indeed more frequent than the rare-type
            mb_tr = tr;
        elseif sum(tr_freq_rare(1:k_trial-1)) < (k_trial-1)/2 % if the frequent-type was actually less frequent than the rare-type
            mb_tr = 1 - tr;
        else % if the frequent-type and the rare-type were equally frequent
            mb_tr = [0.5 0.5];
        end
    end
    
    % choice at the first stage
    Qmb(1) = mb_tr(1)*max(Qmf(3),Qmf(4)) + (1-mb_tr(1))*max(Qmf(5),Qmf(6));
    Qmb(2) = mb_tr(2)*max(Qmf(3),Qmf(4)) + (1-mb_tr(2))*max(Qmf(5),Qmf(6));
    Qnet = w*Qmb + (1-w)*Qmf(1:2);
    prevchoice = [0 0]; % whether option 1 or 2 was chosen in the previous trial; initialization
    if k_trial >= 2
        prevchoice(choices(k_trial-1,1)) = 1;
    end
    tmp_prob1 = exp(b(1)*(Qnet(1)+rho*prevchoice(1))) / (exp(b(1)*(Qnet(1)+rho*prevchoice(1))) + exp(b(1)*(Qnet(2)+rho*prevchoice(2))));
    if choices(k_trial,1) == 1
        LLeach(k_trial,1) = log(tmp_prob1);
    else
        LLeach(k_trial,1) = log(1-tmp_prob1);
    end
    
    % stage transition
    if sum(choices(k_trial,2)==[3 4])
        options = [3 4];
    else
        options = [5 6];
    end
    if ((choices(k_trial,1)==1) && (options(1)==3)) || ((choices(k_trial,1)==2) && (options(1)==5))
        tr_freq_rare(k_trial) = 1; % frequent-type transition
    else
        tr_freq_rare(k_trial) = 0; % rare-type transition
    end
    
    % choice at the second stage
    tmp_prob2 = exp(b(2)*Qmf(options(1))) / sum(exp(b(2)*Qmf(options)));
    if  choices(k_trial,2) == options(1)
        LLeach(k_trial,2) = log(tmp_prob2);
    else
        LLeach(k_trial,2) = log(1-tmp_prob2);
    end
    
    % model-free TD reward-prediction-error for the first stage, and update of the values
    TDE1 = 0 + Qmf(choices(k_trial,2)) - Qmf(choices(k_trial,1));
    Qmf(choices(k_trial,1)) = Qmf(choices(k_trial,1)) + a(1)*TDE1;
    
    % model-free TD reward-prediction-error for the second stage, and update of the values
    TDE2 = rewards(k_trial) + 0 - Qmf(choices(k_trial,2));
    Qmf(choices(k_trial,2)) = Qmf(choices(k_trial,2)) + a(2)*TDE2;
    Qmf(choices(k_trial,1)) = Qmf(choices(k_trial,1)) + a(1)*lamda*TDE2;
    
end

% output
minusLL = -sum(sum(LLeach)); % minus log-likelihood for all the first-stage and second-stage choices
