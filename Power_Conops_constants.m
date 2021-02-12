%%
%each element in time vector represents a 
%second increment
time_scale = 60^2;
time_start = 0;
time_step  = 1;  
time_end   = trek_duration*time_scale; %[Hrs]*[36000 sec/Hr] = sec
occlusion_end_time = 92136;
tolerance  = 1e-2; %used to check if battery state of charge exceeds 100%

time_vector = time_start: time_step: time_end;
tv_length = length(time_vector);


%% Occlusion power multipliers
occ_index = 1;
occ_times       = [7087, 14175, 21262, 28349, 35437, 42524, 49611, ...
                    56699, 63786, 70873, 77961, 85048, 92135];

%100 percent interpolation (site 1)
occ_multipliers_site1 = [1, 0.93, 0.8, 0.69, 0.57, 0.51, ...
                    0.45, 0.26, 0.21, 0.24, 0.47, 0.74, 0.98, 1];

%% Power consumption and generation for different modes
rove_downlink_mode = 59;
charge_downlink_mode = 38;
nominal_rove_mode = 54; 
extreme_rove_mode = 59;
charge_min_mode = 31;
%charge_max_mode = 25;
max_solar_flux = 70;

occlusion_mode = occlusion_power;

%% IGNORE EVERYTHING BELOW FOR NOW
plan_trek_interval = [0: time_step: plan_duration*time_scale];
downlink_interval  = [plan_duration: time_step: downlink_duration*time_scale];
trek_phase1        = [plan_trek_interval, downlink_interval];                                                       
battery_total = 100*3600; %maximum battery energy capacity in W/hrs
velocity_cm  = 4;
velocity_m = velocity_cm/100;
normal_distance = velocity_m;
battery_soc     = zeros(1,tv_length);
battery_cap     = zeros(1,tv_length);
%%
distance_travelled = zeros(1,tv_length);
efficiency_multipliers = zeros(1,tv_length);

efficiency_multipliers(1:35000) = linspace(200-73,200-69,35000)./100;
efficiency_multipliers(35001:45000) = linspace(200-69,200-71,10000)./100;
efficiency_multipliers(45001:65000) = linspace(200-71,200-69,20000)./100;
efficiency_multipliers(65001:92136) = linspace(200-69,200-72,27136)./100;
efficiency_multipliers(92137:tv_length) = linspace(200-72,200-80,tv_length-92136)./100;


azimuth_angle = zeros(1, tv_length); %in degrees

%populating azimuth_angle first since
%the load_in is dependent on angle
for i = occlusion_end_time:length(time_vector)
     if (i > 1)
        prev_value = azimuth_angle(i-1);
        divide_factor = time_step*time_scale;
        %for every .25 hours, or 1/4 hours, divide_factor was 4
        diff = (360/(29.5*24)) / divide_factor; %previously, calculation was for .25 hours
        azimuth_angle(i) = prev_value + diff;
     end
end

sun_vectors = zeros(length(azimuth_angle), 3);
elevation_angle = 5; %fixed elevation angle of 5 degrees

for i = 1: tv_length
    sun_vectors(i,:) = sph2cart(deg2rad(azimuth_angle(i)),deg2rad(elevation_angle),1);
end

panel_normal_vector = [0,1,0];
angle_offset = zeros(1, tv_length);

for i = 1: tv_length
    angle_offset(i) = dot(panel_normal_vector, sun_vectors(i,:));
end


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
        energy_change = curr_net_power / 3600; %[W, or J/s, * 1Wh/3600J = Wh/s
        battery_cap(i) = battery_cap(i-1) + energy_change;
        battery_soc(i) = battery_cap(i)/battery_total;    
    else
        battery_cap(i) = battery_total*init_soc;
        battery_soc(i) = battery_cap(i)/battery_total;
    end
    
    soc_under_100 = abs(battery_soc(i) - 1) > 1e-2;
end











