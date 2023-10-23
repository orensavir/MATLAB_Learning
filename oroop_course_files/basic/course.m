% Course class definition
classdef course
    properties (SetAccess = private)
        Name (1,1) string
        Level (1,1) string {mustBeMember(Level,["White","Yellow","Green","Orange","Red"])} = "White"
        Waypoints (:,1) double {mustBePositive, mustBeInteger}
    end

    methods
        function c = course(name,lvl,waypts)
            if (nargin == 3)
                % Inputs given -> check them
                % Name must be text
                name = convertCharsToStrings(name);
                if isstring(name)
                    c.Name = name;
                else
                    error("Name must be text")
                end
                % Level (values checked by properties block)
                c.Level = lvl;
                % Waypoints must be numeric
                if isnumeric(waypts)
                    c.Waypoints = waypts;
                else
                    error("Waypoints must be numeric")
                end
            elseif (nargin > 0)
                % Inputs given, but not == 3
                error("You need to provide 3 inputs: name, level, and a list of waypoints")
            end
        end

        function ok = checkWaypoint(c,id,wayptidx)
            % Get the index of the previous waypoint found
            [~,prevwpidx] = max(id.Timestamps);
            % Current waypoint should be the next one
            ok = (wayptidx == (1+prevwpidx));
        end

        function disp(c)
            n = numel(c);
            isarray = (n > 1);
            % Add info about array (if nonscalar)
            if isarray
                disp("Array of "+n+" courses"+newline)
            end
            for k = 1:n
                % Start with element number (if nonscalar)
                if isarray
                    str = string(k)+") ";
                else
                    str = "";
                end
                % Make display string for each element
                if isempty(c(k).Waypoints)
                    str = str + "Empty course";
                    disp(str)
                else
                    % Build rest of string with course info
                    str = str + c(k).Level + " course '" + c(k).Name + ...
                        "' with " + numel(c(k).Waypoints) + " waypoints:";
                    disp(str)
                    disp(c(k).Waypoints')
                end
            end
        end
    end

end