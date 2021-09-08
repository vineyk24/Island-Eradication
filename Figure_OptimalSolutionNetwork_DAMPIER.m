clear all

for Recolon = 1:2
    
    if Recolon == 1
        load Dampier_SDP_Results_Yes_recolonisation Dampier* States Optimal*
    else
        load Dampier_SDP_Results_No_recolonisation Dampier* States Optimal*
    end
    
    % Start in the final state, with 15 years to run
    CurrentState = [1 1 1 1 1 1 1 1 1 1];
    NumIslands = length(Dampier_IslandArea);
    
    for i = 1:NumIslands
        ThisStateIndex = find(ismember(States, CurrentState, 'rows'))
        IslandOrder(i) = Optimal_action(ThisStateIndex,end-NumIslands-1+i)-1
        CurrentState(IslandOrder(i)) = 0
    end
    
    figure(Recolon), set(gcf,'color','w')
    clf, subplot('position',[0 0 1 1]); hold on; FS = 10;
    SHIFT = [0 0];
    CreateNetworkDiagrams_DAMPIER
    
    L = -0.025;
    d = 0.05;
    CL = [0 0.25 0];
    for i = 1:NumIslands
        
        plot([Dampier_centroids(IslandOrder(i),1) Dampier_centroids(IslandOrder(i),1)],...
            [Dampier_centroids(IslandOrder(i),2)-d/2 L-(i-0.75)*d ],'--','color',0.7.*ones(1,3));
        
        if i > 1
            plot([Dampier_centroids(IslandOrder(i-1),1) Dampier_centroids(IslandOrder(i),1)],...
                [L-(i-0.5)*d L-(i-0.5)*d],'color',CL)
            
        end
        
        if i == 1
            plot([Dampier_centroids(IslandOrder(i),1) Dampier_centroids(IslandOrder(i),1)],...
                [L-(i+0.5)*d L-(i-0.25)*d],'color',CL)
        elseif i == NumIslands
            plot([Dampier_centroids(IslandOrder(i),1) Dampier_centroids(IslandOrder(i),1)],...
                [L-(i+0.25)*d L-(i-0.5)*d],'color',CL)
        else
            plot([Dampier_centroids(IslandOrder(i),1) Dampier_centroids(IslandOrder(i),1)],...
                [L-(i+0.5)*d L-(i-0.5)*d],'color',CL)
        end
    end
    
    for i = 1:NumIslands
        text(Dampier_centroids(IslandOrder(i),1),L-i*d,num2str(i+2025),'horizontalalignment','center','backgroundcolor','w','color',CL,'fontsize',FS)
    end
    
    ylim([-0.55 1.1])
    if Recolon == 1
        Make_TIFF('../Manuscript/Figures/Dampier_optimal_solution_YesRecolon.tiff',[0 0 17 22])
    else
        Make_TIFF('../Manuscript/Figures/Dampier_optimal_solution_NoRecolon.tiff',[0 0 17 22])
    end
    
end

