import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class EmberView extends WatchUi.WatchFace {
    var _data;
    var _scale = 1.0;
    var _cx = 227.0;
    var _cy = 227.0;
    var _sleeping = false;
    var _dirty = true;
    var _units = -1;
    var _textFont;
    var _timeFont;
    var _valueFont;
    var _stepsFont;
    const WHITE = 0xffffff;
    const DIM_WHITE = 0x777777;
    const TRACK = 0x282828;
    const SCALE_START = 225;
    const SCALE_SWEEP = 270;

    function initialize() {
        WatchFace.initialize();
        _data = new EmberData();
    }
    function font(size, fallback) {
        if (Graphics has :getVectorFont) {
            var f = Graphics.getVectorFont({:face => ["RobotoCondensedRegular", "RobotoRegular"], :size => size * _scale});
            if (f != null) { return f; }
        }
        return fallback;
    }
    function onLayout(dc) {
        _scale = (dc.getWidth() < dc.getHeight() ? dc.getWidth() : dc.getHeight()) / 454.0;
        _cx = dc.getWidth() / 2.0;
        _cy = dc.getHeight() / 2.0;
        _textFont = font(38, Graphics.FONT_SMALL);
        _timeFont = font(61, Graphics.FONT_NUMBER_MEDIUM);
        _valueFont = font(46, Graphics.FONT_MEDIUM);
        _stepsFont = font(26, Graphics.FONT_XTINY);
        _dirty = true;
    }
    function invalidate() { _dirty = true; WatchUi.requestUpdate(); }
    function onShow() { invalidate(); }
    function onEnterSleep() { _sleeping = true; invalidate(); }
    function onExitSleep() { _sleeping = false; invalidate(); }
    function onUpdate(dc) {
        var awake = !_sleeping;
        if (System has :getDisplayMode) { awake = System.getDisplayMode() == System.DISPLAY_MODE_HIGH_POWER; }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (!awake) { return; }
        var now = Time.now();
        var units = Application.Properties.getValue("TemperatureUnits");
        if (units != _units) { _units = units; _dirty = true; }
        _data.refresh(now.value(), _dirty);
        _dirty = false;
        if (dc has :setAntiAlias) { dc.setAntiAlias(true); }
        var clock = System.getClockTime();
        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        render(dc, clock.hour, clock.min, clock.sec, months[date.month - 1] + " " + date.day, System.getDeviceSettings().is24Hour);
    }
    // Shared by the real watch face and simulator-only visual tests.
    function render(dc, hour, minute, second, dateText, is24Hour) {
        drawDial(dc);
        drawDigitalTime(dc, hour, minute, is24Hour);
        label(dc, 227, 153, _textFont, dateText, WHITE);
        drawComplications(dc);
        drawHands(dc, hour, minute, second);
        dc.setPenWidth(1);
    }
    function drawDigitalTime(dc, hour, minute, is24Hour) {
        var h = is24Hour ? hour : (hour % 12 == 0 ? 12 : hour % 12);
        var hh = h.format("%02d");
        var mm = minute.format("%02d");
        var hw = dc.getTextWidthInPixels(hh, _timeFont) / _scale;
        var mw = dc.getTextWidthInPixels(mm, _timeFont) / _scale;
        var start = 227 - (hw + mw + 6) / 2.0;
        label(dc, start + hw/2, 108, _timeFont, hh, WHITE);
        var mx = start + hw + 6 + mw/2;
        for (var i = 0; i < 8; i++) {
            var p = point(mx, 108, 1.2, i * 45);
            label(dc, p[0], p[1], _timeFont, mm, WHITE);
        }
        label(dc, mx, 108, _timeFont, mm, Graphics.COLOR_BLACK);
    }
    function drawDial(dc) {
        // Fine neutral chapter ring, inside the physical watch bezel.
        for (var i = 0; i < 120; i++) {
            if (i % 40 <= 2 || i % 40 >= 38) { continue; }
            var p = point(227,227,i % 10 == 0 ? 214 : 218,i*3);
            var q = point(227,227,223,i*3);
            line(dc,p[0],p[1],q[0],q[1],i % 10 == 0 ? 1.6 : 0.8,0x77777d);
        }
        drawDailyProgress(dc,EmberMath.progress(_data.steps,_data.stepGoal),false);
        drawDailyProgress(dc,EmberMath.progress(_data.floors,_data.floorGoal),true);
        dailyReadout(dc,112,132,EmberMath.stepsText(_data.steps),false);
        dailyReadout(dc,342,322,EmberMath.numberText(_data.floors),true);
    }
    function drawDailyProgress(dc, progress, right) {
        // Steps fill downward from twelve; floors fill upward from six.
        for (var segment = 0; segment < 6; segment++) {
            var start = 2 + segment * 30;
            var end = start + 26;
            ring(dc,227,227,196,(right ? 180 : 360) - end,26,12,TRACK);
            if (progress != null) {
                var filledEnd = 180 * EmberMath.clamp(progress,0.0,1.0);
                if (filledEnd > end) { filledEnd = end; }
                if (filledEnd > start) {
                    ring(dc,227,227,196,(right ? 180 : 360) - filledEnd,filledEnd - start,12,WHITE);
                }
            }
        }
    }
    function dailyReadout(dc,cx,cy,text,floors) {
        var width = dc.getTextWidthInPixels(text,_stepsFont) / _scale;
        var iconX = cx - (width + 8) / 2;
        label(dc,cx + 13,cy,_stepsFont,text,WHITE);
        if (floors) { floorsIcon(dc,iconX,cy); }
        else {
            // Anchor the footprint's visible right edge five units before the text.
            var stepsX = cx + 13 - width / 2 - 5 - 7.7;
            stepsIcon(dc,stepsX,cy - 1.25);
        }
    }
    function floorsIcon(dc,cx,cy) {
        // Three clear stair treads, with the same visual size as the footprints.
        line(dc,cx-9,cy+8,cx-9,cy+2,2,WHITE);
        line(dc,cx-9,cy+2,cx-3,cy+2,2,WHITE);
        line(dc,cx-3,cy+2,cx-3,cy-4,2,WHITE);
        line(dc,cx-3,cy-4,cx+3,cy-4,2,WHITE);
        line(dc,cx+3,cy-4,cx+3,cy-10,2,WHITE);
        line(dc,cx+3,cy-10,cx+9,cy-10,2,WHITE);
    }
    function stepsIcon(dc, cx, cy) {
        // Upright footprints beside the horizontal step count.
        var size = 1.1;
        stepOval(dc,cx,cy,-4.5*size,5*size,2.5*size,4.5*size);
        stepOval(dc,cx,cy,4.5*size,0,2.5*size,4.5*size);
        stepOval(dc,cx,cy,-4.5*size,-3*size,2*size,2*size);
        stepOval(dc,cx,cy,4.5*size,-8*size,2*size,2*size);
    }
    function stepOval(dc, cx, cy, ox, oy, rx, ry) {
        var points = [];
        for (var i = 0; i < 20; i++) {
            var angle = i * Math.PI / 10;
            var px = ox + rx * Math.cos(angle);
            var py = oy + ry * Math.sin(angle);
            points.add([cx + px, cy + py + 1.5]);
        }
        polygon(dc,points,WHITE);
    }
    // All three dials share Sector's lower-left start and lower-right end.
    function gaugeTicks(dc, cx, cy) {
        for (var i = 0; i <= 12; i++) {
            var angle = SCALE_START + i * SCALE_SWEEP / 12.0;
            var a = point(cx, cy, i % 3 == 0 ? 53 : 54, angle);
            var b = point(cx, cy, 56, angle);
            line(dc, a[0], a[1], b[0], b[1], 1, WHITE);
        }
    }
    function gauge(dc,cx,cy,progress) {
        gaugeTicks(dc, cx, cy);
        ring(dc,cx,cy,48,SCALE_START,SCALE_SWEEP,4,TRACK);
        if (progress != null) {
            ring(dc,cx,cy,48,SCALE_START,SCALE_SWEEP * EmberMath.clamp(progress,0.0,1.0),4,EmberMath.bodyBatteryColor(progress * 100));
        }
    }
    function colorScale(dc, cx, cy, progress, low, high, isUv) {
        gaugeTicks(dc, cx, cy);
        if (progress == null || low == null || high == null || high <= low) {
            ring(dc, cx, cy, 48, SCALE_START, SCALE_SWEEP, 4.5, TRACK);
            return;
        }
        // Each segment is colored by its actual value. Temperature bounds
        // are today's low/high; UV retains its fixed 0–11 scale.
        for (var i = 0; i < 45; i++) {
            var value = low + (high - low) * (i + 0.5) / 45.0;
            var shade = isUv ? EmberMath.uvColor(value) : EmberMath.temperatureColor(value);
            ring(dc, cx, cy, 48, SCALE_START + i * 6, i == 44 ? 6 : 7, 4.5, shade);
        }
        // High-contrast sliding indicator remains visible at either endpoint.
        var marker = point(cx, cy, 48, SCALE_START + SCALE_SWEEP * progress);
        color(dc, Graphics.COLOR_BLACK); dc.fillCircle(x(marker[0]), y(marker[1]), 5.5 * _scale);
        color(dc, WHITE); dc.fillCircle(x(marker[0]), y(marker[1]), 3.5 * _scale);
    }

    function thermometerIcon(dc, cx, cy) {
        var size = 1.25;
        color(dc, WHITE);
        dc.setPenWidth(2 * _scale);
        dc.drawRoundedRectangle(x(cx-3*size), y(cy-10*size), 6*size*_scale, 16*size*_scale, 3*size*_scale);
        dc.fillCircle(x(cx), y(cy+7*size), 4*size*_scale);
        line(dc,cx,cy-4*size,cx,cy+7*size,2,WHITE);
    }
    function sunIcon(dc, cx, cy) {
        var size = 1.25;
        color(dc,WHITE); dc.setPenWidth(2*_scale);
        dc.drawCircle(x(cx),y(cy),5*size*_scale);
        for (var i = 0; i < 8; i++) {
            var a = point(cx,cy,8*size,i*45);
            var b = point(cx,cy,11*size,i*45);
            line(dc,a[0],a[1],b[0],b[1],2,WHITE);
        }
    }
    function batteryIcon(dc, cx, cy) {
        polygon(dc,[[cx+3.75,cy-13.75],[cx-10,cy+2.5],[cx-1.25,cy+2.5],[cx-5,cy+13.75],[cx+10,cy-5],[cx+2.5,cy-5]],WHITE);
    }
    function drawComplications(dc) {
        var fahrenheit = _units == 1 || (_units != 2 && System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE);
        colorScale(dc,120,222,EmberMath.temperatureProgress(_data.temperature,_data.lowTemperature,_data.highTemperature),_data.lowTemperature,_data.highTemperature,false);
        thermometerIcon(dc,120,265);
        label(dc,120,222,_valueFont,EmberMath.numberText(EmberMath.temperature(_data.temperature,fahrenheit)),WHITE);
        colorScale(dc,334,222,EmberMath.progress(_data.uv,11),0,11,true);
        sunIcon(dc,334,265);
        label(dc,334,222,_valueFont,EmberMath.numberText(_data.uv),WHITE);
        gauge(dc,227,333,EmberMath.progress(_data.bodyBattery,100));
        batteryIcon(dc,227,376);
        label(dc,227,333,_valueFont,EmberMath.numberText(_data.bodyBattery),WHITE);
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
        // Simple solid batons: slender sides, short pointed tips, no skeletons or caps.
        var root = halfWidth * 0.7;
        handPolygon(dc,[[-root-1.5,5],[-halfWidth-1.5,-length+8],[0,-length-2],[halfWidth+1.5,-length+8],[root+1.5,5]],angle,Graphics.COLOR_BLACK);
        handPolygon(dc,[[-root,3],[-halfWidth,-length+8],[0,-length],[halfWidth,-length+8],[root,3]],angle,WHITE);
    }
    function drawHands(dc, hour, minute, second) {
        drawHand(dc,(hour % 12)*30 + minute*0.5,118,5);
        drawHand(dc,minute*6 + second*0.1,181,3.5);
        var tip = point(227,227,210,second*6);
        var tail = point(227,227,-30,second*6);
        line(dc,tail[0],tail[1],tip[0],tip[1],1.5,WHITE);
        color(dc,Graphics.COLOR_BLACK); dc.fillCircle(_cx,_cy,6*_scale);
        color(dc,WHITE); dc.fillCircle(_cx,_cy,3.5*_scale);
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

}
