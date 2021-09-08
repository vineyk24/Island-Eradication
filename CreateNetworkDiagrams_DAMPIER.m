
% This file creates an simplified network outline for the two archipelagos

Dampier_centroids = [  
  116.6  -20.51
  116.6813  -20.5134
  116.6651  -20.5201
  116.63  -20.6
  116.57  -20.58
  116.6439  -20.5525
  116.6555  -20.6146
  116.673  -20.6528
  116.53  -20.64
  116.59  -20.7003];

Dampier_centroids = Dampier_centroids - repmat(min(Dampier_centroids),10,1);
Dampier_centroids = Dampier_centroids./repmat(max(Dampier_centroids),10,1);

% if exist('SHIFT') == 0; SHIFT = [0 0]; end
% % Shift for plotting reasons
% Dampier_centroids = Dampier_centroids + repmat(SHIFT,size(Dampier_centroids,1),1);

LW = 2; MS = 50;
load 'Model parameterisation'/DampierArchipelago_SPOM_data *Colonisation

for i = 1:10
    for j = i+1:10
        if Dampier_Colonisation(i,j) > 0
            plot([Dampier_centroids(i,1) Dampier_centroids(j,1)],...
                 [Dampier_centroids(i,2) Dampier_centroids(j,2)],...
                 'linewidth',LW,'color',[0 0 0.5])
        end
    end
end

for i = 1:10
    if Dampier_MainlandColonisation(i) > 0
        plot(Dampier_centroids(i,1),Dampier_centroids(i,2),'.','markersize',MS,'color',[1 0.4 0.4])
    else
        plot(Dampier_centroids(i,1),Dampier_centroids(i,2),'.','markersize',MS,'color',0.65.*ones(1,3))
    end
%     text(0.02+Dampier_centroids(i,1),Dampier_centroids(i,2),num2str(i),'fontsize',10)
end

xlim([-0.1 1.1])
ylim([-0.5 1.05])
axis off