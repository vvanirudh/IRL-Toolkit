% Transform hyperparameter to enforce constraints.
function hp = gpirlhpxform(hp,grad,xform,mode)

if mode == 1,
    % Transform from optimization mode to actual value.
    if strcmp(xform,'quad'),
        hp = hp.^2;
    elseif strcmp(xform,'exp'),
        hp = exp(hp);
    elseif strcmp(xform,'sig'),
        hp = 1./(exp(-hp)+1);
    else
        hp = hp;
    end;
elseif mode == 2,
    % Transform derivative.
    if strcmp(xform,'quad'),
        hp = 2*bsxfun(@times,hp',grad);
    elseif strcmp(xform,'exp'),
        hp = bsxfun(@times,exp(hp'),grad);
        hp(grad == 0) = 0;
    elseif strcmp(xform,'sig'),
        exphp = exp(min(-hp',1e2));
        hp = bsxfun(@times,(exphp./((exphp+1).^2)),grad);
    else
        hp = grad;
    end;
elseif mode == 3,
    % Actual value to optimization mode.
    if strcmp(xform,'quad'),
        hp = sqrt(hp);
    elseif strcmp(xform,'exp'),
        hp = log(hp);
    elseif strcmp(xform,'sig'),
        hp = -log((1./hp)-1);
    else
        hp = hp;
    end;
elseif mode == 4,
    % Clamp.
    if strcmp(xform,'quad'),
        hp = min(hp,sqrt(grad));
    elseif strcmp(xform,'exp'),
        hp = min(hp,log(grad));
    elseif strcmp(xform,'sig'),
        hp = hp; % Sigmoid never gets large.
    else
        hp = hp;
    end;
end;
