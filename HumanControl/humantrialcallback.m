% Callback for human trial UI window.
function humantrialcallback(event,value)

global trace;
global trace_params;

switch event
    case 'undo',
        % Undo previous action.
        if trace_params.step(1) > 1,
            trace_params.step(1) = trace_params.step(1)-1;
            trace_params.state = trace{trace_params.step(2),trace_params.step(1)}(1);
            % Move agent.
            feval(strcat(trace_params.mdp,'movehuman'),trace_params.mdp_params,...
                trace_params.mdp_data,trace_params.state,trace_params.agent_fig);
        end;
    case 'action',
        % Take action specified by value.
        step = trace_params.step;
        s = trace_params.state;
        a = value;
        [N,T] = size(trace);
        fprintf(1,'Taking action %i at step %i of %i in trial %i of %i\n',value,step(1),T,step(2),N);
        
        % Figure out where we'll be going.
        samp = rand(1,1);
        csum = 0;
        for k=1:size(trace_params.mdp_data.sa_p,3),
            csum = csum + trace_params.mdp_data.sa_p(s,a,k);
            if csum >= samp,
                trace_params.state = trace_params.mdp_data.sa_s(s,a,k);
                break;
            end;
        end;
        
        % Store step.
        trace{step(2),step(1)} = [s;a];
        
        % Increment counter.
        step(1) = step(1)+1;
        if step(1) > T,
            step(1) = 1;
            step(2) = step(2)+1;
            trace_params.state = ceil(rand(1,1)*trace_params.mdp_data.states);
        end;
        trace_params.step = step;
        
        % Move agent.
        feval(strcat(trace_params.mdp,'movehuman'),trace_params.mdp_params,...
            trace_params.mdp_data,trace_params.state,trace_params.agent_fig);
        
        if step(2) > N,
            fprintf(1,'FINISHED!\n');
            % Close the window.
            close gcf;
        end;
end;
