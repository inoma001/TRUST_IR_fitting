function [fitresult, gof] = createT2_Fit(eTE, TRUST_mean)
%CREATEFIT(ETE,TRUST_MEAN)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : eTE
%      Y Output: TRUST_mean
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 30-Oct-2017 16:12:47


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( eTE, TRUST_mean );

% Set up fittype and options.
ft = fittype( 'a*exp(x*c)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [200 -Inf];
opts.StartPoint = [400 0.0]; %620009054156165

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
%figure( 'Name', 'T2 fit' );
%h = plot( fitresult, xData, yData );
%legend( h, 'dS0 vs. eTE', 'T2 fit', 'Location', 'NorthEast' );

% Label axes
%xlabel eTE
%ylabel dS0
%grid on


