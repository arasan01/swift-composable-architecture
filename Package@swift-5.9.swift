// swift-tools-version:5.9

#if !os(Windows)
import CompilerPluginSupport
#endif
import PackageDescription

let package = Package(
  name: "swift-composable-architecture",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "ComposableArchitecture",
      targets: ["ComposableArchitecture"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: "1.0.2"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
    .package(url: "https://github.com/google/swift-benchmark", from: "0.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-perception", from: "1.1.1"),
    .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "1.1.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.1.0"),
    .combineScheduler,
    .openCombine
  ].compactMap({ $0 }),
  targets: [
    .target(
      name: "ComposableArchitecture",
      dependencies: [
        .macros,
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        .product(name: "OrderedCollections", package: "swift-collections"),
        .product(name: "Perception", package: "swift-perception"),
        .product(
          name: "SwiftUINavigationCore",
          package: "swiftui-navigation",
          condition: .when(platforms: [.macOS, .iOS, .tvOS, .macCatalyst, .watchOS])
        ),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        .combineScheduler,
        .openCombine
      ].compactMap({ $0 }),
      exclude: osSpecificComposableArchitectureExcludes()
    ),
    .testTarget(
      name: "ComposableArchitectureTests",
      dependencies: [
        "ComposableArchitecture"
      ]
    ),
    .macros,
    .macrosTests,
    .executableTarget(
      name: "swift-composable-architecture-benchmark",
      dependencies: [
        "ComposableArchitecture",
        .product(name: "Benchmark", package: "swift-benchmark"),
      ]
    ),
  ].compactMap({ $0 })
)

// We have to conditionally declare the open-combine-schedulers code
// (same goes for OpenCombine) so that we don't break binary packaging on macOS
// Windows doesn't have an answer for binary frameworks for Swift
// for the time being.
extension Package.Dependency {
  static var combineScheduler: Package.Dependency {
    #if os(Windows)
    .package(url: "https://github.com/thebrowsercompany/open-combine-schedulers", branch: "main")
    #else
    .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "1.0.0")
    #endif
  }

  static var openCombine: Package.Dependency? {
    #if os(Windows)
    .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.13.0")
    #else
    return nil
    #endif
  }
}

extension Target.Dependency {
  static var combineScheduler: Target.Dependency {
    #if os(Windows)
    .product(
      name: "OpenCombineSchedulers",
      package: "open-combine-schedulers",
      condition: .when(platforms: [.windows])
    )
    #else
    .product(
      name: "CombineSchedulers",
      package: "combine-schedulers",
      condition: .when(platforms: [.macOS, .iOS, .tvOS, .macCatalyst, .watchOS])
    )
    #endif
  }

  static var openCombine: Target.Dependency? {
    #if os(Windows)
    .product(name: "OpenCombine", package: "OpenCombine")
    #else
    nil
    #endif
  }

  static var macros: Target.Dependency? {
    #if os(Windows)
    nil
    #else
    "ComposableArchitectureMacros"
    #endif
  }
}

extension Target {
  static var macros: Target? {
    #if os(Windows)
    nil
    #else
    .macro(
      name: "ComposableArchitectureMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    )
    #endif
  }

  static var macrosTests: Target? {
    #if os(Windows)
    nil
    #else
    .testTarget(
      name: "ComposableArchitectureMacrosTests",
      dependencies: [
        "ComposableArchitectureMacros",
        .product(name: "MacroTesting", package: "swift-macro-testing"),
      ]
    )
    #endif
  }
}

func osSpecificComposableArchitectureExcludes() -> [String] {
#if os(Windows)
    return [
        "SwiftUI",
        "Internal/Deprecations.swift",
    ]
#else
    return []
#endif
}

//for target in package.targets where target.type != .system {
//  target.swiftSettings = target.swiftSettings ?? []
//  target.swiftSettings?.append(
//    .unsafeFlags([
//      "-c", "release",
//      "-emit-module-interface", "-enable-library-evolution",
//      "-Xfrontend", "-warn-concurrency",
//      "-Xfrontend", "-enable-actor-data-race-checks",
//    ])
//  )
//}
