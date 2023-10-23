classdef difficultylevel < uint8
    enumeration
        % Inheriting from uint8 means levels can be represented numerically
        % and ordered
        White (0)
        Yellow (1)
        Orange (2)
        Green (3)
        Red (4)
    end
end