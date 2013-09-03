module util.math;

import std.math;
import std.algorithm;

/**
Returns $(D val), if it is between $(D lower) and $(D upper).
Otherwise returns the nearest of the two. Equivalent to $(D max(lower,
min(upper,val))). The type of the result is computed by using $(XREF
traits, MaxType).
*/
T clamp(T)(T val, T lower, T upper)
{
    return max(lower, min(upper,val));
}
