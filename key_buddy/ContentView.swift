import Quartz
import QuartzCore
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear() {
          func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {

            var _keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            var shift = event.flags.contains(CGEventFlags.maskShift)
            var caps = event.flags.contains(CGEventFlags.maskAlphaShift)
            var command = event.flags.contains(CGEventFlags.maskCommand)
            var control = event.flags.contains(CGEventFlags.maskControl)
            var option = event.flags.contains(CGEventFlags.maskAlternate)

            print("\(_keyCode) \(event.type) shift \(shift) caps \(caps) cmd \(command) ctrl \(control) alt \(option)")

              return Unmanaged.passUnretained(event)
          }

          let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)

          guard let eventTap = CGEvent.tapCreate(tap: .cghidEventTap,
                            place: .headInsertEventTap,
                            options: .defaultTap,
                            eventsOfInterest: CGEventMask(eventMask),
                            callback: myCGEventCallback,
                                                 userInfo: nil) else {
            fatalError("could not create event tap")
          }

          let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
          CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
          CGEvent.tapEnable(tap: eventTap, enable: true)
          CFRunLoopRun()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

