import Foundation

func getRunningApplications() -> String {
  return """
    tell application "System Events"
        set listOfProcesses to (name of every process where background only is false)
        log listOfProcesses
    end tell
  """
}

// returns output as x, y, width, height
func getAppWindowFrameScript(for appName: String) -> String {
    let appleScriptCode = """
        set targetAppName to "\(appName)"
        set appProcessID to do shell script "pgrep -x " & quoted form of targetAppName
        tell application "System Events"
            tell process targetAppName
                set appWindow to first window
                set appPosition to position of appWindow
                set appSize to size of appWindow
            end tell
        end tell
        return item 1 of appPosition & item 2 of appPosition & item 1 of appSize  & item 2 of appSize
        """

        return appleScriptCode
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
