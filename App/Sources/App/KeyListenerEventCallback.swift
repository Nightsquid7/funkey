import Combine
import Quartz
import Assets

public func KeyListenerEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {

  var keyCode = event.getIntegerValueField(.keyboardEventKeycode)
  let shift = event.flags.contains(CGEventFlags.maskShift)
  let caps = event.flags.contains(CGEventFlags.maskAlphaShift)
  let command = event.flags.contains(CGEventFlags.maskCommand)
  let control = event.flags.contains(CGEventFlags.maskControl)
  let option = event.flags.contains(CGEventFlags.maskAlternate)
  let function = event.flags.contains(CGEventFlags.maskSecondaryFn)

  var type: String = ""
  switch event.type {
  case .flagsChanged:
    type = ""
  case .keyDown:
    type = "keyDown"
  case .keyUp:
    type = "keyUp"

  case .null:
    type = "null"
  default:
    type = "\(event.type)"
  }

  print("\t\t\(keyCode) \(type) shift \(shift) caps \(caps) cmd \(command) ctrl \(control) alt \(option) function \(function)")
  var _event = event
    // IS there async problem here when
  LayerController.shared.parse(&_event)
  return Unmanaged.passRetained(_event)

}

import AVKit
public var enterLayerPlayer: AVAudioPlayer?
public var exitLayerPlayer: AVAudioPlayer?

public func initPlayer() {
  do {
    enterLayerPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: ascendURL))
    exitLayerPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: descendURL))
  } catch {
      print("error \(error)")
  }
}

public final class LayerController {
  public static var shared: LayerController = LayerController()
  public var currentLayer: Layer?
  var layers: [Layer] = [rightCommandOptionLayer]
    var contexts: [Context] =
    [
        .init(name: .app("Slack"),
              mappings: [
                .init(key: 29,
                      modifiers: [.command],
                      commands:
                        [
                        .shellCommand(.applescript, [send(keyCode: 5,
                                                       modifiers: [.command, .shift],
                                                       to: "Slack")])
                        ]
                     )
              ]
            )
    ]

  var stream: [CGEvent] = []
  var lastDownEvent: CGEvent = .init(keyboardEventSource: nil, virtualKey: .zero, keyDown: false)!
  var lastDownEventCount = 0
   func parse(_ event: inout CGEvent) {
     stream.append(event)

     let keycode = event.getIntegerValueField(.keyboardEventKeycode)

     if event.type == .keyDown {
       print("lastDownEvent code: \(lastDownEvent.getIntegerValueField(.keyboardEventKeycode)),  lastDownEventCount: \(lastDownEventCount)")
       if lastDownEvent.getIntegerValueField(.keyboardEventKeycode) == keycode {
         lastDownEventCount += 1
       } else {
         lastDownEventCount = 0
       }
       lastDownEvent = event
     }

       func run(_ command: CommandType) {
           switch command {
           case .remap(let remappedKey):
               event.setIntegerValueField(.keyboardEventKeycode, value: remappedKey)
               // Should not be hardcoded, should add meta key to remove
               event.flags.remove(.maskControl)
               print("remap \(keycode) to \(remappedKey)")
           case .shellCommand(let path, let command):
               runScript(path, command)  { _ in }
               // Set the value to function key to avoid calling native key command if it exists
               event.setIntegerValueField(.keyboardEventKeycode, value: 63)


           case .closure(let closure):
//               print("run closure... ")
               closure()
               event.setIntegerValueField(.keyboardEventKeycode, value: 63)
           }
       }

     switch currentLayer {
     case .some(let layer):
         func shouldDeactivateCurrentLayer(_ keyCode: Int64) -> Bool {
            return layer.exitKeys.contains(keyCode)
        }

       guard shouldDeactivateCurrentLayer(keycode) == false else {
         print("deactivate layer")
         exitLayerPlayer?.play()
         currentLayer = nil
         stream = []
         return
       }


         func contextMatchesCurrentApplication(_ context: String?) -> Bool {
             if let context = context {
                 return context == NSWorkspace.shared.frontmostApplication?.localizedName
             }
             return true
         }

         if let mapping = layer.mappings.first(where: { contextMatchesCurrentApplication($0.context) && ($0.key == keycode) }), event.type == .keyDown {
             for command in mapping.commands {
              run(command)
          }

         stream = []
         return
       }

     case .none:
         func mappingFlagsMatchEventKey(_ mapping: Mapping) -> Bool {
             return mapping.modifiers
                 .map { event.flags.contains($0.cgEventFlag) }
                 .allSatisfy({ $0 == true })
         }

         if event.type == .keyDown {
             for context in contexts {
                 if case .app(let name) = context.name, name == NSWorkspace.shared.frontmostApplication?.localizedName,
                    let mapping = context.mappings.first(where: { $0.key == keycode } ),
                    mappingFlagsMatchEventKey(mapping) {
                    mapping.commands.forEach {
                        run($0)
                    }
                    stream = []
                    return
                 }
             }
         }
         if let layer = layers.first(where: { $0.activationCommand == keycode }) {
             enterLayerPlayer?.play()
             print("set currentLayer")
             currentLayer = layer
         }
     }
  }
}
