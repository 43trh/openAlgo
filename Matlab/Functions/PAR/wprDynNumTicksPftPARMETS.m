function shMETS = wprDynNumTicksPftPARMETS(x,data,minTick,bigPoint,cost,scaling)
% define wprDynNumTicksPft to accept vectorized inputs and return only sharpe ratio
%
% Wrapper for wprDynNumTicksPft to accept vectorized inputs and return only sharpe ratio
% in order to facilitate embarrassingly parallel parametric sweeps.
% PAR wrappers allow the parallel execution of parametric sweeps across HPC clusters
% ordinarily using 'parfor' with MatLab code.  While it is tempting to more granularly
% manage the process into a classically defined job with tasks (as used in Microsoft's HPC)
% the overhead associated with this approach is most often burdensome.
%
% The wrapper will indicate if it is looking to maximize:
%   Standard Sharpe     function(s)PAR
%   METS Sharpe         function(s)PARMETS
%%
% wprDynNumTicksPftPARMETS(x=[Mult,OB,OS,numTicks,openAvg],data,minTick,bigPoint,cost,scaling)
%


row = size(x,1);
shTest = zeros(row,1);
shVal = zeros(row,1);
shMETS = zeros(row,1); %#ok<NASGU>

testPts = floor(0.8*length(data(:,1)));
vBarsTest = data(1:testPts,:);
vBarsVal = data(testPts+1:end,:);


%% Progress Bar
try % Initialization
    ppm = ParforProgressStarter2('Parametric Sweep: wprDynNumTicksPftPARMETS', row, 0.1);
catch me % make sure "ParforProgressStarter2" didn't get moved to a different directory
    if strcmp(me.message, 'Undefined function or method ''ParforProgressStarter2'' for input arguments of type ''char''.')
        error('ParforProgressStarter2 not in path.');
    else
        % this should NEVER EVER happen.
        msg{1} = 'Unknown error while initializing "ParforProgressStarter2":';
        msg{2} = me.message;
        print_error_red(msg);
        % backup solution so that we can still continue.
        ppm.increment = nan(1, nbr_files);
    end %if
end %try


%% Parallel iterations
    parfor ii = 1:row

        [~,~,~,shTest(ii)] = wprDynNumTicksPftSIG(vBarsTest,x(ii,1),x(ii,2),x(ii,3),...
                minTick,x(ii,4),x(ii,5),...
                bigPoint,cost,scaling);
        [~,~,~,shVal(ii)] = wprDynNumTicksPftSIG(vBarsVal,x(ii,1),x(ii,2),x(ii,3),...
                minTick,x(ii,4),x(ii,5),...
                bigPoint,cost,scaling);
       
        ppm.increment(ii); %#ok<PFBNS>

    end; %parfor


%% Destroy progress bar
try % use try / catch here, since delete(struct) will raise an error.
    delete(ppm);
catch me %#ok<NASGU>
end

    
%% Aggregate sharpe ratios
shMETS = ((shTest*2)+shVal)/3;

%%
%   -------------------------------------------------------------------------
%                                  _    _ 
%         ___  _ __   ___ _ __    / \  | | __ _  ___   ___  _ __ __ _ 
%        / _ \| '_ \ / _ \ '_ \  / _ \ | |/ _` |/ _ \ / _ \| '__/ _` |
%       | (_) | |_) |  __/ | | |/ ___ \| | (_| | (_) | (_) | | | (_| |
%        \___/| .__/ \___|_| |_/_/   \_\_|\__, |\___(_)___/|_|  \__, |
%             |_|                         |___/                 |___/
%   -------------------------------------------------------------------------
%        This code is distributed in the hope that it will be useful,
%
%                      	   WITHOUT ANY WARRANTY
%
%                  WITHOUT CLAIM AS TO MERCHANTABILITY
%
%                  OR FITNESS FOR A PARTICULAR PURPOSE
%
%                          expressed or implied.
%
%   Use of this code, pseudocode, algorithmic or trading logic contained
%   herein, whether sound or faulty for any purpose is the sole
%   responsibility of the USER. Any such use of these algorithms, coding
%   logic or concepts in whole or in part carry no covenant of correctness
%   or recommended usage from the AUTHOR or any of the possible
%   contributors listed or unlisted, known or unknown.
%
%   Any reference of this code or to this code including any variants from
%   this code, or any other credits due this AUTHOR from this code shall be
%   clearly and unambiguously cited and evident during any use, whether in
%   whole or in part.
%
%   The public sharing of this code does not relinquish, reduce, restrict or
%   encumber any rights the AUTHOR has in respect to claims of intellectual
%   property.
%
%   IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY
%   DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
%   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
%   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
%   STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
%   ANY WAY OUT OF THE USE OF THIS SOFTWARE, CODE, OR CODE FRAGMENT(S), EVEN
%   IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%   -------------------------------------------------------------------------
%
%                             ALL RIGHTS RESERVED
%
%   -------------------------------------------------------------------------
%
%   Author:        Mark Tompkins
%   Revision:      5332.16531
%   Copyright:     (c)2014
%

