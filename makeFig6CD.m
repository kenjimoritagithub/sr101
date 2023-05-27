% makeFig6CD

%
clear all
rand_seed = 22101801;
rand('twister',rand_seed);

%
n = 100;
a = [0.3 0.3];
b = [5 5];
lamda{1} = [0.4 0.4];
lamda{2} = [0.4 0];
rho = 0.2;
w = 0.5;
for k1 = 1:2
    for k2 = 1:n
        fprintf('sim %d-%d\n',k1,k2);
        Out{k1}{k2} = twostage_modiori_sim(a,b,lamda{k1},rho,w);
    end
end
save data22101801_Out Out

%
ini.a = [0.3 0.3];
ini.b = [5 5];
ini.lamda = 0.2;
ini.rho = 0.2;
ini.w_set = [0.2 0.5 0.8];
fminsearch_option = optimset('fminsearch');
fminsearch_option = optimset(fminsearch_option,'MaxFunEvals', 10000, 'MaxIter', 10000);
for k1 = 1:2
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
save data22101801_estparas estparas
save data22101801_w_flag1 w_flag1

% Wilcoxon rank-sum test (Mann Whitney U test) in R
load data22101801_w_flag1
for k1 = 1:2
    csvwrite(['data22101801_w_' num2str(k1) '.csv'],w_flag1{k1});
end
% codes in R
dat1 <- read.csv("C:/###/data22101801_w_1.csv", header=FALSE, sep=",")
dat2 <- read.csv("C:/###/data22101801_w_2.csv", header=FALSE, sep=",")
wilcox.test(dat1$V1, dat2$V1)
% <Results in R>
% Wilcoxon rank sum test with continuity correction
% data:  dat1$V1 and dat2$V1
% W = 5268, p-value = 0.5134
% alternative hypothesis: true location shift is not equal to 0

% figure
load data22101801_w_flag1
tmpX = [0.05:0.1:0.95];
%Ymax = 0;
for k1 = 1:2
    H{k1} = hist(w_flag1{k1},tmpX);
    %Ymax = max(Ymax,max(H{k1}));
end
%Ymax = ceil(Ymax/5)*5;
Ymax = 55; % to be the same as Ymax in (A,B)
tmp_CD = 'CD';
for k1 = 1:2
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
    print(F,'-depsc',['Figure6' tmp_CD(k1) 'left']);
end

% analysis of choice pattern
clear all
rand_seed = 22111202;
rand('twister',rand_seed);
num_sim = 1000;
a = [0.3 0.3];
b = [5 5];
lamda{1} = [0.4 0.4];
lamda{2} = [0.4 0];
rho = 0.2;
w = 0.5;
for k1 = 1:2
    choice_pattern_set{k1} = NaN(num_sim,4);
    for k2 = 1:num_sim
        fprintf('%d-%d\n',k1,k2);
        Out{k1}{k2} = twostage_modiori_sim(a,b,lamda{k1},rho,w);
        choice_pattern = zeros(2,4);
        for k = 1:length(Out{k1}{k2}.rewards)-1
            tmp_common = ((Out{k1}{k2}.choices(k,1)<1.5)&&(Out{k1}{k2}.choices(k,2)<4.5)) ||...
                ((Out{k1}{k2}.choices(k,1)>1.5)&&(Out{k1}{k2}.choices(k,2)>4.5));
            tmp_stay = (Out{k1}{k2}.choices(k+1,1) == Out{k1}{k2}.choices(k,1));
            choice_pattern(2-tmp_stay,2*(1-Out{k1}{k2}.rewards(k))+(2-tmp_common)) = ...
                choice_pattern(2-tmp_stay,2*(1-Out{k1}{k2}.rewards(k))+(2-tmp_common)) + 1;
        end
        choice_pattern_set{k1}(k2,:) = choice_pattern(1,:) ./ sum(choice_pattern,1);
    end
end
save data22111202_choice_pattern_set choice_pattern_set
tmp_CD = 'CD';
for k1 = 1:2
    F = figure;
    A = axes;
    hold on;
    axis([0 6 0.65 0.85]);
    P1 = bar([1 4],mean(choice_pattern_set{k1}(:,[1 3]),1),1/3);
    P2 = bar([2 5],mean(choice_pattern_set{k1}(:,[2 4]),1),1/3);
    Shading flat;
    P3 = errorbar([1 2 4 5],mean(choice_pattern_set{k1},1),std(choice_pattern_set{k1},1,1)/sqrt(num_sim),'k.');
    set(P1,'FaceColor',0.5*[1 1 1]);
    set(P2,'FaceColor',0*[1 1 1]);
    %set(P3,'MarkerSize',10);
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    set(A,'XTick',[1 2 4 5],'XTickLabel',[],'FontSize',20);
    set(A,'YTick',[0.65:0.05:0.85],'YTickLabel',[0.65:0.05:0.85],'FontSize',20);
    print(F,'-depsc',['Figure6' tmp_CD(k1) 'right']);
end
