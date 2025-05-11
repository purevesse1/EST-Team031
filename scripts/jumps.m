% Script that finds a value range for large jumps in energy demand

data = readtable('data/Team31_demand.csv', 'VariableNamingRule', 'preserve');
time = data.("# time [s]");
power = data.("power [kW]");

% Discrete derivatives
dPower = diff(power);
time_dPower = data{2:end, 1};

% Find threshold (adjust values)
rollingStd = movstd(dPower, 288); % moving standard deviation over 3 days
smoothThreshold = movmean(rollingStd, 96); % average std over 1 day
thresholds = 2.5 * smoothThreshold;

% Find where jump crosses threshold and output range
spikeIdx = find(dPower > thresholds);
spikeTime = data{spikeIdx + 1, 1};
spikeVal = power(spikeIdx + 1);

spikeMin = min(spikeVal);
spikeMax = max(spikeVal);

fprintf('# of spikes: %d\n', numel(spikeVal));
fprintf('Power spike range: [%.2f, %.2f] kW\n', spikeMin, spikeMax);


% Plot
time_days = time / (24 * 3600); % convert seconds to days
spikeTime_days = spikeTime / (24 * 3600);
time_dPower_days = time_dPower / (24 * 3600);

thresholdLine = power(1:end-1) + thresholds;

figure;
plot(time_days, power, 'b'); hold on;
plot(spikeTime_days, spikeVal, 'ro');
plot(time_dPower_days, thresholdLine, 'g', 'LineWidth', 0.8);
axis tight;

xlabel('Time [days]');
ylabel('Power [kW]');
title('Power Demand Jumps');
legend('Power Demand', 'Detected Spikes', 'Spike Threshold', 'Location', 'best');

% Histogram of spikes
sortedSpikes = sort(spikeVal);

figure;
histogram(spikeVal, 'BinMethod', 'fd');

xlabel('Power [kW]');
ylabel('Frequency');
title('Histogram of Power Spikes');