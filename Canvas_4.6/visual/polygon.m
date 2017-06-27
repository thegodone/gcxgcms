function R = polygon(origin)
    
    h = get(2,'userdata');
    linecolor = h.linecolor;

    figure(2);
    h = gca;
    x = get(h,'xlim');
    y = get(h,'ylim');
    xrange = x(2)-x(1);
    yrange = y(2)-y(1);

    R = [origin(1),origin(2)];      % this is the first point for a polygon
    n = 1;
    CLOSE = 0;
    printf('click off-field to UNDO last point.\n');
    while(~CLOSE)                   % keep drawing until polygon is closed
        cords = point;              % click a point
        
        if (isnan(cords))           % the point is off-field
            if (n>1)
                set(hline(n-1),'visible','off');     % clear last edge from figure
                n = n - 1;                           % delete last point
                R = R(1:n,:);
                hline = hline(1:n-1);                % delete last edge
                continue;
            else
                R = [];             % if all points were deleted, then leave
                break;
            end
        end
        
        if (cords(1)-x(1)<xrange*0.01)         % check if the point near to horizontal bounds
            cords(1) = x(1);
        elseif (x(2)-cords(1)<xrange*0.01)
            cords(1) = x(2);
        end
        
        if (cords(2)-y(1)<yrange*0.01)         % check if the point near to vertical bounds
            cords(2) = y(1);
        elseif (y(2)-cords(2)<yrange*0.01)
            cords(2) = y(2);
        end
        
        if (abs(cords(1)-R(n,1))/xrange<0.01 && abs(cords(2)-R(n,2))/yrange<0.01)
            continue;         % the point cannot coincide on last point
        else
            if (abs(cords(1)-R(1,1))/xrange<0.01 && abs(cords(2)-R(1,2))/yrange<0.01)
                cords(1) = R(1,1);
                cords(2) = R(1,2);
                CLOSE = 1;    % close polygon if clicked back on first point
            end
            
            CROSS = 0;        % check if the new edge causes self-crossing
            for i = 1 : n-1,
                if (intersect(cords,R(n,:),R(i,:),R(i+1,:)))
                    CROSS = 1;
                    break;
                end
            end
        end

        if (CROSS)            % if self-crossing, polygon cannot close
            printf('self-crossing is invalid.\n');
            CLOSE = 0;
        else                  % otherwise, add new point and new edge, draw new edge
            n = n + 1;
            R(n,1) = cords(1);
            R(n,2) = cords(2);
            hline(n-1) = line([R(n-1,1),R(n,1)],[R(n-1,2),R(n,2)]);
            set(hline(n-1),'color',linecolor);
        end
    end
