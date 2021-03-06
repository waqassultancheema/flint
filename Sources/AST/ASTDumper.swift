//
//  ASTDumper.swift
//  flintc
//
//  Created by Franklin Schrans on 1/8/18.
//

import Foundation

/// Prints an AST.
public class ASTDumper {
  var topLevelModule: TopLevelModule
  var indentation = 0
  var output = ""

  public init(topLevelModule: TopLevelModule) {
    self.topLevelModule = topLevelModule
  }

  public func dump() -> String {
    dump(topLevelModule)
    return output
  }

  func writeNode(_ node: String, contents: (() -> ())? = nil) {
    output += String(repeating: " ", count: indentation)
    output += "\(node) (\n"
    indentation += 2
    contents?()
    indentation -= 2
    output += String(repeating: " ", count: indentation)
    output += ")\n"
  }

  func writeLine(_ line: String) {
    output += String(repeating: " ", count: indentation)
    output += line + "\n"
  }

  func dump(_ topLevelModule: TopLevelModule) {
    writeNode("TopLevelModule") {
      for declaration in topLevelModule.declarations {
        self.dump(declaration)
      }
    }
  }

  func dump(_ topLevelDeclaration: TopLevelDeclaration) {
    writeNode("TopLevelDeclaration") {
      switch topLevelDeclaration {
      case .contractDeclaration(let contractDeclaration):
        self.dump(contractDeclaration)
      case .contractBehaviorDeclaration(let contractBehaviorDeclaration):
        self.dump(contractBehaviorDeclaration)
      case .structDeclaration(let structDeclaration):
        self.dump(structDeclaration)
      }
    }
  }

  func dump(_ contractDeclaration: ContractDeclaration) {
    writeNode("ContractDeclaration") {
      self.dump(contractDeclaration.contractToken)
      self.dump(contractDeclaration.identifier)

      for variableDeclaration in contractDeclaration.variableDeclarations {
        self.dump(variableDeclaration)
      }
    }
  }

  func dump(_ contractBehaviorDeclaration: ContractBehaviorDeclaration) {
    writeNode("ContractBehaviorDeclaration") {
      self.dump(contractBehaviorDeclaration.contractIdentifier)
      if let capabilityBinding = contractBehaviorDeclaration.capabilityBinding {
        self.writeLine("capability binding \"\(capabilityBinding.name)\"")
      }
      for callerCapability in contractBehaviorDeclaration.callerCapabilities {
        self.dump(callerCapability)
      }
      for member in contractBehaviorDeclaration.members {
        self.dump(member)
      }
      self.dump(contractBehaviorDeclaration.closeBracketToken)
    }
  }

  func dump(_ structDeclaration: StructDeclaration) {
    writeNode("StructDeclaration") {
      self.dump(structDeclaration.identifier)

      for member in structDeclaration.members {
        self.dump(member)
      }
    }
  }

  func dump(_ structMember: StructMember) {
    switch structMember {
    case .functionDeclaration(let functionDeclaration):
      self.dump(functionDeclaration)
    case .variableDeclaration(let variableDeclaration):
      self.dump(variableDeclaration)
    case .initializerDeclaration(let initializerDeclaration):
      self.dump(initializerDeclaration)
    }
  }

  func dump(_ contractBehaviorMember: ContractBehaviorMember) {
    switch contractBehaviorMember {
    case .functionDeclaration(let functionDeclaration):
      self.dump(functionDeclaration)
    case .initializerDeclaration(let initializerDeclaration):
      self.dump(initializerDeclaration)
    }
  }

  func dump(_ variableDeclaration: VariableDeclaration) {
    writeNode("VariableDeclaration") {
      if let declarationToken = variableDeclaration.declarationToken {
        self.dump(declarationToken)
      }
      self.dump(variableDeclaration.identifier)
      self.dump(variableDeclaration.type)

      if let assignedExpression = variableDeclaration.assignedExpression {
        self.dump(assignedExpression)
      }
    }
  }

  func dump(_ functionDeclaration: FunctionDeclaration) {
    writeNode("FunctionDeclaration") {
      self.dumpNodeContents(functionDeclaration)
    }
  }


  func dump(_ initializerDeclaration: InitializerDeclaration) {
    writeNode("InitializerDeclaration") {
      self.dumpNodeContents(initializerDeclaration.asFunctionDeclaration)
    }
  }

  func dumpNodeContents(_ functionDeclaration: FunctionDeclaration) {
    for attribute in functionDeclaration.attributes {
      self.dump(attribute)
    }

    for modifier in functionDeclaration.modifiers {
      self.dump(modifier)
    }

    self.dump(functionDeclaration.funcToken)

    self.dump(functionDeclaration.identifier)

    for parameter in functionDeclaration.parameters {
      self.dump(parameter)
    }

    self.dump(functionDeclaration.closeBracketToken)

    if let resultType = functionDeclaration.resultType {
      self.writeNode("ResultType") {
        self.dump(resultType)
      }
    }

    for statement in functionDeclaration.body {
      self.dump(statement)
    }
  }

  func dump(_ parameter: Parameter) {
    writeNode("Parameter") {
      if parameter.isImplicit {
        self.writeLine("implicit")
      }
      self.dump(parameter.identifier)
      if parameter.isInout {
        self.writeLine("inout")
      }
      self.dump(parameter.type)
    }
  }

  func dump(_ attribute: Attribute) {
    writeNode("Attribute") {
      self.writeLine("attribute \(attribute.kind.rawValue)")
    }
  }

  func dump(_ typeAnnotation: TypeAnnotation) {
    writeNode("TypeAnnotation") {
      self.dump(typeAnnotation.colonToken)
      self.dump(typeAnnotation.type)
    }
  }

  func dump(_ identifer: Identifier) {
    writeNode("Identifier") {
      self.dump(identifer.identifierToken)
    }
  }

  func dump(_ type: Type) {
    writeNode("Type") {
      self.dump(type.rawType)
      self.writeNode("Generic Arguments") {
        for type in type.genericArguments {
          self.dump(type)
        }
      }
    }
  }

  func dump(_ rawType: Type.RawType) {
    switch rawType {
    case .fixedSizeArrayType(let rawType, size: let size):
      writeNode("FixedSizeArrayType") {
        self.dump(rawType)
        self.writeLine("size \(size)")
      }
    case .arrayType(let rawType):
      writeNode("ArrayType") {
        self.dump(rawType)
      }
    case .dictionaryType(key: let keyType, value: let valueType):
      self.writeNode("DictionaryType") {
        self.dump(keyType)
        self.dump(valueType)
      }
    case .basicType(let rawType):
      writeNode("BasicType") {
        self.dump(rawType)
      }
    case .stdlibType(let type):
      writeLine("Stdlib type \(type.rawValue)")
    case .userDefinedType(let userDefinedType):
      writeLine("user-defined type \(userDefinedType)")
    case .inoutType(let rawType):
      writeNode("inout type") {
        self.dump(rawType)
      }
    case .any:
      writeLine("Any")
    case .errorType:
      writeLine("Flint error type \(rawType.name)")
    }
  }

  func dump(_ builtInType: Type.BasicType) {
    writeLine("built-in type \(builtInType.rawValue)")
  }

  func dump(_ callerCapability: CallerCapability) {
    writeNode("CallerCapability") {
      self.dump(callerCapability.identifier)
    }
  }

  func dump(_ expression: Expression) {
    writeNode("Expression") {
      switch expression {
      case .inoutExpression(let inoutExpression): self.dump(inoutExpression)
      case .binaryExpression(let binaryExpression): self.dump(binaryExpression)
      case .bracketedExpression(let expression): self.dump(expression)
      case .functionCall(let functionCall): self.dump(functionCall)
      case .identifier(let identifier): self.dump(identifier)
      case .literal(let token): self.dump(token)
      case .arrayLiteral(let arrayLiteral): self.dump(arrayLiteral)
      case .dictionaryLiteral(let dictionaryLiteral): self.dump(dictionaryLiteral)
      case .self(let token): self.dump(token)
      case .variableDeclaration(let variableDeclaration): self.dump(variableDeclaration)
      case .subscriptExpression(let subscriptExpression): self.dump(subscriptExpression)
      case .sequence(let expressions): expressions.forEach { self.dump($0) }
      case .rawAssembly(_): fatalError()
      }
    }
  }

  func dump(_ statement: Statement) {
    writeNode("Statement") {
      switch statement {
      case .expression(let expression): self.dump(expression)
      case .returnStatement(let returnStatement): self.dump(returnStatement)
      case .ifStatement(let ifStatement): self.dump(ifStatement)
      }
    }
  }
  
  func dump(_ inoutExpression: InoutExpression) {
    writeNode("InoutExpression") {
      self.dump(inoutExpression.expression)
    }
  }

  func dump(_ binaryExpression: BinaryExpression) {
    writeNode("BinaryExpression") {
      self.dump(binaryExpression.lhs)
      self.dump(binaryExpression.op)
      self.dump(binaryExpression.rhs)
    }
  }

  func dump(_ functionCall: FunctionCall) {
    writeNode("FunctionCall") {
      self.dump(functionCall.identifier)

      for argument in functionCall.arguments {
        self.dump(argument)
      }

      self.dump(functionCall.closeBracketToken)
    }
  }

  func dump(_ subscriptExpression: SubscriptExpression) {
    writeNode("SubscriptExpression") {
      self.dump(subscriptExpression.baseIdentifier)
      self.dump(subscriptExpression.indexExpression)
      self.dump(subscriptExpression.closeSquareBracketToken)
    }
  }

  func dump(_ returnStatement: ReturnStatement) {
    writeNode("ReturnStatement") {
      self.dump(returnStatement.returnToken)

      if let expression = returnStatement.expression {
        self.dump(expression)
      }
    }
  }

  func dump(_ ifStatement: IfStatement) {
    writeNode("IfStatement") {
      self.dump(ifStatement.ifToken)
      self.dump(ifStatement.condition)

      for statement in ifStatement.body {
        self.dump(statement)
      }

      self.writeNode("ElseBlock") {
        for statement in ifStatement.elseBody {
          self.dump(statement)
        }
      }
    }
  }

  func dump(_ token: Token) {
    writeLine("token: \(token.kind.description)")
  }

  func dump(_ arrayLiteral: ArrayLiteral) {
    writeNode("ArrayLiteral") {
      for element in arrayLiteral.elements {
        self.dump(element)
      }
    }
  }

  func dump(_ dictionaryLiteral: DictionaryLiteral) {
    writeNode("DictionaryLiteral") {
      for element in dictionaryLiteral.elements {
        self.dump(element.key)
        self.dump(element.value)
      }
    }
  }
}
