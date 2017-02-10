classdef CplxOLpPrFbAtomConcatenator1dTestCase < matlab.unittest.TestCase
    %OLPPRFBATOMCONCATENATOR1DTESTCASE Test case for CplxOLpPrFbAtomConcatenator1d
    %
    % SVN identifier:
    % $Id: CplxOLpPrFbAtomConcatenator1dTestCase.m 683 2015-05-29 08:22:13Z sho $
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
    properties
        module
    end
 
    methods(TestMethodSetup)
      % function createFigure(testCase)
      %     testCase.TestFigure = figure;
      % end
    end
 
    methods(TestMethodTeardown)
      function deleteObject(testCase)
          delete(testCase.module);
      end
    end
 
    methods(Test)
        
        function testDefaultConstraction(testCase)

            % Expected values
            nchExpctd = [ 2 2 ];
            fpeExpctd = false;
            typExpctd = 'Type I';
            ordExpctd = 0;
            
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d();
            
            % Actual values
            fpeActual = get(testCase.module,'IsPeriodicExt');
            nchActual = [ 
                get(testCase.module,'NumberOfSymmetricChannels') ...
                get(testCase.module,'NumberOfAntisymmetricChannels') ];
            typActual = get(testCase.module,'OLpPrFbType');
            ordActual = get(testCase.module,'PolyPhaseOrder');
            
            % Evaluation
            testCase.verifyEqual(fpeActual,fpeExpctd);
            testCase.verifyEqual(nchActual,nchExpctd);
            testCase.verifyEqual(typActual,typExpctd);
            testCase.verifyEqual(ordActual,ordExpctd);
            
        end
        
        function testConstractionTypeII(testCase)
            
            % Expected values
            nchExpctd = [ 3 2 ];
            fpeExpctd = false;
            typExpctd = 'Type II';
            ordExpctd = 0;
            
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nchExpctd(1),...
                'NumberOfAntisymmetricChannels',nchExpctd(2));
            
            % Actual values
            fpeActual = get(testCase.module,'IsPeriodicExt');
            nchActual = [
                get(testCase.module,'NumberOfSymmetricChannels') ...
                get(testCase.module,'NumberOfAntisymmetricChannels') ];
            typActual = get(testCase.module,'OLpPrFbType');
            ordActual = get(testCase.module,'PolyPhaseOrder');
            
            % Evaluation
            testCase.verifyEqual(fpeActual,fpeExpctd);
            testCase.verifyEqual(nchActual,nchExpctd);
            testCase.verifyEqual(typActual,typExpctd);
            testCase.verifyEqual(ordActual,ordExpctd);
            
        end

        function testStepTypeI(testCase)

            % Parameters
            srclen = 16;
            nch   = [ 2 2 ];
            ord   = 0;
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;
            V0 = eye(sum(nch));
            pmCoefs = V0(:);
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;            
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
            
        end           

        function testStepTypeII(testCase)

            % Parameters
            srclen = 16;
            nch   = [ 3 2 ];
            ord   = 0;
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;
            V0 = eye(sum(nch));
            pmCoefs = V0(:);
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
            
        end                   

        function testStepOrd2Ch22(testCase)

            % Parameters
            srclen = 16;
            ord   = 2;
            nch   = [ 2 2 ];
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;
            V0 = eye(sum(nch));
            Ix = eye(nch(1));
            In = eye(nch(2));
            angB = pi/4*ones(floor(nch(1)/2),1);
            pmCoefs = [ V0(:); In(:) ; -In(:) ; angB(:) ; Ix(:) ; -Ix(:) ; angB(:) ];
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-9);
            
        end         

        function testStepOrd2Ch22U0(testCase)

            % Parameters
            srclen = 16;
            ord   = 2;
            nch   = [ 2 2 ];
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;
%             Ix = eye(nch(1));
%             In = eye(nch(2));
%             U0 = dctmtx(nch(2));
%             pmCoefs = [ Ix(:) ; U0(:); -In(:); -In(:) ];
            V0 = eye(sum(nch));
            Ix = eye(nch(1));
            In = eye(nch(2));
            angB = pi/4*ones(floor(nch(1)/2),1);
            pmCoefs = [ V0(:); In(:) ; -In(:) ; angB(:) ; Ix(:) ; -Ix(:) ; angB(:) ];
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;
            %cfsExpctd(nch(1)+1:end,:) = U0*cfsExpctd(nch(1)+1:end,:);
            cfsExpctd = V0*cfsExpctd;
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
            
        end                 

        function testStepOrd0Ch22(testCase)

            % Parameters
            srclen = 16;
            ord   = 0;
            nch   = [ 2 2 ];
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;
            V0 = eye(sum(nch));
            pmCoefs = V0(:);
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
            
        end          

        function testStepOrd4Ch22(testCase)

            % Parameters
            srclen = 16;
            ord   = 4;
            nch   = [ 2 2 ];
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;
            V0 = eye(sum(nch));
            Ix = eye(nch(1));
            In = eye(nch(2));
            angB = pi/4*ones(floor(nch(1)/2),1);
            pmCoefs = [ 
                V0(:) ;
                In(:) ; 
                -In(:) ;
                angB(:) ;
                Ix(:) ;
                -Ix(:) ;
                angB(:) ;
                In(:) ;
                -In(:) ;
                angB(:) ;
                Ix(:) ;                 
                -Ix(:) ;
                angB(:)  ];
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
            
        end         

        function testStepOrd2Ch44(testCase)

            % Parameters
            srclen = 16;
            ord   = 2;
            nch   = [ 4 4 ];
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;
            
            V0 = eye(sum(nch));
            Ix = eye(nch(1));
            In = eye(nch(2));
            angB = pi/4*ones(floor(nch(1)/2),1);
            pmCoefs = [ V0(:); In(:) ; -In(:) ; angB(:) ; Ix(:) ; -Ix(:) ; angB(:) ];
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
            
        end                       

        function testStepOrd2Ch32(testCase)

            % Parameters
            srclen = 16;
            ord   = 2;
            nch   = [ 3 2 ];
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;
            
            I0 = eye(sum(nch));
            Ix = eye(nch(1));
            In = eye(nch(2));
            Ux = blkdiag(-In,1);
            angB = pi/4*ones(floor(sum(nch)/4),1);
            pmCoefs = [
                I0(:) ;
                In(:) ;
                -In(:) ;
                angB ;
                Ix(:) ;
                Ux(:) ;
                angB ];
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
            
        end       

        function testStepOrd2Ch32U0(testCase)

            % Parameters
            srclen = 16;
            ord   = 2;
            nch   = [ 3 2 ];
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;
            
            U0 = dctmtx(sum(nch));
            Ix = eye(nch(1));
            In = eye(nch(2));
            Ux = blkdiag(-In,1);
            angB = pi/4*ones(floor(sum(nch)/4),1);
            pmCoefs = [
                U0(:) ;
                In(:) ;
                -In(:) ;
                angB ;
                Ix(:) ;
                Ux(:) ;
                angB ];
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;
            cfsExpctd = U0.'*cfsExpctd;
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
            
        end      

        function testStepOrd0Ch32(testCase)

            % Parameters
            srclen = 16;
            ord   = 0;
            nch   = [ 3 2 ];
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;
            V0 = eye(sum(nch));
            pmCoefs = V0(:);
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
            
        end         

        function testStepOrd4Ch32(testCase)

            % Parameters
            srclen = 16;
            ord   = 4;
            nch   = [ 3 2 ];
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;
            
            I0 = eye(sum(nch));
            Ix = eye(nch(1));
            In = eye(nch(2));
            Ux = blkdiag(-In,1);
            angB = pi/4*ones(floor(sum(nch)/4),1);
            pmCoefs = [
                I0(:) ;
                In(:) ;
                -In(:) ;
                angB ;
                Ix(:) ;
                Ux(:) ;
                angB ;
                In(:) ;
                -In(:) ;
                angB ;
                Ix(:) ;
                Ux(:) ;
                angB ];
            
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
            
        end                 

        function testStepOrd2Ch54(testCase)

            % Parameters
            srclen = 16;
            ord   = 2;
            nch   = [ 5 4 ];
            coefs = randn(sum(nch), srclen) + 1i*randn(sum(nch), srclen);
            scale = srclen;

            I0 = eye(sum(nch));
            Ix = eye(nch(1));
            In = eye(nch(2));
            Ux = blkdiag(-In,1);
            angB = pi/4*ones(floor(sum(nch)/4),1);
            pmCoefs = [
                I0(:) ;
                In(:) ;
                -In(:) ;
                angB ;
                Ix(:) ;
                Ux(:) ;
                angB ];
            
            % Expected values
            ordExpctd = ord;
            cfsExpctd = coefs;
                        
            % Instantiation
            import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
            testCase.module = CplxOLpPrFbAtomConcatenator1d(...
                'NumberOfSymmetricChannels',nch(1),...
                'NumberOfAntisymmetricChannels',nch(2));
            set(testCase.module,'PolyPhaseOrder',ord);
            
            % Actual values
            ordActual = get(testCase.module,'PolyPhaseOrder');
            cfsActual = step(testCase.module,coefs,scale,pmCoefs);
            
            % Evaluation
            testCase.verifyEqual(ordActual,ordExpctd);
            testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-9);
            
        end

%         function testStepOrd2Ch23(testCase)
% 
%             % Parameters
%             srclen = 16;
%             ord   = 2;
%             nch   = [ 2 3 ];
%             coefs = randn(sum(nch), srclen);
%             scale = srclen;
%             In = eye(nch(1));
%             Ix = eye(nch(2));
%             pmCoefs = [ -In(:) ; Ix(:) ; -In(:) ;  Ix(:) ];
%             
%             % Expected values
%             ordExpctd = ord;
%             cfsExpctd = coefs;
%                         
%             % Instantiation
%             import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
%             testCase.module = CplxOLpPrFbAtomConcatenator1d(...
%                 'NumberOfSymmetricChannels',nch(1),...
%                 'NumberOfAntisymmetricChannels',nch(2));
%             set(testCase.module,'PolyPhaseOrder',ord);
%             
%             % Actual values
%             ordActual = get(testCase.module,'PolyPhaseOrder');
%             cfsActual = step(testCase.module,coefs,scale,pmCoefs);
%             
%             % Evaluation
%             testCase.verifyEqual(ordActual,ordExpctd);
%             testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
%             
%         end       
% 
%         function testStepOrd2Ch23W0(testCase)
% 
%             % Parameters
%             srclen = 16;
%             ord   = 2;
%             nch   = [ 2 3 ];
%             coefs = randn(sum(nch), srclen);
%             scale = srclen;
%             In = eye(nch(1));
%             Ix = eye(nch(2));
%             W0 = dctmtx(nch(1));
%             pmCoefs = [ 
%                 W0(:) ;
%                 Ix(:) ; 
%                 -In(:) ; 
%                 Ix(:) ];
%             
%             % Expected values
%             ordExpctd = ord;
%             cfsExpctd = coefs;
%             cfsExpctd(1:nch(1),:) = -W0.'*cfsExpctd(1:nch(1),:);
%                         
%             % Instantiation
%             import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
%             testCase.module = CplxOLpPrFbAtomConcatenator1d(...
%                 'NumberOfSymmetricChannels',nch(1),...
%                 'NumberOfAntisymmetricChannels',nch(2));
%             set(testCase.module,'PolyPhaseOrder',ord);
%             
%             % Actual values
%             ordActual = get(testCase.module,'PolyPhaseOrder');
%             cfsActual = step(testCase.module,coefs,scale,pmCoefs);
%             
%             % Evaluation
%             testCase.verifyEqual(ordActual,ordExpctd);
%             testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
%             
%         end      
% 
%         function testStepOrd0Ch23(testCase)
% 
%             % Parameters
%             srclen = 16;
%             ord   = 0;
%             nch   = [ 2 3 ];
%             coefs = randn(sum(nch), srclen);
%             scale = srclen;
%             In = eye(nch(1));
%             Ix = eye(nch(2));
%             pmCoefs = [ 
%                 In(:) ; 
%                 Ix(:) ];
%             
%             % Expected values
%             ordExpctd = ord;
%             cfsExpctd = coefs;
%                         
%             % Instantiation
%             import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
%             testCase.module = CplxOLpPrFbAtomConcatenator1d(...
%                 'NumberOfSymmetricChannels',nch(1),...
%                 'NumberOfAntisymmetricChannels',nch(2));
%             set(testCase.module,'PolyPhaseOrder',ord);
%             
%             % Actual values
%             ordActual = get(testCase.module,'PolyPhaseOrder');
%             cfsActual = step(testCase.module,coefs,scale,pmCoefs);
%             
%             % Evaluation
%             testCase.verifyEqual(ordActual,ordExpctd);
%             testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
%             
%         end         
% 
%         function testStepOrd4Ch23(testCase)
% 
%             % Parameters
%             srclen = 16;
%             ord   = 4;
%             nch   = [ 2 3 ];
%             coefs = randn(sum(nch), srclen);
%             scale = srclen;
%             In = eye(nch(1));
%             Ix = eye(nch(2));
%             pmCoefs = [ 
%                 In(:) ; 
%                 Ix(:) ;
%                 -In(:) ; 
%                 Ix(:) ;                
%                 -In(:) ; 
%                 Ix(:) ];
%             
%             % Expected values
%             ordExpctd = ord;
%             cfsExpctd = coefs;
%                         
%             % Instantiation
%             import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
%             testCase.module = CplxOLpPrFbAtomConcatenator1d(...
%                 'NumberOfSymmetricChannels',nch(1),...
%                 'NumberOfAntisymmetricChannels',nch(2));
%             set(testCase.module,'PolyPhaseOrder',ord);
%             
%             % Actual values
%             ordActual = get(testCase.module,'PolyPhaseOrder');
%             cfsActual = step(testCase.module,coefs,scale,pmCoefs);
%             
%             % Evaluation
%             testCase.verifyEqual(ordActual,ordExpctd);
%             testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
%             
%         end                 
% 
%         function testStepOrd2Ch45(testCase)
% 
%             % Parameters
%             srclen = 16;
%             ord   = 2;
%             nch   = [ 4 5 ];
%             coefs = randn(sum(nch), srclen);
%             scale = srclen;
%             In = eye(nch(1));
%             Ix = eye(nch(2));
%             pmCoefs = [ 
%                 -In(:) ; 
%                 Ix(:) ;
%                 -In(:) ; 
%                 Ix(:) ];
%             
%             % Expected values
%             ordExpctd = ord;
%             cfsExpctd = coefs;
%                         
%             % Instantiation
%             import saivdr.dictionary.colpprfb.CplxOLpPrFbAtomConcatenator1d
%             testCase.module = CplxOLpPrFbAtomConcatenator1d(...
%                 'NumberOfSymmetricChannels',nch(1),...
%                 'NumberOfAntisymmetricChannels',nch(2));
%             set(testCase.module,'PolyPhaseOrder',ord);
%             
%             % Actual values
%             ordActual = get(testCase.module,'PolyPhaseOrder');
%             cfsActual = step(testCase.module,coefs,scale,pmCoefs);
%             
%             % Evaluation
%             testCase.verifyEqual(ordActual,ordExpctd);
%             testCase.verifyEqual(cfsActual,cfsExpctd,'RelTol',1e-10);
%             
%         end                                                                                    
 
     end
 
end
