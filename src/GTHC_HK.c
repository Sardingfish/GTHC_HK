#include <stdio.h>
#include <math.h>
#include <stdbool.h>

/**
 * IS_IN_HONGKONG - Check if coordinates are within Hong Kong boundaries
 * 
 * Input:
 *   lat - Latitude in degrees
 *   lon - Longitude in degrees
 * 
 * Output:
 *   result - true if within Hong Kong region, false otherwise
 */
bool is_in_hongkong(double lat, double lon) {
    // Hong Kong geographical boundaries
    const double HK_LAT_MIN = 22.1;
    const double HK_LAT_MAX = 22.6;
    const double HK_LON_MIN = 113.8;
    const double HK_LON_MAX = 114.5;
    
    return (lat >= HK_LAT_MIN && lat <= HK_LAT_MAX) && 
           (lon >= HK_LON_MIN && lon <= HK_LON_MAX);
}

/**
 * Sinusoidal function for ZTD seasonal variation
 */
double func_sinZTD(const double a[3], double t) {
    return a[0] * cos(2 * M_PI * t) + a[1] * sin(2 * M_PI * t) + a[2];
}

/**
 * Sinusoidal function for ZWD seasonal variation
 */
double func_sinZWD(const double a[5], double t) {
    return a[0] * cos(2 * M_PI * t) + a[1] * cos(4 * M_PI * t) +
           a[2] * sin(2 * M_PI * t) + a[3] * cos(4 * M_PI * t) + a[4];
}

/**
 * GTHC_HK - GNSS Tropospheric Height Correction Model for Hong Kong
 * 
 * This function implements a regional tropospheric delay height correction 
 * model specifically designed for Hong Kong area.
 * 
 * Input Parameters:
 *   BaseTrop  - Reference station tropospheric delays [ZHD_base, ZWD_base, ZTD_base] (mm)
 *   BaseCoor  - Reference station coordinates [Lat_base, Lon_base, Hgt_base]
 *   UserCoor  - User station coordinates [Lat_user, Lon_user, Hgt_user]
 *   DOY       - Day of Year (1-366)
 *   YorN      - Seasonal pattern flag (true for seasonal model, false for annual mean)
 *   UserTrop  - Output array for user station delays [ZHD_user, ZWD_user, ZTD_user]
 * 
 * Return:
 *   0 on success, -1 on error
 */
int GTHC_HK(const double BaseTrop[3], const double BaseCoor[3], 
            const double UserCoor[3], int DOY, bool YorN, 
            double UserTrop[3]) {
    
    // Input validation
    if (DOY < 1 || DOY > 366) {
        fprintf(stderr, "GTHC_HK: DOY must be between 1 and 366\n");
        return -1;
    }
    
    // Extract parameters
    double ZHD_base = BaseTrop[0];
    double ZWD_base = BaseTrop[1];
    double ZTD_base = BaseTrop[2];
    
    double Lat_base = BaseCoor[0];
    double Lon_base = BaseCoor[1];
    double Hgt_base = BaseCoor[2];
    
    double Lat_user = UserCoor[0];
    double Lon_user = UserCoor[1];
    double Hgt_user = UserCoor[2];
    
    // Hong Kong region validation
    if (!is_in_hongkong(Lat_base, Lon_base) || !is_in_hongkong(Lat_user, Lon_user)) {
        fprintf(stderr, "GTHC_HK: Station coordinates outside Hong Kong region\n");
        return -1;
    }
    
    // Model coefficients
    const double A_ZTD[3] = {336.744129380450, 40.0468935232165, 7222.97084384999};
    const double A_ZWD[5] = {-16.7865051683731, 36218.6610049341, -130.895834349628,
                            -36297.5776200211, 3253.60038161059};
    
    // Calculate height difference
    double hgt_diff = Hgt_user - Hgt_base;
    
    // ZHD scale height (constant)
    double beta_ZHD = 8431.2;
    
    // Determine seasonal correction parameters
    double beta_ZTD, beta_ZWD;
    
    if (YorN) {
        // Use seasonal variation model
        double doy_normalized = DOY / 365.25;
        beta_ZTD = func_sinZTD(A_ZTD, doy_normalized);
        beta_ZWD = func_sinZWD(A_ZWD, doy_normalized);
    } else {
        // Use annual mean parameters
        beta_ZTD = 7228.8;
        beta_ZWD = 3254.1;
    }
    
    // Apply exponential height correction model
    UserTrop[2] = ZTD_base / exp(-hgt_diff / beta_ZTD);  // ZTD_user
    UserTrop[1] = ZWD_base / exp(-hgt_diff / beta_ZWD);  // ZWD_user
    UserTrop[0] = ZHD_base / exp(-hgt_diff / beta_ZHD);  // ZHD_user
    
    return 0;
}

// Example usage
int main() {
    double BaseTrop[3] = {2200, 150, 2350};
    double BaseCoor[3] = {22.3, 114.2, 50};
    double UserCoor[3] = {22.35, 114.15, 200};
    double UserTrop[3];
    int DOY = 150;
    
    int result = GTHC_HK(BaseTrop, BaseCoor, UserCoor, DOY, true, UserTrop);
    
    if (result == 0) {
        printf("Corrected tropospheric delays:\n");
        printf("ZHD = %.2f mm\n", UserTrop[0]);
        printf("ZWD = %.2f mm\n", UserTrop[1]);
        printf("ZTD = %.2f mm\n", UserTrop[2]);
    }
    
    return result;
}