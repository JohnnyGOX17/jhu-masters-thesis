classdef CustomSeries < timeseries
    %CUSTOMSERIES Extend timeseries with plotting convenience functions
    
    methods
        function u = CustomSeries(obj, varargin)
            u@timeseries(obj,varargin);
			u = setinterpmethod(u, 'zoh');
        end
        function r = class(obj)
            r = 'timeseries';
        end
        function varargout = plot(obj,varargin)
            plot(obj.Time, real(squeeze(obj.Data)), varargin{:});
            xlabel('Time [samples]');
            ylabel('Real part');
		end
		function varargout = plotimag(obj, varargin)
            plot(obj.Time, imag(squeeze(obj.Data)), varargin{:});
            xlabel('Time [samples]');
            ylabel('Magnitude');
        end
        function varargout = plotabs(obj, varargin)
            plot(obj.Time, abs(squeeze(obj.Data)), varargin{:});
            xlabel('Time [samples]');
            ylabel('Magnitude');
        end
        function varargout = plotangle(obj, varargin)
            phase = unwrap(angle(squeeze(obj.Data)),[],2);
            plot(obj.Time, phase, varargin{:});
            xlabel('Time [samples]');
            ylabel('Angle');
        end
        
        function varargout = hist(obj, varargin)
            hist(abs(squeeze(obj.Data(1,:,:))),varargin{:})
        end
    end
end

