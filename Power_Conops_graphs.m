
x_limit = backAtLander_time;
y_limit = max_distance_from_lander + 50;
occlusion_end_time = occlusion_end_time/60^2; %[seconds to hrs]
total_distance = max_distance_from_lander*2*100; %[m to cm]

if (enable_occlusion) 
    x_limit = occlusion_end_time;
elseif (battery_died)
    x_limit = battery_death_time;
end

speed_made_good = round(total_distance/(backAtLander_time*60^2), 2);
driving_time = round((backAtLander_time - occlusion_end_time), 1);

%% Graphing distance-from-lander vs time

if (~enable_occlusion) 
    
    figure

    plot(time_vector/time_scale,distance_travelled)

    title('Distance from Lander vs Time')
    xlabel('Time (hrs)')

    xlim([0, x_limit])
    ylim([0, y_limit])

    xtickformat('%.1f')
    ylabel('Distance from Lander (m)')
    totalTrekTime_text = [{'Speed-made-good: ' [num2str(speed_made_good) ' cm/s']} ];
    text(backAtLander_time - backAtLander_time/3, max_distance_from_lander - 20, totalTrekTime_text);
    totalTrekTime_text = [{'Total time for trek: ' [num2str(driving_time) ' hours']} ];
    text(backAtLander_time - backAtLander_time/3, max_distance_from_lander - 80, totalTrekTime_text);

end

%% Graphing state-of-charge vs time

figure


plot(time_vector/time_scale,battery_soc*100)
title('Battery State-of-Charge vs Time')

hold on

if (enable_occlusion) 
    line_transitionToHibernation = xline(9, '--r', {'Transition to 21W power consumption'});
    line_transitionToHibernation.LabelVerticalAlignment = 'middle';
end

xlim([0, x_limit])
xtickformat('%.1f')
ylim([0,100]);
xlabel('Time (hrs)')
ylabel('State of Charge (100% Max)')


