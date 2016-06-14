% ##############################################
% ########        audio correlator      ########
% ########        of stereo files       ########
% ########      developed for the       ########
% ########          Haupteseminar       ########
% ########      Kommunikationssysteme   ########
% ########          v 0.1               ########
% ##############################################
clear; clc;
pkg load signal;
pkg load optim;

%% INPUT

% path of audiofile
% works with wav, mp3, flac, aif, au, aifc, ogg
path = '.\WAVE\music.wav';

% results (display/save)
output = 'display';

% set priority (time/length)
priority = 'length';

% plot in (samples/seconds)
x_axis = 'seconds';

% length of correlation
Lcor = 8192; 

% amount of correlations 
Ncor = 1;

% start of correlation in audio file in seconds 
t_start = 0;
t_end = 0.1;

%% CODE
% load part of the signal from given path
%  row --> channel
[data, rate] = readAudio(path, t_start, t_end, Lcor, Ncor, priority); 

%% devide into Ncor parts
[channel_a, channel_b] = splitChannel(data, Lcor, Ncor, priority);

if strcmp(priority, 'time')
    Ncor = 1;
end

%% extracting name from path
str1 = regexp(path, '\\' ,'split');
str2 = regexp(str1{length(str1)}, '\.' , 'split');

for i = 1:Ncor
  % completing name
  if strcmp(output, 'save')
    name = strcat(str2{1}, '_res(', num2str(i), ')');
    path_res = strcat('.\RESULTS\', name, '\', name);
    mkdir('.\RESULTS', name);
  end
  
  %% correlate  in time
  [correlation_t(i,:), lags(i,:)] = xcorr(channel_a(i,:), channel_b(i,:),'coeff');

  % in frequency 
  %correlation_f(i,:) = freqMult(channel_a(i,:), channel_b(i,:));

  %% calculate offset between channels
  [~,I(i)] = max(abs(correlation_t(i,:)));
  lagDiff(i) = lags(I(i));
  timeDiff(i) = lagDiff(i)/rate;

  %% calculate ripple factor and decline factor
  ripple(i) = calc_ripple(correlation_t(i,:));

  envelope(i,:) = calc_envelope(correlation_t(i,:), length(channel_a), rate);
  [~,index_en(i)] = max (envelope(i,:));
  [regression(i,:), sigma(i)] = calc_reg(envelope(i,:), rate, index_en(i));

  %% plot
  line_1 = sprintf('ripple = %f \n', ripple(i));
  if strcmp(x_axis, 'seconds') == 1
    line_2 = sprintf('timeDiff = %f s \n\\sigma = %f s', timeDiff(i), sigma(i)/rate);
  else
    line_2 = sprintf('samplesDiff = %d samples \n\\sigma = %d samples', lagDiff(i), sigma(i));
  end
  string = strcat(line_1, line_2);
  fig = plotTandF(channel_a(i,:), channel_b(i,:), correlation_t(i,:), envelope(i,:), regression(i,:), x_axis, rate, string, output);
  if strcmp(output, 'save')
    ack = save_pic(fig, path_res, i)
  end
end
%ripple
%sigma
%lagDiff
%timeDiff

%% delete unneeded variables
%if strcmp(priority,'length') == 1
%    clearvars t_end i
%else
%    clearvars i Lcor Ncor
%end

%% save results

disp('finished');