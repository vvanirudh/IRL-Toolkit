% Fill in default parameters of a structure.
function params = filldefaultparams(params,defaults)

% Get default field names.
defaultfields = fieldnames(defaults);

% Step over all fields in the defaults structure.
for i=1:length(defaultfields),
    if ~isfield(params,defaultfields{i}),
        params.(defaultfields{i}) = defaults.(defaultfields{i});
    end;
end;
