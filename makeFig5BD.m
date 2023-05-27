% makeFig5BD

% reset rand
clear all
rand_seed = 22112611;
rand('twister',rand_seed);

% parameters for the agent function
type_of_learning = 1;
a = [0.09 0.01 0.01 0.09];
b = 10;
n = 50000;
n_act = [3 9];
decay_rate = 0.001;

% parameters for simulations
n_sim = 100;

% simulations
for k1 = 1:2
    res{k1}.ma_obs = NaN(n_sim,n);
    restmp.V = NaN(4,n,n_sim);
    restmp.M{1} = NaN(4,4,n_sim);
    restmp.M{2} = NaN(4,4,n_sim);
    for k2 = 1:n_sim
        fprintf('%d-%d\n',k1,k2);
        out = OCD_model101(type_of_learning,a(1),a(2),a(3),a(4),b,n,n_act(k1),decay_rate);
        res{k1}.ma_obs(k2,:) = out.ma_obs;
        restmp.V(1,:,k2) = out.V_t(1,:);
        restmp.V(2,:,k2) = mean(out.V_t(2:n_act(k1),:),1);
        restmp.V(3,:,k2) = out.V_t(n_act(k1)+1,:);
        restmp.V(4,:,k2) = mean(out.V_t(n_act(k1)+2:n_act(k1)*2,:),1);
        tmp_time = [5000 50000];
        for k3 = 1:2
            restmp.M{k3}(1,1,k2) = out.M_t(1,1,tmp_time(k3));
            restmp.M{k3}(1,2,k2) = sum(out.M_t(1,2:n_act(k1),tmp_time(k3)));
            restmp.M{k3}(1,3,k2) = out.M_t(1,n_act(k1)+1,tmp_time(k3));
            restmp.M{k3}(1,4,k2) = sum(out.M_t(1,n_act(k1)+2:n_act(k1)*2,tmp_time(k3)));
            restmp.M{k3}(2,1,k2) = mean(out.M_t(2:n_act(k1),1,tmp_time(k3)));
            restmp.M{k3}(2,2,k2) = mean(sum(out.M_t(2:n_act(k1),2:n_act(k1),tmp_time(k3)),2));
            restmp.M{k3}(2,3,k2) = mean(out.M_t(2:n_act(k1),n_act(k1)+1,tmp_time(k3)));
            restmp.M{k3}(2,4,k2) = mean(sum(out.M_t(2:n_act(k1),n_act(k1)+2:n_act(k1)*2,tmp_time(k3)),2));
            restmp.M{k3}(3,1,k2) = out.M_t(n_act(k1)+1,1,tmp_time(k3));
            restmp.M{k3}(3,2,k2) = sum(out.M_t(n_act(k1)+1,2:n_act(k1),tmp_time(k3)));
            restmp.M{k3}(3,3,k2) = out.M_t(n_act(k1)+1,n_act(k1)+1,tmp_time(k3));
            restmp.M{k3}(3,4,k2) = sum(out.M_t(n_act(k1)+1,n_act(k1)+2:n_act(k1)*2,tmp_time(k3)));
            restmp.M{k3}(4,1,k2) = mean(out.M_t(n_act(k1)+2:n_act(k1)*2,1,tmp_time(k3)));
            restmp.M{k3}(4,2,k2) = mean(sum(out.M_t(n_act(k1)+2:n_act(k1)*2,2:n_act(k1),tmp_time(k3)),2));
            restmp.M{k3}(4,3,k2) = mean(out.M_t(n_act(k1)+2:n_act(k1)*2,n_act(k1)+1,tmp_time(k3)));
            restmp.M{k3}(4,4,k2) = mean(sum(out.M_t(n_act(k1)+2:n_act(k1)*2,n_act(k1)+2:n_act(k1)*2,tmp_time(k3)),2));
        end
    end
    res{k1}.Vmean = mean(restmp.V,3);
    res{k1}.Vstd = std(restmp.V,1,3);
    for k3 = 1:2
        res{k1}.Mmean{k3} = mean(restmp.M{k3},3);
    end
end
save(['res' num2str(rand_seed)],'res');

% plot
load(['res' num2str(rand_seed)],'res');
tmp_BD = 'BD';
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
    print(F,'-depsc',['Figure5' tmp_BD(k1) '-top']);
    %
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    axis([0 n -1 0.5]);
    P = plot([0 n],[0 0],'k:');
    tmp_color = 'rkbg';
    for k2 = 1:4
        %P = plot([1:n],res{k1}.Vmean(k2,:)-res{k1}.Vstd(k2,:),[tmp_color(k2) '--']);
        %P = plot([1:n],res{k1}.Vmean(k2,:)+res{k1}.Vstd(k2,:),[tmp_color(k2) '--']);
        P = plot([1:n],res{k1}.Vmean(k2,:),tmp_color(k2));
    end
    set(A,'xtick',[0:10000:n],'xticklabel',[0:10000:n],'FontSize',28);
    set(A,'ytick',[-1:0.5:0.5],'yticklabel',[-1:0.5:0.5],'FontSize',28);
    print(F,'-depsc',['Figure5' tmp_BD(k1) '-middle']);
    %
    for k2 = 1:2
        tmp_data_for_image{k2} = res{k1}.Mmean{k2};
        F = figure;
        A = axes;
        hold on
        set(A,'PlotBoxAspectRatio',[1 1 1],'Box','on');
        axis([0.5 4.5 0.5 4.5]);
        tmp_max = 2;
        P1 = image(fliplr(tmp_data_for_image{k2})*(64/tmp_max));
        set(A,'xtick',[1:4],'xticklabel',[1:4],'FontSize',45);
        set(A,'ytick',[1:4],'yticklabel',[1:4],'FontSize',45);
        C = [1:-1/63:0; 1:-1/63:0; 1:-1/63:0]';
        colormap(C);
        P2 = colorbar;
        set(P2,'ytick',[0:0.5:2]*(64/tmp_max),'yticklabel',[0:0.5:2],'FontSize',45);
        print(F,'-depsc',['Figure5' tmp_BD(k1) '-bottom' num2str(k2)]);
    end
end
