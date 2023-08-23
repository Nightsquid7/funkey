import Foundation

var displayRects: [CGRect] = []
var count: Int = 0
public func initWindows() {
    runScript(.applescript, [getScreens()], wantsOutput: true) { result in
        guard case .success(let rawString) = result, let rawString else {
            print("could not get windows: \(result)")
            return
        }
        let splitByComma = rawString
          .split(separator: ",")
          .compactMap {Float($0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines))}
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
        print("displayRects \(displayRects)")
        count = 1
      }
}

enum ScriptPath: String {
  case applescript = "/usr/bin/osascript"
  case bash = "/bin/bash"
}

enum RunScriptError: Error {
    case processPipeError
    case noDataFromFileHandler
    case triedToParseOutputError
}

func asyncRunScript(_ scriptPath: ScriptPath = .bash, _ arguments: [String], wantsOutput: Bool = false) async throws -> String? {
    return try await withCheckedThrowingContinuation { continuation in
        runScript(scriptPath, arguments, wantsOutput: wantsOutput, completion: { result in
            switch result {
            case .success(let string):
                continuation.resume(returning: string)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        })
    }
}

func runScript(_ scriptPath: ScriptPath = .bash, _ arguments: [String], wantsOutput: Bool = false, completion: @escaping (Result<String?, RunScriptError>) -> Void) {
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

        process.terminationHandler = { process in
            guard wantsOutput else {
                completion(.success(nil))
                return
            }

            guard let _output = process.standardOutput as? Pipe else {
                completion(.failure(.processPipeError))
                return
            }

            do {
                guard let data = try _output.fileHandleForReading.readToEnd() else {
                    completion(.failure(.noDataFromFileHandler))
                    return
                }
                completion(.success(String(data: data, encoding: .utf8)))

            } catch {
                print("error parsing string: \(error)")
                completion(.failure(.triedToParseOutputError))
            }
        }
        process.arguments = _arguments + arguments
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        try process.run()
        process.waitUntilExit()
    } catch {
        print("error: \(error)")
    }
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
