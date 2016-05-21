% Render high-quality version of highway object.
function highwayrenderobject(lane,y,c1,c2,quality)

% Determine color scheme.
window = [0.4 0.4 0.6];
window_highlight = [0.8 0.8 1.0];
window_shadow = [0.3 0.3 0.4];
wheel = [0.3 0.2 0.0];
handles = [0.2 0.2 0.2];
if c1 == 1,
    % Civilian.
    primary = [0.6 0.1 0.15];
    primary_highlight = [0.8 0.17 0.2];
    primary_shadow = [0.4 0.1 0.15];
    secondary = [0.6 0.1 0.15];
    secondary_highlight = [0.8 0.17 0.2];
    secondary_shadow = [0.4 0.1 0.15];
    rider = [0.6 0.5 0.4];
    rider_highlight = [0.7 0.6 0.5];
    rider_shadow = [0.4 0.25 0.2];
    draw_siren = 0;
elseif c1 == 2,
    % Police.
    primary = [0.2 0.2 0.2];
    primary_highlight = [0.4 0.4 0.4];
    primary_shadow = [0 0 0];
    secondary = [0.8 0.8 0.8];
    secondary_highlight = [1.0 1.0 1.0];
    secondary_shadow = [0.6 0.6 0.6];
    rider = [0.4 0.4 0.7];
    rider_highlight = [0.6 0.6 0.9];
    rider_shadow = [0.2 0.2 0.5];
    draw_siren = 1;
else
    % Agent.
    primary = [0.3 0.35 0.6];
    primary_highlight = [0.38 0.4 0.8];
    primary_shadow = [0.2 0.21 0.4];
    secondary = [0.3 0.35 0.6];
    secondary_highlight = [0.38 0.4 0.8];
    secondary_shadow = [0.2 0.21 0.4];
    rider = [0.6 0.5 0.4];
    rider_highlight = [0.7 0.6 0.5];
    rider_shadow = [0.4 0.25 0.2];
    draw_siren = 0;
end;

HIGH_QUALITY = quality;
if HIGH_QUALITY,
    secondary_rend = 'interp';
    primary_rend = 'interp';
    window_rend = 'interp';
    rider_rend = 'interp';
else
    primary = min(1,primary*1.5);
    secondary = min(1,secondary*1.5);
    window = min(1,window*1.5);
    %rider = min(1,rider*1.5);
    secondary_rend = secondary;
    primary_rend = primary;
    window_rend = window;
    rider_rend = rider;
end;
    
% See if this is a car or a motorcycle.
if c2 == 1,
    % Car.
    % Car body.
    xv = [lane-0.7 lane-0.3 lane-0.3 lane-0.35 lane-0.65 lane-0.7];
    yv = [y-0.4 y-0.4 y-0.2 y-0.15 y-0.15 y-0.2];
    p = patch('vertices',[xv' yv'],'faces',1:6,'FaceColor',primary_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[primary;primary_highlight;primary_highlight;primary_highlight;primary;primary]);
    end;
    xv = [lane-0.7 lane-0.3 lane-0.3 lane-0.7];
    yv = [y-0.4 y-0.4 y-0.72 y-0.72];
    p = patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',secondary_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[secondary;secondary_highlight;secondary;secondary_shadow]);
    end;
    yv = [y-0.72 y-0.72 y-0.85 y-0.85];
    p = patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',primary_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[primary_shadow;primary;primary;primary_shadow]);
    end;
    
    % Windows.
    xv = [lane-0.65 lane-0.35 lane-0.35 lane-0.65];
    yf = [y-0.33 y-0.33 y-0.48 y-0.48];
    yb = [y-0.65 y-0.65 y-0.75 y-0.75];
    p = patch('vertices',[xv' yf'],'faces',1:4,'FaceColor',window_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[window;window;window_highlight;window]);
    end;
    p = patch('vertices',[xv' yb'],'faces',1:4,'FaceColor',window_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[window;window;window;window_shadow]);
    end;
    
    % Siren.
    if draw_siren,
        xv = [lane-0.52 lane-0.38 lane-0.38 lane-0.52];
        yv = [y-0.58 y-0.58 y-0.54 y-0.54];
        patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',[1 0 0],'EdgeColor','none');
        xv = [lane-0.62 lane-0.5 lane-0.5 lane-0.62];
        patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',[0 0 1],'EdgeColor','none');
    end;
else
    % Motorcycle.
    % First the motorcycle body.
    % Rear component.
    xv = [lane-0.6 lane-0.4 lane-0.4 lane-0.6];
    yv = [y-0.7 y-0.7 y-0.85 y-0.85];
    p = patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',primary_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[primary;primary_highlight;primary;primary_shadow]);
    end;
    % Seat.
    xv = [lane-0.55 lane-0.45 lane-0.45 lane-0.55];
    yv = [y-0.7 y-0.7 y-0.35 y-0.35];
    patch(xv,yv,primary_shadow,'EdgeColor','none');
    % Front fender.
    xv = [lane-0.55 lane-0.45 lane-0.45 lane-0.55];
    yv = [y-0.35 y-0.35 y-0.23 y-0.23];
    p = patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',secondary_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[secondary;secondary;secondary_highlight;secondary]);
    end;
    % Front wheel.
    xv = [lane-0.54 lane-0.46 lane-0.46 lane-0.54];
    yv = [y-0.23 y-0.23 y-0.15 y-0.15];
    patch(xv,yv,wheel,'EdgeColor','none');
    % Handlebars.
    xv = [lane-0.7 lane-0.3 lane-0.3 lane-0.7];
    yv = [y-0.38 y-0.38 y-0.42 y-0.42];
    patch(xv,yv,handles,'EdgeColor','none');
    
    % Windshield.
    xv = [lane-0.6 lane-0.4 lane-0.45 lane-0.55];
    yv = [y-0.35 y-0.35 y-0.45 y-0.45];
    p = patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',window_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[window;window_highlight;window_highlight;window]);
    end;
    
    % Rider.
    xv = [lane-0.65 lane-0.35 lane-0.45 lane-0.55];
    yv = [y-0.52 y-0.52 y-0.68 y-0.68];
    p = patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',rider_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[rider;rider;rider_shadow;rider_shadow]);
    end;
    
    % Rider arms.
    xv = [lane-0.65 lane-0.55 lane-0.6 lane-0.68];
    yv = [y-0.52 y-0.52 y-0.35 y-0.35];
    p = patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',rider_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[rider;rider;rider_highlight;rider_shadow]);
    end;
    xv = [lane-0.35 lane-0.45 lane-0.4 lane-0.32];
    yv = [y-0.52 y-0.52 y-0.35 y-0.35];
    p = patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',rider_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[rider;rider;rider_shadow;rider_highlight]);
    end;
    
    % Rider head.
    xv = [lane-0.57 lane-0.5 lane-0.43 lane-0.43 lane-0.5 lane-0.57];
    yv = [y-0.55 y-0.58 y-0.55 y-0.45 y-0.42 y-0.45];
    p = patch('vertices',[xv' yv'],'faces',1:6,'FaceColor',secondary_rend,'EdgeColor','none');
    if HIGH_QUALITY,
        set(p,'FaceVertexCData',[secondary;secondary;secondary;secondary_highlight;secondary_highlight;secondary]);
    end;
    
    % Sirens.
    if draw_siren,
        % Rear.
        xv = [lane-0.35 lane-0.4 lane-0.4 lane-0.35];
        yv = [y-0.72 y-0.72 y-0.83 y-0.83];
        patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',[1 0 0],'EdgeColor','none');
        xv = [lane-0.65 lane-0.6 lane-0.6 lane-0.65];
        patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',[0 0 1],'EdgeColor','none');
        
        % Front.
        xv = [lane-0.38 lane-0.45 lane-0.45 lane-0.38];
        yv = [y-0.35 y-0.35 y-0.3 y-0.3];
        patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',[0 0 1],'EdgeColor','none');
        xv = [lane-0.62 lane-0.55 lane-0.55 lane-0.62];
        patch('vertices',[xv' yv'],'faces',1:4,'FaceColor',[1 0 0],'EdgeColor','none');
    end;
end;
