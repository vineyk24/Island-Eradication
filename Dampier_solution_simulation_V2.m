clear all

% This file simulates the metapopulation dynamics under optimal policies. It measures the
% performance distribution under a management policy that admits the possibility of recolonisation
% and under a management policy that ignores the role of recolonisation (inter-island and mainland).

figure(1), clf;

for recol = 1:2
    
    % Load the optimal solution results
    if recol == 1
        load Dampier_SDP_Results_Yes_recolonisation Num* States T* Optimal_action V di*
    elseif recol == 2
        load Dampier_SDP_Results_No_recolonisation Num* States Optimal_action V di*
    end
    
    TMax = 2*NumIslands; % How long will we run the simulation for?
    
    S_i = NumStates; % Let's start in the "all invaded" state
    S_i_V = S_i;
    Total_V = V(S_i);
    StateMatrix = States(S_i,:)';
    for t = 1:TMax
        
        %% If recolonisation has been considered
        
        % What should I do in this state, at this time?
        A(t) = Optimal_action(S_i,end-TMax+t);
        
        % What transition vector is expected?
        This_T_Vec = T_all(S_i,:,A(t));
        
        % What's the outcome?
        S_i = randsample(NumStates,1,'true',This_T_Vec);
        
        Total_V = Total_V  + V(S_i).*exp(discount_rate.*t);
        S_i_V = [S_i_V; S_i];
        NumIslands = [NumIslands; sum(States(S_i,:))];
        StateMatrix = [StateMatrix States(S_i,:)'];
    end
        
    for reps = 1:500
        S_i = NumStates; % Let's start in the "all invaded" state
        Total_V = 0;
        for t = 1:TMax
            A = Optimal_action(S_i,end-TMax+t);
            This_T_Vec = T_all(S_i,:,A);
            S_i = randsample(NumStates,1,'true',This_T_Vec);
            Total_V = Total_V  + V(S_i).*exp(discount_rate.*t);
        end
        TV(reps) = Total_V;
    end
    
    subplot(2,1,1); hold on; E = linspace(0,150,50);
    if recol == 1
        n = histc(TV,E); n = n./max(n);
        PP(1) = bar(E,n,0.8);
        set(PP(1),'facealpha',0.5,'edgecolor','none')
        MTV_Yes = mean(TV);
    else
        n = histc(TV,E); n = n./max(n);
        PP(2) = bar(E,n,0.6);
        set(PP(2),'facealpha',0.5,'edgecolor','none')
        MTV_No = mean(TV);
        L = legend(PP,'Considering recolonisation','Ignoring recolonisation');
        set(L,'box','off','location','northeast','fontsize',18)
        xlim([0 120])
        h = gca; h.YAxis.Visible = 'off';
    end
    
    clearvars -except recol T_all PP MTV*
end














