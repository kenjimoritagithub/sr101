% makeFigF3

%
clear all
rand_seed = 23041801;
rand('twister',rand_seed);

%
n = 20;
lrset{1} = [0.27 0.03 0.03 0.27 0.05];
lrset{2} = [0.3 0.3 0 0 0.05];
lrset{3} = [0.03 0.27 0.27 0.03 0.05];
for k1 = 1:3
    for k2 = 1:n
        fprintf('sim %d-%d\n',k1,k2);
        Out{k1}{k2} = twostage_srir_sim(lrset{k1},5,1,1);
    end
end
save data23041801_Out Out

%
ini.b = 5;
fminsearch_option = optimset('fminsearch');
fminsearch_option = optimset(fminsearch_option,'MaxFunEvals', 10000, 'MaxIter', 10000);
for k1 = 1:3
    for k2 = 1:length(Out{k1})
        estparas{k1}{k2} = NaN(9,8);
        for k3 = 1:9
            fprintf('fit %d-%d-%d\n',k1,k2,k3);
            ini.a_SR = [-0.05+ceil(k3/3)*0.1 0.05+mod(k3-1,3)*0.1 0.05];
            ini.a_IR = 0.3-ini.a_SR(1:2);
            iniall = [atanh(2*ini.a_SR-1) atanh(2*ini.a_IR-1) ini.b];
            [estim,fval,exitflag] = fminsearch(@twostage_fitsrir, iniall, fminsearch_option, Out{k1}{k2});
            estparas{k1}{k2}(k3,:) = [(tanh(estim(1:5))+1)/2 estim(6) fval exitflag];
        end
    end
end
save estparas estparas

for k1 = 1:3
    bestestparas{k1} = NaN(length(Out{k1}),8);
    for k2 = 1:length(Out{k1})
        [tmp_value,tmp_index] = min(estparas{k1}{k2}(:,7));
        if estparas{k1}{k2}(tmp_index,8) == 1
            bestestparas{k1}(k2,:) = estparas{k1}{k2}(tmp_index,:);
        end
    end
end
save bestestparas bestestparas

% figure
load bestestparas
%
tmp = bestestparas;
for k2 = 1:3
    F = figure;
    A = axes;
    hold on;
    axis([-1 1 -1 1]);
    set(A,'PlotBoxAspectRatio',[1 1 1]);
    P = plot([0 0],[-1 1],'k:');
    P = plot([-1 1],[0 0],'k:');
    P = plot(tmp{k2}(:,1)-tmp{k2}(:,2), tmp{k2}(:,4)-tmp{k2}(:,5),'kx');
    set(P,'MarkerSize',20,'LineWidth',2);
    set(A,'xtick',[-1:0.5:1],'xticklabel',[-1:0.5:1],'FontSize',28);
    set(A,'ytick',[-1:0.5:1],'yticklabel',[-1:0.5:1],'FontSize',28);
    print(F,'-depsc',['FigureF3_' num2str(k2)]);
end
