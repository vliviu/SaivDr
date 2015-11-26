classdef PolyPhaseCoefOperation1dSystem < matlab.System %#codegen
    %POLYPHASECOEFOPERATION1DSYSTEM 1-D polyphase matrix
    %
    % SVN identifier:
    % $Id: PolyPhaseCoefOperation1dSystem.m 683 2015-05-29 08:22:13Z sho $
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
    
    properties (Nontunable)
        Operation
    end
    
    properties (Access = protected, Nontunable)
        numInputs
        numOutputs
        operationCategory
    end
    
    properties(Hidden,Transient)
        OperationSet = ...
            matlab.system.StringSet({...
            'Char',...
            'Transpose',...
            'CTranspose',...
            'Plus',...
            'Minus',...
            'MTimes',...
            'Upsample',...
            });
    end
    
    methods
        
        function obj = PolyPhaseCoefOperation1dSystem(varargin)
            setProperties(obj,nargin,varargin{:})
            if strcmp(obj.Operation,'Char')
                obj.numInputs = 1;
                obj.numOutputs = 1;
                obj.operationCategory = 'Other';
            elseif strcmp(obj.Operation,'Transpose') || ...
                    strcmp(obj.Operation,'CTranspose')
                obj.numInputs = 1;
                obj.numOutputs = 1;
                obj.operationCategory = 'Unary';
            elseif strcmp(obj.Operation,'Plus') || ...
                    strcmp(obj.Operation,'Minus') || ...
                    strcmp(obj.Operation,'MTimes')
                obj.numInputs = 2;
                obj.numOutputs = 1;
                obj.operationCategory = 'Binary';
            elseif  strcmp(obj.Operation,'Upsample')
                obj.numInputs = 2;
                obj.numOutputs = 1;
                obj.operationCategory = 'Other';
            end
        end
    end
    
    methods (Access = protected)
        
        function s = saveObjectImpl(obj)
            s = saveObjectImpl@matlab.System(obj);
            s.numInputs = obj.numInputs;
            s.numOutputs = obj.numOutupts;
            s.operationCategory = obj.operationCategory;
        end
        
        function loadObjectImpl(obj, s, wasLocked)
            obj.numInputs = s.numInputs;
            obj.numOutputs = s.numOutupts;
            obj.operationCategory = s.operationCategory;
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end
        
        function validateInputsImpl(obj,varargin)
            if strcmp(obj.operationCategory,'Unary')
                input1 = varargin{1};
                flag1 = isnumeric(input1) && ndims(input1) <= 3;
                if ~flag1
                    error('Input must be numeric less than or equal to 3-D.')
                end
            elseif strcmp(obj.operationCategory,'Binary')
                input1 = varargin{1};
                input2 = varargin{2};
                flag1 = isnumeric(input1) && ndims(input1) <= 3;
                flag2 = isnumeric(input2) && ndims(input2) <= 3;
                if ~flag1 || ~flag2
                    error('Input must be numeric less than or equal to 3-D.')
                end
            elseif strcmp(obj.Operation,'Char')
                input1 = varargin{1};
                flag1 = isnumeric(input1) && ndims(input1) <= 3;
                if ~flag1
                    error('Input must be numeric less than or equal to 3-D.')
                end
            elseif strcmp(obj.Operation,'Upsample')
                input = varargin{1};
                factorU = varargin{2};
                flag1 = isnumeric(input) && ndims(input) <= 3;
                if ~flag1
                    error('Input must be numeric less than or equal to 3-D.')
                end                
                if ~isnumeric(factorU) || factorU < 1
                    error('Upsampling factor must be an positive integer.')
                end
            else
                error('Invalid operation')
            end
        end
        
        function output = stepImpl(obj,varargin)
            if strcmp(obj.operationCategory,'Binary') % Binary operation
                coef1 = varargin{1};
                coef2 = varargin{2};
                if strcmp(obj.Operation,'Plus')
                    output = plus(obj,coef1,coef2);
                elseif strcmp(obj.Operation,'Minus')
                    output = minus(obj,coef1,coef2);
                elseif strcmp(obj.Operation,'MTimes')
                    output = mtimes(obj,coef1,coef2);
                end
            elseif strcmp(obj.operationCategory,'Unary')
                coef1 = varargin{1};
                if strcmp(obj.Operation,'CTranspose')
                    output = ctranspose_(obj,coef1);
                elseif strcmp(obj.Operation,'Transpose')
                    output = transpose_(obj,coef1);
                end
            elseif strcmp(obj.Operation,'Char')
                output = char(obj,varargin{1});
            elseif strcmp(obj.Operation,'Upsample')
                coef1 = varargin{1};
                factorU = varargin{2};
                output = upsample_(obj,coef1,factorU);
            else
                error('Invalid inputs')
            end
        end
        
        function N = getNumInputsImpl(obj)
            N = obj.numInputs;
        end
        
        function N = getNumOutputsImpl(obj)
            N = obj.numOutputs;
        end
        
    end
    
    methods (Access = private)
        
        function value = plus(~,coef1,coef2)
            if (ndims(coef1) == ndims(coef2) && ...
                    all(size(coef1) == size(coef2))) || ...
                    (isscalar(coef1) || isscalar(coef2))
                value = coef1+coef2;
            else
                [s1m1,s1m2,s1o1,s1o2] = size(coef1);
                [s2m1,s2m2,s2o1,s2o2] = size(coef2);
                s3 = max( [s1m1,s1m2,s1o1,s1o2],[s2m1,s2m2,s2o1,s2o2]);
                coef3 = zeros( s3 );
                n0 = size(coef1,3);
                n1 = size(coef1,4);
                coef3(:,:,1:n0,1:n1) = coef1(:,:,1:n0,1:n1);
                n0 = size(coef2,3);
                n1 = size(coef2,4);
                coef3(:,:,1:n0,1:n1) = ...
                    coef3(:,:,1:n0,1:n1) + coef2(:,:,1:n0,1:n1);
                value = coef3;
            end
        end % plus
        
        function value = minus(obj,coef1,coef2)
            value = plus(obj,coef1,-coef2);
        end % minus
        
        function value = mtimes(~,coef1,coef2)
            if size(coef1,2) ~= size(coef2,1)
                if (length(coef1)==1 || length(coef2)==1)
                    coef3 = coef1 * coef2;
                else
                    error('Inner dimensions must be the same as each other.');
                end
            else
                nDims = size(coef1,2);
                nRows = size(coef1,1);
                nCols = size(coef2,2);
                nTap = size(coef1,3)+size(coef2,3)-1;
                pcoef1 = permute(coef1,[3 1 2]);
                pcoef2 = permute(coef2,[3 1 2]);
                pcoef3 = zeros(nTap,nRows,nCols);
                for iCol = 1:nCols
                    for iRow = 1:nRows
                        array3 = zeros(nTap,1);
                        for iDim = 1:nDims
                            array1 = pcoef1(:,iRow,iDim);
                            array2 = pcoef2(:,iDim,iCol);
                            array3 = array3 + conv(array1,array2);
                        end
                        pcoef3(1:nTap,iRow,iCol) = array3;
                    end
                end
                coef3 = permute(pcoef3,[2 3 1]);
            end
            value = coef3;
        end
        
        function value = char(~,input)
            nRowsPhs = size(input,1);
            nColsPhs = size(input,2);
            value = ['[' 10]; % 10 -> \n
            if all(input(:) == 0)
                value = '0';
            else
                for iRowPhs = 1:nRowsPhs
                    strrow = 9; % 9 -> \t
                    for iColPhs = 1:nColsPhs
                        coefMatrix = permute(...
                            input(iRowPhs,iColPhs,:,:),[3 1 2]);
                        nOrds = size(coefMatrix,1) - 1;
                        strelm = '0';
                        for iOrd = 0:nOrds
                            elm = coefMatrix(iOrd+1);
                            if elm ~= 0
                                if strelm == '0'
                                    strelm = [];
                                end
                                if ~isempty(strelm)
                                    if elm > 0
                                        strelm = [strelm ' + ' ];
                                    else
                                        strelm = [strelm ' - ' ];
                                        elm = -elm;
                                    end
                                end
                                if elm ~= 1 || (iOrd == 0)
                                    strelm = [strelm num2str(elm)];
                                    if iOrd > 0
                                        strelm = [strelm '*'];
                                    end
                                end
                                if iOrd >=1
                                    strelm = [strelm 'z^(-' int2str(iOrd) ')'];
                                end
                            end % for strelm ~= 0
                        end % for iOrd
                        strrow = [strrow strelm];
                        if iColPhs ~= nColsPhs
                            strrow = [strrow ',' 9]; % 9 -> \t
                        end
                    end % for iColPhs
                    if iRowPhs == nRowsPhs
                        value = [value strrow 10 ']']; % 10 -> \n
                    else
                        value = [value strrow ';' 10]; % 10 -> \n
                    end
                end % for iRowPhs
            end
         end
         
         function value = ctranspose_(~,input)
             coefTmp = permute(input,[2 1 3]);
             coefTmp = flip(coefTmp,3);
             coefTmp = conj(coefTmp);
             value = coefTmp;
         end
         
         function value = transpose_(~,input)
             coefTmp = permute(input,[2 1 3]);
             coefTmp = flip(coefTmp,3);
             value = coefTmp;
         end
         
         function value = upsample_(~,input,ufactor)
             ucoef = input;
             coefTmp = ucoef;
             uLength = size(coefTmp,3);
             uLength = ufactor*(uLength - 1) + 1;
             usize = size(coefTmp);
             usize(3) = uLength;
             ucoef = zeros(usize);
             ucoef(:,:,1:ufactor:end) = coefTmp;
             value = ucoef;
         end
    end

end
