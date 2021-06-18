function [Hct,Hb,T1,gof]=Hb_fitting_script(data_folder)

%data_points=40;
data_points=50;

%load data
d = dir([data_folder '/*.nii']);
T1_name = d.name;
T1_data = double( niftiread([data_folder '/' T1_name]) );


[i,j,k,l]=size(T1_data);

slice=zeros(i,j);
slice(50:74,10:40)=squeeze(T1_data(50:74,10:40,1,2));

TI_vect=150:150:data_points*150;
for i=1:16 
    TI_vect_repeat(1+(i-1)*data_points:i*data_points)=TI_vect;
end

% loop through analysis for for voxels with highest value... find T1 in
% voxel with smallest residual percentage error

roi=sort(slice(:),'descend');
%T1_array=zeros(20,4);
per_err=1E10;
T1_out=0;
do_plot=0;
x=0;
y=0;

for vox = 1:20
    
    [m, n] = find(slice == roi(vox));
    
% % Find the max value.
% maxValue = max(slice(:));
% % Find all locations where it exists.
% [m n] = find(slice == maxValue)

    Tone_vect=(squeeze(T1_data(m,n,1,1:end))); 

    for i=1:16
        Tone_vect_repeat(1+(i-1)*data_points:i*data_points)=Tone_vect(1+(i-1)*60:data_points+(i-1)*60);
    end

    [fitresult, gof] = createT1_Fit(TI_vect_repeat, Tone_vect_repeat,do_plot);
    
    %T1 in seconds
    T1=fitresult.c/1000;
    
    %check percentage error 
    current_error=(gof.rmse)/mean(Tone_vect_repeat(1:5));
    
%     %write results to array
%     m=max(m(:));
%     n=max(n(:));
%     T1_array(vox,1)=current_error;
%     T1_array(vox,2)=T1;
%     T1_array(vox,3)=m;
%     T1_array(vox,4)=n;
    
    % convert T1 to string
    T1 = num2str(round(T1, 5, 'significant'));

    if current_error<per_err
        per_err=current_error;
        T1_out=T1;
        x=m;
        y=n;
    end

%Hb=(((1/T1 - 0.28)/0.83)-0.0083)/0.0301;
%Hct =(0.0485*Hb*0.6206+0.0083)*100;

end

% plot selected fit to check it is correct
do_plot=1;
x
y
Tone_vect=(squeeze(T1_data(x,y,1,1:end))); 
for i=1:16
    Tone_vect_repeat(1+(i-1)*data_points:i*data_points)=Tone_vect(1+(i-1)*60:data_points+(i-1)*60);
end
[fitresult, gof] = createT1_Fit(TI_vect_repeat, Tone_vect_repeat,do_plot);

% % sort T1 array by residuals
% sortrows(T1_array)
% %create average timcourse for fitting of T1 (can consider doing per_error weighted average as it might help) 
% Tone_vect=(squeeze(T1_data(T1_array(1,3),T1_array(1,4),1,1:end))); 
% for vox=2:15
%     Tone_vect=Tone_vect+(T1_array(1,1)/T1_array(vox,1)).*(squeeze(T1_data(T1_array(vox,3),T1_array(vox,4),1,1:end))); 
% end
% Tone_vect=Tone_vect./5;
% 
% for i=1:16
% Tone_vect_repeat(1+(i-1)*data_points:i*data_points)=Tone_vect(1+(i-1)*60:data_points+(i-1)*60);
% end
% [fitresult, gof] = createT1_Fit(TI_vect_repeat, Tone_vect_repeat,do_plot);
% T1=fitresult.c/1000;
% T1 = num2str(round(T1, 5, 'significant'));
% T1_out=T1;


% write result to text file
fileID = fopen([data_folder '/T1.txt'],'w');
fprintf(fileID, T1_out);
fclose(fileID);
% pause matlab for 5 seconds to allow assesment of fit on graph
pause(5)
%exit matlab 
exit

end

