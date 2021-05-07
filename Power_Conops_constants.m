%% Setting up the time vector
%each element in time vector represents a 
%second increment
time_scale = 60^2;
time_start = 0;
time_step  = 1; %single-second increments of time
time_end   = trek_duration*time_scale; %[hrs]*[36000 sec/hr] = sec

occlusion_end_time = 0;

if (enable_occlusion)
    occlusion_end_time = 92136; % times in [secs] at which the occlusion ends in the simulation
    trek_duration = occlusion_end_time/60^2;
end

tolerance  = 1e-2; %used to check if battery state of charge exceeds 100%, or reaches 0%

time_vector = time_start: time_step: time_end;
tv_length = length(time_vector);

%% Variables relating to power generation during occultation
%  a particular time during occlusion (25 hour period)
%  refer to https://docs.google.com/spreadsheets/d/186Un4aNC-d2LEB51xynQXVAxh9xbEgpof89epkbNYiI/edit#gid=0 
%  for more information on solar panel temperature dependence and other
%  relevant calculations

occ_times       = [0:24].*3600; %change power generation 
                    
                    %below are the effective power generations that take
                    %into account solar panel temperature dependence and
                    %the varying visible fraction of the solar disk

occlusion_powers_baseline = [65,64,62,59,56,52,50,47,43,41,39,37,37,30, ...
                            22,21,18,19,19,27,34,42,50,57,65];

occlusion_powers = occlusion_powers_baseline;
                
%% Power consumption at different operating modes (based on power equipment list)
extreme_rove_mode = 58;
nominal_rove_mode = 53; 
rove_downlink_mode = 58;
charge_downlink_mode = 39;
charge_min_mode = 8;
charge_max_mode = 32;

%% Vectors for different missions phases (
plan_trek_interval = [0: time_step: plan_duration*time_scale];
downlink_interval  = [plan_duration: time_step: downlink_duration*time_scale];
trek_phase1        = [plan_trek_interval, downlink_interval];    

%% Setting up the max capacity for "energy bucket" 
%  Setting up the velocity parameter, and vectors used for plotting
battery_total = 200*3600; %maximum battery energy capacity in W/hrs
velocity_cm  = input_velocity;
velocity_m = velocity_cm/100;
normal_distance = velocity_m;

battery_soc     = zeros(1,tv_length);
battery_cap     = zeros(1,tv_length);
distance_travelled = zeros(1,tv_length);

%% Efficiency multipliers to capture panel temperature dependence
%  Increase load power by up to 30%; exact percentage increase depends on
%  and closely resembles the temperature change as outlined in the battery 
%  temperature transient curve (given by the thermal team).

% The datasheet for the LGMJ1 cells highlights an expected decrease in
% capacity of 30% when the batteries are in the zero-degree Celcius range
battery_efficiency_multipliers = zeros(1,tv_length);

%when occlusion is enabled, following vector setup follows the transient
%temperture of batteries and decreases efficiency based on temperature
if (enable_occlusion)
    battery_efficiency_multipliers(1:28800) = linspace(14,25,28800)./100 + 1;
    battery_efficiency_multipliers(28801:34560) = linspace(25,15,5760)./100 + 1;
    battery_efficiency_multipliers(34561:37800) = linspace(15,25,3240)./100 + 1;
    battery_efficiency_multipliers(37801:79200) = 1.2;
    battery_efficiency_multipliers(79201:tv_length) = 1.1;
else 
    battery_efficiency_multipliers(1:tv_length) = 1.1;
end

%% Vectors that capture the regolith power loss 
%  (specified by user parameter)
regolith_factors = zeros(1,tv_length);

regolith_factors(1:occlusion_end_time) = 1 - input_regolith_factor;

%using linspace to evenly distribute the change in effiency over the
%duration of the trek that's left
regolith_factors(occlusion_end_time+1:tv_length) = ...
            linspace((1-input_regolith_factor), ...
                    (1-input_regolith_factor+(regolith_factor_delta)), ...
                    (tv_length-occlusion_end_time));

%%  Vector math with sun vector, elevation, and azimuth angles
%   Note that the hotcase has elevation fixed at 10 degrees, and azimuth at
%   90 degrees. This case is covered with a conditional throughout.

azimuth_angle = zeros(1, tv_length); %in degrees
azimuth_angle(1:tv_length) = 0;

if (enable_hotcase) 
    azimuth_angle(1:tv_length) = 90;
else 
    for i = occlusion_end_time:length(time_vector)
        if (i > 1)
            prev_value = azimuth_angle(i-1);
            divide_factor = time_step*time_scale;
            %for every .25 hours, or 1/4 hours, divide_factor was 4
            diff = (360/(29.5*24)) / divide_factor; %previously, calculation was for .25 hours
            azimuth_angle(i) = prev_value + diff;
        end
    end
end

sun_vectors = zeros(length(azimuth_angle), 3);

elevation_angle = 0; 

if (enable_hotcase)
   elevation_angle = 10;
end

for i = 1: tv_length
    sun_vectors(i,:) = sph2cart(deg2rad(azimuth_angle(i)),deg2rad(elevation_angle),1);
end

panel_normal_vector = [0.5, 0.5, 0];
angle_offset = zeros(1, tv_length);

for i = 1: tv_length
    angle_offset(i) = dot(panel_normal_vector, sun_vectors(i,:));
end

%% This section is no longer relevant, need to update/handle this differently
%  Currently has no effect on any outputs


time_charging = 0; %[mins]
max_charge_time = max_charge_period*time_scale;
is_heating_motors = false; 
soc_under_100 = true;
for i = 1:length(trek_phase1)
    spec_time = trek_phase1(i);
    if (~soc_under_100)
        battery_cap(i) = battery_cap(i-1);
        battery_soc(i) = battery_soc(i-1); 
        continue;
    end
    
    time_charging = time_charging + 1;
    
    %solar angle in degrees, but must be in rad for MATLAB
    curr_sangle_offset = cos(deg2rad(azimuth_angle(i)));
    if (ismember(spec_time, plan_trek_interval))
        curr_load_out = charge_min_mode;
        curr_load_in  = charge_min_mode*curr_sangle_offset;
    elseif (ismember(spec_time, downlink_interval))
        curr_load_out = charge_link_mode;
        curr_load_in  = charge_link_mode*curr_sangle_offset;
    else 
       curr_load_out = 0;
       curr_load_in = 0;
    end
    
    if (mod(time_charging, max_charge_time) == 0)
        is_heating_motors = true;
        curr_load_in = charge_min_mode*curr_sangle_offset;
    end
    
    curr_net_power = curr_load_in - curr_load_out;

    if (i > 1)
        energy_change = curr_net_power / 3600; 
        battery_cap(i) = battery_cap(i-1) + energy_change;
        battery_soc(i) = battery_cap(i)/battery_total;    
    else
        battery_cap(i) = battery_total*init_soc;
        battery_soc(i) = battery_cap(i)/battery_total;
    end
    
    soc_under_100 = abs(battery_soc(i) - 1) > 1e-2;
end











