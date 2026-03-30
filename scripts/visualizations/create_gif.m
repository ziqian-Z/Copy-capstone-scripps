data_path = 'data/Specificdate/';
t_path = dir(data_path + "/Temperature/temperature_avg_output/");
s_path  =  "/Salinity/salinity_avg_output/";
u_path    = "/Meridional_velocity/meridional_velocity_avg_output/";
v_path    = "/Vertical_velocity/vertical_velocity_avg_output/";



function numericTable = convertTableToDoubleOnly(dataTable)
    numericTable = table();  % Empty table to hold numeric columns
    for col = 1:width(dataTable)
        colData = dataTable{:, col};

        % Convert cell columns to numeric
        if iscell(colData)
            % Replace 'NA' and '' with NaN
            colData(strcmp(colData, 'NA') | strcmp(colData, '')) = {NaN};
            colData = str2double(colData);  % Convert to double
        end

        % If it's numeric now, add to the new table
        if isnumeric(colData)
            numericTable.(dataTable.Properties.VariableNames{col}) = colData;
        else
            fprintf('Skipping column "%s" — not numeric after conversion.\n', ...
                dataTable.Properties.VariableNames{col});
        end
    end
end



% Extract depths and dates to determine unique values and subplot layout
uniqueDepths = [280,105,55];

% PUT IN THE DATES THAT HAVE THE X20HZ OR OTHERS

% Read the CSV file into a table. Adjust the file path as needed.
final_merged = readtable('data/Merged_CalCOFI/STD_CalCOFI_final_merged_data_2012-2023.csv');

month = final_merged.month; 
year = final_merged.year; 

% Add leading zeros to month if necessary
monthStr = compose("%02d", month);

% Combine manually: "01.<month>.<year>"
final_merged.date = "01." + monthStr + "." + string(year);

% Convert to datetime
final_merged.date = datetime(final_merged.date, 'InputFormat', 'dd.MM.yyyy', 'Format', 'yyyy-MM-dd');


% Define types and initialize a struct for results
types = {'a_scaled', 'b_scaled', 'd_scaled', 'x20hz_scaled', 'x40hz_scaled'};
results = struct();
for i = 1:length(types)
    type = types{i};
    columnData = final_merged.(type);

    % Make sure it's numeric before using isnan
    if isnumeric(columnData)
        valid_idx = ~isnan(columnData) & columnData ~= 0;
    else
        % For non-numeric data like strings, treat empty strings or blanks as invalid
        valid_idx = columnData ~= "";
    end
    
    % Extract relevant columns
    filtered_dates = final_merged.date(valid_idx);
    signal_values = columnData(valid_idx);
    latitudes = final_merged.lat(valid_idx);
    longitudes = final_merged.lon(valid_idx);
    
    % Store in struct
    results.(type) = table(filtered_dates, signal_values, latitudes, longitudes, ...
        'VariableNames', {'Date', 'SignalValue', 'Latitude', 'Longitude'});
end

call_types = {"a_scaled", "b_scaled", "d_scaled", "x20hz_scaled", "x40hz_scaled"};
call_colors = lines(numel(call_types));


all_valid_dates = [];

for i = 1:length(call_types)
    type = call_types{i};
    data_table = results.(type);
    
    % Handle numeric vs string data for SignalValue
    values = data_table.SignalValue;
    if iscell(values)
        values(strcmp(values, 'NA') | strcmp(values, '')) = {NaN};
        values = str2double(values);
    elseif isstring(values)
        values(values == "NA" | values == "") = NaN;
        values = double(values);
    end

    valid_mask = ~isnan(values) & values ~= 0;
    all_valid_dates = [all_valid_dates; data_table.Date(valid_mask)];
end
uniqueDates = unique(all_valid_dates);           % Step 1: Get unique dates
class(uniqueDates)
uniqueDates.Year
mask = uniqueDates.Year ~= 2023;   % Logical array: true for all years NOT 2023
uniqueDates = uniqueDates(mask);    % Filtered uniqueDates







% Create figure outside the loop
hFig = figure;
set(hFig, 'Position', [1000, 1000, 1200, 600]); % Width and height in pixels
numPlotsPerFrame = 9; % Three plots for temperature and three for salinity
set(0,'DefaultFigureColor','w')
% Total number of frames for the movie

totalFrames = numel(uniqueDates);
mov(totalFrames) = struct('cdata', [], 'colormap', []);


for dateNum = 1:numel(uniqueDates)
    skip = false;
    currentDay = uniqueDates(dateNum);

    clf; % Clear figure for fresh plot
    minLat = 360;
    minLong = 360;
    % Initialize min and max values for latitude and longitude
    maxLat = 0;
    maxLong = -360;
    for depthNum = 1:length(uniqueDepths)
        currentDepth = uniqueDepths(depthNum);
        % Calculate the subplot index to reverse the order
        reversedDepthIndex = numel(uniqueDepths) - depthNum + 1;
        % Temperature subplot
        subplotIndex = (reversedDepthIndex - 1) * 3 + 1;
        % Modify how depthfiles works 
        % Create partial path that should match to a file in the folder
        partial_path = sprintf('_avg_depth_-%g.0_month_%04d-%02d', currentDepth, currentDay.Year, currentDay.Month);
        
        temp_folder = data_path + "/Temperature/temperature_avg_output/";
        temp_filename = "temperature" + partial_path + ".csv";
        try
            dataTable = readtable(temp_folder + temp_filename, 'ReadRowNames', true, 'VariableNamingRule', 'preserve');
        catch
            try
                skip = true;
                temp_folder = data_path + "/Temperature/temperature_2021-2022/";
                dataTable = readtable(temp_folder + temp_filename, 'ReadRowNames', true, 'VariableNamingRule', 'preserve');
            catch
                warning("Failed to load file from both primary and fallback locations: %s", temp_filename);
                continue;  % or: skip = true; or: dataTable = []; depending on your logic
            end
        end
        if currentDay.Year == 2023
            continue;
        end
        lonStrings = extractAfter(dataTable.Properties.RowNames, 'Lon_');
        lons = str2double(lonStrings);
        lons = lons - 360;
        correctedLatStrings = regexprep(dataTable.Properties.VariableNames, 'Lat_([0-9]+)_([0-9]+)', 'Lat_$1.$2');
        latStrings = extractAfter(correctedLatStrings, 'Lat_');
        lats = str2double(latStrings);
        [X, Y] = meshgrid(lats, lons);
        if min(lats) < minLat
            minLat = min(lats);
        end
        if max(lats) > maxLat
            maxLat = max(lats);
        end
        if min(lons) < minLong
            minLong = min(lons);
        end
        if max(lons) > maxLong
            maxLong = max(lons);
        end


        
        numericTable = convertTableToDoubleOnly(dataTable);
        Z = table2array(numericTable);
                     
         subplot(3, 3, subplotIndex);
         contourf(Y, X, Z, 'LineStyle', 'none');
         title(sprintf('Temperature on %s\n %.1f m depth', currentDay, currentDepth));
         xlabel('Longitude');
         ylabel('Latitude');
         colorbar;
         cmin = min(Z(:), [], 'omitnan');
         cmax = max(Z(:), [], 'omitnan');
         clim([cmin, cmax]); % Adjust color limits based on data 
         axis equal;
         xlim([min(lons), max(lons)]);
         ylim([min(lats), max(lats)]);
         daspect([1 cosd(35) 1])
        
        % Salinity subplot
        subplotIndex = (reversedDepthIndex - 1) * 3 + 2;
        temp_filename = "salinity" + partial_path + ".csv";

        if skip
            temp_folder = data_path + "/Salinity/sal_2021-2023/";
            dataTable = readtable(temp_folder + temp_filename, 'ReadRowNames', true, 'VariableNamingRule', 'preserve');
        else 
            temp_folder = data_path + s_path;
            dataTable = readtable(temp_folder + temp_filename, 'ReadRowNames', true, 'VariableNamingRule', 'preserve');
        end 
        
        numericTable = convertTableToDoubleOnly(dataTable);
        Z = table2array(numericTable);

        subplot(3, 3, subplotIndex);
        contourf(Y, X, Z, 'LineStyle', 'none');
        title(sprintf('Salinity on %s\n %.1f m depth', currentDay, currentDepth));
        xlabel('Longitude');
        ylabel('Latitude');
        colorbar;
        cmin = min(Z(:), [], 'omitnan');
        cmax = max(Z(:), [], 'omitnan');
        clim([cmin, cmax]); % Adjust color limits based on data 
        axis equal;
        xlim([min(lons), max(lons)]);
        ylim([min(lats), max(lats)]);
        daspect([1 cosd(35) 1])
        
        temp_filename = "meridional_velocity" + partial_path + ".csv";
        if skip
            temp_folder = data_path + "/Meridional_velocity/meridional_2021/";
            dataTable = readtable(temp_folder + temp_filename, 'ReadRowNames', true, 'VariableNamingRule', 'preserve');
        else 
            temp_folder = data_path + u_path;
            dataTable = readtable(temp_folder + temp_filename, 'ReadRowNames', true, 'VariableNamingRule', 'preserve');
        end 

        numericTable = convertTableToDoubleOnly(dataTable);

        U = table2array(numericTable);
        

        temp_filename = "vertical_velocity" + partial_path + ".csv";
        if skip
            temp_folder = data_path + "/Vertical_velocity/Vertical_velocity_2021-2022/";
            dataTable = readtable(temp_folder + temp_filename, 'ReadRowNames', true, 'VariableNamingRule', 'preserve');
        else 
            temp_folder = data_path + v_path;
            dataTable = readtable(temp_folder + temp_filename, 'ReadRowNames', true, 'VariableNamingRule', 'preserve');
        end 
        numericTable = convertTableToDoubleOnly(dataTable);
        V = table2array(numericTable);
        
        subplotIndex = (reversedDepthIndex - 1) * 3 + 3;
        subplot(3, 3, subplotIndex);
        quiver(Y,X, U, V, 2); % The '2' is a scale factor for visual clarity
        title(sprintf('Velocity on %s\n %.1f m depth', currentDay, currentDepth));
        xlabel('Longitude');
        ylabel('Latitude');
        axis tight;
        daspect([1 cosd(35) 1])
    end 
    % Overlay signal values for currentDay as purple dots on all subplots
    % Define distinct colors for each call type
    call_types = {"a_scaled", "b_scaled", "d_scaled", "x20hz_scaled", "x40hz_scaled"};

    for c = 1:length(call_types)
        call_type = call_types{c};
        currentData = results.(call_type);
        dayMask = currentData.Date == currentDay;
    
        if any(dayMask)

            
            lat_vals = currentData.Latitude(dayMask);
            lon_vals = currentData.Longitude(dayMask);


            raw_vals = currentData.SignalValue(dayMask);
    
            % Convert to double
            if iscell(raw_vals)
                raw_vals(strcmp(raw_vals, 'NA') | strcmp(raw_vals, '')) = {NaN};
                sig_vals = str2double(raw_vals);
            elseif isstring(raw_vals)
                raw_vals(raw_vals == "NA" | raw_vals == "") = NaN;
                sig_vals = double(raw_vals);
            elseif isnumeric(raw_vals)
                sig_vals = raw_vals;
            else
                continue;  % Skip invalid types
            end
    
            % Filter out invalids
            % Filter out invalid signal values
            validSigMask = ~isnan(sig_vals) & sig_vals > 0;

            % Filter out invalid latitude and longitude
            validLatLonMask = ~isnan(lat_vals) & lat_vals < maxLat & lat_vals > minLat & ...
                            ~isnan(lon_vals) & lon_vals < maxLong & lon_vals > minLong;

            % Combine all masks
            finalMask = validSigMask & validLatLonMask;

            % Apply the combined mask to all variables
            sig_vals = sig_vals(finalMask);
            lat_vals = lat_vals(finalMask);
            lon_vals = lon_vals(finalMask);
    
            if isempty(sig_vals)
                continue;
            end
    
            % Normalize size
            marker_sizes = 100 * (sig_vals / max(sig_vals));
    
            % Draw on all subplots
            for subplotIdx = 1:9
                subplot(3, 3, subplotIdx);
                hold on;
                scatter(lon_vals, lat_vals, marker_sizes, ...
                    'MarkerEdgeColor', 'k', ...
                    'MarkerFaceColor', call_colors(c, :), ...
                    'LineWidth', 0.6, ...
                    'DisplayName', call_type);
            end
        end
    end
    % Create an invisible full-width subplot to host the legend
    % Capture the frame for the movie
    % Create a dummy set of invisible scatter plots just for the legend
    legend_handles = gobjects(length(call_types), 1);
    for c = 1:length(call_types)
        legend_handles(c) = scatter(nan, nan, 100, ...
            'MarkerEdgeColor', 'k', ...
            'MarkerFaceColor', call_colors(c,:), ...
            'DisplayName', call_types{c}, ...
            'LineWidth', 0.6);
    end
    % Create a full-width invisible axes for placing the legend
    legend_ax = axes('Position', [0, 0, 1, 1], 'Visible', 'off');
    
    % Draw the legend outside of the subplot area
    lg = legend(legend_ax, legend_handles, call_types, ...
        'Box','on', ...
        'Interpreter','none', ...
        'FontSize', 10);
    
    % Place it on the far right
    lg.Units = 'normalized';
    lg.Position = [0.92, 0.30, 0.06, 0.40];  % Adjust x/y/width/height as needed

 


    mov(dateNum) = getframe(hFig);

end
% Save the movie as a GIF
output_path = "results/visualizations/matlab/";
file_name = sprintf('legend.gif');
filename = fullfile(output_path, file_name);
for idx = 1:length(mov)
    [A,map] = rgb2ind(frame2im(mov(idx)),256);
    if idx == 1
        imwrite(A, map, filename, 'gif', 'LoopCount', Inf, 'DelayTime', 1);
    else
        imwrite(A, map, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 1);
    end
end

% % compute averages and store and plot
% % Initialize storage for aggregated data
% temperatureAggData = cell(numel(uniqueDepths), 1);
% salinityAggData = cell(numel(uniqueDepths), 1);
% uVelocityData = cell(numel(uniqueDepths), 1);
% vVelocityData = cell(numel(uniqueDepths), 1);
% % Read and aggregate temperature data
% for i = 1:numel(temp_files)
%     filename = temp_files(i).name;
%     depth = str2double(regexp(filename, 'depth_(-?[\d\.]+)', 'tokens', 'once'));
%     depthIndex = find(uniqueDepths == depth);
% 
%     dataTable = readtable(fullfile(temp_files(i).folder, temp_files(i).name), 'ReadRowNames', true);
%     Z = table2array(dataTable); % Assuming Z represents temperature data
% 
%     if isempty(temperatureAggData{depthIndex})
%         temperatureAggData{depthIndex} = Z;
%     else
%         temperatureAggData{depthIndex} = cat(3, temperatureAggData{depthIndex}, Z);
%     end
% end
% % Read and aggregate salinity data
% for i = 1:numel(sal_files)
%     filename = sal_files(i).name;
%     depth = str2double(regexp(filename, 'depth_(-?[\d\.]+)', 'tokens', 'once'));
%     depthIndex = find(uniqueDepths == depth);
% 
%     dataTable = readtable(fullfile(sal_files(i).folder, sal_files(i).name), 'ReadRowNames', true);
%     Z = table2array(dataTable); % Assuming Z represents salinity data
% 
%     if isempty(salinityAggData{depthIndex})
%         salinityAggData{depthIndex} = Z;
%     else
%         salinityAggData{depthIndex} = cat(3, salinityAggData{depthIndex}, Z);
%     end
% end
% % aggregate U
% for i = 1:numel(u_files)
%     filename = u_files(i).name;
%     depth = str2double(regexp(filename, 'depth_(-?[\d\.]+)', 'tokens', 'once'));
%     depthIndex = find(uniqueDepths == depth);
% 
%     dataTable = readtable(fullfile(u_files(i).folder, u_files(i).name), 'ReadRowNames', true);
%     Z = table2array(dataTable); % Assuming Z represents salinity data
% 
%     if isempty(uVelocityData{depthIndex})
%         uVelocityData{depthIndex} = Z;
%     else
%         uVelocityData{depthIndex} = cat(3, uVelocityData{depthIndex}, Z);
%     end
% end
% %aggregate V
% for i = 1:numel(v_files)
%     filename = v_files(i).name;
%     depth = str2double(regexp(filename, 'depth_(-?[\d\.]+)', 'tokens', 'once'));
%     depthIndex = find(uniqueDepths == depth);
% 
%     dataTable = readtable(fullfile(v_files(i).folder, v_files(i).name), 'ReadRowNames', true);
%     Z = table2array(dataTable); % Assuming Z represents salinity data
% 
%     if isempty(vVelocityData{depthIndex})
%         vVelocityData{depthIndex} = Z;
%     else
%         vVelocityData{depthIndex} = cat(3, vVelocityData{depthIndex}, Z);
%     end
% end
% % Plotting averages
% figure;
% for i = numel(uniqueDepths):-1:1
%     % Calculate indices for subplot
%     tempIndex = (numel(uniqueDepths)-i+1) * 3 - 2;  % Temperature plots in the first column
%     salIndex = (numel(uniqueDepths)-i+1) * 3 - 1;   % Salinity plots in the second column
%     velIndex = (numel(uniqueDepths)-i+1) * 3;       % Velocity plots in the third column
% 
%     % Average Temperature
%     avgTemp = mean(temperatureAggData{i}, 3, 'omitnan');
%     subplot(numel(uniqueDepths), 3, tempIndex);
%     contourf(Y, X, avgTemp, 'LineStyle', 'none');
%     title(sprintf('Average Temperature \n %.1f m depth', uniqueDepths(i)));
%     xlabel('Longitude');
%     ylabel('Latitude');
%     colorbar;
%     daspect([1 cosd(35) 1]);
%     caxis([10 25]);  % Consistent color limits for temperature
%     % Average Salinity
%     avgSal = mean(salinityAggData{i}, 3, 'omitnan');
%     subplot(numel(uniqueDepths), 3, salIndex);
%     contourf(Y, X, avgSal, 'LineStyle', 'none');
%     title(sprintf('Average Salinity \n %.1f m depth', uniqueDepths(i)));
%     xlabel('Longitude');
%     ylabel('Latitude');
%     colorbar;
%     daspect([1 cosd(35) 1]);
%     caxis([33 34]);  % Consistent color limits for salinity
%     % Average U and V Velocities
%     U_avg = mean(uVelocityData{i}, 3, 'omitnan');
%     V_avg = mean(vVelocityData{i}, 3, 'omitnan');
%     subplot(numel(uniqueDepths), 3, velIndex);
%     quiver(Y, X, U_avg, V_avg, 1, 'k');  % The '1' can be adjusted for scale clarity
%     title(sprintf('Average Velocity \n %.1f m depth', uniqueDepths(i)));
%     xlabel('Longitude');
%     ylabel('Latitude');
%     axis tight;
%     daspect([1 cosd(35) 1]);
%     % Place depth labels on the side
%     for x = 1:numel(uniqueDepths)
%         depthPosition = (numel(uniqueDepths) - x + 0.5) / numel(uniqueDepths);
%         annotation('textbox', [0.06, depthPosition, 0, 0], 'String', sprintf('%.1f m', uniqueDepths(x)), 'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 12);
%     end
% end
% % Save the figure as a PNG file
% pngFileName = fullfile(data_path, 'AverageTempSalinityCurrents.png');
% saveas(gcf, pngFileName, 'png');