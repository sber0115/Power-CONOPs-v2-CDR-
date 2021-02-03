%% Populating crater and rock vectors according to user parameters
%  Crater and rock characteristics determined by the Rock and
%  CraterDistribution files
if (enable_rocks)
    rock_findings = randi([occlusion_end_time, length(time_vector)], 1, length(rockAvoidances)*2);
    all_avoided_rocks = zeros(1, length(rockAvoidances));
else
    rock_findings = [];
    all_avoided_rocks = [];
end

if (enable_shadows)
    shadow_findings = randi([occlusion_end_time, length(time_vector)], 1, 50);
else
    shadow_findings = [];
end

if (enable_craters)
    crater_findings = randi([occlusion_end_time, length(time_vector)], 1, length(craterAvoidances)*2);
    all_avoided_craters = zeros(1, length(craterAvoidances));
else
    crater_findings = [];
    all_avoided_craters = [];
end

%%
rock_find_index = 1;
rock_turn_energy = 0;
rock_straight_distance = 0;
rock_turn_time = 0;

crater_find_index = 1;
crater_turn_energy = 0;
crater_straight_distance = 0;
crater_turn_time = 0;

is_charging = false;
is_avoiding_rock = false;
is_avoiding_crater = false;
in_shadow    = false;
changed_direction = false;

change_power_multiplier = false;

time_avoiding_rock = 0; %[secs]
time_avoiding_crater = 0; %[secs]
time_in_shadow = 0; %[secs]
distance_covered = 0;
direction_change_time = 0;
backAtLander_time = 0;

%{
Factor by which the distance travelled toward target decreases 
is determined by calculating two times

Time 1: Determining time required to execute avoidance
Time 2: Determining time it takes rover to travel (diameter of turn) meters, 
        assuming a straight path
Take the ratio of time2/time1
%}

%% Control flow for obstacle avoidance
soc_under_100 = true; %flag to make sure battery state of charge is under 100%
for i = length(trek_phase1)+1:length(time_vector)
    spec_time = time_vector(i);
    rock_found = ismember(spec_time, rock_findings);
    shadow_found = ismember(spec_time, shadow_findings);
    crater_found = ismember(spec_time, crater_findings);
    change_power_multiplier = ismember(spec_time, occ_times);
    
    if (change_power_multiplier && occ_index < length(occ_times))
       occ_index = occ_index + 1; 
    end
    
    if (distance_travelled(i-1) >= 500 && ~is_avoiding_rock & ~is_avoiding_crater)
       changed_direction = true; 
       direction_change_time = spec_time;
    end
    
    power_multiplier = occ_multipliers_site1(occ_index); %site 1
    %power_fraction is the factor by which max_solar_flux is multiplied (< 1)
 
    can_avoid_rock = ~is_avoiding_rock && ~is_avoiding_crater ...
                     && rock_find_index <= length(rockAvoidances);
    %similarly for craters
    can_avoid_crater = ~is_avoiding_crater && ~is_avoiding_rock ...
                       && crater_find_index <= length(craterAvoidances);
    
    if (spec_time < 92136)
        energy_change = (max_solar_flux*power_multiplier - occlusion_mode*efficiency_multipliers(i));
        distance_covered = 0;
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ROCK AVOIDANCE
    elseif (rock_found && can_avoid_rock)    
        all_avoided_rocks(rock_find_index) = rockAvoidances(4, rock_find_index);
        is_avoiding_rock = true;
        time_avoiding_rock = 0;
        
        rock_turn_energy = rockAvoidances(1,rock_find_index);
        rock_straight_distance = rockAvoidances(2, rock_find_index);
        rock_avoidance_duration = rockAvoidances(3,rock_find_index);
        %calculate linear distance factor (factor by which speed is affected during skid-steer)
        straight_total_time = rock_straight_distance / velocity_m;
        linear_distance_factor = straight_total_time / rock_avoidance_duration;
        
        avionics_consumption = extreme_rove_mode;
        %note, rock turn energy given in Joules, but total energy must be
        %expended over the duration of the entire manuever, so we must
        %divide by the manuever duration 
        avoidance_consumption = rock_turn_energy / rock_avoidance_duration;
        power_generated = (max_solar_flux*angle_offset(i))*0.6;         
        energy_change = power_generated + -1 *(avoidance_consumption + avionics_consumption);    
     
        rock_find_index = rock_find_index + 1;
        
        distance_covered = normal_distance*linear_distance_factor;
   
    elseif (is_avoiding_rock)
        if (time_avoiding_rock == rock_avoidance_duration-1)
            is_avoiding_rock = false;
            time_avoiding_rock = 0;
            energy_change = max_solar_flux*angle_offset(i) - nominal_rove_mode;
    
            distance_covered = normal_distance;
            
        else %still avoiding rock
            time_avoiding_rock = time_avoiding_rock + 1;
            
            if (time_in_shadow >= max_shadow_time)
                time_in_shadow = 0;
                in_shadow = false;
                power_generated = (max_solar_flux*angle_offset(i)); 
            elseif (in_shadow)
                time_in_shadow = time_in_shadow + 1;
                power_generated = 0;
                power_generated = (max_solar_flux*angle_offset(i))*0.6;  
            end
             
            energy_change = power_generated + -1 *(avoidance_consumption + avionics_consumption); 
     
            distance_covered = (normal_distance*linear_distance_factor);
        end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CRATER AVOIDANCE
    elseif (crater_found && can_avoid_crater)  
        all_avoided_craters(crater_find_index) = craterAvoidances(4, crater_find_index);
        is_avoiding_crater = true;
        time_avoiding_crater = 0;
        
        crater_turn_energy = craterAvoidances(1,crater_find_index);
        crater_straight_distance = craterAvoidances(2, crater_find_index);
        crater_avoidance_duration = craterAvoidances(3,crater_find_index);
        %calculate linear distance factor (factor by which speed is affected during skid-steer)
        straight_total_time = crater_straight_distance / velocity_m;
        linear_distance_factor = straight_total_time / crater_avoidance_duration;
        avionics_consumption = extreme_rove_mode;
        avoidance_consumption = crater_turn_energy / crater_avoidance_duration; 
        power_generated = (max_solar_flux*angle_offset(i))*0.6;    
        energy_change = power_generated + -1 *(avoidance_consumption + avionics_consumption); 
  
        distance_covered = (normal_distance*linear_distance_factor);
        crater_find_index = crater_find_index + 1;
        
    elseif (is_avoiding_crater)
        if (time_avoiding_crater == crater_avoidance_duration-1)
            is_avoiding_crater = false;
            time_avoiding_crater = 0;
            %finished avoiding crater so back to nominal rove
            energy_changed = max_solar_flux*angle_offset(i) - nominal_rove_mode;
     
            distance_covered = normal_distance;
            
        else %still avoiding crater
            time_avoiding_crater = time_avoiding_crater + 1;
 
            
            if (time_in_shadow >= max_shadow_time)
                time_in_shadow = 0;
                in_shadow = false;
                power_generated = (max_solar_flux*angle_offset(i));
            elseif (in_shadow)
                time_in_shadow = time_in_shadow + 1;
                power_generated = 0;
            else
                power_generated = (max_solar_flux*angle_offset(i))*0.6;     
            end
             
            energy_change = power_generated + -1 *(avoidance_consumption + avionics_consumption); 
     
            distance_covered = (normal_distance*linear_distance_factor);
        
        end
    else
        
        energy_change = (max_solar_flux*angle_offset(i) - nominal_rove_mode*efficiency_multipliers(i));
        if (shadow_found) %may encounter shadow
            in_shadow = true;
            energy_change = (-1 * nominal_rove_mode);
            time_in_shadow = 0;
        elseif (in_shadow && time_in_shadow < max_shadow_time)
            energy_change = (-1 * nominal_rove_mode);  
            time_in_shadow = time_in_shadow + 1;
        elseif (time_in_shadow == max_shadow_time)
            in_shadow = false;
            time_in_shadow = 0;
        end
        
        distance_covered = normal_distance;
        
    end
    
    temp_cap = (battery_cap(i-1) + energy_change);
    %check to see if state-of-charge exceeds 100%
    %if too much energy is being generated, then it will cap out on
    %the state-of-charge graph
    if (abs(temp_cap/battery_total - 1) > tolerance)
        battery_cap(i) = (battery_cap(i-1) + energy_change);
    else
        battery_cap(i) = battery_cap(i-1);
    end
    
    battery_soc(i) = battery_cap(i)/battery_total;
    
    if (changed_direction)
        if (distance_travelled(i-1) <= 0)
           backAtLander_time = spec_time; 
           break;
        else
            distance_covered = -1*distance_covered;
        end
    else
        distance_covered = distance_covered;
    end
    
    distance_travelled(i) = distance_travelled(i-1) + distance_covered;
end