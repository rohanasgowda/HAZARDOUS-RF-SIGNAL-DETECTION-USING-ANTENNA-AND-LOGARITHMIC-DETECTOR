%% LPDA + RF‐Power‑Detector Demo
% ------------------------------------------------------------
% 1.  Build LPDA            (basic linearArray)
% 2.  Analyse S11 / Gain
% 3.  Estimate received RF power via Friis
% 4.  Convert power -> AD8318 voltage
% 5.  Threshold logic -> alert
% ------------------------------------------------------------

clear; close all; clc

%% USER PARAMETERS
fLow   = 0.5e9;           % low end of band [Hz]
fHigh  = 3e9;             % high end of band [Hz]
numEle = 8;               % number of dipoles
tau    = 0.9;             % length‑scaling factor
sigma  = 0.1;             % spacing factor
L0     = 0.3;             % longest dipole length (m) ~= λ/2 at 500 MHz
haz_dBm = -20;            % hazard threshold in dBm (example)

%% 1 ─ Build LPDA (linearArray approximation)
el     = dipole.empty(numEle,0);        % dipole element list
spacing = zeros(1,numEle-1);            % element spacings
for k = 1:numEle
    Lk     = L0 * tau^(k-1);
    el(k)  = dipole('Length',Lk,'Width',1e-3);
    if k>1, spacing(k-1) = sigma*L0*tau^(k-2); end
end
lpda  = linearArray('Element',el,'ElementSpacing',spacing);
figure; show(lpda); title('LPDA Geometry');

%% 2 ─ Analyse S11 and Gain
freq  = linspace(fLow,fHigh,100);
S     = sparameters(lpda,freq);
figure; rfplot(S,1,1); title('S_{11} of LPDA (0.5‑3 GHz)');

% Gain at centre of band
fC    = (fLow+fHigh)/2;
figure; pattern(lpda,fC); title(sprintf('Radiation Pattern at %.2f GHz',fC/1e9));

%% 3 ─ Estimate received RF power (simple Friis example)
Pt_dBm = 0;                % hypothetical transmitter power (isotropic) 0 dBm
Gt_dBi = 0;                % isotropic Tx gain
Gr_dBi = pattern(lpda,fC,0,0);    % LPDA gain (boresight) [dBi]
d      = 5;                % distance [m]
lambda = 3e8/fC;
Friis_loss_dB = 20*log10(4*pi*d/lambda);
Pr_dBm = Pt_dBm + Gt_dBi + Gr_dBi - Friis_loss_dB;  % received power

fprintf('Estimated received power at %.1f m: %.2f dBm\n',d,Pr_dBm);

%% 4 ─ AD8318 Log Detector Model (approx.)
% Datasheet: Vout ≈ 0.85 V + 0.025 V/dB × (Pin[dBm] + 10)
slope     = 0.025;        % V per dB
intercept = 0.85;         % V at −10 dBm
Vout      = intercept + slope * (Pr_dBm + 10);

fprintf('AD8318 Vout = %.3f V\n',Vout);

%% 5 ─ Hazard threshold logic
Vth   = intercept + slope * (haz_dBm + 10);
alert = Vout > Vth;

if alert
    fprintf('\n⚠️  HAZARDOUS RF LEVEL DETECTED! (>%d dBm)\n',haz_dBm);
else
    fprintf('\n✅ RF level safe (≤%d dBm).\n',haz_dBm);
end

%% Optional sweep: show Vout vs Pin and alert region
PinVec = (-60:2:0).';                     % input‑power sweep
Vvec   = intercept + slope*(PinVec+10);   % detector curve
figure; plot(PinVec,Vvec,'b',haz_dBm*[1 1],[0 3],'r--');
xlabel('Input Power Pin [dBm]'); ylabel('V_{OUT} [V]');
title('AD8318 Transfer Curve + Hazard Threshold');
grid on
