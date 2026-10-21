import Toybox.Math;
import Toybox.Lang;

module SectorMath {
    function clamp(value, low, high) {
        if (value < low) { return low; }
        if (value > high) { return high; }
        return value;
    }

    function progress(value, goal) {
        if (value == null || goal == null || goal <= 0) { return null; }
        return clamp(value.toFloat() / goal, 0.0, 1.0);
    }

    function temperatureProgress(value, low, high) {
        if (value == null || low == null || high == null || high <= low) { return null; }
        return clamp((value - low).toFloat() / (high - low), 0.0, 1.0);
    }

    function temperature(celsius, fahrenheit) {
        if (celsius == null) { return null; }
        return Math.round(fahrenheit ? celsius * 1.8 + 32.0 : celsius).toNumber();
    }

    function numberText(value) {
        return value == null ? "--" : Math.round(value).toNumber().toString();
    }

    function stepsText(value) {
        if (value == null) { return "--"; }
        if (value < 1000) { return value.toNumber().toString(); }
        // Truncate, so 9,999 steps never falsely reads as a completed 10k.
        return (Math.floor(value / 100.0) / 10.0).format("%.1f") + "k";
    }
    function blendColor(a, b, fraction) {
        var t = clamp(fraction, 0.0, 1.0);
        var r = Math.round(((a >> 16) & 255) * (1 - t) + ((b >> 16) & 255) * t).toNumber();
        var g = Math.round(((a >> 8) & 255) * (1 - t) + ((b >> 8) & 255) * t).toNumber();
        var blue = Math.round((a & 255) * (1 - t) + (b & 255) * t).toNumber();
        return (r << 16) | (g << 8) | blue;
    }

    function rampColor(value, stops as Lang.Array<Lang.Numeric>, colors as Lang.Array<Lang.Number>) {
        if (value <= stops[0]) { return colors[0]; }
        for (var i = 1; i < stops.size(); i++) {
            if (value <= stops[i]) {
                return blendColor(colors[i - 1], colors[i], (value - stops[i - 1]).toFloat() / (stops[i] - stops[i - 1]));
            }
        }
        return colors[colors.size() - 1];
    }

    function temperatureColor(celsius) {
        return rampColor(celsius, [-10, 0, 7, 17, 27, 37],
            [0x747bff, 0x40cfff, 0x75d98a, 0xffc45b, 0xff9349, 0xff4b4b]);
    }

    function uvColor(value) {
        // Standard UV category colors, with smooth transitions between bands.
        return rampColor(value, [0, 2, 3, 5, 6, 7, 8, 10, 11],
            [0x6ee7a0, 0x6ee7a0, 0xffd35b, 0xffd35b, 0xff9349, 0xff9349, 0xff4b4b, 0xff4b4b, 0xb78aff]);
    }
}
