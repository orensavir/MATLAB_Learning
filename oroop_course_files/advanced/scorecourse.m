classdef scorecourse < course

    % Properties in addition to those inherited
    properties
        Points (:,1) double {mustBeNonnegative} = []
        TimeLimit (1,1) duration
        TimePenalty (1,1) double {mustBePositive} = Inf
    end

    methods
        % Need constructor to allow for extra properties
        function c = scorecourse(name,level,waypts,points,maxtime,penalty)
            % Want to allow 0, 5, or 6 inputs
            % 0 = defaults, 6 = all properties specified
            % 5 = properties specified by penalty = default (Inf)

            % Get arguments to pass to the superclass constructor
            if (nargin == 0)
                % Default constructor
                superargs = {};
            elseif (nargin >= 5)
                % Inputs for superclass constructor
                superargs = {name,level,waypts};
            else
                error("Wrong number of inputs")
            end
            % Call superclass constructor
            c@course(superargs{:});

            % Set time limit if given (otherwise get default)
            if (nargin == 6)
                c.TimePenalty = penalty;
            end

            % Deal with the remaining inputs
            if nargin
                % From earlier checking, we know nargin >= 5
                c.TimeLimit = maxtime;
                % Check the list of point/score values
                if (isnumeric(points) && isvector(points))
                    % Check the number of points
                    n = numel(points);
                    nwaypts = numel(c.Waypoints);
                    % If start and end point values are excluded, add 0s
                    if (n+2) == nwaypts
                        points = [0;points(:);0];
                        n = n+2;
                    end
                    % Now points should match waypoints
                    if (n == nwaypts) && (points(1)==0) && (points(n)==0)
                        c.Points = points;
                    else
                        error("Point values for the start and end waypoints must either be 0 or excluded")
                    end
                else
                    error("Points have to be specified as a numeric vector")
                end
            end
        end

        function ok = checkWaypoint(c,id,wayptidx)
            ok = true;
            % Check if over time
            t = id.Timestamps;
            % Can't be over time until started
            if (wayptidx > 1)
                % OK as long as elapsed time isn't over the limit
                ok = ((datetime("now") - t(1)) <= c.TimeLimit);
            end
        end

        function [score,scoretxt,txt] = resulttable(c,t)
            % Get timestamps for waypoints achieved
            idx = ~ismissing(t);
            t = t(idx);
            % And corresponding waypoints and point values
            waypts = c.Waypoints(idx);
            pts = c.Points(idx);
            % Put in time order
            [t,idx] = sort(t);
            waypts = waypts(idx);
            pts = pts(idx);
            % Cutoff time
            tcut = t(1) + c.TimeLimit;
            % Get time for each leg and cumulative
            dfmt = "hh:mm:ss.SS";
            legtime = [0;diff(t)];
            tott = t - t(1);
            legtime = string(legtime,dfmt);
            tott = string(tott,dfmt);
            % No points for waypoints found after the cutoff
            idx = (t > tcut);
            penalty = any(idx);
            pts(idx) = 0;
            % Total score
            score = sum(pts(~idx));

            % Make text for table
            txt = string(repmat('-',1,52)) + newline;
            txt = txt + " Waypoint |   Leg time    |  Total time   |  Points" + newline;
            txt = txt + repmat('-',1,52) + newline;
            txt = txt + join(join([compose("%8d",waypts) legtime tott compose("%6d",pts)],"  |  "),newline) + newline;
            txt = txt + repmat('-',1,52);
            % Make text for score, with penalty if applicable
            scoretxt = "Total score: " + score;
            if penalty
                % Negative score -> 0
                score = max(0,score - c.TimePenalty);
                scoretxt = scoretxt + " - " + c.TimePenalty + " = " + score;
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
                str = str + newline + indent + ...
                    join(compose("%d (%d pts)",c.Waypoints(:),c.Points(:)),",  ");
            end
        end
    end

end