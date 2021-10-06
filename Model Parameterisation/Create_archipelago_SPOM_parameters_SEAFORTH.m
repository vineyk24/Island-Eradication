clear all

%% Calculate values for the Seaforth islands

load Seaforth_archipelago_data
PT = 1;

if PT == 1
    figure(1), clf; CL = get(gca,'colororder');
    subplot('position',[0 0 1 1]), hold on; set(gcf,'color','w')
    
    patch(SouthIsland(:,1),SouthIsland(:,2),ones(1,3)*0.85);
    for s = 1:length(IslandsWorthPlotting)
        plot(IslandsWorthPlotting{s}(:,1),IslandsWorthPlotting{s}(:,2),'k');
    end
    for s = 1:length(SeaforthIslands)
        pp = patch(SeaforthIslands(s).X(1:end-1),SeaforthIslands(s).Y(1:end-1),CL(1,:));
        set(pp,'facealpha',0.3)
        text(SeaforthIslands(s).X(1),SeaforthIslands(s).Y(1),num2str(s),'fontsize',20,'color',[0.7 0 0])
    end
    % xlim([MapLimits(1,:)])
    % ylim([MapLimits(2,:)])
    box off, axis off
    xlim([166.5603  166.9445])
    ylim([-45.8019 -45.7004 ])
end

NumPatches = length(SeaforthIslands);
% First define colonisation probability as a function of distance
% Fit data in Lohr et al. (2017)

% === Rats, Rattus spp ===
Dist = 0:50:1250;
Prob = zeros(size(Dist));
Prob(Dist<=1000) = 0.1;
Prob(Dist<=500) = 0.4;
Prob(Dist<=250) = 0.72;
Prob(Dist<50) = 1;
Dist = Dist./1000;
k = 2.6;
p = exp(-k.*Dist);
if PT == 1
    figure(4)
    subplot(2,1,2), hold on; box on, title('Rats')
    plot(Dist,Prob,'k.','markersize',12)
    xlabel('Distance (m)','fontsize',16)
    ylabel('Probability of colonisation','fontsize',16)
    ylim([0 1]); xlim([0 1.260])
    plot(Dist,p,'r--')
    ssd_r = sum((Prob-p).^2)
end

for p1 = 1:NumPatches
    for p2 = p1+1:NumPatches
        
        % Find the closest distance
        dst = 79*pdist2([SeaforthIslands(p1).X(1:end-1)' SeaforthIslands(p1).Y(1:end-1)'],...
            [SeaforthIslands(p2).X(1:end-1)' SeaforthIslands(p2).Y(1:end-1)']);
        mindist = min(dst(:));
        Seaforth_Distance(p1,p2) = mindist;
        Seaforth_Distance(p2,p1) = mindist;
    end
    
    % Find the closest distance to the mainland
    dst = 79*pdist2([SeaforthIslands(p1).X(1:end-1)' SeaforthIslands(p1).Y(1:end-1)'],SouthIsland);
    mindist = min(dst(:));
    Seaforth_MainlandDistance(p1,1) = mindist;
    Seaforth_IslandArea(p1,1) = polyarea(79*SeaforthIslands(p1).X(1:end-1)',79*SeaforthIslands(p1).Y(1:end-1)');
end

% Lohr et al. report that the likelihood of any dispersal attempt is 10% for rats, which we will increase by 100% for safety
Prob_any_attempt = 0.2;

Seaforth_Colonisation = Prob_any_attempt*exp(-k.*Seaforth_Distance);
Seaforth_MainlandColonisation = Prob_any_attempt*exp(-k.*Seaforth_MainlandDistance);

% Lohr et al. report a maximum distance of 500m, which we will increase by 100% for safety
Seaforth_MainlandColonisation(Seaforth_MainlandDistance > 2) = 0;
Seaforth_Colonisation(Seaforth_Distance > 1) = 0;

% Define natural extinction probability as a function of area
% We assume that rodent populations on islands are very unlikely to go extinct
% and that this probability is unrelated to the total patch area
P_ext = 0.05;

% Third, define eradication probability as a function of area

%     {'Failed'                }
%     {'In Progress'           }
%     {'Incomplete'            }
%     {'Planned'               }
%     {'Status (Eradication)'  }
%     {'Successful'            }
%     {'Successful (Reinvaded)'}
%     {'To Be Confirmed'       }
%     {'Trial or Research only'}
%     {'Unknown'               }
%     {'Unknown pre-status'    }

[D,T] = xlsread('DIISE_2018_query.xlsx'); T = T(2:end,:);
IslandArea = D(:,end);
EradStatus = T(:,4);
Success = nan*ones(1,length(EradStatus));
for e = 1:length(EradStatus)
    if EradStatus{e}(1) == 'S'
        Success(e) = 1;
    elseif EradStatus{e}(1) == 'F'
        Success(e) = 0;
    end
end
F = find(isnan(Success));
Success(F) = [];
IslandArea(F) = [];

% Fit a logistic regression to the binary data
mdl = fitglm(log(IslandArea),Success, "Distribution", "binomial")
xnew = linspace(-7,10,1000)';
ynew = predict(mdl, xnew);

% Plot the best-fit relationship
% figure(2), clf, hold on
% plot(log(IslandArea),Success,'.')
% plot(xnew, ynew,'k','linewidth',2);

% Use this to estimate the probability of extinction
Seaforth_EradicationProbability = predict(mdl,Seaforth_IslandArea);

% Define natural extinction probability as a function of area
% We assume that rodent populations on islands are very unlikely to go extinct
% and that this probability is unrelated to the total patch area
P_ext = 0.05;

NumPatches = length(SeaforthIslands);

% Calculate the extinction vector
Seaforth_Extinction = P_ext.*ones(1,NumPatches);

save SeaforthArchipelago_SPOM_data Seaforth* SouthIsland
return

% === Cane toads, Rhinella marinus ===
Dist = 0:15;
Prob = [1 0.7 0.7 0.4 0.4 0.4 0.1 0.1 0.1 0.1 0.1 0 0 0 0 0];
k = 0.26;
p = exp(-k.*Dist);
if PT == 1
    figure(2), clf; set(gcf,'color','w')
    subplot(2,1,1), hold on; box on
    plot(Dist,Prob,'k.','markersize',12)
    ylim([0 1]);
    xlabel('Distance (km)','fontsize',16)
    ylabel('Probability of colonisation','fontsize',16)
    plot(Dist,p,'r--')
    ssd_c = sum((Prob-p).^2)
end

