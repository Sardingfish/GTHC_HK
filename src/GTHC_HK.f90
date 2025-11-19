module GTHC_HK_Module
    implicit none
    
    ! Model coefficients
    real(8), parameter :: A_ZTD(3) = [336.744129380450d0, 40.0468935232165d0, 7222.97084384999d0]
    real(8), parameter :: A_ZWD(5) = [-16.7865051683731d0, 36218.6610049341d0, -130.895834349628d0, &
                                     -36297.5776200211d0, 3253.60038161059d0]
    
    ! Hong Kong boundaries
    real(8), parameter :: HK_LAT_MIN = 22.1d0
    real(8), parameter :: HK_LAT_MAX = 22.6d0
    real(8), parameter :: HK_LON_MIN = 113.8d0
    real(8), parameter :: HK_LON_MAX = 114.5d0
    
contains

    logical function is_in_hongkong(lat, lon)
    ! IS_IN_HONGKONG - Check if coordinates are within Hong Kong boundaries
    !
    ! Input:
    !   lat - Latitude in degrees
    !   lon - Longitude in degrees
    !
    ! Output:
    !   result - .true. if within Hong Kong region
    
        real(8), intent(in) :: lat, lon
        
        is_in_hongkong = (lat >= HK_LAT_MIN .and. lat <= HK_LAT_MAX) .and. &
                        (lon >= HK_LON_MIN .and. lon <= HK_LON_MAX)
    end function is_in_hongkong

    real(8) function func_sinZTD(a, t)
    ! Sinusoidal function for ZTD seasonal variation
    
        real(8), intent(in) :: a(3), t
        
        func_sinZTD = a(1) * cos(2 * 3.141592653589793d0 * t) + &
                     a(2) * sin(2 * 3.141592653589793d0 * t) + &
                     a(3)
    end function func_sinZTD

    real(8) function func_sinZWD(a, t)
    ! Sinusoidal function for ZWD seasonal variation
    
        real(8), intent(in) :: a(5), t
        
        func_sinZWD = a(1) * cos(2 * 3.141592653589793d0 * t) + &
                     a(2) * cos(4 * 3.141592653589793d0 * t) + &
                     a(3) * sin(2 * 3.141592653589793d0 * t) + &
                     a(4) * cos(4 * 3.141592653589793d0 * t) + &
                     a(5)
    end function func_sinZWD

    subroutine GTHC_HK(BaseTrop, BaseCoor, UserCoor, DOY, YorN, UserTrop, ierr)
    ! GTHC_HK - GNSS Tropospheric Height Correction Model for Hong Kong
    !
    ! This subroutine implements a regional tropospheric delay height correction 
    ! model specifically designed for Hong Kong area.
    !
    ! Input Parameters:
    !   BaseTrop  - Reference station tropospheric delays [ZHD_base, ZWD_base, ZTD_base] (mm)
    !   BaseCoor  - Reference station coordinates [Lat_base, Lon_base, Hgt_base]
    !   UserCoor  - User station coordinates [Lat_user, Lon_user, Hgt_user]
    !   DOY       - Day of Year (1-366)
    !   YorN      - Seasonal pattern flag (.true. for seasonal model, .false. for annual mean)
    !
    ! Output Parameters:
    !   UserTrop  - User station delays [ZHD_user, ZWD_user, ZTD_user]
    !   ierr      - Error flag (0=success, -1=error)
    
        real(8), intent(in) :: BaseTrop(3), BaseCoor(3), UserCoor(3)
        integer, intent(in) :: DOY
        logical, intent(in) :: YorN
        real(8), intent(out) :: UserTrop(3)
        integer, intent(out) :: ierr
        
        real(8) :: ZHD_base, ZWD_base, ZTD_base
        real(8) :: Lat_base, Lon_base, Hgt_base
        real(8) :: Lat_user, Lon_user, Hgt_user
        real(8) :: hgt_diff, beta_ZHD, beta_ZTD, beta_ZWD
        real(8) :: doy_normalized
        
        ! Initialize error flag
        ierr = 0
        
        ! Input validation
        if (DOY < 1 .or. DOY > 366) then
            write(*,*) 'GTHC_HK: DOY must be between 1 and 366'
            ierr = -1
            return
        end if
        
        ! Extract parameters
        ZHD_base = BaseTrop(1)
        ZWD_base = BaseTrop(2)
        ZTD_base = BaseTrop(3)
        
        Lat_base = BaseCoor(1)
        Lon_base = BaseCoor(2)
        Hgt_base = BaseCoor(3)
        
        Lat_user = UserCoor(1)
        Lon_user = UserCoor(2)
        Hgt_user = UserCoor(3)
        
        ! Hong Kong region validation
        if (.not. is_in_hongkong(Lat_base, Lon_base) .or. &
            .not. is_in_hongkong(Lat_user, Lon_user)) then
            write(*,*) 'GTHC_HK: Station coordinates outside Hong Kong region'
            ierr = -1
            return
        end if
        
        ! Calculate height difference
        hgt_diff = Hgt_user - Hgt_base
        
        ! ZHD height decay coefficient (constant)
        beta_ZHD = 8431.2d0
        
        ! Determine seasonal correction parameters
        if (YorN) then
            ! Use seasonal variation model
            doy_normalized = real(DOY, 8) / 365.25d0
            beta_ZTD = func_sinZTD(A_ZTD, doy_normalized)
            beta_ZWD = func_sinZWD(A_ZWD, doy_normalized)
        else
            ! Use annual mean parameters
            beta_ZTD = 7228.8d0
            beta_ZWD = 3254.1d0
        end if
        
        ! Apply exponential height correction model
        UserTrop(3) = ZTD_base / exp(-hgt_diff / beta_ZTD)  ! ZTD_user
        UserTrop(2) = ZWD_base / exp(-hgt_diff / beta_ZWD)  ! ZWD_user
        UserTrop(1) = ZHD_base / exp(-hgt_diff / beta_ZHD)  ! ZHD_user
        
    end subroutine GTHC_HK

end module GTHC_HK_Module

! Example usage
program test_GTHC_HK
    use GTHC_HK_Module
    implicit none
    
    real(8) :: BaseTrop(3) = [2200.0d0, 150.0d0, 2350.0d0]
    real(8) :: BaseCoor(3) = [22.3d0, 114.2d0, 50.0d0]
    real(8) :: UserCoor(3) = [22.35d0, 114.15d0, 200.0d0]
    real(8) :: UserTrop(3)
    integer :: DOY = 150
    integer :: ierr
    
    call GTHC_HK(BaseTrop, BaseCoor, UserCoor, DOY, .true., UserTrop, ierr)
    
    if (ierr == 0) then
        write(*,*) 'Corrected tropospheric delays:'
        write(*,*) 'ZHD = ', UserTrop(1), ' mm'
        write(*,*) 'ZWD = ', UserTrop(2), ' mm'
        write(*,*) 'ZTD = ', UserTrop(3), ' mm'
    else
        write(*,*) 'Error in GTHC_HK calculation'
    end if
    
end program test_GTHC_HK