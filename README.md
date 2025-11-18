# GTHC_HK

![](https://img.shields.io/badge/version-1.0.0-green.svg) ![](https://img.shields.io/badge/build-passing-brightgreen.svg) ![](https://img.shields.io/badge/compiler-matlab-yellow.svg)![](https://img.shields.io/badge/compiler-python-blue.svg)![](https://img.shields.io/badge/compiler-C-red.svg)![](https://img.shields.io/badge/compiler-Fortran-pink.svg) ![](https://img.shields.io/badge/license-MIT-ff69b4.svg)

GTHC_HK: GNSS Tropospheric delay Height Correction (Hong Kong version) . 

This repository offers advanced GNSS tropospheric delay correction models, specifically optimized for the Hong Kong region. Developed through long-term (> 10-year) analysis of Hong Kong CORS data, these models deliver enhanced accuracy for mitigating tropospheric delays in GNSS applications, especially for the large height difference areas. Currently, it supports versions in four programming languages: C, Fortran, MATLAB, and Python.

## News and Updates

[18 Nov 2025] This repository is created.

## Installation

If the tropospheric delay correction is a separate function in your code, simply replace it with the function file in the src folder. If it is not a separate function, you can replace the original function model with the function parameters and function calculation parts.

Please select the appropriate implementation file based on your programming environment:

| Language | File Name | Primary Reference |
|----------|-----------|-------------------|
| MATLAB | `GTHC_HK.m` | ✅ **Reference Standard** |
| Python | `GTHC_HK.py` | |
| C | `GTHC_HK.c` | |
| Fortran | `GTHC_HK.f90` | |

**Consistency Assurance**: While all implementations maintain the same core algorithm, any discrepancies between versions should be resolved by referring to the MATLAB implementation as the authoritative reference standard.

### Usage Recommendations

- **New Projects**: Choose the version that best integrates with your existing codebase
- **Cross-Validation**: When migrating between languages, verify results against the MATLAB reference
- **Algorithm Fidelity**: The MATLAB version represents the canonical implementation with full validation

The 18 Hong Kong CORS stations involved in the modeling are: stationlist = {'HKCL', 'HKFN', 'HKKS', 'HKKT', 'HKLM', 'HKLT', 'HKMW', 'HKNP', 'HKOH', 'HKPC', 'HKQT', 'HKSC', 'HKSL', 'HKSS', 'HKST', 'HKTK', 'HKWS', 'T430'}

## Perfermance

**Table 1**. Station profiles of two representative test cases in Hong Kong.

|          Cases          |       Base 1       |       Base 2        |       Base 3        |        User         | Average elevation difference |
| :---------------------: | :----------------: | :-----------------: | :-----------------: | :-----------------: | :--------------------------: |
| Case 1<br>(high to low) | HKSL <br>(95.30 m) | HKNP <br>(350.67 m) | HKMW <br>(194.95 m) |  HKCL<br> (7.71 m)  |          -205.93 m           |
| Case 2<br>(low to high) | HKSC <br>(20.24 m) | HKSS <br>(38.71 m)  | HKKT <br>(34.58 m)  | HKST <br>(258.70 m) |           227.52 m           |

**Table 2**. Improvements of two positioning verification cases under two refined models.

|  Cases | Horizontal |             |   Vertical |             | Fixed rate |             |
| -----: | ---------: | ----------: | ---------: | ----------: | ---------: | ----------: |
|        | $EXP_{HW}$ | $EXP_{HWp}$ | $EXP_{HW}$ | $EXP_{HWp}$ | $EXP_{HW}$ | $EXP_{HWp}$ |
| Case 1 |      40.0% |       50.0% |      63.6% |       63.6% |      32.5% |       33.3% |
| Case 2 |      27.3% |       27.3% |      42.4% |       42.4% |      16.7% |       17.1% |



## Acknowledgments

We would like to thank the Nevada Geodetic Laboratory (NGL) for the provision of tropospheric products (http://geodesy.unr.edu/gps_timeseries/trop/sites) and the the Hong Kong Satellite Positioning Reference Station Network (SatRef) for the GNSS observation data (https://www.geodetic.gov.hk/en/satref/satref.htm).

## License

[MIT](LICENSE) © Richard Littauer

## References

If you use the resource in your research, please cite our paper:

Ding et al.,  (2025) Refinement of Tropospheric Delay Correction for Large Height Differences to Enhance Hong Kong Network RTK Performance.