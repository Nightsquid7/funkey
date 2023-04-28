import Quartz

struct Mapping {
  var key: Int64
  var actions: [ActionType]
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
    .init(key: 15, actions: [.shellCommand(.bash, ["open -a Finder"])]),
      .init(key: 14, actions: [.shellCommand(.bash, ["open -a Notes"])]),
      .init(key: 13, actions: [.shellCommand(.bash, ["open -a Simulator"])]),
      .init(key: 12, actions: [.shellCommand(.bash, ["open -a Slack"])]),
      .init(key: 5, actions: [.shellCommand(.bash, ["open -a Things3"])]),
      .init(key: 3, actions: [.shellCommand(.bash, ["open -a Xcode_14.2.app"])]),
      .init(key: 2, actions: [.shellCommand(.bash, ["open -a 'Visual Studio Code'"])]),
      .init(key: 1, actions: [.shellCommand(.bash, ["open -a 'Arc'"])]),
      .init(key: 0, actions: [.shellCommand(.bash, ["open -a Iterm"])]),

      .init(key: 6, actions: [.closure( { print("location: ", CGPoint.mousePointForScreen()) })]), // z
      .init(key: 7, actions: [.closure( { SwiftCommand.clickAtPoint(CGPoint(x: 1460.30078125, y: 954.44140625)) } )]), // x
      .init(key: 8, actions: [.closure( { SwiftCommand.clickAtPoint(CGPoint(x: 1483.1953125, y: 958.44140625)) } )]), // c
      .init(key: 9, actions: [  // v
        .shellCommand(.applescript, [goHomeSimulator()]),
        .closure({
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                SwiftCommand.dragUpAtPoint(CGPoint(x: 1325.71484375, y: 444.66796875))
            }
        }),
        .closure( {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                runScript(.bash, ["open -a Xcode_14.2.app"])

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let script = send(keyCode: 15, modifiers: ["command down"], to: "Xcode_14.2.app")
                    print(script)
                    runScript(.applescript, [send(keyCode: 15, modifiers: ["command down"], to: "Xcode_14.2.app")])
                }

            }
        })
      ]),

        .init(key: 32, actions: [.shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .full))])]), // u
        .init(key: 38, actions: [.shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .bottomHalf))])]), // n
      .init(key: 40, actions: [.shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .topHalf))])]), // e
      .init(key: 37, actions: [.shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .leftHalf))])]), // i
      .init(key: 41, actions: [.shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .rightHalf))])]), // o

])

//public let controlArrowKeys = Layer(activationCommand: [.sequence([59])], escapeKeys: [59, 53, 49], mappings: [
//  .init(key: 38, action: .remap(123)), // n
//  .init(key: 40, action: .remap(125)), // e
//  .init(key: 37, action: .remap(126)), // i
//  .init(key: 41, action: .remap(124)), // o
//])

