% Qlearning_version_of_makeFig4AB

% reset rand
clear all
rand_seed = 22102208;
rand('twister',rand_seed);

% parameters for the agent function
type_of_learning = 2;
a{1} = [0 0 0.1 0.1];
a{2} = [0.1 0.1 0 0];
a{3} = [0.05 0.05 0.05 0.05];
a{4} = [0.09 0.01 0.01 0.09];
b = 10;
n = 50000;

% parameters for simulations
n_sim = 100;

% simulations
for k1 = 1:4
    res{k1}.Vdiff = NaN(n_sim,n);
    res{k1}.ma_obs = NaN(n_sim,n);
    restmp.V = NaN(4,n,n_sim);
    restmp.IR_Q = NaN(4,n,n_sim);
    restmp.w = NaN(4,n,n_sim);
    restmp.M5000 = NaN(4,4,n_sim);
    restmp.M50000 = NaN(4,4,n_sim);
    for k2 = 1:n_sim
        fprintf('%d-%d\n',k1,k2);
        out = OCD_model_rev(type_of_learning,a{k1}(1),a{k1}(2),a{k1}(3),a{k1}(4),b,n);
        res{k1}.Vdiff(k2,:) = out.V_t(3,:) - out.V_t(4,:);
        res{k1}.ma_obs(k2,:) = out.ma_obs;
        restmp.V(:,:,k2) = out.V_t;
        restmp.IR_Q(:,:,k2) = out.IR_Q_t;
        restmp.w(:,:,k2) = out.w_t;
        restmp.M5000(:,:,k2) = out.M_t(:,:,5000);
        restmp.M50000(:,:,k2) = out.M_t(:,:,50000);
    end
    res{k1}.Vmean = mean(restmp.V,3);
    res{k1}.Vstd = std(restmp.V,1,3);
    res{k1}.IR_Qmean = mean(restmp.IR_Q,3);
    res{k1}.IR_Qstd = std(restmp.IR_Q,1,3);
    res{k1}.wmean = mean(restmp.w,3);
    res{k1}.wstd = std(restmp.w,1,3);
    res{k1}.M5000mean = mean(restmp.M5000,3);
    res{k1}.M50000mean = mean(restmp.M50000,3);
end
res4 = res{4};
save(['res4_' num2str(rand_seed)],'res4');

% plot
load(['res4_' num2str(rand_seed)],'res4');
res{4} = res4;
for k1 = 4
    %
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    axis([0 n -1 0.8]);
    P = plot([0 n],[0 0],'k:');
    P = plot([1:n],res{k1}.Vdiff(1,:),'k');
    set(A,'xtick',[0:10000:n],'xticklabel',[0:10000:n],'FontSize',28);
    set(A,'ytick',[-1:0.5:0.5],'yticklabel',[-1:0.5:0.5],'FontSize',28);
    print(F,'-depsc','QFigure4A-top');
    %
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    axis([0 n 0 1]);
    P = plot([1:n],res{k1}.ma_obs(1,:),'k');
    set(A,'xtick',[0:10000:n],'xticklabel',[0:10000:n],'FontSize',28);
    set(A,'ytick',[0:0.1:1],'yticklabel',[0:0.1:1],'FontSize',28);
    print(F,'-depsc','QFigure4A-middle');
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
    print(F,'-depsc','QFigure4A-bottom');
    %
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    axis([0 n -1.5 0.5]);
    P = plot([0 n],[0 0],'k:');
    tmp_color = 'rkbg';
    for k2 = 1:4
        %P = plot([1:n],res{k1}.Vmean(k2,:)-res{k1}.Vstd(k2,:),[tmp_color(k2) '--']);
        %P = plot([1:n],res{k1}.Vmean(k2,:)+res{k1}.Vstd(k2,:),[tmp_color(k2) '--']);
        P = plot([1:n],res{k1}.Vmean(k2,:),tmp_color(k2));
    end
    set(A,'xtick',[0:10000:n],'xticklabel',[0:10000:n],'FontSize',28);
    set(A,'ytick',[-1.5:0.5:0.5],'yticklabel',[-1.5:0.5:0.5],'FontSize',28);
    print(F,'-depsc','QFigure4B-top');
    %
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    axis([0 n -175 125]);
    P = plot([0 n],[0 0],'k:');
    tmp_color = 'rkbg';
    for k2 = 1:4
        %P = plot([1:n],res{k1}.wmean(k2,:)-res{k1}.wstd(k2,:),[tmp_color(k2) '--']);
        %P = plot([1:n],res{k1}.wmean(k2,:)+res{k1}.wstd(k2,:),[tmp_color(k2) '--']);
        P = plot([1:n],res{k1}.wmean(k2,:),tmp_color(k2));
    end
    for k2 = 1:4
        %P = plot([1:n],res{k1}.IR_Qmean(k2,:)-res{k1}.IR_Qstd(k2,:),[tmp_color(k2) ':']);
        %P = plot([1:n],res{k1}.IR_Qmean(k2,:)+res{k1}.IR_Qstd(k2,:),[tmp_color(k2) ':']);
        P = plot([1:n],res{k1}.IR_Qmean(k2,:),tmp_color(k2));
    end
    set(A,'xtick',[0:10000:n],'xticklabel',[0:10000:n],'FontSize',28);
    set(A,'ytick',[-150:50:100],'yticklabel',[-150:50:100],'FontSize',28);
    print(F,'-depsc','QFigure4B-middle');
    %
    tmp_data_for_image{1} = res{k1}.M5000mean;
    tmp_data_for_image{2} = res{k1}.M50000mean;
    for k2 = 1:2
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
        print(F,'-depsc',['QFigure4B-bottom' num2str(k2)]);
    end
end
