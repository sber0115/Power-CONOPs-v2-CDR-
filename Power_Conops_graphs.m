
figure
plot(time_vector/time_scale,distance_travelled, 'color', 'k')
xline(25.59, '--r', {'Occlusion end'});
%xline(rover_reached_40, '--m', {'Rover reached 40%'});
title('Net Distance vs Time')
xlabel('Time (hrs)')
xlim([19, trek_duration])
%xticks(linspace(0,trek_duration, 10))
xtickformat('%.1f')
ylabel('Distance (m)')

figure
plot(time_vector/time_scale,battery_soc*100, 'color', 'k')
line_30W = xline(7.87, '--r', {'Transition to nominal 20W total'});
line_30W.LabelVerticalAlignment = 'middle';
line_pos_power = xline(21.65, '--r', {'Can rove with positive net power again'});
line_pos_power.LabelVerticalAlignment = 'middle';
%line([21.65, 24.1], [50,50], 'Color', 'blue', 'LineStyle', '--');
%xline(24.1, '--b', {'Reaches 80% charge'});
%line_occlusion_end = xline(25.59, '--r', {'Occlusion end'});
line_occlusion_end.LabelVerticalAlignment = 'middle';
hold on
title('Battery State-of-Charge vs Time')
%xlim([0, 25.6])
xlim([0, trek_duration])
%xticks(linspace(0,trek_duration, 10))
xtickformat('%.1f')
ylim([0,100]);
xlabel('Time (hrs)')
ylabel('State of Charge (100% Max)')


occlusionText = [{'Nominal power' 'throughout' 'occlusion: ' [num2str(occlusion_mode) 'W']} ];
text(1.5, 30, occlusionText);

craterText = [{'Diameter of' 'biggest crater: ' [num2str(max(all_avoided_craters)) 'm']} ];
text(30, 30, craterText);

cratersAvoidedText = [{'Number of' 'craters avoided: ' [num2str(crater_find_index)]} ];
text(37.5, 30, cratersAvoidedText);

rockText = [{'Diameter of' 'biggest rock: ' [num2str(max(all_avoided_rocks)) 'm']} ];
text(30, 15, rockText);

rocksAvoidedText = [{'Number of' 'rocks avoided: ' [num2str(rock_find_index)]} ];
text(37.5, 15, rocksAvoidedText);

%efficiencyText = [{'Battery efficiency'} ['through occlusion: ' num2str(efficiency_multiplier) '%']];
%text(1.5, 40, efficiencyText)
%annotation('textbox',[.9 .5 .1 .2],'String',{'Occlusion power: ', num2str(occlusion_mode)},'EdgeColor','none')

