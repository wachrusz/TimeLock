//
//  Logger.swift
//  TimeLock
//
//  Created by Misha Vakhrushin on 22.04.2025.
//

import Foundation

final class Logger {
    static let shared = Logger()

    private init() {}

    enum LogLevel: String {
        case debug = "💚 DEBUG"
        case info = "💙 INFO"
        case warning = "💛 WARNING"
        case error = "❤️ ERROR"
    }

    func log(_ message: @autoclosure () -> String,
             level: LogLevel = .debug,
             file: String = #file,
             function: String = #function,
             line: Int = #line) {
#if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.loggerDateFormatter.string(from: Date())
        print("[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(function) -> \(message())")
#endif
    }
}

private extension DateFormatter {
    static let loggerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}
