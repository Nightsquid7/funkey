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
  var _event = event
  LayerController.shared.parse(&_event)
  return Unmanaged.passRetained(_event)

}



public final class LayerController {
  public static var shared: LayerController = LayerController()
  public var currentLayer: Layer?
  var layers: [Layer] = [leftRightCommandOptionLayer]
  var stream: [CGEvent] = []

   func parse(_ event: inout CGEvent) {
     stream.append(event)
     let keycode = event.getIntegerValueField(.keyboardEventKeycode)

     print("\tstream.count \(stream.count)")
     switch currentLayer {
     case .some(let layer):

       guard layer.shouldDeactivate(event) == false else {
         print("deactivate layer")
         currentLayer = nil
         stream = []
         return
       }
       print("\tdo something with event")
       if let mapping = layer.mappings.first(where: { $0.key == keycode }), event.type == .keyDown {
         runScript(mapping.value)
         // FIXME: is there another key code to replace instead of function key?
         event.setIntegerValueField(.keyboardEventKeycode, value: 63)
//         currentLayer = nil
//         stream = []
       }

     case .none:
       layerLoop: for layer in layers  {
         let command = layer.activationCommand
         let commandLength = command
           .map { $0.count }
           .reduce(0, { $0 + $1 })

         guard commandLength <= stream.count else {
           print("\t\(#function):\(#line) commandLength >= stream.count \(stream.count)")
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


         print("set currentLayer: \(layer)")
         currentLayer = layer
         stream = []
       }
     }
  }
}
