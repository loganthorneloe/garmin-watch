import Toybox.Application;
import Toybox.WatchUi;

class EmberApp extends Application.AppBase {
    var _view;
    function initialize() {
        AppBase.initialize();
    }

    (:live)
    function getInitialView() {
        _view = new EmberView();
        return [_view];
    }

    (:preview)
    function getInitialView() {
        _view = new EmberPreviewView();
        return [_view];
    }

    function onSettingsChanged() {
        if (_view != null) { _view.invalidate(); }
    }

    function onDisplayModeChanged() {
        if (_view != null) { _view.invalidate(); }
    }
}
