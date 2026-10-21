import Toybox.Test;
import Toybox.Lang;
import Toybox.Time;

(:test)
class BodyBatterySample {
    var data;
    var when;
    function initialize(value, timestamp) {
        data = value;
        when = timestamp == null ? null : new Time.Moment(timestamp);
    }
}

(:test)
class BodyBatteryHistory {
    var _samples as Lang.Array<BodyBatterySample>;
    var _index = 0;
    function initialize(samples as Lang.Array<BodyBatterySample>) { _samples = samples; }
    function next() {
        if (_index >= _samples.size()) { return null; }
        var sample = _samples[_index];
        _index++;
        return sample;
    }
}

(:test)
function testBodyBatteryMissingNewestSample(logger) {
    var data = new SectorData();
    var history = new BodyBatteryHistory([
        new BodyBatterySample(null, 100000),
        new BodyBatterySample(-1, 99990),
        new BodyBatterySample(88, 99900),
        new BodyBatterySample(90, 99800)
    ]);
    Test.assertEqual(data.latestBodyBattery(history, 100000), 88);
    return true;
}

(:test)
function testBodyBatteryHistoryValidity(logger) {
    var data = new SectorData();
    Test.assert(data.latestBodyBattery(new BodyBatteryHistory([]), 100000) == null);
    var invalid = new BodyBatteryHistory([
        new BodyBatterySample(101, 99999),
        new BodyBatterySample(80, null),
        new BodyBatterySample(80, 110000),
        new BodyBatterySample(80, 90000)
    ]);
    Test.assert(data.latestBodyBattery(invalid, 100000) == null);
    Test.assertEqual(data.latestBodyBattery(new BodyBatteryHistory([new BodyBatterySample(0, 99999)]), 100000), 0);
    Test.assertEqual(data.latestBodyBattery(new BodyBatteryHistory([new BodyBatterySample(100, 99999)]), 100000), 100);
    Test.assert(!data.validScore("88"));
    Test.assert(!data.validScore(null));
    Test.assert(data.validScore(88.0));
    return true;
}

(:test)
class WeatherSample {
    var temperature;
    var lowTemperature;
    var highTemperature;
    var uvIndex;
    var observationTime;
    function initialize(temp, low, high, uv, timestamp) {
        temperature = temp;
        lowTemperature = low;
        highTemperature = high;
        uvIndex = uv;
        observationTime = timestamp == null ? null : new Time.Moment(timestamp);
    }
}

(:test)
function testWeatherUsesGarminAfterOvernight(logger) {
    var data = new SectorData();
    var weather = new WeatherSample(16.0, 8.0, 17.0, 2.0, 100000);
    data.updateWeather(weather, 100000);
    Test.assertEqual(data.temperature, 16.0);
    data.updateWeather(weather, 132400);
    Test.assertEqual(data.temperature, 16.0);
    Test.assertEqual(data.lowTemperature, 8.0);
    Test.assertEqual(data.highTemperature, 17.0);
    Test.assertEqual(data.uv, 2.0);
    data.updateWeather(new WeatherSample(10.0, 5.0, 20.0, 0.0, 132400), 132400);
    Test.assertEqual(data.temperature, 10.0);
    Test.assertEqual(data.uv, 0.0);
    return true;
}

(:test)
function testWeatherDoesNotReuseUnavailableReadings(logger) {
    var data = new SectorData();
    data.updateWeather(new WeatherSample(0.0, -5.0, 5.0, 0.0, 100000), 100000);
    Test.assertEqual(data.temperature, 0.0);
    Test.assertEqual(data.uv, 0.0);
    data.updateWeather(null, 100030);
    Test.assert(data.temperature == null);
    Test.assert(data.lowTemperature == null);
    Test.assert(data.highTemperature == null);
    Test.assert(data.uv == null);
    return true;
}

(:test)
function testWeatherMissingAndPartialValues(logger) {
    var data = new SectorData();
    data.updateWeather(null, 100000);
    Test.assert(data.temperature == null);
    Test.assert(data.uv == null);
    data.updateWeather(new WeatherSample(12.0, null, null, null, 100000), 100000);
    Test.assertEqual(data.temperature, 12.0);
    Test.assert(data.lowTemperature == null);
    Test.assert(data.uv == null);
    data.updateWeather(new WeatherSample(null, null, null, 0.0, 100000), 100001);
    Test.assert(data.temperature == null);
    Test.assertEqual(data.uv, 0.0);
    return true;
}

(:test)
function testWeatherUsesLatestSuppliedValues(logger) {
    var data = new SectorData();
    data.updateWeather(new WeatherSample(12.0, 8.0, 17.0, 2.0, 100000), 132400);
    Test.assertEqual(data.temperature, 12.0);
    // Re-read each response, even if Garmin's timestamp is unchanged or absent.
    data.updateWeather(new WeatherSample(15.0, 9.0, 20.0, 4.0, 100000), 132430);
    Test.assertEqual(data.temperature, 15.0);
    Test.assertEqual(data.uv, 4.0);
    data.updateWeather(new WeatherSample(16.0, 9.0, 20.0, 5.0, null), 132460);
    Test.assertEqual(data.temperature, 16.0);
    Test.assertEqual(data.uv, 5.0);
    return true;
}
