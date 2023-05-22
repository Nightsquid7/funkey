import Quartz

struct Context {
    enum `Type` {
        case global
        case app(String)
    }
    // Name of app
    let name: `Type`
    // when app is focused, these key commands are triggered
    let mappings: [Mapping]
}


struct Mapping {
  var key: Int64
  var context: String?
  var commands: [CommandType]
}

enum CommandType {
  case shellCommand(ScriptPath, [String])
  case closure(() -> Void)
  case remap(Int64)
//  case switchLayer(Layer) // TODO: add layer command
}

public struct Layer {
    // for now only activate layer with single key...
  var activationCommand: Int64
  var exitKeys: [Int64] = [53] // default is escape
  var mappings: [Mapping]
}

public let rightCommandOptionLayer = Layer(activationCommand: 54, exitKeys: [53, 54], mappings: [
    .init(key: 46, commands: [.shellCommand(.bash, ["osascript /Users/s-berkowitz/Development/scripting/toggle_mic_googleMeets.applescript"])]),
    .init(key: 17, commands: [.shellCommand(.bash, ["open -a Kaleidoscope"])]),
    .init(key: 15, commands: [.shellCommand(.bash, ["open -a Finder"])]),
      .init(key: 14, commands: [.shellCommand(.bash, ["open -a Notes"])]),
      .init(key: 13, commands: [.shellCommand(.bash, ["open -a Simulator"])]),
      .init(key: 12, commands: [.shellCommand(.bash, ["open -a Slack"])]),
      .init(key: 5, commands: [.shellCommand(.bash, ["open -a Things3"])]),
      .init(key: 3, commands: [.shellCommand(.bash, ["open -a Xcode_14.2.app"])]),
      .init(key: 2, commands: [.shellCommand(.bash, ["open -a 'Visual Studio Code'"])]),
      .init(key: 1, commands: [.shellCommand(.bash, ["open -a 'Arc'"])]),
      .init(key: 0, commands: [.shellCommand(.bash, ["open -a Iterm"])]),

      .init(key: 6, commands: [.closure( { print("location: ", CGPoint.mousePointForScreen()) })]), // z


      .init(key: 7, context: "Arc", commands: [.closure( { SwiftCommand.clickAtPoint(CGPoint(x: 64.6953125, y: 904.35546875)) } )]), // x
      .init(key: 7, commands: [.closure( { SwiftCommand.clickAtPoint(CGPoint(x: 1460.30078125, y: 954.44140625)) } )]), // x
      .init(key: 8, commands: [.closure( { SwiftCommand.clickAtPoint(CGPoint(x: 1483.1953125, y: 958.44140625)) } )]), // c
      .init(key: 9, commands: [  // v
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

        .init(key: 32, commands: [.shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .full))])]), // u
        .init(key: 38, commands: [.shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .bottomHalf))])]), // n
      .init(key: 40, commands: [.shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .topHalf))])]), // e
      .init(key: 37, commands: [.shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .leftHalf))])]), // i
      .init(key: 41, commands: [.shellCommand(.applescript, [moveWindow(rect: displayRects.first?.rect(for: .rightHalf))])]), // o

])

public let controlArrowKeys = Layer(activationCommand: 59, exitKeys: [59, 53, 49], mappings: [
  .init(key: 38, commands: [.remap(123)]), // n
  .init(key: 40, commands: [.remap(125)]), // e
  .init(key: 37, commands: [ .remap(126)]), // i
  .init(key: 41, commands: [.remap(124)]), // o
])

