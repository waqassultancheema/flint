//
//  Diagnostic.swift
//  Diagnostic
//
//  Created by Franklin Schrans on 1/4/18.
//

public struct Diagnostic {
  public enum Severity {
    case warning
    case error
  }

  public var severity: Severity
  public var sourceLocation: SourceLocation?
  public var message: String

  public var isError: Bool {
    return severity == .error
  }

  public init(severity: Severity, sourceLocation: SourceLocation?, message: String) {
    self.severity = severity
    self.sourceLocation = sourceLocation
    self.message = message
  }
}

public struct SourceLocation: Equatable {
  public var line: Int
  public var column: Int
  public var length: Int

  public init(line: Int, column: Int, length: Int) {
    self.line = line
    self.column = column
    self.length = length
  }

  public static func ==(lhs: SourceLocation, rhs: SourceLocation) -> Bool {
    return lhs.line == rhs.line && lhs.column == rhs.column && lhs.length == rhs.length
  }

  public static var dummy: SourceLocation {
    return SourceLocation(line: 0, column: 0, length: 0)
  }
}