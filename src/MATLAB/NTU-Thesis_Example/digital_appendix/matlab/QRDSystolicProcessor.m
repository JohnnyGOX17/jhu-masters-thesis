classdef QRDSystolicProcessor
	methods (Static)
		function [output_ts]=Process(input,lambda,delta,nodetype)
			% PROCESS Simulate QRD-RLS systolic array. Input should be a time
			% series collection with the reference channel named 'REF',
			% and any extra channels named 'CH1', 'CH2' etc.
			% Parameter 'nodetype' is used to choose node simulation
			% function. If 'givens' is selected, the simulator will use
			% boundary_givens() and internal_givens() functions.
			% Returns filtered output.
			[time, d, x] = unpackcollection(input);

			MN = input.size(2)-1; % input width, excluding reference
			L = input.length();   % length of time vector
			
			state_struct = struct( ...
				'node', zeros(MN, MN+2),... % store r values in recursion
				'ready', false(MN, MN+2), ... % nodes that are ready
				'c', zeros(MN), ... % rotation parameters between nodes
				's', zeros(MN), ...
				'xin', zeros(MN+1, MN+2) ... % inputs from above, for each node.
				... % xin is 1 row larger because we are interested in the
				... % xin's for the MN+1 row (i.e. outputs from the last MN row)
			);
			state_struct.node(1:MN,1) = sqrt(delta); % initialize r11, r22 etc.
			cs = state_struct;
			ns = cs; % use next state ns and current state cs

			ns.ready(1,1) = true; % r11 is ready, it only depends on x0 input

			outputhist = zeros(1, L);

			sqrtlambda = sqrt(lambda); % may be precomputed
			boundary = str2func(strcat('boundary_', nodetype));
			internal = str2func(strcat('internal_', nodetype));

			input = [x; 
				ones(1, length(d));
				d];
			%%
			h = waitbar(0,'');
			for l = 1:L
				if (mod(l,25) == 0)
					waitbar(l/L,h,sprintf('IQRD-RLS Structure simulation: %02.0f%%',100*l/L))
				end
				cs = ns;

				% feed new elements into the top of the xin matrix. We read a
				% time-shifted slice of the input matrix
				invector = zeros(1, MN+2);
				for j =	1:MN+2
					if (l-(j-1) < 1)
						break; % during initialization, not all values are ready
					end
					invector(j) = input(j, l-(j-1));
				end
				invector = round(invector);
				cs.xin(1,1:MN+2) = invector;

				%fprintf('\nIteration start: %i\n',l);
				for j = 1:size(cs.node, 1) % visit each row..
					for k = 1:size(cs.node, 2) % visit each node in that row

						if cs.ready(j,k) == true

							% find type of node and evaluate the node
							if k == 1 % leftmost row, only boundary nodes.
								%fprintf('Boundary node %i,%i------\n', j,k)
								[ns.s(j,k), ns.c(j,k), ns.node(j,k)] = ...
								 boundary(cs.node(j,k),cs.xin(j,k),sqrtlambda);

								% mark node to the right as ready
								ns.ready(j,k+1) = true;
							else
								%fprintf('Internal node %i,%i------\n', j,k)
								% same as inverse nodes, just a different node
								[ns.s(j,k),ns.c(j,k),ns.node(j,k),ns.xin(j+1,k-1)] = ...
									internal(cs.s(j,k-1), cs.c(j,k-1), cs.node(j,k),...
									cs.xin(j,k), sqrtlambda);

								% propagate readiness
								ns.ready(j+1,k-1) = true; % below and to left
								ns.ready(j,k+1) = true; % to the right
							end
						end

					end
					
					% in each row, zero the node feedback for the column
					% computing gamma
					column = (MN+1):-1:1;
					ns.node(j, column(j)) = 0;
				end % all rows and columns processed

				outputhist(:,l) = real(ns.xin(MN+1,1)).*(ns.xin(MN+1, 2));
			end
			close(h);

			% outputs are ready in following cycle, so add 1 to time.
			% this structure does not create a weight output
			output_ts = CustomSeries(outputhist, time);
		end
	end
end

