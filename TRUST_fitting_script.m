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

%use maximum value in ACQ 1 to determine SS voxel (need to test this for
%robustness)
slice=squeeze(TRUST_sub(:,:,1));
% Find the max value.
maxValue = max(slice(:));
% Find all locations where it exists.
[m n] = find(slice == maxValue);

TRUST_vect=squeeze(TRUST_sub(m,n,:));
TRUST_mean=TRUST_vect(1:4);
for i=2:3
    TRUST_mean=TRUST_mean+TRUST_vect((i-1)*4+1:i*4);
end

TRUST_mean=TRUST_mean./3;

eTE(1)=0;
eTE(2)=40;
eTE(3)=80;
eTE(4)=160;

[fitresult, gof] = createT2_Fit(eTE, TRUST_mean',[data_folder '/TRUST']); %'

C1=fitresult.c;

T2b=1/(1/(T1*1000)-C1);
Hb=(((1/T1 - 0.28)/0.83)-0.0083)/0.0301; %use IR T1 to Hb equation (ignoring T2 contribution for now, but could correct for blood T2 when calculating [Hb])

Hct=(0.0485*Hb*0.6206+0.0083) %convert Hb to Hct

% Y calculation from Bush et al 2017 'Empirical Model of Human Blood Transverse Relaxation at 3T Improves MRI T2 Oximetry'


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