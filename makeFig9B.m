% makeFig9B

%
clear all
num_sub = [23 58];
for k1 = 1:2
    choice_pattern_set{k1} = NaN(num_sub(k1),4);
    for k2 = 1:num_sub(k1)
        tmp = csvread(['exp' num2str(k1) 'sub' num2str(k2) '.csv']); % csv file containing G, K, L, and N columns of the original data file
        choices = NaN(200,2);
        choices(:,1) = tmp(:,1);
        choices(:,2) = 2*(tmp(:,3)-1) + tmp(:,2);
        rewards = tmp(:,4);
        choice_pattern = zeros(2,4);
        for k = 1:199
            if rewards(k) >= 0
                tmp_common = ((choices(k,1)<1.5)&&(choices(k,2)<4.5)) || ((choices(k,1)>1.5)&&(choices(k,2)>4.5));
                tmp_stay = (choices(k+1,1) == choices(k,1));
                choice_pattern(2-tmp_stay,2*(1-rewards(k))+(2-tmp_common)) =...
                    choice_pattern(2-tmp_stay,2*(1-rewards(k))+(2-tmp_common)) + 1;
            end
        end
        choice_pattern_set{k1}(k2,:) = choice_pattern(1,:) ./ sum(choice_pattern,1);
    end
end

%
for k1 = 1:2
    F = figure;
    A = axes;
    hold on;
    axis([0 6 0.5 1]);
    P1 = bar([1 4],mean(choice_pattern_set{k1}(:,[1 3]),1),1/3);
    P2 = bar([2 5],mean(choice_pattern_set{k1}(:,[2 4]),1),1/3);
    Shading flat;
    P3 = errorbar([1 2 4 5],mean(choice_pattern_set{k1},1),std(choice_pattern_set{k1},1,1)/sqrt(num_sub(k1)),'k.');
    set(P1,'FaceColor',0.5*[1 1 1]);
    set(P2,'FaceColor',0*[1 1 1]);
    %set(P3,'MarkerSize',10);
    set(A,'PlotBoxAspectRatio',[2 1 1]);
    set(A,'XTick',[1 2 4 5],'XTickLabel',[],'FontSize',20);
    set(A,'YTick',[0.5:0.1:1],'YTickLabel',[0.5:0.1:1],'FontSize',20);
    print(F,'-depsc',['Figure9B' num2str(k1)]);
end

% Exp1
csvwrite('data_Exp1_sub40_1.csv',choice_pattern_set{1}(:,1)-choice_pattern_set{1}(:,2));
csvwrite('data_Exp1_sub40_2.csv',choice_pattern_set{1}(:,4)-choice_pattern_set{1}(:,3));
% codes in R
dat1 <- read.csv("C:/###/data_Exp1_sub40_1.csv", header=FALSE, sep=",")
dat2 <- read.csv("C:/###/data_Exp1_sub40_2.csv", header=FALSE, sep=",")
shapiro.test(dat1$V1-dat2$V1) % Shapiro-Wilk normality test, W = 0.9806, p-value = 0.9162
t.test(dat1$V1, dat2$V1, paired=TRUE)
% Paired t-test
% data:  dat1$V1 and dat2$V1
% t = -1.3135, df = 22, p-value = 0.2025
% alternative hypothesis: true difference in means is not equal to 0
% 95 percent confidence interval:
%  -0.07685129  0.01724986
% sample estimates:
% mean of the differences 
% -0.02980072 

% Exp2
csvwrite('data_Exp2_sub40_1.csv',choice_pattern_set{2}(:,1)-choice_pattern_set{2}(:,2));
csvwrite('data_Exp2_sub40_2.csv',choice_pattern_set{2}(:,4)-choice_pattern_set{2}(:,3));
% codes in R
dat1 <- read.csv("C:/###/data_Exp2_sub40_1.csv", header=FALSE, sep=",")
dat2 <- read.csv("C:/###/data_Exp2_sub40_2.csv", header=FALSE, sep=",")
shapiro.test(dat1$V1-dat2$V1) % Shapiro-Wilk normality test, W = 0.96392, p-value = 0.08214
t.test(dat1$V1, dat2$V1, paired=TRUE)
% Paired t-test
% data:  dat1$V1 and dat2$V1
% t = -1.9884, df = 57, p-value = 0.05157
% alternative hypothesis: true difference in means is not equal to 0
% 95 percent confidence interval:
%  -0.0847515623  0.0002982278
% sample estimates:
% mean of the differences 
% -0.04222667 
