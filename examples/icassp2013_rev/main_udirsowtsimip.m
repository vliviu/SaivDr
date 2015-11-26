% MAIN_UDIRSOWTSIMIP Image Inpainting with Union of DirSOWTs 
%
% This script executes image inpainting with ISTA and Union of DirSOWT
% The design data placed under the folder '../dirlot/filters' are loaded.
%
% SVN identifier:
% $Id: main_udirsowtsimip.m 683 2015-05-29 08:22:13Z sho $
%
% Requirements: MATLAB R2013b
%
% Copyright (c) 2014-2015, Shogo MURAMATSU
%
% All rights reserved.
%
% Contact address: Shogo MURAMATSU,
%                Faculty of Engineering, Niigata University,
%                8050 2-no-cho Ikarashi, Nishi-ku,
%                Niigata, 950-2181, JAPAN
% 
% LinedIn: http://www.linkedin.com/pub/shogo-muramatsu/4b/b08/627
%
clear all; clc

%% Parameter setting for image restoration

% Parameters for degradation
losstype = 'Random'; % Pixel loss type
density  = 0.2;      % Pixel loss density 
seed     = 0;        % Random seed for pixel loss
nsigma   = 0;        % Sigma for AWGN

% Parameters for dictionary
strdic  = 'UDirSowt'; 
nlevels = [ 6, 6, 6, 6, 6 ]; % # of wavelet tree levels
dec  = [2 2];        % Decimation factor
ord  = [4 4];        % Polyphase order
vm   = 2;            % # of vanishing moments
sdir = '../dirlot/filters/'; % Folder contains dictionary parameter

% Parameter for ISTA
lambda =  0.00465;    % Lambda 
maxIter = 1000;         % Maximum number of iterations
eps0 = 1e-7;         % Criteria for convergence
isverbose = true;    % Verbose mode
isvisible = true;    % Monitor intermediate results 

%% Load test image
[img,strpartpic] = support.fcn_load_testimg('lena128');
orgImg = im2double(img);
nDim = size(orgImg);

%% Create degradation linear process
import saivdr.degradation.linearprocess.*
linproc = PixelLossSystem(...
    'LossType',losstype,...
    'Density',density,...
    'Seed',seed);

% String for identificatin of linear process
strlinproc = support.fcn_make_strlinproc(linproc); 

% Use file for lambda_max
fname_lmax = sprintf('./lmax/%s_%dx%d.mat',strlinproc,nDim(1),nDim(2));
set(linproc,...
    'UseFileForLambdaMax',true,...
    'FileNameForLambdaMax',fname_lmax);

%% Load or create an observed image
obsImg = support.fcn_observation(...
    linproc,orgImg,strpartpic,strlinproc,nsigma);

%% Create a dictionary
import saivdr.dictionary.nsgenlotx.*
import saivdr.dictionary.nsoltx.*
import saivdr.dictionary.mixture.*
synthesizers = cell(1,5);
analyzers = cell(1,5);
%
s = load(sprintf('%s/nsgenlot_d%dx%d_o%d+%d_v%d.mat',sdir,...
    dec(1),dec(2),ord(1),ord(2),vm),'lppufb');
lppufb = saivdr.dictionary.utility.fcn_upgrade(s.lppufb);
release(lppufb);
set(lppufb,'OutputMode','ParameterMatrixSet');
synthesizers{1} = NsoltFactory.createSynthesis2dSystem(lppufb);
analyzers{1} = NsoltFactory.createAnalysis2dSystem(lppufb);
%
phiset = [ -30 30 60 120 ];
idx = 2;
for phi = phiset
    s = load(sprintf('%s/dirlot_d%dx%d_o%d+%d_tvm%06.2f.mat',sdir,...
        dec(1),dec(2),ord(1),ord(2),phi),'lppufb');
    lppufb = saivdr.dictionary.utility.fcn_upgrade(s.lppufb);
    release(lppufb);
    set(lppufb,'OutputMode','ParameterMatrixSet');
    synthesizers{idx} = NsoltFactory.createSynthesis2dSystem(lppufb);
    analyzers{idx} = NsoltFactory.createAnalysis2dSystem(lppufb);
    idx = idx + 1;
end
%
synthesizer = MixtureOfUnitarySynthesisSystem(...
    'UnitarySynthesizerSet',synthesizers);
analyzer = MixtureOfUnitaryAnalysisSystem(...
    'UnitaryAnalyzerSet',analyzers);

%% Create a step monitor
import saivdr.utility.StepMonitoringSystem
hfig1 = figure(1);
stepmonitor = StepMonitoringSystem(...
    'SourceImage',orgImg,...
    'ObservedImage',obsImg,...
    'MaxIter', maxIter,...
    'IsMSE', true,...
    'IsPSNR', true,...
    'IsSSIM', true,...
    'IsVisible', isvisible,...
    'ImageFigureHandle',hfig1,...
    'IsVerbose', isverbose);

%% ISTA
stralg = 'ISTA';
fprintf('\n%s',stralg)
import saivdr.restoration.ista.IstaImRestoration
rstr = IstaImRestoration(...
    'Synthesizer',synthesizer,...
    'AdjOfSynthesizer',analyzer,...
    'LinearProcess',linproc,...
    'NumberOfTreeLevels',nlevels,...
    'Lambda',lambda);
set(rstr,'MaxIter',maxIter);
set(rstr,'Eps0',eps0);  
set(rstr,'StepMonitor',stepmonitor);
set(hfig1,'Name',[stralg ' ' strdic])

tic
resImg = step(rstr,obsImg);
toc

%% Save results
nItr   = get(stepmonitor,'nItr');
mses_  = get(stepmonitor,'MSEs');
psnrs_ = get(stepmonitor,'PSNRs');
ssims_ = get(stepmonitor,'SSIMs');
mse = mses_(1:nItr);   %#ok
psnr = psnrs_(1:nItr); %#ok
ssim = ssims_(1:nItr); %#ok
s = sprintf('%s_%s_%s_%s_ns%06.2f',...
    strpartpic,lower(stralg),lower(strdic),strlinproc,nsigma);
imwrite(resImg,sprintf('./results/res_%s.tif',s));
save(sprintf('./results/eval_%s.mat',s),'nItr','psnr','mse','ssim')

%% Median
stralg = 'Median';
fprintf('\n%s',stralg)
%
hfig2 = figure(2);
stepmonitor = StepMonitoringSystem(...
    'SourceImage',orgImg,...
    'ObservedImage',obsImg,...
    'MaxIter', 1,...
    'IsMSE', true,...
    'IsPSNR', true,...
    'IsSSIM', true,...
    'IsVisible', true,...
    'ImageFigureHandle',hfig2,...
    'IsVerbose', isverbose);
set(hfig2,'Name',stralg)
%
tic
medImg = medfilt2(obsImg);
[mse, psnr,ssim] = step(stepmonitor,medImg);
toc
%
s = sprintf('%s_%s_%s_ns%06.2f',strpartpic,lower(stralg),strlinproc,nsigma);
imwrite(medImg,sprintf('./results/res_%s.tif',s));
save(sprintf('./results/eval_%s.mat',s),'psnr','mse','ssim')
