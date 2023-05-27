% makeFig9Abottom

% analysis of choice pattern
clear all
rand_seed = 23030101;
rand('twister',rand_seed);
num_sim = 1000;
lrset = [0.03 0.27 0.27 0.03 0.05];
choice_pattern_set = NaN(num_sim,4);
for k2 = 1:num_sim
    fprintf('%d\n',k2);
    Out{k2} = twostagePun_srir_sim(lrset,5,1,1);
    choice_pattern = zeros(2,4);
    for k = 1:length(Out{k2}.rewards)-1
        tmp_common = ((Out{k2}.choices(k,1)<1.5)&&(Out{k2}.choices(k,2)<4.5)) ||...
            ((Out{k2}.choices(k,1)>1.5)&&(Out{k2}.choices(k,2)>4.5));
        tmp_stay = (Out{k2}.choices(k+1,1) == Out{k2}.choices(k,1));
        choice_pattern(2-tmp_stay,2*(1-(Out{k2}.rewards(k)+1))+(2-tmp_common)) = ...
            choice_pattern(2-tmp_stay,2*(1-(Out{k2}.rewards(k)+1))+(2-tmp_common)) + 1;
    end
    choice_pattern_set(k2,:) = choice_pattern(1,:) ./ sum(choice_pattern,1);
end
save data23030101_choice_pattern_set choice_pattern_set
F = figure;
A = axes;
hold on;
axis([0 6 0.4 0.6]);
P1 = bar([1 4],mean(choice_pattern_set(:,[1 3]),1),1/3);
P2 = bar([2 5],mean(choice_pattern_set(:,[2 4]),1),1/3);
Shading flat;
P3 = errorbar([1 2 4 5],mean(choice_pattern_set,1),std(choice_pattern_set,1,1)/sqrt(num_sim),'k.');
set(P1,'FaceColor',0.5*[1 1 1]);
set(P2,'FaceColor',0*[1 1 1]);
%set(P3,'MarkerSize',10);
set(A,'PlotBoxAspectRatio',[2 1 1]);
set(A,'XTick',[1 2 4 5],'XTickLabel',[],'FontSize',20);
set(A,'YTick',[0.4:0.05:0.6],'YTickLabel',[0.4:0.05:0.6],'FontSize',20);
print(F,'-depsc','Figure9Abottom');
