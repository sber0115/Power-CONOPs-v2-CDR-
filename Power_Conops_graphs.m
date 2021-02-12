figure 
plot(time_vector/time_scale,azimuth_angle)


figure
plot(time_vector/time_scale,distance_travelled)
%xline(25.59, '--r', {'Occlusion end'});
%xline(rover_reached_40, '--m', {'Rover reached 40%'});
%title('Distance from Lander vs Time')
xlabel('Time (hrs)')
xlim([25.59, backAtLander_time/60^2])
ylim([0, 550])
%xticks(linspace(0,trek_duration, 10))
xtickformat('%.1f')
ylabel('Distance from Lander (m)')

figure
plot(time_vector/time_scale,battery_soc*100)
%line_30W = xline(7.87, '--r', {'Transition to nominal 20W total'});
line_30W.LabelVerticalAlignment = 'middle';
%line_pos_power = xline(21.65, '--r', {'Can rove with positive net power again'});
line_pos_power.LabelVerticalAlignment = 'middle';
%line([21.65, 24.1], [50,50], 'Color', 'blue', 'LineStyle', '--');
%xline(24.1, '--b', {'Reaches 80% charge'});
%line_occlusion_end = xline(25.59, '--r', {'Occlusion end'});
line_occlusion_end.LabelVerticalAlignment = 'middle';
hold on
%title('Battery State-of-Charge vs Time')
%xlim([0, 25.6])
xlim([25.59, backAtLander_time/60^2])
%xticks(linspace(0,trek_duration, 10))
xtickformat('%.1f')
ylim([0,100]);
xlabel('Time (hrs)')
ylabel('State of Charge (100% Max)')


occlusionText = [{'Nominal power' 'throughout' 'occlusion: ' [num2str(occlusion_mode) 'W']} ];
text(1.5, 30, occlusionText);

%{
craterText = [{'Diameter of' 'biggest crater: ' [num2str(max(all_avoided_craters)) 'm']} ];
text(backAtLander_time/60^2 - 5, 30, craterText);

cratersAvoidedText = [{'Number of' 'craters avoided: ' [num2str(crater_find_index)]} ];
text(backAtLander_time/60^2 - 2, 30, cratersAvoidedText);

rockText = [{'Diameter of' 'biggest rock: ' [num2str(max(all_avoided_rocks)) 'm']} ];
text(backAtLander_time/60^2 - 5, 15, rockText);

rocksAvoidedText = [{'Number of' 'rocks avoided: ' [num2str(rock_find_index)]} ];
text(backAtLander_time/60^2 - 2, 15, rocksAvoidedText);
%}


