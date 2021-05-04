
x_limit = backAtLander_time/60^2;
y_limit = max_distance_from_lander + 50;

if (enable_occlusion) 
    x_limit = trek_duration;
end

speed_made_good = round(100000/(backAtLander_time - occlusion_end_time), 2);
driving_time = round((backAtLander_time/60^2 - occlusion_end_time/60^2), 1);

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
    text(backAtLander_time/60^2 - 3.5, 490, totalTrekTime_text);
    totalTrekTime_text = [{'Total time for trek: ' [num2str(driving_time) ' hours']} ];
    text(backAtLander_time/60^2 - 3.5, 425, totalTrekTime_text);

end

%% Graphing state-of-charge vs time

figure

plot(time_vector/time_scale,battery_soc*100)
title('Battery State-of-Charge vs Time')

hold on

xlim([0, x_limit])
xtickformat('%.1f')
ylim([0,100]);
xlabel('Time (hrs)')
ylabel('State of Charge (100% Max)')


