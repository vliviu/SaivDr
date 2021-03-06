classdef GradientPursuit < ...
        saivdr.sparserep.AbstSparseApproximation %#codegen
    %GRADIENTPURSUIT Gradient pursuit
    %
    % Reference
    %  - Thomas Blumensath and Mike E. Davies, "Gradient pursuits,"
    %    IEEE Trans. Signal Process., vol. 56, no. 6, pp. 2370-2382,
    %    July 2008.
    %    
    % SVN identifier:
    % $Id: GradientPursuit.m 683 2015-05-29 08:22:13Z sho $
    %
    % Requirements: MATLAB R2015b
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
    % http://msiplab.eng.niigata-u.ac.jp/    
    %
    
    methods
        function obj = GradientPursuit(varargin)
            obj = ...
                obj@saivdr.sparserep.AbstSparseApproximation(varargin{:});        
        end
    end
    
    methods (Access = protected)
        
        function [ residual, coefvec, scales ] = stepImpl(obj, srcImg, nCoefs)
            source = im2double(srcImg);
            residual = source;

            % Initialization
            indexSet = [];
            coefvec  = 0;
            if ~isempty(obj.StepMonitor)
                reset(obj.StepMonitor)
            end
            
            % Iteration
            for iCoef = 1:nCoefs
                % g = Phi.'*r
                [gradvec,scales] = step(obj.AdjOfSynthesizer,...
                    residual,obj.NumberOfTreeLevels);
                if iCoef == 1
                    dirvec = zeros(size(gradvec));
                end
                % i = argmax|gi|
                [~, idxgmax ] = max(gradvec);
                % 
                indexSet = union(indexSet,idxgmax);
                % Calculate update direction
                dirvec(indexSet) = gradvec(indexSet);
                %
                c = step(obj.Synthesizer,dirvec,scales);
                %
                a = (residual(:).'*c(:))/(norm(c(:))^2);
                %
                coefvec  = coefvec  + a*dirvec;
                %
                residual = residual - a*c;
                %
                if ~isempty(obj.StepMonitor)
                    reconst = source - residual;
                    step(obj.StepMonitor,reconst);
                end
                %
            end
        end

    end
    
end
