% makeFig9Atop

%
clear all
rand_seed = 23030511;
rand('twister',rand_seed);

%
n = 100;
lrset{1} = [0.03 0.27 0.27 0.03 0.05];
for k1 = 1
    for k2 = 1:n
        fprintf('sim %d-%d\n',k1,k2);
        Out{k1}{k2} = twostagePun_srir_sim(lrset{k1},5,1,1);
    end
end
save data23030511_Out Out

%
ini.a = [0.3 0.3];
ini.b = [5 5];
ini.lamda = 0.2;
ini.rho = 0.2;
ini.w_set = [0.2 0.5 0.8];
fminsearch_option = optimset('fminsearch');
fminsearch_option = optimset(fminsearch_option,'MaxFunEvals', 10000, 'MaxIter', 10000);
for k1 = 1
    w_flag1{k1} = [];
    for k2 = 1:n
        estparas{k1}{k2} = NaN(length(ini.w_set),9);
        for k3 = 1:length(ini.w_set)
            fprintf('fit %d-%d-%d\n',k1,k2,k3);
            iniall = [atanh(2*ini.a-1) ini.b atanh(2*ini.lamda-1) ini.rho atanh(2*ini.w_set(k3)-1)];
            [estim,fval,exitflag] = fminsearch(@twostage_fit7, iniall, fminsearch_option, Out{k1}{k2});
            estparas{k1}{k2}(k3,:) = [(tanh(estim(1:2))+1)/2 estim(3:4) (tanh(estim(5))+1)/2 estim(6) (tanh(estim(7))+1)/2 fval exitflag];
        end
        [tmp_value,tmp_index] = min(estparas{k1}{k2}(:,8));
        if estparas{k1}{k2}(tmp_index,9) == 1
            w_flag1{k1} = [w_flag1{k1}; estparas{k1}{k2}(tmp_index,7)];
        end
    end
end
save data23030511_estparas estparas
save data23030511_w_flag1 w_flag1

% figure
load data23030511_w_flag1
tmpX = [0.05:0.1:0.95];
H{1} = hist(w_flag1{1},tmpX);
Ymax = 55;
for k1 = 1
    F = figure;
    A = axes;
    hold on;
    axis([0 1 0 Ymax]);
    P = bar(tmpX,H{k1},1);
    Shading flat;
    set(P,'FaceColor',0.5*[1 1 1]);
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    set(A,'XTick',[0:0.1:1],'XTickLabel',[0:0.1:1],'FontSize',16);
    set(A,'YTick',[0:5:Ymax],'YTickLabel',[0:5:Ymax],'FontSize',16);
    print(F,'-depsc','Figure9Atop');
end
