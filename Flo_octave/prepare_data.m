% Gets the Data from the .wav files. First it reads the correct part of the
% audio-file. It then splits the stereo-data into two mono-data-samples.
% Also it ensures that the sample-amount is even for the FFT.
% At the End it calculates the length of the mono-data in time.
function [rate, duration, Lcor, channel_a, channel_b] = prepare_data(path, t_start, t_end, Lcor, Ncor, priority)

  % load part of the signal from given path
  % row --> channel
  [data, rate] = readAudio(path, t_start, t_end, Lcor, Ncor, priority); 
  
  %% devide into Ncor parts
  [channel_a, channel_b] = splitChannel(data, Lcor, Ncor, priority);
  
  % deleting last sample if amount odd
  len = length(channel_a(1,:));
  if mod(len,2) == 1
    channel_a(:,length(channel_a)) = [];
    channel_b(:,length(channel_b)) = [];
  end
  
  %calculate length of correlation in samples and time
  Lcor = length(channel_a(1,:));
  duration = Lcor/rate;
end