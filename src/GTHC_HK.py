import math

def is_in_hongkong(lat, lon):
    """
    IS_IN_HONGKONG - Check if coordinates are within Hong Kong boundaries
    
    Input:
        lat - Latitude in degrees
        lon - Longitude in degrees
    
    Output:
        result - Logical True if within Hong Kong region
    """
    # Hong Kong geographical boundaries
    HK_LAT_MIN = 22.1
    HK_LAT_MAX = 22.6
    HK_LON_MIN = 113.8
    HK_LON_MAX = 114.5
    
    return (HK_LAT_MIN <= lat <= HK_LAT_MAX) and (HK_LON_MIN <= lon <= HK_LON_MAX)

def GTHC_HK(BaseTrop, BaseCoor, UserCoor, DOY, YorN):
    """
    GTHC_HK - GNSS Tropospheric Height Correction Model for Hong Kong
    
    This function implements a regional tropospheric delay height correction 
    model specifically designed for Hong Kong area, transferring tropospheric
    parameters from reference station to user station.
    
    Input Parameters:
        BaseTrop  - Reference station tropospheric delays [ZHD_base, ZWD_base, ZTD_base] (unit: mm)
        BaseCoor  - Reference station coordinates [Latitude_base, Longitude_base, Height_base] 
                    (Latitude, Longitude: degrees; Height: meters)
        UserCoor  - User station coordinates [Latitude_user, Longitude_user, Height_user]
                    (Latitude, Longitude: degrees; Height: meters)
        DOY       - Day of Year, range: 1-365/366
        YorN      - Seasonal pattern flag (boolean)
                    True: enable seasonal variation model
                    False: use annual mean parameters
    
    Output Parameters:
        UserTrop  - User station tropospheric delays [ZHD_user, ZWD_user, ZTD_user] (unit: mm)
    
    Model Features:
        - Specifically designed for Hong Kong region with automatic geographic validation
        - Supports seasonal variation modeling based on day of year
        - Employs exponential function for height correction
    
    Example:
        BaseTrop = [2200, 150, 2350]  # Reference station zenith delays (mm)
        BaseCoor = [22.3, 114.2, 50]  # Reference station coordinates
        UserCoor = [22.35, 114.15, 200] # User station coordinates
        DOY = 150  # Day of year
        UserTrop = GTHC_HK(BaseTrop, BaseCoor, UserCoor, DOY, True)
    """
    
    # Input validation
    if len(BaseTrop) != 3 or len(BaseCoor) != 3 or len(UserCoor) != 3:
        raise ValueError("GTHC_HK: All input vectors must have exactly 3 elements")
    
    if not (1 <= DOY <= 366):
        raise ValueError("GTHC_HK: DOY must be between 1 and 366")
    
    # Extract parameters
    ZHD_base, ZWD_base, ZTD_base = BaseTrop
    Lat_base, Lon_base, Hgt_base = BaseCoor
    Lat_user, Lon_user, Hgt_user = UserCoor
    
    # Hong Kong region validation
    if not is_in_hongkong(Lat_base, Lon_base) or not is_in_hongkong(Lat_user, Lon_user):
        raise ValueError("GTHC_HK: Station coordinates outside Hong Kong region. "
                        "This model is specifically designed for Hong Kong area "
                        "(Lat: 22.1-22.6, Lon: 113.8-114.5).")
    
    # Define sinusoidal functions for seasonal variation
    def func_sinZTD(a, t):
        return a[0] * math.cos(2 * math.pi * t) + a[1] * math.sin(2 * math.pi * t) + a[2]
    
    def func_sinZWD(a, t):
        return (a[0] * math.cos(2 * math.pi * t) + a[1] * math.cos(4 * math.pi * t) +
                a[2] * math.sin(2 * math.pi * t) + a[3] * math.cos(4 * math.pi * t) + a[4])
    
    # Model coefficients derived from Hong Kong CORS data analysis
    A_ZTD = [336.744129380450, 40.0468935232165, 7222.97084384999]
    A_ZWD = [-16.7865051683731, 36218.6610049341, -130.895834349628,
             -36297.5776200211, 3253.60038161059]
    
    # Calculate height difference between stations
    hgt_diff = Hgt_user - Hgt_base
    
    # ZHD scale height (constant)
    beta_ZHD = 8431.2
    
    # Determine seasonal correction parameters
    if YorN:
        # Use seasonal variation model
        # Normalize DOY to fractional year for trigonometric functions
        doy_normalized = DOY / 365.25
        beta_ZTD = func_sinZTD(A_ZTD, doy_normalized)
        beta_ZWD = func_sinZWD(A_ZWD, doy_normalized)
    else:
        # Use annual mean parameters
        beta_ZTD = 7228.8
        beta_ZWD = 3254.1
    
    # Apply exponential height correction model
    ZTD_user = ZTD_base / math.exp(-hgt_diff / beta_ZTD)
    ZWD_user = ZWD_base / math.exp(-hgt_diff / beta_ZWD)
    ZHD_user = ZHD_base / math.exp(-hgt_diff / beta_ZHD)
    
    return [ZHD_user, ZWD_user, ZTD_user]

# Example usage
if __name__ == "__main__":
    BaseTrop = [2200, 150, 2350]
    BaseCoor = [22.3, 114.2, 50]
    UserCoor = [22.35, 114.15, 200]
    DOY = 150
    
    UserTrop = GTHC_HK(BaseTrop, BaseCoor, UserCoor, DOY, True)
    print(f"Corrected tropospheric delays: ZHD={UserTrop[0]:.2f}, ZWD={UserTrop[1]:.2f}, ZTD={UserTrop[2]:.2f} mm")