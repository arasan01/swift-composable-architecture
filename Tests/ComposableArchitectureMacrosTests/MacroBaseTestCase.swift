#if canImport(ComposableArchitectureMacros)
  import ComposableArchitectureMacros
  import MacroTesting
  import SwiftSyntaxMacros
  import SwiftSyntaxMacrosTestSupport
  import XCTest

  class MacroBaseTestCase: XCTestCase {
    override func invokeTest() {
      MacroTesting.withMacroTesting(
        //isRecording: true,
        macros: [
          ObservableStateMacro.self,
          ObservationStateTrackedMacro.self,
          ObservationStateIgnoredMacro.self,
          PresentsMacro.self
        ]
        #if canImport(SwiftUI)
        .append(newElement: ViewActionMacro.self)
        #endif
      ) {
        super.invokeTest()
      }
    }
  }
#endif
