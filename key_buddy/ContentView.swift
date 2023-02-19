import App
import Assets
import SwiftUI

struct ContentView: View {
//  @State var cancellables: Set<AnyCancellable> = []

  @State var eventText: String = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
        }
        .padding()
        .frame(minWidth: 300, minHeight: 300)

        .onAppear() {
          initWindows()
          initPlayer()

          let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)

          guard let eventTap = CGEvent.tapCreate(tap: .cghidEventTap,
                            place: .headInsertEventTap,
                            options: .defaultTap,
                            eventsOfInterest: CGEventMask(eventMask),
                            callback: KeyListenerEventCallback,
                                                 userInfo: nil) else {
            fatalError("could not create event tap")
          }

          let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
          CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
          CGEvent.tapEnable(tap: eventTap, enable: true)
//          CFRunLoopRun()

        }
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
