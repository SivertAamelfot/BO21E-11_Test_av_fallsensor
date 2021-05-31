% clc;
% clear all;
% close all;
% Browse Video File :
[ video_file_name,video_file_path ] = uigetfile({'*.mp4'});
if(video_file_path==0)
    return;
end
% Output path
output_image_path = fullfile(video_file_path,[video_file_name(1:strfind(video_file_name,'.')-1),'.avi']);
% mkdir(output_image_path);
input_video_file = [video_file_path,video_file_name];


% % Read Video
% videoFReader = VideoReader(input_video_file);
% % Write Video
% videoFWrite = VideoWriter(output_image_path,'Uncompressed AVI');
% open(videoFWrite);
% while videoFReader.hasFrame()
%     key_frame = videoFReader.readFrame;
%     writeVideo(videoFWrite,key_frame);
% end
% % Release video object
% %close(videoFReader);
% videoFWrite.close();

% Nokia 8 Sirocco: Slow-motion = 120 fps, vanlig video = 30fps
ffmpegtranscode(input_video_file, output_image_path, 'AudioCodec', 'none', 'VideoCodec', 'x264','InputFrameRate', 90, 'OutputFrameRate', 60);
disp('COMPLETED');

% 
% videofile = 'video.mp4';
% maskfile = 'mask.png'; % same size as video.mp4 frame
% filtgraph = [ffmpegfilter.head ffmpegfilter.overlay ffmpegfilter.tail];
% filtgraph(1).link(filtgraph(2),'0:v'); % video.mp4 as the main
% filtgraph(1).link(filtgraph(2),'1:v',true); % mask.png as overlayed
% filtgraph(2).link(filtgraph(3));
% ffmpegcombine({'videofile.mp4' 'maskfile'},'output.mp4',filtgraph);
% 
% 
% 
% ffmpegexec(-i input.MP4 -vf "drawtext=fontfile=Arial.ttf:text='%{frame_num}':r=25:x=(w-tw)/2:y=h-(2*lh):fontcolor=white:fontsize=50:" -c:a copy output.mp4')
% winopen
% drawtext="fontfile=/usr/share/fonts/truetype/freefont/FreeSerif.ttf: text='Test Text'"
