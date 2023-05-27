% makeFig7AB

% reset rand
clear all
rand_seed = 20230001;
rand('twister',rand_seed);

% parameters
lr{1} = [0.02 0.02 0 0]; % SR-only
lr{2} = [0.018 0.002 0.002 0.018]; % appetitive SR + aversive IR
b = 0.25;
g = 0.75;
decay_rate = 0.001;
num_sim = 1000;

% simulation
for k1 = 1:2
    r_set{k1}{1} = NaN(num_sim,7); % immediate, session 1-6 and sessions 5&6
    r_set{k1}{2} = NaN(num_sim,7); % delayed, session 1-6 and sessions 5&6
    for k2 = 1:num_sim
        fprintf('%d-%d\n',k1,k2);
        his = df(lr{k1},b,g,decay_rate,0);
        r_set{k1}{1}(k2,1:6) = sum(reshape(his.rim,110,6),1);
        r_set{k1}{2}(k2,1:6) = sum(reshape(his.rde,110,6),1);
        r_set{k1}{1}(k2,7) = sum(his.rim(441:end));
        r_set{k1}{2}(k2,7) = sum(his.rde(441:end));
    end
end
save(['DF_r_set_' num2str(rand_seed)],'r_set');

% plot
for k = 1:2
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[1 2 1]);
    axis([0.5 6.5 -300 800]);
    P = plot([0.5 6.5],[0 0],'k--');
    P = errorbar([1:6],mean(r_set{1}{k}(:,1:6),1),std(r_set{1}{k}(:,1:6),1,1)/sqrt(num_sim),'b');
    P = errorbar([1:6],mean(r_set{2}{k}(:,1:6),1),std(r_set{2}{k}(:,1:6),1,1)/sqrt(num_sim),'r');
    P = plot([1:6],mean(r_set{1}{k}(:,1:6),1),'b:');
    P = plot([1:6],mean(r_set{2}{k}(:,1:6),1),'r:');
    set(A,'xtick',[1:6],'xticklabel',[1:6],'FontSize',28);
    set(A,'ytick',[-200:200:800],'yticklabel',[-200:200:800],'FontSize',28);
    print(F,'-depsc',['Figure7A' num2str(k)]);
end
F = figure;
A = axes;
hold on
set(A,'PlotBoxAspectRatio',[1 1.5 1]);
axis([0.5 3.5 -500 1500]);
P = plot([0.5 3.5],[0 0],'k--');
P = errorbar([1 3],[mean(r_set{1}{1}(:,7)) mean(r_set{1}{2}(:,7))],...
    [std(r_set{1}{1}(:,7),1)/sqrt(num_sim) std(r_set{1}{2}(:,7),1)/sqrt(num_sim)],'b');
P = errorbar([1 3],[mean(r_set{2}{1}(:,7)) mean(r_set{2}{2}(:,7))],...
    [std(r_set{2}{1}(:,7),1)/sqrt(num_sim) std(r_set{2}{2}(:,7),1)/sqrt(num_sim)],'r');
P = plot([1 3],[mean(r_set{1}{1}(:,7)) mean(r_set{1}{2}(:,7))],'b:');
P = plot([1 3],[mean(r_set{2}{1}(:,7)) mean(r_set{2}{2}(:,7))],'r:');
set(A,'xtick',[1 3],'xticklabel',[],'FontSize',28);
set(A,'ytick',[-500:500:1500],'yticklabel',[-500:500:1500],'FontSize',28);
print(F,'-depsc','Figure7B');
