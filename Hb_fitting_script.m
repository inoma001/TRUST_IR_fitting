function [Hct,Hb,T1,gof]=Hb_fitting_script(data_folder)

%data_points=20; %only use first X data points in the calculation as later data points are probably more refective of tissue T1
% as this is where the water will have come from.

data_points=40;

%load data
d = dir([data_folder '/*.nii']);
T1_name = d.name;
T1_data = double( niftiread([data_folder '/' T1_name]) );


[i,j,k,l]=size(T1_data);

slice=zeros(i,j);
slice(50:74,10:40)=squeeze(T1_data(50:74,10:40,1,2));
% Find the max value.
maxValue = max(slice(:));
% Find all locations where it exists.
[m n] = find(slice == maxValue)



Tone_vect=(squeeze(T1_data(m,n,1,1:end))); 
%size(Tone_vect)

for i=1:16
Tone_vect_repeat(1+(i-1)*data_points:i*data_points)=Tone_vect(1+(i-1)*60:data_points+(i-1)*60);
end

TI_vect=150:150:data_points*150;
for i=1:16 
TI_vect_repeat(1+(i-1)*data_points:i*data_points)=TI_vect;
end


[fitresult, gof] = createT1_Fit(TI_vect_repeat, Tone_vect_repeat);
T1=fitresult.c/1000;


%T1 in seconds
Hb=(((1/T1 - 0.28)/0.83)-0.0083)/0.0301;
Hct =(0.0485*Hb*0.6206+0.0083)*100;


T1 = num2str(round(T1, 5, 'significant'));

% write result to text file

fileID = fopen([data_folder '/T1.txt'],'w');
fprintf(fileID, T1);
fclose(fileID);
%exit matlab 
exit

end

