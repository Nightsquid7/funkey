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

  print("\(keyCode) \(type) shift \(shift) caps \(caps) cmd \(command) ctrl \(control) alt \(option) function \(function)")


  if LayerController.shared.currentLayer == nil {
    // Parse the event to get layer
    if event.type == .keyDown || event.type == .flagsChanged, let layer = LayerController.shared.parse(event) {
      print("activate layer \(layer)")
      LayerController.shared.currentLayer = layer
      return Unmanaged.passUnretained(event)
    }
  }

  if let layer = LayerController.shared.currentLayer {
    if !layer.escapeKeys.contains(keyCode) && function == false {
      print("do some thing in layer \(layer)")

    } else {
      print("deactivate layer \(layer)")
      LayerController.shared.currentLayer = nil
    }
  }

  return Unmanaged.passUnretained(event)
}

public final class LayerController {
  public static var shared: LayerController = LayerController()
  public var currentLayer: Layer?
  var layers: [Layer] = [functionLayer]
  var stream: [CGEvent] = []

  // need to only parse note on events
  func parse(_ event: CGEvent) -> Layer? {
    stream.append(event)

    commandLoop: for layer in layers  {
      let command = layer.activationCommand
      let commandLength = command
        .map { $0.count }
        .reduce(0, { $0 + $1 })
      print("\(#function):\(#line) command \(command), length: \(commandLength)")
      guard commandLength <= stream.count else {
        print("\(#function):\(#line) commandLength >= stream.count \(stream.count)")
        continue commandLoop
      }

      var commandIndex: Int = commandLength - 1
      while commandIndex > 0 {
        switch command[commandIndex] {
        case .sequence(let sequence):
          let sequenceStartIndex = commandIndex - sequence.count
          let streamSequence = stream[sequenceStartIndex...commandIndex]
            .map { $0.getIntegerValueField(.keyboardEventKeycode)}
          guard sequence == streamSequence else {
            break commandLoop
          }

        case .combination(let combination):
          let sequenceStartIndex = commandIndex - combination.count
          let streamSequence = stream[sequenceStartIndex...commandIndex]
//            .filter { $0.type == .keyDown }
            .map { $0.getIntegerValueField(.keyboardEventKeycode)}

          guard Set(combination) == Set(streamSequence) else {
            break commandLoop
          }
        }

        commandIndex -= command.count
      }
      print("\(#function):\(#line) return layer \(layer)")
      return layer
    }
    print("\(#function):\(#line) return nil")
    return nil
  }
}

public struct Layer {
  var activationCommand: [KeyPattern]
  var escapeKeys: [Int64] = [53] // default is escape
  var mappings: [Int:String]
}


public let functionLayer = Layer(activationCommand: [.sequence([63])], escapeKeys: [63], mappings: [:])

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


