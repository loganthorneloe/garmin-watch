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
