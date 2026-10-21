import Toybox.Test;
import Toybox.Lang;

(:test)
class GaugeRecordingView extends EmberView {
    var arcs as Lang.Array<Lang.Array<Lang.Numeric>>;
    function initialize() { EmberView.initialize(); arcs = []; }
    function gaugeTicks(dc, cx, cy) {}
    function ring(dc, cx, cy, radius, start, sweep, width, value) {
        arcs.add([start, sweep, value]);
    }
}

(:test)
function testBodyBatteryArcGeometry(logger) {
    var view = new GaugeRecordingView();
    var scores = [0, 50, 100];
    var colors = [0xff4b4b, 0xffc45b, 0x6ee7a0];
    for (var i = 0; i < scores.size(); i++) {
        view.arcs = [];
        view.gauge(null, 227, 333, EmberMath.progress(scores[i], 100));
        Test.assertEqual(view.arcs.size(), 2);
        Test.assertEqual(view.arcs[0][0], 225);
        Test.assertEqual(view.arcs[0][1], 270);
        Test.assertEqual(view.arcs[1][0], 225);
        Test.assertEqual(view.arcs[1][1], scores[i] * 2.7);
        Test.assertEqual(view.arcs[1][2], colors[i]);
    }
    view.arcs = [];
    view.gauge(null, 227, 333, null);
    Test.assertEqual(view.arcs.size(), 1);
    Test.assertEqual(view.arcs[0][1], 270);
    Test.assertEqual(view.arcs[0][2], 0x282828);
    return true;
}

(:test)
function testDailyArcsOppositeStartsAndFill(logger) {
    var left = new GaugeRecordingView();
    var right = new GaugeRecordingView();
    var cases = [null,0.0,0.5,0.7,1.0,1.5];
    var expectedFill = [0.0,0.0,78.0,108.0,156.0,156.0];
    for (var c = 0; c < cases.size(); c++) {
        left.arcs = []; right.arcs = [];
        left.drawDailyProgress(null,cases[c],false);
        right.drawDailyProgress(null,cases[c],true);
        Test.assertEqual(left.arcs.size(),right.arcs.size());
        Test.assertEqual(left.arcs[0][0],332);
        Test.assertEqual(right.arcs[0][0],152);
        var fill = 0.0;
        var tracks = 0;
        for (var i = 0; i < left.arcs.size(); i++) {
            var l = left.arcs[i]; var r = right.arcs[i];
            var offset = l[0] - r[0];
            Test.assert(offset > 179.99 && offset < 180.01);
            Test.assertEqual(l[1],r[1]);
            Test.assertEqual(l[2],r[2]);
            if (r[2] == 0xffffff) { fill += r[1]; }
            else { tracks++; }
        }
        Test.assertEqual(tracks,6);
        Test.assert(fill > expectedFill[c] - 0.01 && fill < expectedFill[c] + 0.01);
    }
    return true;
}
