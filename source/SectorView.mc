import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class SectorView extends WatchUi.WatchFace {
    var _data;
    var _scale = 1.0;
    var _cx = 227.0;
    var _cy = 227.0;
    var _sleeping = false;
    var _dirty = true;
    var _units = -1;
    const WHITE = 0xffffff;
    const TRACK = 0x282828;
    const STEPS_COLOR = 0xff785d;
    const SLEEP_COLOR = 0xb78aff;
    const BODY_COLOR = 0x47ddcc;
    var _valueFont;
    var _dateFont;
    var _smallFont;
    var _hourFont;
    var _stepsFont;

    function initialize() {
        WatchFace.initialize();
        _data = new SectorData();
    }

    function onLayout(dc) {
        _scale = (dc.getWidth() < dc.getHeight() ? dc.getWidth() : dc.getHeight()) / 454.0;
        _cx = dc.getWidth() / 2.0;
        _cy = dc.getHeight() / 2.0;
        _valueFont = font(34, Graphics.FONT_MEDIUM);
        _dateFont = font(29, Graphics.FONT_SMALL);
        _smallFont = font(19, Graphics.FONT_XTINY);
        _hourFont = font(28, Graphics.FONT_SMALL);
        _stepsFont = font(30, Graphics.FONT_SMALL);
        _dirty = true;
    }

    function font(size, fallback) {
        if (Graphics has :getVectorFont) {
            var result = Graphics.getVectorFont({:face => ["RobotoCondensedRegular", "RobotoRegular"], :size => size * _scale});
            if (result != null) { return result; }
        }
        return fallback;
    }

    function invalidate() {
        _dirty = true;
        WatchUi.requestUpdate();
    }

    function onShow() { invalidate(); }

    function onEnterSleep() {
        _sleeping = true;
        _dirty = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() {
        _sleeping = false;
        _dirty = true;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        // Display mode is authoritative on this AMOLED target. Sleep callbacks
        // can arrive before/after the mode transition and are only a fallback.
        var awake = !_sleeping;
        if (System has :getDisplayMode) {
            awake = System.getDisplayMode() == System.DISPLAY_MODE_HIGH_POWER;
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (!awake) { return; }
        var now = Time.now();
        var units = Application.Properties.getValue("TemperatureUnits");
        if (units != _units) {
            _units = units;
            _dirty = true;
        }
        _data.refresh(now.value(), _dirty);
        _dirty = false;
        if (dc has :setAntiAlias) { dc.setAntiAlias(true); }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        var time = System.getClockTime();
        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        var dateText = months[date.month - 1] + " " + date.day;

        drawDial(dc);
        drawComplications(dc, dateText);
        drawHands(dc, time.hour, time.min, time.sec);
        dc.setPenWidth(1);
    }

    function drawComplications(dc, dateText) {
        // Three positions down each side, with open space above and below the hands.
        var date = point(227, 227, 125, 90);
        var uv = point(227, 227, 125, 30);
        var temp = point(227, 227, 125, 150);
        var body = point(227, 227, 125, 210);
        var sleep = point(227, 227, 125, 270);
        var steps = point(227, 227, 125, 330);

        // Date is a plain readout at the far right: no circle or window.
        label(dc, date[0], date[1], _dateFont, dateText, WHITE);

        gauge(dc, steps[0], steps[1], SectorMath.progress(_data.steps, _data.stepGoal), STEPS_COLOR);
        label(dc, steps[0], steps[1] - 3, _stepsFont, SectorMath.stepsText(_data.steps), WHITE);
        stepsIcon(dc, steps[0], steps[1] + 28);

        colorScale(dc, uv[0], uv[1], SectorMath.progress(_data.uv, 11), 0, 11, true);
        label(dc, uv[0], uv[1] - 3, _valueFont, SectorMath.numberText(_data.uv), WHITE);
        label(dc, uv[0], uv[1] + 28, _smallFont, "UV", WHITE);

        var fahrenheit = _units == 1 || (_units != 2 && System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE);
        colorScale(dc, temp[0], temp[1], SectorMath.temperatureProgress(_data.temperature, _data.lowTemperature, _data.highTemperature), _data.lowTemperature, _data.highTemperature, false);
        label(dc, temp[0], temp[1] - 3, _valueFont, SectorMath.numberText(SectorMath.temperature(_data.temperature, fahrenheit)), WHITE);
        label(dc, temp[0], temp[1] + 28, _smallFont, fahrenheit ? "°F" : "°C", WHITE);
        // Low/high remain outside the gauge with a clear gap below the unit.
        label(dc, temp[0] - 23, temp[1] + 50, _smallFont, SectorMath.numberText(SectorMath.temperature(_data.lowTemperature, fahrenheit)), WHITE);
        label(dc, temp[0] + 23, temp[1] + 50, _smallFont, SectorMath.numberText(SectorMath.temperature(_data.highTemperature, fahrenheit)), WHITE);

        gauge(dc, sleep[0], sleep[1], SectorMath.progress(_data.sleepScore, 100), SLEEP_COLOR);
        label(dc, sleep[0], sleep[1] - 3, _valueFont, SectorMath.numberText(_data.sleepScore), WHITE);
        moonIcon(dc, sleep[0], sleep[1] + 28);

        gauge(dc, body[0], body[1], SectorMath.progress(_data.bodyBattery, 100), BODY_COLOR);
        label(dc, body[0], body[1] - 3, _valueFont, SectorMath.numberText(_data.bodyBattery), WHITE);
        var bx = body[0]; var by = body[1] + 28;
        polygon(dc, [[bx+2,by-9],[bx-6,by+1],[bx-1,by+1],[bx-3,by+9],[bx+6,by-3],[bx+1,by-3]], WHITE);
    }

    // Coordinate helpers keep the composition proportional on round AMOLED screens.
    function x(value) { return _cx + (value - 227) * _scale; }
    function y(value) { return _cy + (value - 227) * _scale; }
    function point(cx, cy, radius, angle) as [Lang.Numeric, Lang.Numeric] {
        var a = angle * Math.PI / 180.0;
        return [cx + radius * Math.sin(a), cy - radius * Math.cos(a)];
    }
    function color(dc as Graphics.Dc, value) {
        dc.setColor(value, Graphics.COLOR_TRANSPARENT);
    }
    function line(dc, x1, y1, x2, y2, width, value) {
        color(dc, value);
        dc.setPenWidth(width * _scale < 1 ? 1 : width * _scale);
        dc.drawLine(x(x1), y(y1), x(x2), y(y2));
    }
    function polygon(dc, points as Lang.Array<[Lang.Numeric, Lang.Numeric]>, value) {
        var scaled = [];
        for (var i = 0; i < points.size(); i++) { scaled.add([x(points[i][0]), y(points[i][1])]); }
        color(dc, value);
        dc.fillPolygon(scaled);
    }
    function label(dc, cx, cy, face, text, value) {
        color(dc, value);
        dc.drawText(x(cx), y(cy), face, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    function ring(dc, cx, cy, radius, start, sweep, width, value) {
        if (sweep <= 0) { return; }
        color(dc, value);
        dc.setPenWidth(width * _scale < 1 ? 1 : width * _scale);
        if (sweep >= 359.5) {
            dc.drawCircle(x(cx), y(cy), radius * _scale);
        } else {
            // Garmin angles are counterclockwise from 3; design angles clockwise from 12.
            // Guard sub-degree values: equal truncated angles mean a full circle in the API.
            var from = (90 - start).toNumber();
            var to = (90 - start - sweep).toNumber();
            if (from == to) { return; }
            dc.drawArc(x(cx), y(cy), radius * _scale, Graphics.ARC_CLOCKWISE, from, to);
        }
    }

    function drawDial(dc as Graphics.Dc) {
        // Every background pixel stays true AMOLED black. Cardinal numerals sit
        // in the timing track; the other eight hour batons remain prominent.
        for (var i = 0; i < 120; i++) {
            var cardinalOffset = i % 30;
            if (cardinalOffset <= 2 || cardinalOffset >= 28) { continue; }
            var major = i % 10 == 0;
            var minute = i % 2 == 0;
            var start = point(227, 227, major ? 194 : (minute ? 207 : 212), i * 3);
            var end = point(227, 227, 218, i * 3);
            line(dc, start[0], start[1], end[0], end[1], major ? 3.3 : (minute ? 1.5 : 1), WHITE);
        }
        label(dc, 227, 28, _hourFont, "12", WHITE);
        label(dc, 426, 227, _hourFont, "3", WHITE);
        label(dc, 227, 426, _hourFont, "6", WHITE);
        label(dc, 28, 227, _hourFont, "9", WHITE);
    }

    function gaugeTicks(dc, cx, cy) {
        // White scale marks remain outside the colored dial.
        for (var i = 0; i <= 12; i++) {
            var a = point(cx, cy, i % 3 == 0 ? 44 : 45, 225 + i * 22.5);
            var b = point(cx, cy, 47, 225 + i * 22.5);
            line(dc, a[0], a[1], b[0], b[1], 1, WHITE);
        }
    }

    function gauge(dc, cx, cy, progress, accent) {
        gaugeTicks(dc, cx, cy);
        ring(dc, cx, cy, 39, 225, 270, 4, TRACK);
        if (progress != null) { ring(dc, cx, cy, 39, 225, 270 * progress, 4, accent); }
    }

    function colorScale(dc, cx, cy, progress, low, high, isUv) {
        gaugeTicks(dc, cx, cy);
        if (progress == null || low == null || high == null || high <= low) {
            ring(dc, cx, cy, 39, 225, 270, 4.5, TRACK);
            return;
        }
        // Each segment is colored by its actual value. Temperature bounds
        // are today's low/high; UV retains its fixed 0–11 scale.
        for (var i = 0; i < 45; i++) {
            var value = low + (high - low) * (i + 0.5) / 45.0;
            var shade = isUv ? SectorMath.uvColor(value) : SectorMath.temperatureColor(value);
            ring(dc, cx, cy, 39, 225 + i * 6, i == 44 ? 6 : 7, 4.5, shade);
        }
        // High-contrast sliding indicator remains visible at either endpoint.
        var marker = point(cx, cy, 39, 225 + 270 * progress);
        color(dc, Graphics.COLOR_BLACK); dc.fillCircle(x(marker[0]), y(marker[1]), 5.5 * _scale);
        color(dc, WHITE); dc.fillCircle(x(marker[0]), y(marker[1]), 3.5 * _scale);
    }

    function stepsIcon(dc, cx, cy) {
        color(dc, WHITE);
        dc.fillEllipse(x(cx - 6), y(cy + 2), 3 * _scale, 5 * _scale);
        dc.fillEllipse(x(cx + 3), y(cy - 3), 3 * _scale, 5 * _scale);
        dc.fillCircle(x(cx - 6), y(cy - 6), 2 * _scale);
        dc.fillCircle(x(cx + 3), y(cy - 11), 2 * _scale);
    }

    function moonIcon(dc, cx, cy) {
        color(dc, WHITE); dc.fillCircle(x(cx), y(cy), 8 * _scale);
        color(dc, Graphics.COLOR_BLACK); dc.fillCircle(x(cx + 4), y(cy - 3), 7 * _scale);
    }

    function handPolygon(dc, local as Lang.Array<[Lang.Numeric, Lang.Numeric]>, angle, value) {
        var a = angle * Math.PI / 180.0;
        var c = Math.cos(a);
        var s = Math.sin(a);
        var points = [];
        for (var i = 0; i < local.size(); i++) {
            points.add([227 + local[i][0] * c - local[i][1] * s, 227 + local[i][0] * s + local[i][1] * c]);
        }
        polygon(dc, points, value);
    }

    function drawHand(dc, angle, length, halfWidth) {
        // Crisp white hands with a black center facet and black separation edge.
        handPolygon(dc, [[-halfWidth-1,10],[-halfWidth-2,-25],[0,-length-2],[halfWidth+2,-25],[halfWidth+1,10]], angle, Graphics.COLOR_BLACK);
        handPolygon(dc, [[-halfWidth,8],[-halfWidth,-25],[0,-length],[halfWidth,-25],[halfWidth,8]], angle, WHITE);
        handPolygon(dc, [[-0.8,-25],[0,-length+16],[0.8,-25]], angle, Graphics.COLOR_BLACK);
    }

    function drawHands(dc, hour, minute, second) {
        drawHand(dc, (hour % 12) * 30 + minute * 0.5, 112, 4);
        drawHand(dc, minute * 6 + second * 0.1, 179, 2.8);
        // A straight red seconds needle, without an arrowhead or diamond tail.
        var angle = second * 6;
        var tip = point(227, 227, 210, angle);
        var tail = point(227, 227, -30, angle);
        line(dc, tail[0], tail[1], tip[0], tip[1], 1.5, 0xff4545);
        color(dc, Graphics.COLOR_BLACK); dc.fillCircle(_cx, _cy, 8 * _scale);
        color(dc, WHITE); dc.fillCircle(_cx, _cy, 5 * _scale);
        color(dc, 0xff4545); dc.fillCircle(_cx, _cy, 2 * _scale);
    }
}
