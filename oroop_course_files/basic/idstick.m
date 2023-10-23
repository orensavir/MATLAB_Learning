% ID Stick class definition
classdef idstick
    properties (SetAccess = immutable)
        SerialNumber (1,1) uint32
    end
    properties (Access = private)
        Status (1,1) string
    end
    properties (SetAccess = private)
        Participant (1,1) string
        Course (1,1) course
        Timestamps (:,1) datetime
    end

    methods
        function id = idstick(snum)
            if (nargin > 0)
                % Check attributes of given serial number(s)
                mustBeNumeric(snum)
                mustBeInteger(snum)
                mustBePositive(snum)
                % Make array of objects
                for k = 1:numel(snum)
                    id(k).SerialNumber = snum(k);
                end
            end
        end

        function disp(id)
            for k = 1:numel(id)
                % Start building display string
                str = "ID stick #" + id(k).SerialNumber;
                % Add participant info, if applicable
                if (id(k).Participant == "")
                    str = str + " which is not yet registered";
                    disp(str)
                else
                    str = str + " is registered to " + id(k).Participant + " who is ";
                    % Use status to get the correct wording
                    switch id(k).Status
                        case "Ready"
                            str = str + "ready to run";
                        case "Running"
                            str = str + "running";
                        case "Done"
                            str = str + "finished with";
                    end
                    % Display the string, then display the course details
                    disp(str)
                    disp(id(k).Course)
                end
            end
        end

        function id = register(id,name,c)
            arguments
                % Registration is a single participant registering a single
                % ID stick for a single course
                id (1,1) idstick
                name (1,1) string
                c (1,1) course
            end
            % Load the info onto the stick
            id.Participant = name;
            id.Course = c;
            id.Timestamps = NaT(size(c.Waypoints));
            % If we get here with no error, we're set to run
            id.Status = "Ready";
            signal(id,true)
        end

        function id = checkWaypoint(id,wayptnum)
            arguments
                % Check-ins happen individually (scalar ID stick, scalar
                % waypoint)
                id (1,1) idstick
                wayptnum (1,1) double
            end
            % Get the course object
            c = id.Course;
            % Check and update ID stick status
            % Check that this waypoint is on this course
            [id,ok,n] = updateStatus(id,wayptnum);
            % If the waypoint is valid, the ID stick status is ok, and the
            % waypoint is not the start, use the course method to check
            % this waypoint according to the rules of the course. (If this
            % waypoint is the start, there's nothing more to check.)
            if ok && (n > 1)
                ok = checkWaypoint(c,id,n);
            end
            % Update the time stamp of this waypoint
            id.Timestamps(n) = datetime("now");
            % Tell the participant what happened
            signal(id,ok)
        end

    end
    
    methods (Access = private)
        function signal(id,ok)
            % Give feedback to the participant
            if ok
                if (id.Status == "Ready") || (id.Status == "Done")
                    disp("Beep beep")
                else
                    disp("Beep")
                end
            else
                disp("Buzz")
            end
        end

        function [id,ok,idx] = updateStatus(id,wayptnum)
            % Find the given waypoint in the list for this course
            wplist = id.Course.Waypoints;
            idx = find(wayptnum == wplist,1,"first");
            % What is the current ID Stick status?
            if (id.Status == "Error") || (id.Status == "Done")
                % Leave status alone, this check-in is a fail
                ok = false;
            elseif (id.Status == "Ready")
                % Ready to start. Check that this waypoint is the start
                if (idx == 1)
                    % Alright, let's go!
                    id.Status = "Running";
                    ok = true;
                else
                    % Checking in at a later waypoint before starting
                    ok = false;
                end
            else
                % In progress. Check that this waypoint is on this course
                ok = ~isempty(idx);
                % If this waypoint is the end, we're done
                if (idx == numel(wplist))
                    id.Status = "Done";
                end
            end
        end
    end

end