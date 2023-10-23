% Course class definition
classdef orderedcourse < course
    % Orderedcourse is subclass of the generic (abstract) course class

    % No need for properties (all properties are inherited)

    methods
        % No need for a constructor (superclass constructor is fine)

        function ok = checkWaypoint(c,id,wayptidx)
            % Get the index of the previous waypoint found
            [~,prevwpidx] = max(id.Timestamps);
            % Current waypoint should be the next one
            ok = (wayptidx == (1+prevwpidx));
        end

        function [score,scoretxt,txt] = resulttable(c,t)
            arguments
                c (1,1) orderedcourse
                t (:,1) datetime
            end
            % Get waypoints
            waypts = c.Waypoints;
            % Format for displaying times
            dfmt = "hh:mm:ss.SS";
            % Total run time (time from start)
            tott = t - t(1);
            n = numel(tott);
            % Index for which waypoints were reached (at all)
            gotidx = ~isnan(tott);
            % Make a table to keep track of waypoints and times
            T = table((1:n)',tott,'VariableNames',["Num","Time"]);
            % Get rid of the waypoints missed entirely and number the rest
            T = rmmissing(T);
            T.Sidx = (1:height(T))';
            T = sortrows(T,"Time");
            % Check that the rest are in order
            goodidx = T.Num([true;diff(T.Sidx)==1]);
            % Turn times into text. Start with blanks and fill in where
            % there are valid values
            legtime = repmat("  -------  ",n,1);
            legtime(goodidx) = string([0;diff(tott(goodidx))],dfmt);
            % Turn cumulative run time into text. Replace NaT with blanks
            tott = string(tott,dfmt);
            tott(~gotidx) = "  -------  ";

            % Build string
            txt = string(repmat('-',1,41)) + newline;
            txt = txt + " Waypoint |   Leg time    |  Total time" + newline;
            txt = txt + repmat('-',1,41) + newline;
            txt = txt + join(join([compose("%8d",waypts) legtime tott],"  |  "),newline) + newline;
            txt = txt + repmat('-',1,41);

            % Final score = total time
            score = tott(end);
            scoretxt = "Total time: " + score;
            if (numel(goodidx) < n)
                % Add caveat if any bad legs
                scoretxt = scoretxt + " (Not completed)";
            end
        end
    end

    methods (Access = ?course)
        function str = dispstring(c,indent)
            % Make indent (0 or 3 spaces)
            if (nargin < 2)
                indent = false;
            end
            indent = repmat(' ',1,3*indent);
            if isempty(c.Waypoints)
                str = "Empty course";
            else
                % Build string with course info
                str = string(c.Level) + " course '" + c.Name + ...
                    "' with " + numel(c.Waypoints) + " waypoints:";
                str = str + newline + indent + join(string(c.Waypoints'),",  ");
            end
        end
    end

end