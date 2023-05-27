% makeFig3A-D

% reset rand
clear all
rand_seed = 22102201;
rand('twister',rand_seed);

% parameters for the agent function
type_of_learning = 1;
a{1} = [0 0 0.1 0.1];
a{2} = [0.1 0.1 0 0];
a{3} = [0.05 0.05 0.05 0.05];
a{4} = [0.09 0.01 0.01 0.09];
b = 10;
n = 5000;

% parameters for simulations
n_sim = 100;

% simulations
for k1 = 1:4
    res{k1}.Vdiff = NaN(n_sim,n);
    res{k1}.ma_obs = NaN(n_sim,n);
    for k2 = 1:n_sim
        fprintf('%d-%d\n',k1,k2);
        out = OCD_model(type_of_learning,a{k1}(1),a{k1}(2),a{k1}(3),a{k1}(4),b,n);
        res{k1}.Vdiff(k2,:) = out.V_t(3,:) - out.V_t(4,:);
        res{k1}.ma_obs(k2,:) = out.ma_obs;
    end
end
save(['res' num2str(rand_seed)],'res');

% plot
load(['res' num2str(rand_seed)],'res');
tmp_names = 'ABCD';
for k1 = 1:4
    %
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    axis([0 n -0.5 0.1]);
    P = plot([0 n],[0 0],'k:');
    P = plot([1:n],res{k1}.Vdiff(1,:),'k');
    set(A,'xtick',[0:1000:n],'xticklabel',[0:1000:n],'FontSize',28);
    set(A,'ytick',[-0.5:0.1:0.1],'yticklabel',[-0.5:0.1:0.1],'FontSize',28);
    print(F,'-depsc',['Figure3' tmp_names(k1) '-top']);
    %
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    axis([0 n 0 1]);
    P = plot([1:n],res{k1}.ma_obs(1,:),'k');
    set(A,'xtick',[0:1000:n],'xticklabel',[0:1000:n],'FontSize',28);
    set(A,'ytick',[0:0.1:1],'yticklabel',[0:0.1:1],'FontSize',28);
    print(F,'-depsc',['Figure3' tmp_names(k1) '-middle']);
    %
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    axis([0 n 0 1]);
    P = plot([1:n],mean(res{k1}.ma_obs,1)-std(res{k1}.ma_obs,1,1),'k--');
    P = plot([1:n],mean(res{k1}.ma_obs,1)+std(res{k1}.ma_obs,1,1),'k--');
    P = plot([1:n],mean(res{k1}.ma_obs,1),'k');
    set(A,'xtick',[0:1000:n],'xticklabel',[0:1000:n],'FontSize',28);
    set(A,'ytick',[0:0.1:1],'yticklabel',[0:0.1:1],'FontSize',28);
    print(F,'-depsc',['Figure3' tmp_names(k1) '-bottom']);
end
