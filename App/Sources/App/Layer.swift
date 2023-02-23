import Quartz

struct Mapping {
  var key: Int64
  var action: ActionType
}

enum ActionType {
  case shellCommand(ScriptPath, [String])
  case remap(Int64)
//  case layer(Layer) // TODO: add layer command
  case closure(() -> Void)
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
  .init(key: 15, action: .shellCommand(.bash, ["open -a Finder"])),
  .init(key: 14, action: .shellCommand(.bash, ["open -a Notes"])),
  .init(key: 13, action: .shellCommand(.bash, ["open -a Simulator"])),
  .init(key: 12, action: .shellCommand(.bash, ["open -a Slack"])),
  .init(key: 5, action: .shellCommand(.bash, ["open -a Things3"])),
  .init(key: 3, action: .shellCommand(.bash, ["open -a Xcode_14.2.app"])),
  .init(key: 2, action: .shellCommand(.bash, ["open -a 'Visual Studio Code'"])),
  .init(key: 1, action: .shellCommand(.bash, ["open -a 'Firefox'"])),
  .init(key: 0, action: .shellCommand(.bash, ["open -a Iterm"])),

  .init(key: 6, action: .closure( { print("location: ", CGPoint.mousePointForScreen()) })),
  .init(key: 9, action: .closure( { SwiftCommand.clickAtPoint(CGPoint(x: 1265, y: 788.863037109375)) } )),
  .init(key: 8, action: .closure( { SwiftCommand.clickAtPoint(CGPoint(x: 1242, y: 785.863037109375)) } )),
  .init(key: 7, action: .closure( { SwiftCommand.clickAtPoint(CGPoint(x: 1145, y: 788.863037109375)) } )),

    .init(key: 32, action: .shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .full))])), // u
    .init(key: 38, action: .shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .bottomHalf))])), // n
  .init(key: 40, action: .shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .topHalf))])), // e
  .init(key: 37, action: .shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .leftHalf))])), // i
  .init(key: 41, action: .shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .rightHalf))])), // o

])

//public let controlArrowKeys = Layer(activationCommand: [.sequence([59])], escapeKeys: [59, 53, 49], mappings: [
//  .init(key: 38, action: .remap(123)), // n
//  .init(key: 40, action: .remap(125)), // e
//  .init(key: 37, action: .remap(126)), // i
//  .init(key: 41, action: .remap(124)), // o
//])

