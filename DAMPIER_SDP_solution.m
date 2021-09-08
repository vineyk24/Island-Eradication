clear all

run('Model parameterisation/Create_archipelago_SPOM_parameters_DAMPIER.m')

% How many times should we run the MC simulation
NumReps = 1000;


% Run the SDP solution with and without recolonisation
RunTMats = 1;
for Recolon = 0:1 % Are we allowing recolonisation to occur between islands?
    for Mainland = 0 % Are we allowing recolonisation to occur from the mainland?
        if RunTMats == 1
            
            load 'Model parameterisation'/DampierArchipelago_SPOM_data
            NumIslands = length(Dampier_Extinction);
            
            % How many states will there be (islands can be occupied or unoccupied).
            States = ff2n(NumIslands);
            NumStates = length(States);
            
            % Define value vector (we like states where there are more unoccupied islands)
            % We also like states where large islands are unoccupied
            %         V = sum(repmat(sqrt(Dampier_IslandArea'),NumStates,1).*(States==0),2);
            %         V = sum(States==0,2);
            V = sum(repmat((Dampier_IslandArea'),NumStates,1).*(States==0),2);
            
            % Define Markov transition matrix for doing nothing (by monte carlo methods)
            T_all = zeros(NumStates,NumStates,NumIslands+1);
            
            % Go through the states one-by-one
            
            % Transition matrix 1 = DO NOTHING
            T = zeros(NumStates,NumStates);
            for si = 1:NumStates
                if mod(si,50)==0; disp(['Completed state # ' num2str(si) ' out of ' num2str(NumStates)]); end
                
                for reps = 1:NumReps
                    
                    CurrentState = States(si,:);
                    
                    % Eradication first
                    
                    % Natural extinction second
                    Did_go_extinct = rand(1,NumIslands) < Dampier_Extinction;
                    CurrentState = CurrentState.*(1 - Did_go_extinct);
                    
                    % If we want recolonisation to occur between islands
                    if Recolon == 1
                        % Recolonisation third
                        for a = 1:NumIslands
                            for b = 1:NumIslands
                                if rand < Dampier_Colonisation(a,b) && CurrentState(a) == 1 && CurrentState(b) == 0
                                    CurrentState(b) = 1;
                                end
                            end
                        end
                    end
                    
                    % If we want recolonisation to occur from the mainland
                    if Recolon == 1 && Mainland == 1
                        % Mainland colonisation fourth
                        for a = 1:NumIslands
                            if rand < Dampier_MainlandColonisation(a) && CurrentState(a) == 0
                                CurrentState(a) = 1;
                            end
                        end
                    end
                    sf = find(ismember(States, CurrentState, 'rows'));
                    
                    T(si,sf) = T(si,sf) + 1;
                end
            end
            T = T./NumReps;
            T_all(:,:,1) = T; % Matrix 1 corresponds to doing nothing
            clear T
            
            if Recolon == 1
                if Mainland == 1;     save Dampier_SDP_Results_Yes_recolonisation
                elseif Mainland == 0; save Dampier_SDP_Results_Yes_recolonisation_No_mainland
                end
            else
                save Dampier_SDP_Results_No_recolonisation
            end
            
            % Create transition matrices for each of the island eradication choices in turn
            for Eradicate_this_island = 1:NumIslands
                
                disp(['Completed action # ' num2str(Eradicate_this_island)])
                
                for si = 1:NumStates
                    CurrentState = States(si,:);
                    
                    % If we start by eradicating from the island, we automatically shift into a different state
                    CurrentState(Eradicate_this_island) = 0;
                    sn = find(ismember(States, CurrentState, 'rows'));
                    
                    % Choose a new transition vector that is a weighted sum of the two possible end-states
                    T_all(si,:,Eradicate_this_island+1) = ...
                        T_all(sn,:,1).*Dampier_EradicationProbability(Eradicate_this_island) + ...
                        T_all(si,:,1).*(1-Dampier_EradicationProbability(Eradicate_this_island));
                    
                end
            end
        else
            if Recolon == 1
                if Mainland == 1;     save Dampier_SDP_Results_Yes_recolonisation
                elseif Mainland == 0; save Dampier_SDP_Results_Yes_recolonisation_No_mainland
                end
            else
                save Dampier_SDP_Results_No_recolonisation
            end
        end
        %% Apply SDP
        
        Timesteps = 50;
        ValueMatrix = zeros(NumStates,Timesteps+1);
        ValueMatrix(:,end) = V;
        
        discount_rate = -0.01; % Assign a discount rate to the future of 2.5%
        for t = Timesteps:-1:1 % Backward step through all the years
            for n = 1:NumIslands+1 % Go through all the actions
                Action_value(:,n) = T_all(:,:,n)*ValueMatrix(:,t+1) + V.*exp(discount_rate.*t);
                RelVal(t) = exp(discount_rate.*t);
            end
            [ValueMatrix(:,t), Optimal_action(:,t)] = max(Action_value,[],2);
        end
        Optimal_action
        
        if Recolon == 1
            if Mainland == 1;     save Dampier_SDP_Results_Yes_recolonisation
            elseif Mainland == 0; save Dampier_SDP_Results_Yes_recolonisation_No_mainland
            end
        else
            save Dampier_SDP_Results_No_recolonisation
        end
        
        clearvars -except Recolon RunTMats NumReps
    end
end



%                   o4    <---- islands (can eradicate)
%           o       |
%           |       |
%       o   |       |             o
% ===================================================
%       Mainland (always has invasive species)


% Si = [x x x 0]
% Sf = [x x x 1]
% p(Si,Sf) = c4











