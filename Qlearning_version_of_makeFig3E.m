% Qlearning_version_of_makeFig3E

% reset rand
clear all
rand_seed = 22102206;
rand('twister',rand_seed);

% parameters for the agent function
a_base = 0.1;
b = 10;
n = 5000;
type_of_learning = 2;

% parameters for simulations
f = 10; % fineness of the variations of the learning rates
n_sim = 100;
res.ma_obs_end = NaN(f+1,f+1,n_sim);

% simulations
for k1 = 0:1:f
    SR_ap = a_base * (k1/f);
    IR_ap = a_base - SR_ap;
    for k2 = 0:1:f
        SR_an = a_base * (k2/f);
        IR_an = a_base - SR_an;
        for k3 = 1:n_sim
            fprintf('%d-%d-%d\n',k1,k2,k3);
            out = OCD_model(type_of_learning,SR_ap,SR_an,IR_ap,IR_an,b,n);
            res.ma_obs_end(k1+1,k2+1,k3) = out.ma_obs(end);
        end
    end
end
save(['res' num2str(rand_seed)],'res');

% plot
load(['res' num2str(rand_seed)],'res');
F = figure;
A = axes;
hold on
set(A,'PlotBoxAspectRatio',[1 1 1]);
axis([0.5 f+1.5 0.5 f+1.5]);
h_cl = max(max(mean(res.ma_obs_end,3)));
P1 = image(mean(res.ma_obs_end,3)'*(64/h_cl));
set(A,'xtick',[1 (f+2)/2 f+1],'xticklabel',[0 a_base/2 a_base],'FontSize',20);
set(A,'ytick',[1 (f+2)/2 f+1],'yticklabel',[0 a_base/2 a_base],'FontSize',20);
P2 = colorbar;
set(P2,'ytick',[0:0.1:0.5]*(64/h_cl),'yticklabel',[0:0.1:0.5],'FontSize',20);
print(F,'-depsc','QFigure3E');
