

init_soc = .8;             %initial state of charge
trek_duration     =  28.5; %[Hrs]

choose_power_multiplier = 1; %select the occlusion multipliers to use (1-6)

plan_duration     =  0;    %[Hrs]
downlink_duration =  0;  %[Hrs, 1hr and 20mins]

%% User can see how energy expenditure changes by disabling/enabling rocks/craters
enable_rocks = true;
enable_shadows = false;
enable_craters = true;

max_soc = 1;           %maximum state of charge [100%]
max_charge_period = 0; %[Hrs]
max_shadow_time   = 5*60; %[secs, 5 mins total]


