classdef IQRDSystolicProcessor
	methods (Static)
		function [output_ts, weight_ts] = Process(input,lambda,delta,nodetype)
			% PROCESS Simulate IQRD-RLS systolic array. Input should be a time
			% series collection with the reference channel named 'REF',
			% and any extra channels named 'CH1', 'CH2' etc.
			% Returns filtered output and weight vector at every sample.
			[time, d, x] = unpackcollection(input);

			MN = input.size(2)-1; % input width, excluding reference
			L = input.length();   % length of time vector

			state_struct = struct( ...
				'node',zeros(MN+1, MN+2),... % stores r values in recursion
				'ready',false(MN+1, MN+2),... % nodes that are ready
				'c',ones(MN+1),... % rotation parameters between nodes
				's',zeros(MN+1),... 
				'xin',zeros(MN+1, MN+2)... % inputs from above, for each node
			);
			state_struct.node(1:MN,1) = sqrt(delta); % init r11, r22 etc.
			state_struct.node(1:MN,end) = 1/sqrt(delta); % init rm11, rm22 etc.
			cs = state_struct;
			ns = cs; % use next state ns and current state cs

			ns.ready(1,1) = true; % mark r11 ready, only depends on x0 input
			ns.ready(MN+1,MN+2) = true; % mark 1/gamma as ready. node not used
			outputrowhist = zeros(MN+1, L);
			whist = zeros(MN, L);
			outputhist = zeros(1, L);

			sqrtlambda = sqrt(lambda); % may be precomputed
			invsqrtlambda = 1/sqrtlambda;
			boundary = str2func(strcat('boundary_', nodetype));
			internal = str2func(strcat('internal_', nodetype));

			input = [x; d];
			%%
			h = waitbar(0,'');
			for l = 1:L
				if (mod(l,25) == 0)
					waitbar(l/L,h,sprintf('IQRD-RLS Structure simulation: %02.0f%%',100*l/L))
				end
				cs = ns;

				% feed new elements into the top of the xin matrix. We read a
				% time-shifted slice of the input matrix.
				invector = zeros(1, MN+1);
				for j =	1:MN+1
					if (l-(j-1) < 1)
						break; % during initialization, not all values are ready
					end
					invector(j) = input(j, l-(j-1));
				end
				invector = round(invector);
				cs.xin(1,1:MN+1) = invector;

				cs.xin(:,end) = 0; % zero rightmost column for clarity
				% not really needed since nothing else writes this column

				for j = 1:size(cs.node, 1) % visit each row..
					for k = 1:size(cs.node, 2) % visit each node in that row

						if cs.ready(j,k) == true

							% find type of node and evaluate the node
							if k == 1 % leftmost row, only boundary nodes.
								%fprintf('Boundary node %i,%i------\n', j,k)
								[ns.s(j,k), ns.c(j,k), ns.node(j,k)] =	...
								 boundary(cs.node(j,k),cs.xin(j,k),sqrtlambda);

								% mark node to the right as ready
								ns.ready(j,k+1) = true;
							elseif j > MN + 1 -(k-1) % inverse internal nodes
								%fprintf('Inv internal node %i,%i------\n', j,k)
								% upper left triangle, internal nodes. Produces outputs
								% that are indexed down and to the left so that that the
								% receiving node reads it at its own index.
								[ns.s(j,k), ns.c(j,k), ns.node(j,k), ns.xin(j+1,k-1)] = ...
									internal(cs.s(j,k-1), cs.c(j,k-1), cs.node(j,k),...
									cs.xin(j,k), invsqrtlambda);

								% propagate readiness, if possible
								if j+1 <= size(ns.ready,1)
									ns.ready(j+1,k-1) = true; % node below and to left
								end
								if k+1 <= size(ns.ready, 2)
									ns.ready(j,k+1) = true; % node to the right
								end
							else
								%fprintf('Internal node %i,%i------\n', j,k)
								% same as inverse nodes, just a different node
								[ns.s(j,k),ns.c(j,k),ns.node(j,k),ns.xin(j+1,k-1)] = ...
									internal(cs.s(j,k-1),cs.c(j,k-1),cs.node(j,k),...
									cs.xin(j,k), sqrtlambda);

								% propagate readiness
								ns.ready(j+1,k-1) = true; % below and to left
								ns.ready(j,k+1) = true; % to the right
							end

						end

					end
				end
				gamma = ns.node(MN+1, 1);
				wtilde = ns.node(MN+1, 2:(end-1));
				outputrowhist(:,l) = [gamma wtilde];

				w = zeros(MN,1);
				if cs.ready% only generate weigths once all nodes are initialized
					gamma = outputrowhist(1,l-MN);
					for j = 1:MN
						w(j) = -gamma*outputrowhist(1+j, l-MN+j);
					end
				end
				whist(:,l) = w;
				latency = l-(3*MN + 2 - 1);
				if ((l-latency) >= 1)
					outputhist(l) = d(l-latency) - w'*x(:,l-latency);
				else
					outputhist(l) = 0;
				end
			end
			close(h);

			% outputs are ready in following cycle, so add 1 to time
			weight_ts = CustomSeries(whist, time+1);
			output_ts = CustomSeries(outputhist, time+1);
		end
	end
end

