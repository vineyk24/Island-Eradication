clear all

%% Calculate values for the Dampier islands
PT = 1;

PLY =   [116.4134  -20.7440
         116.4126  -20.4203
         116.7511  -20.4330
         116.7398  -20.7465];

% PLY =   [113.4134  -25.7440
%          113.4126  -10.4203
%          119.7511  -10.4330
%          119.7398  -25.7465];
     
% Calculate the geographical data for the archipelago
S = shaperead('/Users/bodem/Dropbox/MXN423_Modelling_in_Ecology/Project 1 - Eradicating from islands/Matlab/OLD/western_australia/cstwacd_r.shp');
if PT == 1
    figure(1), clf; CL = get(gca,'colororder');
    subplot('position',[0 0 1 1]), axis off
    hold on; set(gcf,'color','w')
end
count = 1;
for s = 1:length(S)
    if strcmp(S(s).GROUP_NAME,'DAMPIER ARCHIPELAGO')==1 & S(s).AREA > 7e-5
        if inpolygon(S(s).X(1),S(s).Y(1),PLY(:,1),PLY(:,2)) == 1
            if s ~= 3000
                DampierIslands{count} = [S(s).X(1:end-1)' S(s).Y(1:end-1)'];
                Dampier_IslandArea(count,1) = S(s).AREA*110^2;
                count = count + 1;
            end
        end
    end
end
disp(['Modelling ' num2str(count-1) ' islands'])

t = DampierIslands{5};
DampierIslands{5} = DampierIslands{6};
DampierIslands{6} = t;
if PT == 1
    for i = 1:count-1
        pp = patch(DampierIslands{i}(:,1),DampierIslands{i}(:,2),CL(1,:));set(pp,'facealpha',0.2);
        text(DampierIslands{i}(1,1),DampierIslands{i}(1,2),num2str(i),'color','r','fontsize',20);
    end
end

load AustStateOutlines StateRaw
F = find(isnan(StateRaw(:,1)));
WA_coastline = [StateRaw(F(1505):F(1506),1),StateRaw(F(1505):F(1506),2)];
if PT == 1
    pp = patch(WA_coastline(2:end-1,1),WA_coastline(2:end-1,2),'k'); set(pp,'facealpha',0.2);
    xlim([116.4000  117.0000])
    ylim([-20.7500  -20.3500])
end

NumPatches = length(DampierIslands)
% First define colonisation probability as a function of distance
% Fit data in Lohr et al. (2017)

% === Cane toads, Rhinella marinus ===
Dist = [0:15]*1000;
Prob = [1 0.7 0.7 0.4 0.4 0.4 0.1 0.1 0.1 0.1 0.1 0 0 0 0 0];
k = 0.25/1000;
p = exp(-k.*Dist);
if PT == 1
    figure(4)
    subplot(2,1,1), cla, hold on; box on
    title('Cane toads')
    plot(Dist,Prob,'k.','markersize',12)
    ylim([0 1]);
    xlabel('Distance (m)','fontsize',16)
    ylabel('Probability of colonisation','fontsize',16)
    plot(Dist,p,'r--')
    ssd_c = sum((Prob-p).^2)
end
return
for p1 = 1:NumPatches
    for p2 = p1+1:NumPatches
        
        % Find the closest distance
        dst = 110*pdist2(DampierIslands{p1},DampierIslands{p2});
        mindist = min(dst(:));
        Dampier_Distance(p1,p2) = mindist;
        Dampier_Distance(p2,p1) = mindist;
    end
    
    % Find the closest distance to the mainland
    dst = 110*pdist2(DampierIslands{p1},WA_coastline);
    mindist = min(dst(:));
    Dampier_MainlandDistance(p1,1) = mindist;
end
Dampier_Colonisation = exp(-k.*Dampier_Distance);
Dampier_MainlandColonisation = exp(-k.*Dampier_MainlandDistance);

% Lohr et al. report that the likelihood of Cane Toads making any dispersal attempt is 50%
Prob_any_attempt = 0.5;

Dampier_Colonisation = Prob_any_attempt*exp(-k.*Dampier_Distance);
Dampier_MainlandColonisation = Prob_any_attempt*exp(-k.*Dampier_MainlandDistance);

% Lohr et al. report a maximum distance of 5000m, which we will increase by 50% for safety
Dampier_Colonisation(Dampier_Distance>5) = 0
Dampier_MainlandColonisation(Dampier_MainlandDistance>5) = 0

% Define natural extinction probability as a function of area
% We assume that cane toad populations on islands are very unlikely to go extinct
% and that this probability is unrelated to the total patch area
P_ext = 0.05;
Dampier_Extinction = P_ext.*ones(1,NumPatches);

% Third, define eradication probability as a function of area
% If we have 100% of the needed budget, we have a 100% probability of eradication
% If we have 10% of the budget, we have a 10$ chance.
AnnualBudget = 1e5;
EradicationCost_perkm = 96556;
Dampier_EradicationProbability = min(1,AnnualBudget./(Dampier_IslandArea*EradicationCost_perkm));

save DampierArchipelago_SPOM_data Dampier* WA*

%Extinction EradicationProbability *Colonisation Seaforth_IslandArea SeaforthIslands SouthIsland IslandArea Distance
return


