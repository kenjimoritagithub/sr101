% reset rand
clear all
rand_seed = 23030702;
rand('twister',rand_seed);

% simulation
out{1} = OCD_model_rev_decay(1,0.09,0.01,0.01,0.09,10,50000,0.001);
out{2} = OCD_model_rev_decay(1,0.1,0.1,0,0,10,50000,0.001);

% plot
n = 50000;
tmp_12 = '12';
for k = 1:2
    %
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    axis([0 n -0.2 0.5]);
    P = plot([0 n],[0 0],'k--');
    P = plot([1:n],out{k}.V_t(1,:)-out{k}.V_t(2,:),'k');
    set(A,'xtick',[0:10000:n],'xticklabel',[0:10000:n],'FontSize',28);
    set(A,'ytick',[-0.2:0.1:0.5],'yticklabel',[-0.2:0.1:0.5],'FontSize',28);
    print(F,'-depsc',['FigureR2.1.' tmp_12(k1)]);
end
