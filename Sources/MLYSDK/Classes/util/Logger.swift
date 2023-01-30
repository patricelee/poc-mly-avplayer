import Foundation
import Sentry

enum LoggerLevel: Int {
    case TRACE = 1, TRACK = 2, INFO = 3, WARN = 4, DEBUG = 5, ERROR = 6, CRITICAL = 7
}

protocol LoggerHandler {
    var level: LoggerLevel { get set }

    func log(_ level: LoggerLevel, _ message: String?, _ params: LogParams?, _ options: LogOptions?)
}

class LoggerConsole: LoggerHandler {
    var level: LoggerLevel = .DEBUG
    func log(_ level: LoggerLevel, _ message: String? = nil, _ params: LogParams? = nil, _ options: LogOptions? = nil) {
        if level.rawValue < self.level.rawValue { return }
        print(LoggerTool.levelString(level), message ?? "", params ?? "", options ?? "")
    }
}

class Logger {
    static var loggers: [LoggerHandler] = [LoggerConsole()]

    static func trace(_ message: String? = nil, _ params: LogParams? = nil, _ options: LogOptions? = nil) {
        log(LoggerLevel.TRACE, message, params, options)
    }

    static func track(_ message: String? = nil, _ params: LogParams? = nil, _ options: LogOptions? = nil) {
        log(LoggerLevel.TRACK, message, params, options)
    }

    static func debug(_ message: String? = nil, _ params: LogParams? = nil, _ options: LogOptions? = nil) {
        log(LoggerLevel.DEBUG, message, params, options)
    }

    static func info(_ message: String? = nil, _ params: LogParams? = nil, _ options: LogOptions? = nil) {
        log(LoggerLevel.INFO, message, params, options)
    }

    static func warn(_ message: String? = nil, _ params: LogParams? = nil, _ options: LogOptions? = nil) {
        log(LoggerLevel.WARN, message, params, options)
    }

    static func error(_ message: String? = nil, _ params: LogParams? = nil, _ options: LogOptions? = nil) {
        log(LoggerLevel.ERROR, message, params, options)
    }

    static func critical(_ message: String? = nil, _ params: LogParams? = nil, _ options: LogOptions? = nil) {
        log(LoggerLevel.CRITICAL, message, params, options)
    }

    static func log(_ level: LoggerLevel, _ message: String? = nil, _ params: LogParams? = nil, _ options: LogOptions? = nil) {
        for logger in loggers {
            logger.log(level, message, params, options)
        }
    }

    static func error(_ error: Error) {
        Self.error(nil, nil, LogOptions(nil, error))
    }

    static func error(_ message: String, _ error: Error) {
        Self.error(message, nil, LogOptions(nil, error))
    }
}

class LoggerTool {
    static let LOGGER_LEVELS = ["", "TRACE", "TRACK", "INFO", "WARN", "DEBUG", "ERROR", "CRITICAL"]
    static func levelString(_ level: LoggerLevel) -> String {
        return Self.LOGGER_LEVELS[level.rawValue]
    }
}

typealias LogParams = [String: Any]

struct LogOptions: CustomStringConvertible {
    var traceID: String?
    var error: Error?
    var frame: Int?
    var description: String {
        return error?.localizedDescription ?? ""
    }
    init(_ traceID: String? = nil, _ error: Error? = nil, _ frame: Int? = nil) {
        self.traceID = traceID
        self.error = error
        self.frame = frame
    }
}
