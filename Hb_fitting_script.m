function [Hct,Hb,T1,gof]=Hb_fitting_script(data_folder)

data_points=40;

%load data
d = dir([data_folder '/*.nii']);
T1_name = d.name;
T1_data = double( niftiread([data_folder '/' T1_name]) );


[i,j,k,l]=size(T1_data);

slice=zeros(i,j);
slice(50:74,10:25)=squeeze(T1_data(50:74,10:25,1,2));

TI_vect=150:150:data_points*150;
for i=1:16 
    TI_vect_repeat(1+(i-1)*data_points:i*data_points)=TI_vect;
end

% loop through analysis for for voxels with highest value... find T1 in
% voxel with smallest residual percentage error

roi=sort(slice(:),'descend');

per_err=1E10;
T1_out=0;
do_plot=0;
x=0;
y=0;

for vox = 1:20
    
    [m, n] = find(slice == roi(vox));
    
    Tone_vect=(squeeze(T1_data(m,n,1,1:end))); 

    for i=1:16
        Tone_vect_repeat(1+(i-1)*data_points:i*data_points)=Tone_vect(1+(i-1)*60:data_points+(i-1)*60);
    end

    [fitresult, gof] = createT1_Fit(TI_vect_repeat, Tone_vect_repeat, data_folder, do_plot);
    
    %T1 in seconds
    T1=fitresult.c/1000;
    
    %check percentage error 
    current_error=(gof.rmse)/mean(Tone_vect_repeat(1:5));
        
    % convert T1 to string
    T1 = num2str(round(T1, 5, 'significant'));

    if current_error<per_err
        per_err=current_error;
        T1_out=T1;
        x=m;
        y=n;
    end

end

% plot selected fit to check it is correct
do_plot=1;
Tone_vect=(squeeze(T1_data(x,y,1,1:end))); 
for i=1:16
    Tone_vect_repeat(1+(i-1)*data_points:i*data_points)=Tone_vect(1+(i-1)*60:data_points+(i-1)*60);
end
[fitresult, gof] = createT1_Fit(TI_vect_repeat, Tone_vect_repeat, data_folder, do_plot);


% write result to text file
fileID = fopen([data_folder '/T1.txt'],'w');
fprintf(fileID, T1_out);
fclose(fileID);
% pause matlab for 2 seconds to allow assesment of fit on graph
pause(2)
%exit matlab 
exit

end