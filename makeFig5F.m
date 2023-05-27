% makeFig5F

% reset rand
clear all
rand_seed = 23030701;
rand('twister',rand_seed);

% parameters for the agent function
type_of_learning = 1;
a = [0.09 0.01 0.01 0.09];
b = 10;
n = 50000;
n_act{1} = [2 9];
n_act{2} = [9 2];
decay_rate = 0.001;

% parameters for simulations
n_sim = 100;

% simulations
for k1 = 1:2
    res{k1}.ma_obs = NaN(n_sim,n);
    for k2 = 1:n_sim
        fprintf('%d-%d\n',k1,k2);
        out = OCD_model102(type_of_learning,a(1),a(2),a(3),a(4),b,n,n_act{k1}(1),n_act{k1}(2),decay_rate);
        res{k1}.ma_obs(k2,:) = out.ma_obs;
    end
end
save(['res' num2str(rand_seed)],'res');

% plot
load(['res' num2str(rand_seed)],'res');
tmp_12 = '12';
for k1 = 1:2
    %
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    axis([0 n 0 1]);
    P = plot([1:n],mean(res{k1}.ma_obs,1)-std(res{k1}.ma_obs,1,1),'k--');
    P = plot([1:n],mean(res{k1}.ma_obs,1)+std(res{k1}.ma_obs,1,1),'k--');
    P = plot([1:n],mean(res{k1}.ma_obs,1),'k');
    set(A,'xtick',[0:10000:n],'xticklabel',[0:10000:n],'FontSize',28);
    set(A,'ytick',[0:0.1:1],'yticklabel',[0:0.1:1],'FontSize',28);
    print(F,'-depsc',['Figure5F' tmp_12(k1)]);
end
