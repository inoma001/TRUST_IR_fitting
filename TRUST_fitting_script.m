function [Y,OEF_est,T2b]=TRUST_fitting_script(data_folder)

%need T1 in seconds (from IR sequence fits)
fileID = fopen([data_folder '/IR/T1.txt'],'r');
tline = fgetl(fileID);
T1=str2num(tline);

%load data
d = dir([data_folder '/TRUST/*.nii']);
TRUST_name = d.name;
TRUST_data = double( niftiread( [data_folder '/TRUST/' TRUST_name]) );

%subtraction
TRUST_sub(:,:,:)=TRUST_data(:,:,2:2:end)-TRUST_data(:,:,1:2:end-1);

eTE(1)=0;
eTE(2)=40;
eTE(3)=80;
eTE(4)=160;


%use maximum values in ACQ 1 to determine SS voxels - robust fit to 3 most intense voxels
slice=squeeze(TRUST_sub(:,:,1));
roi=sort(slice(:),'descend');

do_plot=1;

data_points=4;
for i=1:9 %3 averages x 3 voxels
    eTE_repeat(1+(i-1)*data_points:i*data_points)=eTE;
end


for vox = 1:3 %try most intense 3 voxels..
    
    [m, n] = find(slice == roi(vox));
    
    TRUST_vect(1+(vox-1)*data_points*3:vox*data_points*3)=squeeze(TRUST_sub(m,n,:));

end

[fitresult, gof] = createT2_Fit(eTE_repeat, TRUST_vect,[data_folder '/TRUST'], do_plot);

C1=fitresult.c;

T2b=1/(1/(T1*1000)-C1);
Hb=(((1/T1 - 0.28)/0.83)-0.0083)/0.0301; %use IR T1 to Hb equation (ignoring T2 contribution for now, but could correct for blood T2 when calculating [Hb])

Hct=(0.0485*Hb*0.6206+0.0083) %convert Hb to Hct


% Y calculation from Bush 2017 calibration   
A1 = 77.5;
A2 = 27.8;
A3 = 6.95;
A4 = 2.34;

R2b = 1000/T2b

one_minus_Y = sqrt ( (R2b - A3*Hct - A4)/(A1*Hct + A2) )
Y=1-one_minus_Y;
OEF_est=0.98-Y


% write result to text file
OEF = num2str(round(OEF_est, 4, 'significant'));
T2b = num2str(round(T2b, 4, 'significant'));
Hct = num2str(round(Hct, 4, 'significant'));

fileID = fopen([data_folder '/TRUST/OEF.txt'],'w');
fprintf(fileID, OEF);
fclose(fileID);

fileID = fopen([data_folder '/TRUST/T2b.txt'],'w');
fprintf(fileID, T2b);
fclose(fileID);

fileID = fopen([data_folder '/TRUST/Hct.txt'],'w');
fprintf(fileID, Hct);
fclose(fileID);

% pause matlab for 2 seconds to allow assesment of fit on graph
pause(2)
%exit matlab 
exit

end
