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
    
    subplot(3,2,[1 3]+recol-1); hold on; MS = 7;
    for i = 1:size(StateMatrix,1)
        for j = 1:size(StateMatrix,2)
            if StateMatrix(i,j) == 1
                plot(i,t-j,'ko','markersize',MS,'MarkerFaceColor','k')
            else
                plot(i,t-j,'ko','markersize',MS,'MarkerFaceColor','w')
            end
        end
    end
    xlim([0 10]); axis off
    
    
    for reps = 1:5000
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
    
    subplot(3,2,[5 6]); hold on
    if recol == 1
        [n,x] = hist(TV,15); n = n./max(n);
        PP(1) = plot(x,n,'b-','linewidth',2);
        MTV_Yes = mean(TV);
        plot(MTV_Yes.*[1 1],[0 0.1],'b-','linewidth',2)
    else
        [n,x] = hist(TV,15); n = n./max(n);
        PP(2) = plot(x,n,'k-','linewidth',2);
        MTV_No = mean(TV);
        plot(MTV_No.*[1 1],[0 0.1],'k-','linewidth',2)
        L = legend(PP,'Considering recolonisation','Ignoring recolonisation');
        set(L,'box','off','location','northwest')
    end
    
    clearvars -except recol T_all PP MTV*
end














