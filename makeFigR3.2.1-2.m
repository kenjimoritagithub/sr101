%% FigR3.2.1

% reset rand
clear all
rand_seed_base = 23030801;

% parameters for the agent function
a_base = 0.1;
b = 10;
n = 50000;
type_of_learning = 1;
decay_rate = 0.001;

% parameters for simulations
f = 10; % fineness of the variations of the learning rates
n_sim = 100;
res.ma_obs_end = NaN(f+1,f+1,n_sim);

% simulations
for k1 = 0:1:f
    rand_seed = rand_seed_base + k1;
    rand('twister',rand_seed);
    SR_ap = a_base * (k1/f);
    IR_ap = a_base - SR_ap;
    for k2 = 0:1:f
        SR_an = a_base * (k2/f);
        IR_an = a_base - SR_an;
        for k3 = 1:n_sim
            fprintf('%d-%d-%d\n',k1,k2,k3);
            out = OCD_model_rev_decay_scaling(type_of_learning,SR_ap,SR_an,IR_ap,IR_an,b,n,decay_rate);
            res.ma_obs_end(k1+1,k2+1,k3) = out.ma_obs(end);
        end
    end
    save(['respart' num2str(rand_seed)],'res');
end

% integrate the saved results
f = 10; % fineness of the variations of the learning rates
n_sim = 100;
tmp_res.ma_obs_end = NaN(f+1,f+1,n_sim);
for k1 = 0:1:f
    rand_seed = rand_seed_base + k1;
    load(['respart' num2str(rand_seed) '.mat']);
    tmp_res.ma_obs_end(k1+1,:,:) = res.ma_obs_end(k1+1,:,:);
    clear res
end
res = tmp_res;
save(['res' num2str(rand_seed_base)],'res');

% plot
load(['res' num2str(rand_seed_base) '.mat']);
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
print(F,'-depsc','FigureR3.2.1');

%% FigR3.2.2

clear all
rand_seed = 23030703;
rand('twister',rand_seed);
n = 50000;
out = OCD_model_rev_decay_scaling(1,0.09,0.01,0.01,0.09,10,n,0);
F = figure;
A = axes;
hold on
set(A,'PlotBoxAspectRatio',[2 1 1]);
axis([0 n -120 80]);
P = plot([0 n],[0 0],'k:');
tmp_color = 'rkbg';
P = plot([1:n],out.w_t(1,:),'r');
P = plot([1:n],out.IR_Q_t(1,:),'b');
set(A,'xtick',[0:10000:n],'xticklabel',[0:10000:n],'FontSize',28);
set(A,'ytick',[-120:20:80],'yticklabel',[-120:20:80],'FontSize',28);
print(F,'-depsc','FigureR3.2.2');