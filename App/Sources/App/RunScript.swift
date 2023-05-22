import Foundation

var displayRects: [CGRect] = []
var count: Int = 0
public func initWindows() {
  runScript(.applescript, [getScreens()])
}
enum ScriptPath: String {
  case applescript = "/usr/bin/osascript"
  case bash = "/bin/bash"
}

func runScript(_ scriptPath: ScriptPath = .bash, _ arguments: [String]) {
  do {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: scriptPath.rawValue)
    var _arguments: [String] = []
    switch scriptPath {
    case .applescript:
      _arguments.append("-e")
    case .bash:
      _arguments.append("-c")
    }

    process.arguments = _arguments + arguments
    print("process.arguments: \(process.arguments)")
    let outputPipe = Pipe()
    process.standardOutput = outputPipe
    try process.run()
    process.waitUntilExit()
    process.terminationHandler = { process -> Void in
      if let _output = process.standardOutput as? Pipe {

        do {
          guard let data = try _output.fileHandleForReading.readToEnd(),
                let rawString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines) else {
            print("Could not run process~ \(process)")
            return
          }
          // TODO:Move this out of here...
          print("rawString \n\(rawString)")
          let splitByComma = rawString
            .split(separator: ",")
            .compactMap { Float($0.trimmingCharacters(in: .whitespaces)) }
            .map { CGFloat($0) }

          guard (splitByComma.count % 4) == 0  else {
            return
          }

          guard count == 0 else {
            return
          }

          print(splitByComma)
          let frame1 = CGRect(x: splitByComma[0], y: splitByComma[1], width: splitByComma[2], height: splitByComma[3])
          displayRects.append(frame1)
          if splitByComma.count == 8 {
            let frame2 = CGRect(x: splitByComma[4], y: splitByComma[5], width: splitByComma[6], height: splitByComma[7])
            displayRects.append(frame2)
          }
          print("displayRects \(displayRects)")
          count = 1
        } catch {
          print("error \(error.localizedDescription)")
        }

      }
    }

  } catch {
    print("error \(error.localizedDescription)")
  }
}



func getRunningApplications() -> String {
  return """
    tell application "System Events"
        set listOfProcesses to (name of every process where background only is false)
        log listOfProcesses
    end tell
  """
}


func moveWindow(rect: CGRect?) -> String {
  guard let rect = rect else {
    print("dont have rect..")
    return ""
  }
  return """
  tell application "System Events"
    set currentApp to name of first application process whose frontmost is true
    set position of window 1 of application process currentApp to {\(rect.origin.x), \(rect.origin.y)}
    set size of window 1 of application process currentApp to {\(rect.width), \(rect.height)}
  end tell
"""
}

func send(keyCode: Int, modifiers: [Modifier] = [], to application: String) -> String {
    func modifierKeys() -> String {
        if modifiers.count < 1 {
            return ""
        } else {
            let text = "{\(modifiers.map { $0.rawValue + " down"}.joined(separator: ",") )}"
            return text
        }
    }
    return """
    tell application "System Events"
      set currentApplication to first process where it is frontmost

      tell process "\(application)" to set frontmost to true
      tell application "System Events"
          key code \(keyCode) using \(modifierKeys())
      end tell

      tell currentApplication to set frontmost to true

   end tell
  """
}

func goHomeSimulator() -> String {
    return """
tell application "System Events"
        tell process "Simulator" to set frontmost to true
        tell application "System Events"
            key code 4 using {shift down, command down}
            key code 4 using {shift down, command down}
         end tell
end tell
"""
}
//// FIXME: add command modifiers, and array and update above method...
//func send(keyCodes: [Int], modifierKeys: [String], to application: String) -> String {
//    func repeatedKeyCodes(_ keyCodes: [Int]) -> String {
//        var result = [""]
//        var modifierKeys: String = modifierKeys.count > 0 ? " using {\(modifierKeys.joined(separator: ", "))}" : ""
//        for keyCode in keyCodes {
//            result.append("keyCode \(keyCode)\(modifierKeys)")
//        }
//        return result.joined(separator: "\n")
//    }
//    let repeatedKeyCodes = repeatedKeyCodes(keyCodes)
//  return """
//    tell application "System Events"
//        set currentApplication to first process where it is frontmost
//        log currentApplication
//
//        tell application "System Events"
//            tell process "\(application)"
//                set frontmost to true
//                \(repeatedKeyCodes)
//            end tell
//
//        end tell
//
//        delay 0.1
//        tell currentApplication to set frontmost to true
//
//    end tell
//  """
//}

func getScreens() -> String {
  return """
    use AppleScript version "2.4" -- Yosemite (10.10) or later
    use framework "Foundation"
    use framework "AppKit"

    set screensList to {}
    set allScreens to current application's NSScreen's screens() as list
    repeat with screen in allScreens
      set aFrame to screen's frame()
      set pixelFrame to (screen's convertRectToBacking:aFrame)
      set contents of screen to {current application's NSWidth(pixelFrame), current application's NSHeight(pixelFrame)}
      set width to current application's NSWidth(pixelFrame)
      set height to current application's NSHeight(pixelFrame)
      log width & height
      set end of screensList to aFrame
    end repeat
  return screensList
  """
}

func focusApp(app: String) -> String {
  return """
  do shell script "open -a \(app)"

  delay 0.3
    tell application "System Events"
            key code 125
            key code 126
        end tell

    end tell
  """
}

func click(point: CGPoint) -> String {
  return """
tell application "System Events"
  click at {\(point.x), \(point.y)}
end tell

"""
}

import Quartz
enum SwiftCommand {
    static func clickAtPoint(_ location: CGPoint) {
        // Single mouse click.
        var e = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: location, mouseButton: .left)!
        e.post(tap: .cghidEventTap)

        e = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: location, mouseButton: .left)!
        e.post(tap: .cghidEventTap)
    }

    static func dragUpAtPoint(_ location: CGPoint) {
      var e = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: location, mouseButton: .left)!
      e.post(tap: .cghidEventTap)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var newLocation = location
            newLocation.y -= 100
            e = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: newLocation, mouseButton: .left)!
            e.post(tap: .cghidEventTap)

            e = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: newLocation, mouseButton: .left)!
            e.post(tap: .cghidEventTap)
        }

    }
}

extension CGPoint {
  static func mousePointForScreen(_ screenIndex: Int = 0) -> CGPoint {
    var ml = NSEvent.mouseLocation
    ml.y = NSHeight(NSScreen.screens[0].frame) - ml.y
    return CGPoint(x: ml.x, y: ml.y)
  }
}
