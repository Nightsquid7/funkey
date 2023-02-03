import Combine
import Quartz

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
  LayerController.shared.parse(event)
  return Unmanaged.passRetained(event)

}



public final class LayerController {
  public static var shared: LayerController = LayerController()
  public var currentLayer: Layer?
  var layers: [Layer] = [commandOptionControlComboLayer, leftRightCommandOptionLayer]
  var stream: [CGEvent] = []

   func parse(_ event: CGEvent) {
     stream.append(event)
     print("stream.count \(stream.count)")
     switch currentLayer {
     case .some(let layer):

       guard layer.shouldDeactivate(event) == false else {
         print("deactivate layer")
         currentLayer = nil
         stream = []
         return
       }
       print("do something with event")

     case .none:
       layerLoop: for layer in layers  {
         let command = layer.activationCommand
         let commandLength = command
           .map { $0.count }
           .reduce(0, { $0 + $1 })

         guard commandLength <= stream.count else {
           print("\(#function):\(#line) commandLength >= stream.count \(stream.count)")
           continue layerLoop
         }

         var nextStreamIndex = stream.count - 1
         sequenceLoop: for sequence in command.reversed() {
           switch sequence {
           case .sequence(let sequence):
             var sequenceStartIndex = nextStreamIndex - (sequence.count - 1)

             let streamSequence = stream[sequenceStartIndex...nextStreamIndex]
               .map { $0.getIntegerValueField(.keyboardEventKeycode)}
//             print("layerSequence \(sequence) Stream sequence \(streamSequence) \(stream.last!.getIntegerValueField(.keyboardEventKeycode             ))")
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


         print("set currentLayer: \(layer)")
         currentLayer = layer
         stream = []
       }
     }
  }
}

public struct Layer {
  var activationCommand: [KeyPattern]
  var escapeKeys: [Int64] = [53] // default is escape
  var mappings: [Int:String]

  func shouldDeactivate(_ event: CGEvent) -> Bool {
    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
    if escapeKeys.contains(keyCode) {
      for key in escapeKeys {
        switch key {
        case 63:
          // false fo key down event..
          return event.flags.contains(.maskSecondaryFn) == false
        default:
          return true
        }
      }

    }
    return false
  }
}


public let commandOptionControlComboLayer = Layer(activationCommand: [.sequence([55])], escapeKeys: [53], mappings: [:])
public let leftRightCommandOptionLayer = Layer(activationCommand: [.sequence([54, 58])], escapeKeys: [53], mappings: [:])


enum KeyPattern {
  case sequence([Int64])
  case combination([Int64])

  var count: Int {
  switch self {
    case .sequence(let values):
      return values.count
    case .combination(let values):
      return values.count
    }
  }
}


struct ModifierFlags {

}
