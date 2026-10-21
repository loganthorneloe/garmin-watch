import Toybox.ActivityMonitor;
import Toybox.Complications;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.Weather;

class EmberData {
    var steps = null;
    var stepGoal = null;
    var floors = null;
    var floorGoal = null;
    var bodyBattery = null;
    var temperature = null;
    var lowTemperature = null;
    var highTemperature = null;
    var uv = null;
    var _lastRefresh = null;

    function initialize() {}

    function refresh(now, force) {
        if (!force && _lastRefresh != null && now >= _lastRefresh && now - _lastRefresh < 30) {
            return false;
        }
        _lastRefresh = now;
        var activity = ActivityMonitor.getInfo();
        updateActivity(activity);
        bodyBattery = null;
        if (Complications has :COMPLICATION_TYPE_BODY_BATTERY) {
            try {
                var current = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_BODY_BATTERY));
                if (validScore(current.value)) { bodyBattery = current.value; }
            } catch (e instanceof Complications.ComplicationNotFoundException) {
                // Firmware may not provide this complication yet; use valid history.
            }
        }
        if (bodyBattery == null && (SensorHistory has :getBodyBatteryHistory)) {
            var history = SensorHistory.getBodyBatteryHistory({:period => new Time.Duration(7200), :order => SensorHistory.ORDER_NEWEST_FIRST});
            bodyBattery = latestBodyBattery(history, now);
        }

        var weather = null;
        if (Weather has :getCurrentConditions) {
            weather = Weather.getCurrentConditions();
        }
        updateWeather(weather, now);
        return true;
    }

    function updateActivity(activity) {
        steps = activity.steps;
        stepGoal = activity.stepGoal;
        // Clear missing readings, including when the provider changes at midnight.
        floors = null;
        floorGoal = null;
        if ((activity has :floorsClimbed) && activity.floorsClimbed != null && activity.floorsClimbed >= 0) {
            floors = activity.floorsClimbed;
        }
        if ((activity has :floorsClimbedGoal) && activity.floorsClimbedGoal != null && activity.floorsClimbedGoal > 0) {
            floorGoal = activity.floorsClimbedGoal;
        }
    }

    function updateWeather(weather, now) {
        temperature = null;
        lowTemperature = null;
        highTemperature = null;
        uv = null;
        // Show Garmin's latest supplied conditions directly. Garmin owns their
        // freshness; do not discard them using a separate face-level age limit
        // or retain a previous response when the provider reports no weather.
        if (weather == null) { return; }
        temperature = weather.temperature;
        lowTemperature = weather.lowTemperature;
        highTemperature = weather.highTemperature;
        if ((weather has :uvIndex) && weather.uvIndex != null && weather.uvIndex >= 0) {
            uv = weather.uvIndex;
        }
    }
    function validScore(value) {
        return (value instanceof Lang.Number || value instanceof Lang.Float) && value >= 0 && value <= 100;
    }

    function latestBodyBattery(history, now) {
        // Empty samples are common when charging or briefly off-wrist. Skip them,
        // but never substitute a fabricated score or an old day's reading.
        for (var i = 0; i < 120; i++) {
            var sample = history.next();
            if (sample == null) { return null; }
            if (!validScore(sample.data) || sample.when == null) { continue; }
            var age = now - sample.when.value();
            if (age >= -300 && age <= 7200) { return sample.data; }
        }
        return null;
    }

}
