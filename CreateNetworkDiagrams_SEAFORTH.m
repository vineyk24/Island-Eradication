
% This file creates an simplified network outline for the two archipelagos

Seaforth_centroids = [  166.9275  -45.7254
                        166.8345  -45.7325
                        166.79  -45.75
                        166.6955  -45.76
                        166.58  -45.78
                        166.625  -45.783
                        166.603  -45.7962
                        166.56  -45.7916];

Seaforth_centroids = Seaforth_centroids - repmat(min(Seaforth_centroids),8,1);
Seaforth_centroids = Seaforth_centroids./repmat(max(Seaforth_centroids),8,1);

Seaforth_centroids(Seaforth_centroids(:,1)>0.3,:) = Seaforth_centroids(Seaforth_centroids(:,1)>0.3,:)*0.8;
Seaforth_centroids(Seaforth_centroids(:,1)<0.3,:) = Seaforth_centroids(Seaforth_centroids(:,1)<0.3,:)*1.2;

if exist('SHIFT') == 0; SHIFT = [0 0]; end
% Shift for plotting reasons
Seaforth_centroids = Seaforth_centroids + repmat(SHIFT,size(Seaforth_centroids,1),1);

LW = 2; MS = 50;
load 'Model parameterisation'/SeaforthArchipelago_SPOM_data *Colonisation

for i = 1:8
    for j = i+1:8
        if Seaforth_Colonisation(i,j) > 0
            plot([Seaforth_centroids(i,1) Seaforth_centroids(j,1)],...
                 [Seaforth_centroids(i,2) Seaforth_centroids(j,2)],...
                 'linewidth',LW,'color',[0 0 0.5])
        end
    end
end

for i = 1:8
    if Seaforth_MainlandColonisation(i) > 0
        plot(Seaforth_centroids(i,1),Seaforth_centroids(i,2),'.','markersize',MS,'color',[1 0.4 0.4])
    else
        plot(Seaforth_centroids(i,1),Seaforth_centroids(i,2),'.','markersize',MS,'color',0.65.*ones(1,3))
    end
%     text(0.02+Seaforth_centroids(i,1),Seaforth_centroids(i,2),num2str(i),'fontsize',10)
end
xlim([-0.1 1])
ylim([-0.5 0.8])
axis off