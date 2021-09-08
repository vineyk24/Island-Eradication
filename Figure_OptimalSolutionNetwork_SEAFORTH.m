clear all
for Recolon = 1:2
    
    if Recolon == 1
        load Seaforth_SDP_Results_Yes_recolonisation Optim* States
    else
        load Seaforth_SDP_Results_No_recolonisation Optim* States
    end
    
    % Start in the final state, with 15 years to run
    CurrentState = [1 1 1 1 1 1 1 1];
    
    for i = 1:8
        ThisStateIndex = find(ismember(States, CurrentState, 'rows'))
        IslandOrder(i) = Optimal_action(ThisStateIndex,end-15+i)-1
        CurrentState(IslandOrder(i)) = 0
    end
    
    figure(Recolon), clf, subplot('position',[0 0 1 1]); hold on
    SHIFT = [0 0];
    CreateNetworkDiagrams_SEAFORTH
    L = 0.12;
    d = 0.05;
    CL = [0 0.25 0];
    for i = 1:8
        
        plot([Seaforth_centroids(IslandOrder(i),1) Seaforth_centroids(IslandOrder(i),1)],...
            [Seaforth_centroids(IslandOrder(i),2)-d/2 L-(i-0.75)*d ],'--','color',0.7.*ones(1,3));
        
        if i > 1
            plot([Seaforth_centroids(IslandOrder(i-1),1) Seaforth_centroids(IslandOrder(i),1)],...
                [L-(i-0.5)*d L-(i-0.5)*d],'color',CL)
            
        end
        
        if i == 1
            plot([Seaforth_centroids(IslandOrder(i),1) Seaforth_centroids(IslandOrder(i),1)],...
                [L-(i+0.5)*d L-(i-0.25)*d],'color',CL)
        elseif i == 8
            plot([Seaforth_centroids(IslandOrder(i),1) Seaforth_centroids(IslandOrder(i),1)],...
                [L-(i+0.25)*d L-(i-0.5)*d],'color',CL)
        else
            plot([Seaforth_centroids(IslandOrder(i),1) Seaforth_centroids(IslandOrder(i),1)],...
                [L-(i+0.5)*d L-(i-0.5)*d],'color',CL)
        end
    end
    
    for i = 1:8
        text(Seaforth_centroids(IslandOrder(i),1),L-i*d,num2str(i+2025),'horizontalalignment','center','backgroundcolor','w','color',CL)
    end
    
    ylim([-0.325 0.85])
    
    if Recolon == 1
        Make_TIFF('../Manuscript/Figures/Seaforth_optimal_solution_YesRecolon.tiff',[0 0 17 22])
    else
        Make_TIFF('../Manuscript/Figures/Seaforth_optimal_solution_NoRecolon.tiff',[0 0 17 22])
    end
end

