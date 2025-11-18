function UserTrop = GTHC_HK(BaseTrop, BaseCoor, UserCoor, DOY, YorN)
% GTHC_HK - GNSS Tropospheric Height Correction Model for Hong Kong
% 
% This function implements a regional tropospheric delay height correction 
% model specifically designed for Hong Kong area, transferring tropospheric
% parameters from reference station to user station.
%
% Input Parameters:
%   BaseTrop  - Reference station tropospheric delays [ZHD_base, ZWD_base, ZTD_base] (unit: mm)
%   BaseCoor  - Reference station coordinates [Latitude_base, Longitude_base, Height_base] 
%               (Latitude, Longitude: degrees; Height: meters)
%   UserCoor  - User station coordinates [Latitude_user, Longitude_user, Height_user]
%               (Latitude, Longitude: degrees; Height: meters)
%   DOY       - Day of Year, range: 1-365/366
%   YorN      - Seasonal pattern flag (logical)
%               true(1): enable seasonal variation model
%               false(0): use annual mean parameters
%
% Output Parameters:
%   UserTrop  - User station tropospheric delays [ZHD_user, ZWD_user, ZTD_user] (unit: mm)
%
% Model Features:
%   - Specifically designed for Hong Kong region with automatic geographic validation
%   - Supports seasonal variation modeling based on day of year
%   - Employs exponential function for height correction
%
% Example:
%   BaseTrop = [2200, 150, 2350];  % Reference station zenith delays (mm)
%   BaseCoor = [22.3, 114.2, 50];  % Reference station coordinates
%   UserCoor = [22.35, 114.15, 200]; % User station coordinates
%   DOY = 150;  % Day of year
%   UserTrop = GTHC_HK(BaseTrop, BaseCoor, UserCoor, DOY, true);
%
% Development Information:
%   Regional tropospheric correction model based on long-term HK CORS GNSS observations
%   Model parameters derived from multi-year GNSS data analysis
%
% Reference:
%   Regional GNSS tropospheric delay characteristics study for Hong Kong area

%% Input Parameter Validation
if nargin ~= 5
    error('GTHC_HK: Exactly 5 input parameters are required');
end

if length(BaseTrop) ~= 3 || length(BaseCoor) ~= 3 || length(UserCoor) ~= 3
    error('GTHC_HK: All input vectors must have exactly 3 elements');
end

% Extract reference station tropospheric parameters
ZHD_base = BaseTrop(1);
ZWD_base = BaseTrop(2); 
ZTD_base = BaseTrop(3);

% Extract coordinate parameters
Lat_base = BaseCoor(1);
Lon_base = BaseCoor(2);
Hgt_base = BaseCoor(3);

Lat_user = UserCoor(1);
Lon_user = UserCoor(2);
Hgt_user = UserCoor(3);

%% Hong Kong Region Validation
% Define Hong Kong geographical boundaries (approximate)
HK_LAT_MIN = 22.1;
HK_LAT_MAX = 22.6;
HK_LON_MIN = 113.8;
HK_LON_MAX = 114.5;

% Check if both stations are within Hong Kong region
if ~is_in_hongkong(Lat_base, Lon_base) || ~is_in_hongkong(Lat_user, Lon_user)
    error(['GTHC_HK: Station coordinates outside Hong Kong region. ' ...
           'This model is specifically designed for Hong Kong area (Lat: %.1f-%.1f, Lon: %.1f-%.1f).'], ...
           HK_LAT_MIN, HK_LAT_MAX, HK_LON_MIN, HK_LON_MAX);
end

%% Height Correction Model Implementation

% Define sinusoidal functions for seasonal variation
func_sinZTD = @(a,t) a(1)*cos(2*pi*t) + a(2)*sin(2*pi*t) + a(3);
func_sinZWD = @(a,t) a(1)*cos(2*pi*t) + a(2)*cos(4*pi*t) ...
                + a(3)*sin(2*pi*t) + a(4)*cos(4*pi*t) + a(5);

% Model coefficients derived from Hong Kong CORS data analysis
A_ZTD = [336.744129380450, 40.0468935232165, 7222.97084384999];
A_ZWD = [-16.7865051683731, 36218.6610049341, -130.895834349628, ...
         -36297.5776200211, 3253.60038161059];

% Calculate height difference between stations
hgt_diff = Hgt_user - Hgt_base;

% ZHD scale height (constant)
beta_ZHD = 8431.2;

% Determine seasonal correction parameters
if YorN
    % Use seasonal variation model
    % Normalize DOY to fractional year for trigonometric functions
    doy_normalized = DOY / 365.25;
    beta_ZTD = func_sinZTD(A_ZTD, doy_normalized);
    beta_ZWD = func_sinZWD(A_ZWD, doy_normalized);
else
    % Use annual mean parameters
    beta_ZTD = 7228.8;
    beta_ZWD = 3254.1;
end

% Apply exponential height correction model
ZTD_user = ZTD_base ./ exp(-hgt_diff / beta_ZTD);
ZWD_user = ZWD_base ./ exp(-hgt_diff / beta_ZWD);
ZHD_user = ZHD_base ./ exp(-hgt_diff / beta_ZHD);

% Compose output vector
UserTrop = [ZHD_user, ZWD_user, ZTD_user];

end

function result = is_in_hongkong(lat, lon)
% IS_IN_HONGKONG - Check if coordinates are within Hong Kong boundaries
%
% Input:
%   lat - Latitude in degrees
%   lon - Longitude in degrees
%
% Output:
%   result - Logical true if within Hong Kong region

% Hong Kong geographical boundaries
HK_LAT_MIN = 22.1;
HK_LAT_MAX = 22.6;
HK_LON_MIN = 113.8;
HK_LON_MAX = 114.5;

result = (lat >= HK_LAT_MIN && lat <= HK_LAT_MAX) && ...
         (lon >= HK_LON_MIN && lon <= HK_LON_MAX);
end