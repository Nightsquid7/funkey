import Quartz

public struct Layer {
  var activationCommand: [KeyPattern]
  var escapeKeys: [Int64] = [53] // default is escape
  var mappings: [Int64:String]

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
  15: "open -a Finder",
  14: "open -a Notes",
  13: "open -a Simulator",
  12: "open -a Slack",

  3: "open -a Xcode_14.2.app",
  2: "open -a 'Visual Studio Code'",
  1: "open -a 'Firefox'",
  0: "open -a Iterm",
])



