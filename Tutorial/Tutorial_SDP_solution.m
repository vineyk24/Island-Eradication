clear all

% How many times should we run the MC simulation
NumReps = 10;


% Run the SDP solution with and without recolonisation
RunTMats = 1;
if RunTMats == 1
    
    % Extract data on the location of the islands
    Island_coordinates = csvread('Tutorial_island_location.csv');
    NumIslands = length(Island_coordinates);
    
    % Extract data on extinction and eradication rates
    Tutorial_Extinction = csvread('Tutorial_natural_extinction.csv');
    Tutorial_EradicationProbability = csvread('Tutorial_eradication_probability.csv');
    % Extract data on the island area
    Tutorial_IslandArea = csvread('Tutorial_island_area.csv');
    
    % Extract data on recolonisation
    Tutorial_Colonisation = csvread('Tutorial_recolonisation_probabilities.csv');
    Tutorial_MainlandColonisation = csvread('Tutorial_recolonisation_probabilities_mainland.csv');
    
    % How many states will there be (islands can be occupied or unoccupied).
    States = ff2n(NumIslands);
    NumStates = length(States);
    
    % Define value vector 

    % This first value vector prefers states where a larger amount of island area is unoccupied by
    % the invasive species
    V = sum(repmat((Tutorial_IslandArea'),NumStates,1).*(States==0),2);

    % This second value vector prefers states where there are a larger number of islands that are 
    % unoccupied by the invasive species, regardless of their area.
    % V = sum(States==0,2);
    
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
            Did_go_extinct = rand(1,NumIslands) < Tutorial_Extinction;
            CurrentState = CurrentState.*(1 - Did_go_extinct);
            
            % Recolonisation third
            for a = 1:NumIslands
                for b = 1:NumIslands
                    if rand < Tutorial_Colonisation(a,b) && CurrentState(a) == 1 && CurrentState(b) == 0
                        CurrentState(b) = 1;
                    end
                end
            end
            
            % Mainland colonisation fourth
            for a = 1:NumIslands
                if rand < Tutorial_MainlandColonisation(a) && CurrentState(a) == 0
                    CurrentState(a) = 1;
                end
            end
            sf = find(ismember(States, CurrentState, 'rows'));
            
            T(si,sf) = T(si,sf) + 1;
        end
    end
    T = T./NumReps;
    T_all(:,:,1) = T; % Matrix 1 corresponds to doing nothing
    clear T
        
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
                T_all(sn,:,1).*Tutorial_EradicationProbability(Eradicate_this_island) + ...
                T_all(si,:,1).*(1-Tutorial_EradicationProbability(Eradicate_this_island));
            
        end
    end
else
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
Optimal_island_to_eradicate = Optimal_action-1

save Tutorial_SDP_Results








