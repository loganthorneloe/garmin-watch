import Toybox.Application;
import Toybox.WatchUi;

class SectorApp extends Application.AppBase {
    var _view;
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        _view = new SectorView();
        return [_view];
    }

    function onSettingsChanged() {
        if (_view != null) { _view.invalidate(); }
    }

    function onDisplayModeChanged() {
        if (_view != null) { _view.invalidate(); }
    }
}
