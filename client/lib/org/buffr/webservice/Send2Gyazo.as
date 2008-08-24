// 2008-08-24 t.koyachi
// WebService::Gyazo for flash

package  org.buffr.webservice {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;
    import mx.graphics.codec.*;

    public class Send2Gyazo {
        private var encoder:PNGEncoder = new PNGEncoder();
//        private var urlBase:String = "http://localhost:8080"; // debug
        private var urlBase:String = "http://send2gyazo.appspot.com";
        private var loader:URLLoader = new URLLoader();
        private var cb:Function;
        private var eb:Function;

        public function Send2Gyazo() {
            
        }
        public function post(bd:BitmapData, callback:Function, errback:Function):void {
            cb = callback;
            eb = errback;
            var ba:ByteArray = encoder.encode(bd);
            var url:String = urlBase + "/upload";
            var req:URLRequest = new URLRequest(url);
            req.contentType = 'application/octet-stream';
            req.data = ba;
            req.method = URLRequestMethod.POST;
            loader.addEventListener(Event.COMPLETE, onLoadComplete);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            loader.load(req);
        }
        private function onLoadComplete(e:Event):void {
            cb(String(loader.data));
        }
        private function onIOError(e:IOErrorEvent):void {
            eb(e);
        }
    }
}
