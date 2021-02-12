
occ_multipliers = [1, 0.93, 0.8, 0.69, 0.57, 0.51, ...
                    0.45, 0.26, 0.21, 0.24, 0.47, 0.74, 0.98, 1];
                
max_power = 80;

powers = max_power.*occ_multipliers;
time = [0, 7087, 14175, 21262, 28349, 35437, 42524, 49611, ...
                    56699, 63786, 70873, 77961, 85048, 92135];

figure
plot(time/(60^2), powers)
xlabel('Time (hrs)')
ylabel('Power generation (Watts)')
xlim([0,25.59])
ylim([0,85])
