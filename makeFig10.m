% makeFig10

%
clear all
rand_seed = 23051100;
rand('twister',rand_seed);
n = 200000;
x = [100:100:n];
a{1} = [0.01,0.09,0.09,0.01];
a{2} = [0.09,0.01,0.01,0.09];
a{3} = [0.05,0.05,0.05,0.05];
a{4} = [0.1,0.1,0,0];
a{5} = [0,0,0.1,0.1];
b = 10;
gm = 0.8;
pun_obstay = -0.2; % punishment upon staying at the obsession state
%
for k = 1:5
    out{k} = OCDalt(a{k},b,gm,pun_obstay,n);
end
%
F = figure;
for k = 1:5
    P = subplot(5,1,k); plot(x,out{k}.ma_obs(x),'k'); axis([0 n 0 1]);
    set(gca,'XTick',[0:50000:n],'XTickLabel',[0:5:n/10000],'YTick',[0:0.5:1],'YTickLabel',[0:0.5:1]);
    set(gca,'FontSize',8,'PlotBoxAspectRatio',[8 1 1]);
end
print(F,'-depsc','Figure10B');

%
clear all
n = 50000;
nsim = 100;
bgp{1} = [10 0.8 -0.2];
bgp{2} = [10 0.8 -0.1];
bgp{3} = [10 0.8 -0.3];
bgp{4} = [10 0.8 -0.4];
bgp{5} = [10 0.8 -0.5];
bgp{6} = [5 0.8 -0.2];
bgp{7} = [20 0.8 -0.2];
bgp{8} = [10 0.7 -0.2];
bgp{9} = [10 0.9 -0.2];
for k0 = 1:9
    rand_seed = 23051100 + k0;
    rand('twister',rand_seed);
    durOCburst{k0} = NaN(6,6,nsim);
    b = bgp{k0}(1);
    gm = bgp{k0}(2);
    pun_obstay = bgp{k0}(3);
    for k1 = 1:6
        for k2 = 1:6
            a = [(k1-1)*0.02, (k2-1)*0.02, 0.1-(k1-1)*0.02, 0.1-(k2-1)*0.02];
            for k3 = 1:nsim
                fprintf('%d-%d-%d-%d\n',k0,k1,k2,k3);
                out = OCDalt(a,b,gm,pun_obstay,n);
                durOCburst{k0}(k1,k2,k3) = sum(out.ma_obs>=0.5);
            end
        end
    end
    save(['OCDalt_' num2str(k0)],'durOCburst');
end
save durOCburst durOCburst
% plot
n = 50000;
FL{1}='C'; FL{2}='D1'; FL{3}='D2'; FL{4}='D3'; FL{5}='D4'; FL{6}='E1'; FL{7}='E2'; FL{8}='F1'; FL{9}='F2';
for k0 = 1:9
    F = figure;
    A = axes;
    hold on
    set(A,'PlotBoxAspectRatio',[1 1 1]);
    axis([0.5 6.5 0.5 6.5]);
    h_cl = max(max(mean(durOCburst{k0},3)));
    P1 = image(mean(durOCburst{k0},3)'*(64/h_cl));
    set(A,'xtick',[1 6],'xticklabel',[0 0.1],'FontSize',20);
    set(A,'ytick',[1 6],'yticklabel',[0 0.1],'FontSize',20);
    P2 = colorbar;
    if (h_cl/n)*100 < 1
        set(P2,'ytick',[0:0.01:1]*(n/100)*(64/h_cl),'yticklabel',[0:0.01:1],'FontSize',20);
    elseif (h_cl/n)*100 < 10
        set(P2,'ytick',[0:1:10]*(n/100)*(64/h_cl),'yticklabel',[0:1:10],'FontSize',20);
    else
        set(P2,'ytick',[0:5:25]*(n/100)*(64/h_cl),'yticklabel',[0:5:25],'FontSize',20);
    end
    print(F,'-depsc',['Figure10' FL{k0}]);
end
