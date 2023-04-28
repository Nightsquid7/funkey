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
  var layers: [Layer] = [leftRightCommandOptionLayer]
  var stream: [CGEvent] = []

   func parse(_ event: inout CGEvent) {
     stream.append(event)
     let keycode = event.getIntegerValueField(.keyboardEventKeycode)

     switch currentLayer {
     case .some(let layer):

       guard layer.shouldDeactivate(event) == false else {
         print("deactivate layer")
         exitLayerPlayer?.play()
         currentLayer = nil
         stream = []
         return
       }

       if let mapping = layer.mappings.first(where: { $0.key == keycode }), event.type == .keyDown {
           for action in mapping.actions {
               switch action {
               case .remap(let remappedKey):
                   event.setIntegerValueField(.keyboardEventKeycode, value: remappedKey)
                   event.flags.remove(.maskControl)
                   print("remap \(mapping.key) to \(remappedKey)")
               case .shellCommand(let path, let command):
                   runScript(path, command)
                   // Set the value to function key to avoid calling native key command if it exists
                   event.setIntegerValueField(.keyboardEventKeycode, value: 63)

               case .closure(let closure):
                   print("run closure... ")
                   closure()
                   event.setIntegerValueField(.keyboardEventKeycode, value: 63)
               }
           }

         stream = []
         return
       }

     case .none:
       layerLoop: for layer in layers  {
         let command = layer.activationCommand
         let commandLength = command
           .map { $0.count }
           .reduce(0, { $0 + $1 })

         guard commandLength <= stream.count else {
//           print("\t\(#function):\(#line) commandLength >= stream.count \(stream.count)")
           continue layerLoop
         }

         var nextStreamIndex = stream.count - 1
         sequenceLoop: for sequence in command.reversed() {
           switch sequence {
           case .sequence(let sequence):
             let sequenceStartIndex = nextStreamIndex - (sequence.count - 1)

             let streamSequence = stream[sequenceStartIndex...nextStreamIndex]
               .map { $0.getIntegerValueField(.keyboardEventKeycode)}
             guard sequence == streamSequence else {
               continue layerLoop
             }
             nextStreamIndex -= sequence.count

           case .combination(let combination):
             var sequenceStartIndex = nextStreamIndex - combination.count
             if sequenceStartIndex < stream.count { sequenceStartIndex = stream.count - 1 }
             let streamSequence = stream[sequenceStartIndex...nextStreamIndex]
             //            .filter { $0.type == .keyDown }
               .map { $0.getIntegerValueField(.keyboardEventKeycode)}

             guard Set(combination) == Set(streamSequence) else {
               continue layerLoop
             }

             nextStreamIndex -= combination.count
           }
         }


         print("set currentLayer")
         enterLayerPlayer?.play()
         currentLayer = layer
         stream = []

       }
     }
  }
}
