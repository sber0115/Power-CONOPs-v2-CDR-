

figure
plot(time_vector/time_scale,distance_travelled)
%xline(25.59, '--r', {'Occlusion end'});
%title('Distance from Lander vs Time')
xlabel('Time (hrs)')
xlim([25.59, backAtLander_time/60^2])
ylim([0, 550])
%xticks(linspace(0,trek_duration, 10))
xtickformat('%.1f')
ylabel('Distance from Lander (m)')
totalTrekTime_text = [{'Speed-made-good: ' [num2str(round(100000/(backAtLander_time - occlusion_end_time), 2)) ' cm/s']} ];
text(backAtLander_time/60^2 - 3.5, 490, totalTrekTime_text);
totalTrekTime_text = [{'Total time for trek: ' [num2str(round((backAtLander_time/60^2 - occlusion_end_time/60^2), 1)) ' hours']} ];
text(backAtLander_time/60^2 - 3.5, 425, totalTrekTime_text);

figure
plot(time_vector/time_scale,battery_soc*100)
line_30W.LabelVerticalAlignment = 'middle';
line_pos_power.LabelVerticalAlignment = 'middle';
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

startSOC_text = ['Charge once state-of-charge reaches ' num2str(start_charge_soc*100) ' %'];
text(27, 40, startSOC_text);

occlusionText = [{'Nominal power' 'throughout' 'occlusion: ' [num2str(occlusion_power_consumption) 'W']} ];
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


