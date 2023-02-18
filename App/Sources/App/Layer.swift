import Quartz

struct Mapping {
  var key: Int64
  var action: ActionType
}

enum ActionType {
  case shellCommand([String])
  case remap(Int64)
}

public struct Layer {
  var activationCommand: [KeyPattern]
  var escapeKeys: [Int64] = [53] // default is escape
  var mappings: [Mapping]

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

public let leftRightCommandOptionLayer = Layer(activationCommand: [.sequence([54])], escapeKeys: [53, 54], mappings: [
  .init(key: 15, action: .shellCommand(["-c", "open -a Finder"])),
  .init(key: 14, action: .shellCommand(["-c", "open -a Notes"])),
  .init(key: 13, action: .shellCommand(["-c", "open -a Simulator"])),
  .init(key: 12, action: .shellCommand(["-c", "open -a Slack"])),
  .init(key: 5, action: .shellCommand(["-c", "open -a Things3"])),
  .init(key: 3, action: .shellCommand(["-c", "open -a Xcode_14.2.app"])),
  .init(key: 2, action: .shellCommand(["-c", "open -a 'Visual Studio Code'"])),
  .init(key: 1, action: .shellCommand(["-c", "open -a 'Firefox'"])),
  .init(key: 0, action: .shellCommand(["-c", "open -a Iterm"])),

])

public let controlArrowKeys = Layer(activationCommand: [.sequence([59])], escapeKeys: [59, 53], mappings: [
  .init(key: 38, action: .remap(123)), // n
  .init(key: 40, action: .remap(125)), // e
  .init(key: 37, action: .remap(126)), // i
  .init(key: 41, action: .remap(124)), // o
])

