import Cocoa
import FlutterMacOS

public class WinhookerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler  {

    var keyBoardEventSink: FlutterEventSink?
    var mouseEventSink: FlutterEventSink?
    var keyBoardEventMonitor: EventMonitor?
    var localEventMonitor: LocalEventMonitor?
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "winhooker", binaryMessenger: registrar.messenger)
    let keyBoardEventChannel = FlutterEventChannel(name: "win_tracker_keyboard", binaryMessenger: registrar.messenger)
    let mouseEventChannel = FlutterEventChannel(name: "win_tracker_mouse",binaryMessenger: registrar.messenger)
    keyBoardEventChannel.setStreamHandler(WinhookerPlugin())
    mouseEventChannel.setStreamHandler(WinhookerPlugin())

    let instance = WinhookerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
   public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
         events("onListen event");
        if let argument = arguments as? String {
                   if (argument == "keyBoard_event") {
                       self.keyBoardEventSink = events
                       let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String :  true]
                       let accessEnabled = AXIsProcessTrustedWithOptions(options)
                       if !accessEnabled {
                           print("Access Not Enabled")
                           events("Access Keyboard Filed");
                       }
                       
                       else{
                           print("permission passes")
                           keyBoardEventMonitor = EventMonitor(mask: [.keyUp,.keyDown,.mouseMoved,.leftMouseUp,.rightMouseUp,.rightMouseDown,
                                                                      .rightMouseDragged,.leftMouseDown,.leftMouseDragged,.mouseMoved,.flagsChanged,.cursorUpdate,.scrollWheel, .otherMouseDown,
                                                                      .otherMouseDragged,.otherMouseUp, .mouseEntered,.mouseExited]) {[weak self]event in
                                                                          if let tempEvent = event
                                                                          {
                                                                              if tempEvent.type == NSEvent.EventType.keyUp || tempEvent.type == NSEvent.EventType.keyDown
                                                                              {
                                                                                  let date = Date()
                                                                                  let calendar = Calendar.current
                                                                                  let seconds = calendar.component(.second, from: date)
                                                                                  let hour = calendar.component(.hour, from: date)
                                                                                  let minutes = calendar.component(.minute, from: date)
                                                                                  events("keyboard-\(hour):\(minutes):\(seconds)");
                                                                              }

                                                                              else
                                                                              {

                                                                              }
                                                                          }
                                                                      }
                           keyBoardEventMonitor?.start()
                       }
                   } else if (argument == "mouse_event") {
                       self.mouseEventSink = events
                       let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String :  true]
                       let accessEnabled = AXIsProcessTrustedWithOptions(options)
                       if !accessEnabled {
                           print("Access Not Enabled")
                           events("Access Mouse Filed");
                       }
                       else{
                           print("permission passes")
                           keyBoardEventMonitor = EventMonitor(mask: [.keyUp,.keyDown,.mouseMoved,.leftMouseUp,.rightMouseUp,.rightMouseDown,
                                                                      .rightMouseDragged,.leftMouseDown,.leftMouseDragged,.mouseMoved,.flagsChanged,.cursorUpdate,.scrollWheel, .otherMouseDown,
                                                                      .otherMouseDragged,.otherMouseUp, .mouseEntered,.mouseExited]) {[weak self] event in
                                                                          if let tempEvent = event
                                                                          {
                                                                            if tempEvent.type == NSEvent.EventType.leftMouseDown || tempEvent.type == NSEvent.EventType.leftMouseUp || tempEvent.type == NSEvent.EventType.rightMouseDown || tempEvent.type == NSEvent.EventType.rightMouseUp || tempEvent.type == NSEvent.EventType.mouseMoved || tempEvent.type == NSEvent.EventType.leftMouseDragged || tempEvent.type == NSEvent.EventType.rightMouseDragged || tempEvent.type == NSEvent.EventType.mouseEntered || tempEvent.type == NSEvent.EventType.mouseExited || tempEvent.type == NSEvent.EventType.rightMouseDragged || tempEvent.type == NSEvent.EventType.flagsChanged || tempEvent.type == NSEvent.EventType.cursorUpdate || tempEvent.type == NSEvent.EventType.scrollWheel || tempEvent.type == NSEvent.EventType.otherMouseDown || tempEvent.type == NSEvent.EventType.otherMouseUp || tempEvent.type == NSEvent.EventType.scrollWheel || tempEvent.type == NSEvent.EventType.otherMouseDragged
                                                                              {

                                                                                    let date = Date()
                                                                                    let calendar = Calendar.current
                                                                                    let seconds = calendar.component(.second, from: date)
                                                                                    let hour = calendar.component(.hour, from: date)
                                                                                    let minutes = calendar.component(.minute, from: date)
                                                                                    events("mouse-\(hour):\(minutes):\(seconds)");
                                                                              }
                                                                              else
                                                                              {

                                                                              }
                                                                          }
                                                                      }
                           keyBoardEventMonitor?.start()
                       }
                   } else {
                       events("Not Registered");
                       // Unknown stream listener registered
                   }
               }
        return nil
    }
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        WinhookerPlugin().keyBoardEventSink = nil
        WinhookerPlugin().mouseEventSink = nil
        return nil
    }
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
public class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    deinit {
        stop()
    }

    public func start() {
        print("kjbkjbkbj")
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }

    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
public class LocalEventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> NSEvent

    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> NSEvent) {
        self.mask = mask
        self.handler = handler
    }
    deinit {
        stop()
    }

    public func start() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler)
    }

    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }

}
