/// Linear fade envelope over a lifetime fraction [t] in `[0, 1]`: ramps up
/// for the first half and back down for the second half at a constant
/// rate, peaking at `t == 0.5`. Used instead of a `sin(pi*t)` hump (which
/// plateaus near its peak and only visibly changes right at the very
/// start/end) so a drifting wave/glint/ripple keeps changing brightness
/// across its ENTIRE life instead of just at the tail end.
double lifecycleFade(double t) => 1.0 - (2.0 * t - 1.0).abs();
