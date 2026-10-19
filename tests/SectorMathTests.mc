import Toybox.Test;

(:test)
function testStepGoalBoundaries(logger) {
    Test.assertEqual(SectorMath.progress(0, 10000), 0.0);
    Test.assertEqual(SectorMath.progress(15000, 10000), 1.0);
    Test.assert(SectorMath.progress(100, 0) == null);
    Test.assert(SectorMath.progress(null, 10000) == null);
    Test.assert(SectorMath.progress(100, null) == null);
    Test.assertEqual(SectorMath.progress(-1, 10000), 0.0);
    return true;
}

(:test)
function testTemperatureUnitsAndRange(logger) {
    Test.assertEqual(SectorMath.temperature(20, true), 68);
    Test.assertEqual(SectorMath.temperature(20, false), 20);
    Test.assertEqual(SectorMath.temperature(-40, true), -40);
    Test.assert(SectorMath.temperature(null, true) == null);
    Test.assert(SectorMath.temperatureProgress(10, 10, 10) == null);
    Test.assert(SectorMath.temperatureProgress(10, 20, 0) == null);
    Test.assert(SectorMath.temperatureProgress(null, 0, 20) == null);
    Test.assertEqual(SectorMath.temperatureProgress(10, 0, 20), 0.5);
    Test.assertEqual(SectorMath.temperatureProgress(30, 0, 20), 1.0);
    Test.assertEqual(SectorMath.temperatureProgress(-10, 0, 20), 0.0);
    return true;
}

(:test)
function testReadoutFormatting(logger) {
    Test.assertEqual(SectorMath.stepsText(999), "999");
    Test.assertEqual(SectorMath.stepsText(7842), "7.8k");
    Test.assertEqual(SectorMath.stepsText(9999), "9.9k");
    Test.assertEqual(SectorMath.stepsText(10000), "10.0k");
    Test.assertEqual(SectorMath.stepsText(null), "--");
    Test.assertEqual(SectorMath.numberText(null), "--");
    Test.assertEqual(SectorMath.numberText(0), "0");
    Test.assertEqual(SectorMath.numberText(4.2), "4");
    return true;
}

(:test)
function testColorScaleBoundaries(logger) {
    Test.assertEqual(SectorMath.blendColor(0, 0xffffff, 0), 0);
    Test.assertEqual(SectorMath.blendColor(0, 0xffffff, 1), 0xffffff);
    Test.assertEqual(SectorMath.blendColor(0, 0xffffff, 0.5), 0x808080);
    Test.assertEqual(SectorMath.temperatureColor(-50), 0x747bff);
    Test.assertEqual(SectorMath.temperatureColor(0), 0x40cfff);
    Test.assertEqual(SectorMath.temperatureColor(7), 0x75d98a);
    Test.assertEqual(SectorMath.temperatureColor(17), 0xffc45b);
    Test.assertEqual(SectorMath.temperatureColor(27), 0xff9349);
    Test.assertEqual(SectorMath.temperatureColor(60), 0xff4b4b);
    Test.assertEqual(SectorMath.uvColor(0), 0x6ee7a0);
    Test.assertEqual(SectorMath.uvColor(2), 0x6ee7a0);
    Test.assertEqual(SectorMath.uvColor(3), 0xffd35b);
    Test.assertEqual(SectorMath.uvColor(6), 0xff9349);
    Test.assertEqual(SectorMath.uvColor(8), 0xff4b4b);
    Test.assertEqual(SectorMath.uvColor(11), 0xb78aff);
    Test.assertEqual(SectorMath.uvColor(15), 0xb78aff);
    return true;
}
