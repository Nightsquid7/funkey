import Foundation

var frames: [CGRect] = []
func runScript(_ message: String) {
//  let executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
  let executableURL = URL(fileURLWithPath: "/bin/bash")
  do {
    let process = Process()
    process.executableURL = executableURL
//    process.arguments = ["-e", message]
    process.arguments = ["-c", message]
    
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

              print("rawString \n\(rawString)")
            let splitByComma = rawString
              .split(separator: ",")
              .compactMap { Float($0.trimmingCharacters(in: .whitespaces)) }
              .map { CGFloat($0) }

            guard (splitByComma.count % 4) == 0  else {
                return
            }

            print(splitByComma)
            let frame1 = CGRect(x: splitByComma[0], y: splitByComma[1], width: splitByComma[2], height: splitByComma[3])
            frames.append(frame1)
            if splitByComma.count == 8 {
              let frame2 = CGRect(x: splitByComma[4], y: splitByComma[5], width: splitByComma[6], height: splitByComma[7])
              frames.append(frame2)
            }
          print("frames \(frames)")
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


func moveWindow(rect: CGRect) -> String {
  return """
  tell application "System Events"
    set currentApp to name of first application process whose frontmost is true
    set position of window 1 of application process currentApp to {\(rect.origin.x), \(rect.origin.y)}
    set size of window 1 of application process currentApp to {\(rect.width), \(rect.height)}
  end tell
"""
}

func send(keyCode: Int, to application: String) -> String {
  return """
    tell application "System Events"
        set currentApplication to first process where it is frontmost
        log currentApplication

        tell application "System Events"
            tell process "\(application)"
                set frontmost to true
                key code \(keyCode)
            end tell

        end tell

        delay 0.1
        tell currentApplication to set frontmost to true

    end tell
  """
}

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
  tell application "\(app)" to activate
  """
}
