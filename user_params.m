

init_soc = .8;             %initial state of charge
trek_duration     =  28.5; %[Hrs]

plan_duration     =  0;    %[Hrs]
downlink_duration =  0;  %[Hrs, 1hr and 20mins]

%% User can see how energy expenditure changes by disabling/enabling rocks/craters
enable_rocks = false;
enable_shadows = false;
enable_craters = false;

max_soc = 1;           %maximum state of charge [100%]
max_charge_period = 0; %[Hrs]
max_shadow_time   = 5*60; %[secs, 5 mins total]


