% makeFig7C

%
clear all
rand_seed = 23030301;
rand('twister',rand_seed);

% simulations
lr{1} = [0.02 0.02 0 0]; % SR-only
lr{2} = [0.018 0.002 0.002 0.018]; % appetitive SR + aversive IR
b = 0.25;
g = 0.75;
decay_rate = 0.001;
num_sim = 50;

% simulation
for k1 = 1:2
    for k2 = 1:num_sim
        fprintf('%d-%d\n',k1,k2);
        his{k1}{k2} = df2(lr{k1},b,g,decay_rate,0);
    end
end
save(['DF_his_' num2str(rand_seed)],'his');

%
%load(['DF_his_' num2str(rand_seed)],'his');
ini.lr = 0.0011;
ini.b = 2.96;
ini.nyu_set = [0.1 0.1; 0.1 0.5; 0.1 0.9; 0.5 0.1; 0.5 0.5; 0.5 0.9; 0.9 0.1; 0.9 0.5; 0.9 0.9];
fminsearch_option = optimset('fminsearch');
fminsearch_option = optimset(fminsearch_option,'MaxFunEvals', 10000, 'MaxIter', 10000);
for k1 = 1
    for k2 = 1:num_sim
        estparas{k1}{k2} = NaN(size(ini.nyu_set,1),6);
        for k3 = 1:size(ini.nyu_set,1)
            fprintf('fit %d-%d-%d\n',k1,k2,k3);
            iniall = [atanh(2*ini.lr-1) ini.b atanh(2*ini.nyu_set(k3,1)-1) atanh(2*ini.nyu_set(k3,2)-1)];
            [estim,fval,exitflag] = fminsearch(@dfet_fit, iniall, fminsearch_option, his{k1}{k2});
            estparas{k1}{k2}(k3,:) = [(tanh(estim(1))+1)/2 estim(2) (tanh(estim(3))+1)/2 (tanh(estim(4))+1)/2 fval exitflag];
        end
        save data23030301_estparas estparas
    end
end

%
load data23030301_estparas
num_sim = 50;
for k1 = 1:2
    nyu_p_n_res{k1} = [];
    for k2 = 1:num_sim
        if sum(estparas{k1}{k2}(:,6)==1)
            tmp_estparas = estparas{k1}{k2}(estparas{k1}{k2}(:,6)==1,:);
            [tmp_value,tmp_index] = min(tmp_estparas(:,5));
            nyu_p_n_res{k1} = [nyu_p_n_res{k1}; tmp_estparas(tmp_index,3:4)];
        end
    end
end
tmp_colors = 'br';
for k1 = 1:2
    F = figure;
    A = axes;
    hold on;
    axis([0 1 0 1]);
    set(A,'PlotBoxAspectRatio',[1 1 1]);
    P = plot([0 1],[0 1],'k');
    for k = 1:size(nyu_p_n_res{k1},1)
        P = plot(nyu_p_n_res{k1}(k,1),nyu_p_n_res{k1}(k,2),[tmp_colors(k1) 'x']);
        set(P,'MarkerSize',20,'LineWidth',2);
    end
    set(A,'xtick',[0 0.5 1],'xticklabel',[0 0.5 1],'FontSize',28);
    set(A,'ytick',[0 0.5 1],'yticklabel',[0 0.5 1],'FontSize',28);
    print(F,'-depsc',['Figure7C' num2str(k1)]);
end
