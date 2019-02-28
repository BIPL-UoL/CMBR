% Get location of data; alter file depending on location of dataset.
%
% INPUTS
%   set_ind     - [optional] set index, value between 0 and nsets-1
%
% OUTPUTS
%   dir         - final directory 
%
% EXAMPLE
%   dir = getclipsdir( 'mouse00', 'features' )

function dir = datadir

    % root directory
    %dir = 'C:/code/mice/data';
    %dir = 'C:/code/faces/data';
    dir = 'C:\Users\40108307\Documents\MATLAB\our_database\mouse_data';
    
