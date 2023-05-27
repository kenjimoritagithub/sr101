function Out = twostage_modiori_sim(a,b,lamda,rho,w)

% simulation of the two-stage task (Daw et al., 2011, Neuron) by modified original model w/ separate eligibility trace for positive/negative TDE
%	first-stage: options 1&2
%	second-stage: options 3&4 or 5&6
% <parameters>
%   a: learning rates for the [first second] stages
%   b: inverse temperatures for the [first second] stages
%   lamda: eligibility trace for [positive(non-negative) negative] TDE
%   rho: degree of repetition bias for first-stage choice (positive: tend to repeat, negative: tend to switch)
%   w: weight of model-based value (weight of model-free value is given by 1-w)

%
num_trial = 201; % number of trials
choices = NaN(num_trial,2); % choices at the [first second] stages at each trial
rewards = NaN(num_trial,1); % reward at each trial

%
Qmf = zeros(6,1); % model-free values of options (1 2 3 4 5 6); initialization
Qmb = zeros(2,1); % model-based values of options (1 2)

%
tr = [0.7 0.3]; % probabilities of transition to the second-stage with options 3&4 when choosing [1 2] at the first-stage
tr_freq_rare = NaN(num_trial,1); % whether the stage transition is the frequent-type (0.7) or the rare-type (0.3)

%
p_rew = 0.25 + 0.5*rand(1,4); % reward probabilities for second-stage options (3 4 5 6); initialization
p_rew_set = NaN(num_trial,4); % set of reward probabilities for all the trials; initialization

for k_trial = 1:num_trial
    
    % reward probabilities
    p_rew_set(k_trial,:) = p_rew;
    
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
    
    % generate pseudo-random numbers used for first-stage choice, stage transition, second-stage choice, and reward
    tmp_rand = rand(1,4);
    
    % choice at the first stage
    Qmb(1) = mb_tr(1)*max(Qmf(3),Qmf(4)) + (1-mb_tr(1))*max(Qmf(5),Qmf(6));
    Qmb(2) = mb_tr(2)*max(Qmf(3),Qmf(4)) + (1-mb_tr(2))*max(Qmf(5),Qmf(6));
    Qnet = w*Qmb + (1-w)*Qmf(1:2);
    prevchoice = [0 0]; % whether option 1 or 2 was chosen in the previous trial; initialization
    if k_trial >= 2
        prevchoice(choices(k_trial-1,1)) = 1;
    end
    tmp_prob1 = exp(b(1)*(Qnet(1)+rho*prevchoice(1))) / (exp(b(1)*(Qnet(1)+rho*prevchoice(1))) + exp(b(1)*(Qnet(2)+rho*prevchoice(2))));
    if tmp_rand(1) <= tmp_prob1
        choices(k_trial,1) = 1;
    else
        choices(k_trial,1) = 2;
    end
    
    % stage transition
    if tmp_rand(2) <= tr(choices(k_trial,1))
        options = [3 4];
        if tr(choices(k_trial,1)) == 0.7
            tr_freq_rare(k_trial) = 1; % frequent-type transition
        else
            tr_freq_rare(k_trial) = 0; % rare-type transition
        end
    else
        options = [5 6];
        if tr(choices(k_trial,1)) == 0.7
            tr_freq_rare(k_trial) = 0; % rare-type transition
        else
            tr_freq_rare(k_trial) = 1; % frequent-type transition
        end
    end
    
    % choice at the second stage
    tmp_prob2 = exp(b(2)*Qmf(options(1))) / sum(exp(b(2)*Qmf(options)));
    if tmp_rand(3) <= tmp_prob2
        choices(k_trial,2) = options(1);
    else
        choices(k_trial,2) = options(2);
    end
    
    % reward
    if tmp_rand(4) <= p_rew(choices(k_trial,2)-2)
        rewards(k_trial) = 1;
    else
        rewards(k_trial) = 0;
    end
    
    % model-free TD reward-prediction-error for the first stage, and update of the values
    TDE1 = 0 + Qmf(choices(k_trial,2)) - Qmf(choices(k_trial,1));
    Qmf(choices(k_trial,1)) = Qmf(choices(k_trial,1)) + a(1)*TDE1;
    
    % model-free TD reward-prediction-error for the second stage, and update of the values
    TDE2 = rewards(k_trial) + 0 - Qmf(choices(k_trial,2));
    Qmf(choices(k_trial,2)) = Qmf(choices(k_trial,2)) + a(2)*TDE2;
    if TDE2 >= 0
        Qmf(choices(k_trial,1)) = Qmf(choices(k_trial,1)) + a(1)*lamda(1)*TDE2;
    else
        Qmf(choices(k_trial,1)) = Qmf(choices(k_trial,1)) + a(1)*lamda(2)*TDE2;
    end
    
    % change the reward probabilities
    tmp_randn = randn(1,4);
    for k = 1:4
        p_tmp = p_rew(k) + 0.025*tmp_randn(k);
        if p_tmp < 0.25
            p_rew(k) = 0.25 + (0.25 - p_tmp);
        elseif p_tmp > 0.75
            p_rew(k) = 0.75 - (p_tmp - 0.75);
        else
            p_rew(k) = p_tmp;
        end
        if (p_rew(k)<0.25) || (p_rew(k)>0.75)
            error('reward probability becomes out of range');
        end
    end
    
end

% output
Out.choices = choices;
Out.rewards = rewards;
Out.p_rew_set = p_rew_set;
Out.tr_freq_rare = tr_freq_rare;
