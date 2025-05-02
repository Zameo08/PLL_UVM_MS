_amsaIeConnectRulesInfo='(nil
    count 1
    connectRules
    (
        (nil
         name "uCR"
         file "../../../../../../Cadence/xcelium/2409/24.09.007/tools/affirma_ams/etc/connect_lib/uCR.vams"
         library "connectLib"
         header "`define accuracy    \"moderate\"                _//_liberal_|_moderate_|_conservative \n `define vsup        1.0                       _//_Supply_voltage_based_on_vss \n `define rout        200                       _//_Output_resistance \n `define tr          200p                      _//_Transition_rising_time \n `define vsupmin     0.5                       _//_Minimal_supply_voltage \n `define vss         0                         _//_Voltage_of_source_and_substrate \n `define vlo         `vss                      _//_Logic-0_output_voltage \n `define vhi         `vsup+`vss                _//_Logic-1_output_voltage \n `define vthi        `vlo+(`vhi-(`vlo))*2.0/3.0                _//_High_threshold_voltage \n `define vtlo        `vlo+(`vhi-(`vlo))/3.0                    _//_Low_threshold_voltage \n `define vx          `accuracy==\"conservative\"?(`vhi+(`vlo))/2.0:`vlo  _//_Voltage_from_digital_X \n `define vz          `accuracy==\"conservative\"?(`vhi+(`vlo))/2.0:`vlo  _//_Voltage_from_digital_Z \n `define vtol        (`vthi-(`vtlo))/(`accuracy==\"conservative\"?10.0:4.0)  _//_Voltage_tol_of_cross \n `define tf          `tr                       _//_Transition_falling_Time \n `define txdel       (`tr)*4.0                 _//_Delay_of_analog_mid-range_to_X \n `define tdeltran    0                         _//_Delay_of_D_to_A_transition \n `define tdeltran_rise  `tdeltran              _//_Delay_of_D_to_A_transition_rise \n `define tdeltran_fall  `tdeltran_rise         _//_Delay_of_D_to_A_transition_fall \n `define ttoltran    (`tr)/10.0                _//_Time_tolerance_of_transition \n `define ttolcross   (`tr)/4.0                 _//_Time_tolerance_of_cross \n `define rlo         `rout                     _//_Output_resistance_of_pull_down \n `define rhi         `rout                     _//_Output_resistance_of_pull_up \n `define rx          `accuracy==\"conservative\"?(`rlo+(`rhi))/10:(`rlo+(`rhi))/2     _//_Output_resistance_of_pull_X \n `define rz          10M                       _//_Output_resistance_of_high-Z \n `define vdelta      (`vsup)/64.0              _//_Voltage_delta_of_absdelta \n `define vtoldelta   (`vdelta)/4.0             _//_Voltage_tolerance_of_absdelta \n `define ttoldelta   (`tr)/20.0                _//_Time_tolerance_of_absdelta \n `define vpso        0.2                       _//_Vpso \n `define rsupply     ((`rhi>`rlo)?`rlo:`rhi)/2.5<4?((`rhi>`rlo)?`rlo:`rhi)/2.5:4          _//_Output_resistance_of_SUPPLY_strength \n `define rpull       ((`rhi>`rlo)?`rhi:`rlo)*2.5>1.5e3?((`rhi>`rlo)?`rhi:`rlo)*2.5:1.5e3  _//_Output_resistance_of_PULL_strength \n `define rlarge      (`rpull)*2.5>9.0e3?(`rpull)*2.5:9.0e3     _//_Output_resistance_of_LARGE_strength \n `define rweak       (`rlarge)*2.5>5.5e4?(`rlarge)*2.5:5.5e4   _//_Output_resistance_of_WEAK_strength \n `define rmedium     (`rweak)*2.5>3.2e5?(`rweak)*2.5:3.2e5     _//_Output_resistance_of_MEDIUM_strength \n `define rsmall      (`rmedium)*2.5>1.9e6?(`rmedium)*2.5:1.9e6  _//_Output_resistance_of_SMALL_strength \n `define vtrhi       (`vthi)/(`vsup)           _//_relative_high_threshold_voltage \n `define vtrlo       (`vtlo)/(`vsup)           _//_relative_high_threshold_voltage \n `define vrtol       (`vtol)/(`vsup)           _//_relative_voltage_tol_of_cross \n `define nox         `accuracy==\"liberal\"?1:0        _//_1:_No_X_in_E-to-L_conversion \n `define ignore_xz   `accuracy==\"liberal\"?1:0        _//_1:_Ignore_X/Z_in_L-to-E_conversion \n `define analog_load `accuracy==\"conservative\"?1:0   _//_1:_analog_loading_effect_in_L-to-E \n `define ramp_type   `accuracy==\"conservative\"?1:0   _//_1:_resistance_ramps_on_log_scale \n `define debug       0                         _//_1:_enable_debug_features \n `define vinlimit   `vss+(`vsup)*4.0/3.0       _//_input_signal_limit \n `define vddlimit   `vss+(`vsup)*4.0/3.0       _//_vdd_supply_limit \n `define vsup_low_output_x       0             _//_1:_output_X_if_supply_below_vsupmin \n `define enable_ilimit  0                      _//_1:_enable_output_current_limiting \n `define ilimit         500u                   _//_limit_output_current_in_between_+/-ilimit \n `define bidir_trangate 0                      _//_1:_enable_bidir_trangate_flow \n `define currentmode 0                         _//_1_for_wreal_current \n `define clamp       0                         _//_1_to_enable_peak_voltage_clamp \n `define rin         200                       _//_Current_load_resistance \n `define idelta      10u                       _//_Current_delta_of_absdelta \n `define itoldelta   (`idelta)/4.0             _//_Current_tolerance_of_absdelta \n `define ix          0                         _//_Current_of_wreal_X \n `define vbias       `vss+(`vsup)/2.0          _//_Bias_voltage_of_current_load \n `define dvclamp     (`vsup)/20.0              _//_Voltage_clamp_zoon \n `define enable_highz      0                   _//_1:_enable_dyn_highz_in_E-to-L_conversion \n `define duration          5n                  _//_See_details_in_\"spectre_-h_dyn_highz\" \n `define Ts  1n               _//_[sec]_sample_rate_of_conversion \n `define Ra  100              _//_[ohms]_assumed_resistance_of_analog_network \n `define MaxIter  4           _//_max_number_discrete_changes_per_analog_sample \n `define Vtol  1e-6           _//_[V]_voltage_tolerance \n `define Itol  1e-10          _//_[A]_current_tolerance \n `define Rrel  1e-4           _//_[-]_fractional_resistance_tolerance \n `define Roff  1e12           _//_[ohms]_resistance_for_high-impedance_state \n `define Vx  0                _//_[V]_analog_output_voltage_for_discrete_X \n `define Rx  `Roff            _//_[ohms]_analog_output_resistance_for_discrete_X"
         basic_header "`define accuracy    \"moderate\"                _//_liberal_|_moderate_|_conservative \n `define vsup        1.0                       _//_Supply_voltage_based_on_vss \n `define rout        200                       _//_Output_resistance \n `define tr          200p                      _//_Transition_rising_time"
         extended_header "`define vsupmin     0.5                       _//_Minimal_supply_voltage \n `define vss         0                         _//_Voltage_of_source_and_substrate \n `define vlo         `vss                      _//_Logic-0_output_voltage \n `define vhi         `vsup+`vss                _//_Logic-1_output_voltage \n `define vthi        `vlo+(`vhi-(`vlo))*2.0/3.0                _//_High_threshold_voltage \n `define vtlo        `vlo+(`vhi-(`vlo))/3.0                    _//_Low_threshold_voltage \n `define vx          `accuracy==\"conservative\"?(`vhi+(`vlo))/2.0:`vlo  _//_Voltage_from_digital_X \n `define vz          `accuracy==\"conservative\"?(`vhi+(`vlo))/2.0:`vlo  _//_Voltage_from_digital_Z \n `define vtol        (`vthi-(`vtlo))/(`accuracy==\"conservative\"?10.0:4.0)  _//_Voltage_tol_of_cross \n `define tf          `tr                       _//_Transition_falling_Time \n `define txdel       (`tr)*4.0                 _//_Delay_of_analog_mid-range_to_X \n `define tdeltran    0                         _//_Delay_of_D_to_A_transition \n `define tdeltran_rise  `tdeltran              _//_Delay_of_D_to_A_transition_rise \n `define tdeltran_fall  `tdeltran_rise         _//_Delay_of_D_to_A_transition_fall \n `define ttoltran    (`tr)/10.0                _//_Time_tolerance_of_transition \n `define ttolcross   (`tr)/4.0                 _//_Time_tolerance_of_cross \n `define rlo         `rout                     _//_Output_resistance_of_pull_down \n `define rhi         `rout                     _//_Output_resistance_of_pull_up \n `define rx          `accuracy==\"conservative\"?(`rlo+(`rhi))/10:(`rlo+(`rhi))/2     _//_Output_resistance_of_pull_X \n `define rz          10M                       _//_Output_resistance_of_high-Z \n `define vdelta      (`vsup)/64.0              _//_Voltage_delta_of_absdelta \n `define vtoldelta   (`vdelta)/4.0             _//_Voltage_tolerance_of_absdelta \n `define ttoldelta   (`tr)/20.0                _//_Time_tolerance_of_absdelta \n `define vpso        0.2                       _//_Vpso \n `define rsupply     ((`rhi>`rlo)?`rlo:`rhi)/2.5<4?((`rhi>`rlo)?`rlo:`rhi)/2.5:4          _//_Output_resistance_of_SUPPLY_strength \n `define rpull       ((`rhi>`rlo)?`rhi:`rlo)*2.5>1.5e3?((`rhi>`rlo)?`rhi:`rlo)*2.5:1.5e3  _//_Output_resistance_of_PULL_strength \n `define rlarge      (`rpull)*2.5>9.0e3?(`rpull)*2.5:9.0e3     _//_Output_resistance_of_LARGE_strength \n `define rweak       (`rlarge)*2.5>5.5e4?(`rlarge)*2.5:5.5e4   _//_Output_resistance_of_WEAK_strength \n `define rmedium     (`rweak)*2.5>3.2e5?(`rweak)*2.5:3.2e5     _//_Output_resistance_of_MEDIUM_strength \n `define rsmall      (`rmedium)*2.5>1.9e6?(`rmedium)*2.5:1.9e6  _//_Output_resistance_of_SMALL_strength \n `define vtrhi       (`vthi)/(`vsup)           _//_relative_high_threshold_voltage \n `define vtrlo       (`vtlo)/(`vsup)           _//_relative_high_threshold_voltage \n `define vrtol       (`vtol)/(`vsup)           _//_relative_voltage_tol_of_cross \n `define nox         `accuracy==\"liberal\"?1:0        _//_1:_No_X_in_E-to-L_conversion \n `define ignore_xz   `accuracy==\"liberal\"?1:0        _//_1:_Ignore_X/Z_in_L-to-E_conversion \n `define analog_load `accuracy==\"conservative\"?1:0   _//_1:_analog_loading_effect_in_L-to-E \n `define ramp_type   `accuracy==\"conservative\"?1:0   _//_1:_resistance_ramps_on_log_scale \n `define debug       0                         _//_1:_enable_debug_features \n `define vinlimit   `vss+(`vsup)*4.0/3.0       _//_input_signal_limit \n `define vddlimit   `vss+(`vsup)*4.0/3.0       _//_vdd_supply_limit \n `define vsup_low_output_x       0             _//_1:_output_X_if_supply_below_vsupmin \n `define enable_ilimit  0                      _//_1:_enable_output_current_limiting \n `define ilimit         500u                   _//_limit_output_current_in_between_+/-ilimit \n `define bidir_trangate 0                      _//_1:_enable_bidir_trangate_flow \n `define currentmode 0                         _//_1_for_wreal_current \n `define clamp       0                         _//_1_to_enable_peak_voltage_clamp \n `define rin         200                       _//_Current_load_resistance \n `define idelta      10u                       _//_Current_delta_of_absdelta \n `define itoldelta   (`idelta)/4.0             _//_Current_tolerance_of_absdelta \n `define ix          0                         _//_Current_of_wreal_X \n `define vbias       `vss+(`vsup)/2.0          _//_Bias_voltage_of_current_load \n `define dvclamp     (`vsup)/20.0              _//_Voltage_clamp_zoon \n `define enable_highz      0                   _//_1:_enable_dyn_highz_in_E-to-L_conversion \n `define duration          5n                  _//_See_details_in_\"spectre_-h_dyn_highz\""
         extended_eenet_header "`define Ts  1n               _//_[sec]_sample_rate_of_conversion \n `define Ra  100              _//_[ohms]_assumed_resistance_of_analog_network \n `define MaxIter  4           _//_max_number_discrete_changes_per_analog_sample \n `define Vtol  1e-6           _//_[V]_voltage_tolerance \n `define Itol  1e-10          _//_[A]_current_tolerance \n `define Rrel  1e-4           _//_[-]_fractional_resistance_tolerance \n `define Roff  1e12           _//_[ohms]_resistance_for_high-impedance_state \n `define Vx  0                _//_[V]_analog_output_voltage_for_discrete_X \n `define Rx  `Roff            _//_[ohms]_analog_output_resistance_for_discrete_X"
         description "This is the description for uCR"
         moduleInfo
         (
            (nil
             name "uE2L"
             paramInfo
             (
                (nil name "accuracy"
                     value "`accuracy"
                )
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vhi"
                     value "`vhi"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vthi"
                     value "`vthi"
                )
                (nil name "vtlo"
                     value "`vtlo"
                )
                (nil name "tr"
                     value "`tr"
                )
                (nil name "tf"
                     value "`tf"
                )
                (nil name "vtol"
                     value "`vtol"
                )
                (nil name "txdel"
                     value "`txdel"
                )
                (nil name "nox"
                     value "`nox"
                )
                (nil name "ttol_c"
                     value "`ttolcross"
                )
                (nil name "vsup_min"
                     value "`vsupmin"
                )
                (nil name "enable_highz"
                     value "`enable_highz"
                )
                (nil name "duration"
                     value "`duration"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
                (nil name "vddlimit"
                     value "`vddlimit"
                )
                (nil name "vpso"
                     value "`vpso"
                )
                (nil name "vsup_low_output_x"
                     value "`vsup_low_output_x"
                )
             )
            )
            (nil
             name "uL2E"
             paramInfo
             (
                (nil name "accuracy"
                     value "`accuracy"
                )
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vhi"
                     value "`vhi"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vthi"
                     value "`vthi"
                )
                (nil name "vtlo"
                     value "`vtlo"
                )
                (nil name "tr"
                     value "`tr"
                )
                (nil name "tf"
                     value "`tf"
                )
                (nil name "vtol"
                     value "`vtol"
                )
                (nil name "txdel"
                     value "`txdel"
                )
                (nil name "nox"
                     value "`nox"
                )
                (nil name "ttol_c"
                     value "`ttolcross"
                )
                (nil name "vsup_min"
                     value "`vsupmin"
                )
                (nil name "enable_highz"
                     value "`enable_highz"
                )
                (nil name "duration"
                     value "`duration"
                )
                (nil name "ignore_xz"
                     value "`ignore_xz"
                )
                (nil name "vx"
                     value "`vx"
                )
                (nil name "vz"
                     value "`vz"
                )
                (nil name "bidir_trangate"
                     value "`bidir_trangate"
                )
                (nil name "ttol_t"
                     value "`ttoltran"
                )
                (nil name "tdeltran_rise"
                     value "`tdeltran_rise"
                )
                (nil name "tdeltran_fall"
                     value "`tdeltran_fall"
                )
                (nil name "ramp_type"
                     value "`ramp_type"
                )
                (nil name "rhi"
                     value "`rhi"
                )
                (nil name "rlo"
                     value "`rlo"
                )
                (nil name "rx"
                     value "`rx"
                )
                (nil name "rz"
                     value "`rz"
                )
                (nil name "analog_load"
                     value "`analog_load"
                )
                (nil name "r_SUPPLY"
                     value "`rsupply"
                )
                (nil name "r_PULL"
                     value "`rpull"
                )
                (nil name "r_LARGE"
                     value "`rlarge"
                )
                (nil name "r_WEAK"
                     value "`rweak"
                )
                (nil name "r_MEDIUM"
                     value "`rmedium"
                )
                (nil name "r_SMALL"
                     value "`rsmall"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
                (nil name "vddlimit"
                     value "`vddlimit"
                )
                (nil name "vpso"
                     value "`vpso"
                )
                (nil name "vsup_low_output_x"
                     value "`vsup_low_output_x"
                )
                (nil name "enable_ilimit"
                     value "`enable_ilimit"
                )
                (nil name "ilimit"
                     value "`ilimit"
                )
             )
            )
            (nil
             name "uBidir"
             paramInfo
             (
                (nil name "accuracy"
                     value "`accuracy"
                )
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vhi"
                     value "`vhi"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vthi"
                     value "`vthi"
                )
                (nil name "vtlo"
                     value "`vtlo"
                )
                (nil name "tr"
                     value "`tr"
                )
                (nil name "tf"
                     value "`tf"
                )
                (nil name "vtol"
                     value "`vtol"
                )
                (nil name "txdel"
                     value "`txdel"
                )
                (nil name "nox"
                     value "`nox"
                )
                (nil name "ttol_c"
                     value "`ttolcross"
                )
                (nil name "vsup_min"
                     value "`vsupmin"
                )
                (nil name "enable_highz"
                     value "`enable_highz"
                )
                (nil name "duration"
                     value "`duration"
                )
                (nil name "ignore_xz"
                     value "`ignore_xz"
                )
                (nil name "vx"
                     value "`vx"
                )
                (nil name "vz"
                     value "`vz"
                )
                (nil name "bidir_trangate"
                     value "`bidir_trangate"
                )
                (nil name "ttol_t"
                     value "`ttoltran"
                )
                (nil name "tdeltran_rise"
                     value "`tdeltran_rise"
                )
                (nil name "tdeltran_fall"
                     value "`tdeltran_fall"
                )
                (nil name "ramp_type"
                     value "`ramp_type"
                )
                (nil name "rhi"
                     value "`rhi"
                )
                (nil name "rlo"
                     value "`rlo"
                )
                (nil name "rx"
                     value "`rx"
                )
                (nil name "rz"
                     value "`rz"
                )
                (nil name "analog_load"
                     value "1"
                )
                (nil name "r_SUPPLY"
                     value "`rsupply"
                )
                (nil name "r_PULL"
                     value "`rpull"
                )
                (nil name "r_LARGE"
                     value "`rlarge"
                )
                (nil name "r_WEAK"
                     value "`rweak"
                )
                (nil name "r_MEDIUM"
                     value "`rmedium"
                )
                (nil name "r_SMALL"
                     value "`rsmall"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
                (nil name "vddlimit"
                     value "`vddlimit"
                )
                (nil name "vpso"
                     value "`vpso"
                )
                (nil name "vsup_low_output_x"
                     value "`vsup_low_output_x"
                )
                (nil name "enable_ilimit"
                     value "`enable_ilimit"
                )
                (nil name "ilimit"
                     value "`ilimit"
                )
             )
            )
            (nil
             name "uE2R"
             paramInfo
             (
                (nil name "vdelta"
                     value "`vdelta"
                )
                (nil name "vtol"
                     value "`vtoldelta"
                )
                (nil name "ttol"
                     value "`ttoldelta"
                )
                (nil name "vss"
                     value "`vss"
                )
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "currentmode"
                     value "`currentmode"
                )
                (nil name "idelta"
                     value "`idelta"
                )
                (nil name "itol"
                     value "`itoldelta"
                )
                (nil name "vbias"
                     value "`vbias"
                )
                (nil name "rin"
                     value "`rin"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
             )
            )
            (nil
             name "uR2E"
             paramInfo
             (
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vdelta"
                     value "`vdelta"
                )
                (nil name "vss"
                     value "`vss"
                )
                (nil name "vx"
                     value "`vx"
                )
                (nil name "tr"
                     value "`ttoldelta"
                )
                (nil name "tf"
                     value "`ttoldelta"
                )
                (nil name "tdelay"
                     value "`tdeltran"
                )
                (nil name "ignore_xz"
                     value "`ignore_xz"
                )
                (nil name "rout"
                     value "`rout"
                )
                (nil name "rx"
                     value "`rx"
                )
                (nil name "rz"
                     value "`rz"
                )
                (nil name "currentmode"
                     value "`currentmode"
                )
                (nil name "idelta"
                     value "`idelta"
                )
                (nil name "clamp"
                     value "`clamp"
                )
                (nil name "dvclamp"
                     value "`dvclamp"
                )
                (nil name "ix"
                     value "`ix"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
             )
            )
            (nil
             name "uERbidir"
             paramInfo
             (
                (nil name "vdelta"
                     value "`vdelta"
                )
                (nil name "vtol"
                     value "`vtoldelta"
                )
                (nil name "ttol"
                     value "`ttoldelta"
                )
                (nil name "tr"
                     value "`ttoldelta"
                )
                (nil name "tf"
                     value "`ttoldelta"
                )
                (nil name "tdelay"
                     value "`tdeltran"
                )
                (nil name "ignore_xz"
                     value "`ignore_xz"
                )
                (nil name "rout"
                     value "`rout"
                )
                (nil name "rz"
                     value "`rz"
                )
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "currentmode"
                     value "`currentmode"
                )
                (nil name "idelta"
                     value "`idelta"
                )
                (nil name "itol"
                     value "`itoldelta"
                )
                (nil name "vbias"
                     value "`vbias"
                )
                (nil name "rin"
                     value "`rin"
                )
                (nil name "clamp"
                     value "`clamp"
                )
                (nil name "dvclamp"
                     value "`dvclamp"
                )
                (nil name "ix"
                     value "`ix"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
             )
            )
            (nil
             name "L2R"
             paramInfo
             (
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vhi"
                     value "`vhi"
                )
             )
            )
            (nil
             name "R2L"
             paramInfo
             (
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vhi"
                     value "`vhi"
                )
                (nil name "vtlo"
                     value "`vtlo"
                )
                (nil name "vthi"
                     value "`vthi"
                )
             )
            )
            (nil
             name "RL_bidir"
             paramInfo
             (
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vhi"
                     value "`vhi"
                )
                (nil name "vtlo"
                     value "`vtlo"
                )
                (nil name "vthi"
                     value "`vthi"
                )
             )
            )
            (nil
             name "uE2L_LPS"
             paramInfo
             (
                (nil name "accuracy"
                     value "`accuracy"
                )
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vhi"
                     value "`vhi"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vthi"
                     value "`vthi"
                )
                (nil name "vtlo"
                     value "`vtlo"
                )
                (nil name "tr"
                     value "`tr"
                )
                (nil name "tf"
                     value "`tf"
                )
                (nil name "vtol"
                     value "`vtol"
                )
                (nil name "txdel"
                     value "`txdel"
                )
                (nil name "nox"
                     value "`nox"
                )
                (nil name "ttol_c"
                     value "`ttolcross"
                )
                (nil name "vsup_min"
                     value "`vsupmin"
                )
                (nil name "enable_highz"
                     value "`enable_highz"
                )
                (nil name "duration"
                     value "`duration"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
                (nil name "vddlimit"
                     value "`vddlimit"
                )
                (nil name "vpso"
                     value "`vpso"
                )
                (nil name "vsup_low_output_x"
                     value "`vsup_low_output_x"
                )
             )
            )
            (nil
             name "uL2E_LPS"
             paramInfo
             (
                (nil name "accuracy"
                     value "`accuracy"
                )
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vhi"
                     value "`vhi"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vthi"
                     value "`vthi"
                )
                (nil name "vtlo"
                     value "`vtlo"
                )
                (nil name "tr"
                     value "`tr"
                )
                (nil name "tf"
                     value "`tf"
                )
                (nil name "vtol"
                     value "`vtol"
                )
                (nil name "txdel"
                     value "`txdel"
                )
                (nil name "nox"
                     value "`nox"
                )
                (nil name "ttol_c"
                     value "`ttolcross"
                )
                (nil name "vsup_min"
                     value "`vsupmin"
                )
                (nil name "enable_highz"
                     value "`enable_highz"
                )
                (nil name "duration"
                     value "`duration"
                )
                (nil name "ignore_xz"
                     value "0"
                )
                (nil name "vx"
                     value "`vx"
                )
                (nil name "vz"
                     value "`vz"
                )
                (nil name "ttol_t"
                     value "`ttoltran"
                )
                (nil name "tdeltran_rise"
                     value "`tdeltran_rise"
                )
                (nil name "tdeltran_fall"
                     value "`tdeltran_fall"
                )
                (nil name "ramp_type"
                     value "`ramp_type"
                )
                (nil name "rhi"
                     value "`rhi"
                )
                (nil name "rlo"
                     value "`rlo"
                )
                (nil name "rx"
                     value "`rx"
                )
                (nil name "rz"
                     value "`rz"
                )
                (nil name "analog_load"
                     value "`analog_load"
                )
                (nil name "r_SUPPLY"
                     value "`rsupply"
                )
                (nil name "r_PULL"
                     value "`rpull"
                )
                (nil name "r_LARGE"
                     value "`rlarge"
                )
                (nil name "r_WEAK"
                     value "`rweak"
                )
                (nil name "r_MEDIUM"
                     value "`rmedium"
                )
                (nil name "r_SMALL"
                     value "`rsmall"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
                (nil name "vddlimit"
                     value "`vddlimit"
                )
                (nil name "vpso"
                     value "`vpso"
                )
                (nil name "vsup_low_output_x"
                     value "`vsup_low_output_x"
                )
             )
            )
            (nil
             name "uBidir_LPS"
             paramInfo
             (
                (nil name "accuracy"
                     value "`accuracy"
                )
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vhi"
                     value "`vhi"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vthi"
                     value "`vthi"
                )
                (nil name "vtlo"
                     value "`vtlo"
                )
                (nil name "tr"
                     value "`tr"
                )
                (nil name "tf"
                     value "`tf"
                )
                (nil name "vtol"
                     value "`vtol"
                )
                (nil name "txdel"
                     value "`txdel"
                )
                (nil name "nox"
                     value "`nox"
                )
                (nil name "ttol_c"
                     value "`ttolcross"
                )
                (nil name "vsup_min"
                     value "`vsupmin"
                )
                (nil name "enable_highz"
                     value "`enable_highz"
                )
                (nil name "duration"
                     value "`duration"
                )
                (nil name "ignore_xz"
                     value "0"
                )
                (nil name "vx"
                     value "`vx"
                )
                (nil name "vz"
                     value "`vz"
                )
                (nil name "ttol_t"
                     value "`ttoltran"
                )
                (nil name "tdeltran_rise"
                     value "`tdeltran_rise"
                )
                (nil name "tdeltran_fall"
                     value "`tdeltran_fall"
                )
                (nil name "ramp_type"
                     value "`ramp_type"
                )
                (nil name "rhi"
                     value "`rhi"
                )
                (nil name "rlo"
                     value "`rlo"
                )
                (nil name "rx"
                     value "`rx"
                )
                (nil name "rz"
                     value "`rz"
                )
                (nil name "analog_load"
                     value "1"
                )
                (nil name "r_SUPPLY"
                     value "`rsupply"
                )
                (nil name "r_PULL"
                     value "`rpull"
                )
                (nil name "r_LARGE"
                     value "`rlarge"
                )
                (nil name "r_WEAK"
                     value "`rweak"
                )
                (nil name "r_MEDIUM"
                     value "`rmedium"
                )
                (nil name "r_SMALL"
                     value "`rsmall"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
                (nil name "vddlimit"
                     value "`vddlimit"
                )
                (nil name "vpso"
                     value "`vpso"
                )
                (nil name "vsup_low_output_x"
                     value "`vsup_low_output_x"
                )
             )
            )
            (nil
             name "L2R_LPS"
             paramInfo
             (
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vhi"
                     value "`vhi"
                )
             )
            )
            (nil
             name "R2L_LPS"
             paramInfo
             (
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vhi"
                     value "`vhi"
                )
                (nil name "vtlo"
                     value "`vtlo"
                )
                (nil name "vthi"
                     value "`vthi"
                )
                (nil name "vtrhi"
                     value "`vtrhi"
                )
                (nil name "vtrlo"
                     value "`vtrlo"
                )
             )
            )
            (nil
             name "RL_Bidir_LPS"
             paramInfo
             (
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vhi"
                     value "`vhi"
                )
                (nil name "vtlo"
                     value "`vtlo"
                )
                (nil name "vthi"
                     value "`vthi"
                )
                (nil name "vtrhi"
                     value "`vtrhi"
                )
                (nil name "vtrlo"
                     value "`vtrlo"
                )
             )
            )
            (nil
             name "E2R_LPS"
             paramInfo
             (
                (nil name "vdelta"
                     value "`vdelta"
                )
                (nil name "vtol"
                     value "`vtoldelta"
                )
                (nil name "ttol"
                     value "`ttoldelta"
                )
                (nil name "currentmode"
                     value "`currentmode"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
             )
            )
            (nil
             name "R2E_2_LPS"
             paramInfo
             (
                (nil name "vsup"
                     value "`vsup"
                )
                (nil name "vdelta"
                     value "`vdelta"
                )
                (nil name "vlo"
                     value "`vlo"
                )
                (nil name "vx"
                     value "`vx"
                )
                (nil name "tr"
                     value "`ttoldelta"
                )
                (nil name "tf"
                     value "`ttoldelta"
                )
                (nil name "tdelay"
                     value "`tdeltran"
                )
                (nil name "rout"
                     value "`rout"
                )
                (nil name "rx"
                     value "`rx"
                )
                (nil name "rz"
                     value "`rz"
                )
                (nil name "vpso"
                     value "`vpso"
                )
                (nil name "currentmode"
                     value "`currentmode"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
             )
            )
            (nil
             name "ER_Bidir_LPS"
             paramInfo
             (
                (nil name "vdelta"
                     value "`vdelta"
                )
                (nil name "vtol"
                     value "`vtoldelta"
                )
                (nil name "ttol"
                     value "`ttoldelta"
                )
                (nil name "tr"
                     value "`ttoldelta"
                )
                (nil name "tf"
                     value "`ttoldelta"
                )
                (nil name "tdelay"
                     value "`tdeltran"
                )
                (nil name "rout"
                     value "`rout"
                )
                (nil name "rz"
                     value "`rz"
                )
                (nil name "vpso"
                     value "`vpso"
                )
                (nil name "currentmode"
                     value "`currentmode"
                )
                (nil name "debug"
                     value "`debug"
                )
                (nil name "vinlimit"
                     value "`vinlimit"
                )
             )
            )
            (nil
             name "E_EEnet_Bidir"
             paramInfo
             (
                (nil name "Ts"
                     value "`Ts"
                )
                (nil name "Ra"
                     value "`Ra"
                )
                (nil name "MaxIter"
                     value "`MaxIter"
                )
                (nil name "Vtol"
                     value "`Vtol"
                )
                (nil name "Itol"
                     value "`Itol"
                )
                (nil name "Rrel"
                     value "`Rrel"
                )
                (nil name "Roff"
                     value "`Roff"
                )
                (nil name "Vx"
                     value "`Vx"
                )
                (nil name "Rx"
                     value "`Rx"
                )
             )
            )
            (nil
             name "E_2_EEnet"
             paramInfo
             (
                (nil name "Ts"
                     value "`Ts"
                )
                (nil name "Ra"
                     value "`Ra"
                )
                (nil name "MaxIter"
                     value "`MaxIter"
                )
                (nil name "Vtol"
                     value "`Vtol"
                )
                (nil name "Itol"
                     value "`Itol"
                )
                (nil name "Rrel"
                     value "`Rrel"
                )
                (nil name "Roff"
                     value "`Roff"
                )
                (nil name "Vx"
                     value "`Vx"
                )
                (nil name "Rx"
                     value "`Rx"
                )
             )
            )
            (nil
             name "EEnet_2_E"
             paramInfo
             (
                (nil name "Ts"
                     value "`Ts"
                )
                (nil name "Ra"
                     value "`Ra"
                )
                (nil name "MaxIter"
                     value "`MaxIter"
                )
                (nil name "Vtol"
                     value "`Vtol"
                )
                (nil name "Itol"
                     value "`Itol"
                )
                (nil name "Rrel"
                     value "`Rrel"
                )
                (nil name "Roff"
                     value "`Roff"
                )
                (nil name "Vx"
                     value "`Vx"
                )
                (nil name "Rx"
                     value "`Rx"
                )
             )
            )
         )
        )
    )
)
