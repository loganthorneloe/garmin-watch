import Toybox.Graphics;

// Excluded from release and test binaries. These are synthetic display fixtures.
(:preview)
class EmberPreviewView extends EmberView {
    function initialize() { EmberView.initialize(); }
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setAntiAlias(true);
        _units = 1;
        _data.steps = 11200;
        _data.stepGoal = 15000;
        _data.floors = 7;
        _data.floorGoal = 10;
        _data.temperature = 22;
        _data.lowTemperature = 12;
        _data.highTemperature = 26;
        _data.uv = 4;
        _data.bodyBattery = 78;
        render(dc,10,10,20,"SEP 26",false);
    }
}
