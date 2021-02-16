

init_soc = 0.8;             %initial state of charge
occlusion_power = 20;
trek_duration     =  50; %[Hrs]

plan_duration     =  0;    %[Hrs]
downlink_duration =  0;  %[Hrs, 1hr and 20mins]

%% User can see how energy expenditure changes by disabling/enabling rocks/craters
enable_rocks = true;
enable_shadows = false;
enable_craters = true;

max_soc = 1;           %maximum state of charge [100%]
max_charge_period = 0; %[Hrs]
max_shadow_time   = 5*60; %[secs, 5 mins total]


