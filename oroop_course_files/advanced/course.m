% Course class definition
classdef (Abstract) course < matlab.mixin.Heterogeneous
    % Abstract classes define a template for a class, but you can't create
    % objects of this class. However you can define (non-abstract)
    % subclasses that inherit from it, and make objects of those classes.
    %
    % Inheriting from matlab.mixin.Heterogeneous means you can make arrays
    % of objects from the subclasses, with different subclasses in the same
    % array.

    properties (SetAccess = private)
        Name (1,1) string
        Level (1,1) difficultylevel
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
        
    end

    methods(Sealed)
        % Sealed methods cannot be redefined in subclasses
        function nm = names(c)
            % Return a vector of the names of the courses
            nm = cat(1,c.Name);
        end

        function disp(c)
            disp(string(c))
        end

        function waypts = unique(c)
            % Unique waypoint numbers for all courses
            waypts = unique(cat(1,c.Waypoints));
        end

        function str = string(c)
            % Make display string from individual elements, using a helper
            % method from the subclasses
            n = numel(c);
            if (n > 1)
                % Array -> a litte extra decoration
                str = "Array of "+n+" courses";
                for k = 1:n
                    str = str + newline + k + ") " + dispstring(c(k),true);
                end
            else
                % Scalar -> plain
                str = dispstring(c);
            end
        end
    end

    methods(Abstract)
        % Abstract methods have to be defined in subclasses
        % That is, a subclass has to have methods with these names to be a
        % valid subclass
        ok = checkWaypoint(c,id,wayptidx)
        [score,scoretxt,tbl] = resulttable(c,t)
    end

    methods(Abstract, Access = ?course)
        % To get the different displays to work with the heterogenous
        % array, each subclass has a helper method that is only accessible
        % to the superclass (Access = ?course)
        str = dispstring(c,indent)
    end

end