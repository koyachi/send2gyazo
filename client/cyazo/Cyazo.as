// 2008-08-24 t.koyachi
// Cyazo
// capture with webcam and send to gyazo.com
package  {
    import flash.display.*;
    import flash.media.Camera;
    import flash.media.Video;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.events.StatusEvent;
    import flash.events.MouseEvent;
    import flash.events.IOErrorEvent;
    import flash.system.SecurityPanel;
    import flash.system.Security;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import org.buffr.webservice.Send2Gyazo;
    import flash.net.*;

    public class Cyazo extends Sprite {
        private var cam:Camera;
        private var tf:TextField;
        private var t:Timer = new Timer(100);
        private var loading:Array = "\\ | / -".split(' ');
        private var loadingCount:uint = 0;
        private var gyazo:Send2Gyazo = new Send2Gyazo();
        private var w:uint = 640;
        private var h:uint = 480;
        private var video:Video;
        private var msgHeader:String = "[Cyazo] ";
        private var messages:Object = {
            waiting: msgHeader + "click to capture",
            sending: msgHeader + "sending to gyazo.com...",
            done: msgHeader + "done. click to capture",
            error: msgHeader + "IOError",
            camera_not_installed: msgHeader + "No Camera is installed.",
            camera_muted: msgHeader + ["To enable the use of the camera,\n",
                                       "please click on this text field.\n",
                                       "When the Flash Player Setting dialog appears,\n",
                                       "make sure to select the Allow radio button\n",
                                       "to grant access to your camera."].join("")
        };

        public function Cyazo() {
            stage.align = StageAlign.TOP_LEFT;
            var format:TextFormat = new TextFormat();
            format.color = 0x0000FF;
            format.size = 24;
            tf = new TextField();
            tf.defaultTextFormat = format;
            tf.x = 0;
            tf.y = 0;
            tf.background = false;
            tf.selectable = false;
            tf.width = w;
            tf.height = h;

            if (Camera.names.length > 1) {
                Security.showSettings(SecurityPanel.CAMERA);
            }
            cam = Camera.getCamera();
            cam.setMode(w, h, 15);
            if (!cam) {
                tf.text = messages.camera_not_installed;
            }
            else if (cam.muted) {
                tf.text = messages.camera_muted;
                tf.addEventListener(MouseEvent.CLICK, clickHandler);
            }
            else {
                tf.text = "Connecting";
                connectCamera();
            }
            addChild(tf);
            t.addEventListener(TimerEvent.TIMER, timerHandler);
        }

        private function clickHandler(e:MouseEvent):void {
            Security.showSettings(SecurityPanel.PRIVACY);
            cam.addEventListener(StatusEvent.STATUS, statusHandler);
            tf.removeEventListener(MouseEvent.CLICK, clickHandler);
        }

        private function statusHandler(e:StatusEvent):void {
            if (e.code == "Camera.Unmuted") {
                connectCamera();
                cam.removeEventListener(StatusEvent.STATUS, statusHandler);
            }
        }

        private function connectCamera():void {
            w = cam.width;
            h = cam.height;
            video = new Video(w, h);
            video.x = 0;
            video.y = 0;
            video.attachCamera(cam);
            addChild(video);
            tf.text = messages.waiting;
            addEventListener(MouseEvent.CLICK, onClickCapture);
        }

        private function timerHandler(e:TimerEvent):void {
            tf.text = messages.sending + loading[loadingCount];
            if (loadingCount < (loading.length - 1)) {
                loadingCount++;
            }
            else {
                loadingCount = 0;
            }
        }

        private function onClickCapture(e:MouseEvent):void {
            tf.text = messages.sending;
            var bd:BitmapData = new BitmapData(w, h);
            bd.draw(video);
            t.start();
            gyazo.post(bd, function(url:String):void{
                t.stop();
                tf.text = messages.done;
                navigateToURL(new URLRequest(url));
            }, function(e:IOErrorEvent):void{
                t.stop();
                tf.text = messages.error;
            });
        }
    }
}
