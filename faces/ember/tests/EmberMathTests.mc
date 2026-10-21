import Toybox.Test;

(:test)
function testStepGoalBoundaries(logger) {
    Test.assertEqual(EmberMath.progress(0, 10000), 0.0);
    Test.assertEqual(EmberMath.progress(15000, 10000), 1.0);
    Test.assert(EmberMath.progress(100, 0) == null);
    Test.assert(EmberMath.progress(null, 10000) == null);
    Test.assert(EmberMath.progress(100, null) == null);
    Test.assertEqual(EmberMath.progress(-1, 10000), 0.0);
    return true;
}

(:test)
function testTemperatureUnitsAndRange(logger) {
    Test.assertEqual(EmberMath.temperature(20, true), 68);
    Test.assertEqual(EmberMath.temperature(20, false), 20);
    Test.assertEqual(EmberMath.temperature(-40, true), -40);
    Test.assert(EmberMath.temperature(null, true) == null);
    Test.assert(EmberMath.temperatureProgress(10, 10, 10) == null);
    Test.assert(EmberMath.temperatureProgress(10, 20, 0) == null);
    Test.assert(EmberMath.temperatureProgress(null, 0, 20) == null);
    Test.assertEqual(EmberMath.temperatureProgress(10, 0, 20), 0.5);
    Test.assertEqual(EmberMath.temperatureProgress(30, 0, 20), 1.0);
    Test.assertEqual(EmberMath.temperatureProgress(-10, 0, 20), 0.0);
    return true;
}

(:test)
function testReadoutFormatting(logger) {
    Test.assertEqual(EmberMath.stepsText(999), "999");
    Test.assertEqual(EmberMath.stepsText(7842), "7.8k");
    Test.assertEqual(EmberMath.stepsText(9999), "9.9k");
    Test.assertEqual(EmberMath.stepsText(10000), "10.0k");
    Test.assertEqual(EmberMath.stepsText(null), "--");
    Test.assertEqual(EmberMath.numberText(null), "--");
    Test.assertEqual(EmberMath.numberText(0), "0");
    Test.assertEqual(EmberMath.numberText(4.2), "4");
    return true;
}

(:test)
function testColorScaleBoundaries(logger) {
    Test.assertEqual(EmberMath.blendColor(0, 0xffffff, 0), 0);
    Test.assertEqual(EmberMath.blendColor(0, 0xffffff, 1), 0xffffff);
    Test.assertEqual(EmberMath.blendColor(0, 0xffffff, 0.5), 0x808080);
    Test.assertEqual(EmberMath.temperatureColor(-50), 0x747bff);
    Test.assertEqual(EmberMath.temperatureColor(0), 0x40cfff);
    Test.assertEqual(EmberMath.temperatureColor(7), 0x75d98a);
    Test.assertEqual(EmberMath.temperatureColor(17), 0xffc45b);
    Test.assertEqual(EmberMath.temperatureColor(27), 0xff9349);
    Test.assertEqual(EmberMath.temperatureColor(60), 0xff4b4b);
    Test.assertEqual(EmberMath.uvColor(0), 0x6ee7a0);
    Test.assertEqual(EmberMath.uvColor(2), 0x6ee7a0);
    Test.assertEqual(EmberMath.uvColor(3), 0xffd35b);
    Test.assertEqual(EmberMath.uvColor(6), 0xff9349);
    Test.assertEqual(EmberMath.uvColor(8), 0xff4b4b);
    Test.assertEqual(EmberMath.uvColor(11), 0xb78aff);
    Test.assertEqual(EmberMath.uvColor(15), 0xb78aff);
    return true;
}
