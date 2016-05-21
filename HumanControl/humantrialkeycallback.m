% Callback for key presses in the human trial window.
function humantrialkeycallback(~,event)

global trace_params;

for i=1:length(trace_params.keys),
    if event.Key == trace_params.keys{i},
        humantrialcallback('action',i);
    end;
end;
if event.Key == trace_params.undo,
    humantrialcallback('undo',0);
end;
