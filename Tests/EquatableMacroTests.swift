// swiftlint:disable all
import EquatableMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

extension Issue {
  @discardableResult static func record(_ failure: TestFailureSpec) -> Self {
    Self.record(
      Comment(rawValue: failure.message),
      sourceLocation: SourceLocation(
        fileID: failure.location.fileID,
        filePath: failure.location.filePath,
        line: failure.location.line,
        column: failure.location.column
      )
    )
  }
}

let macroSpecs = [
  "Equatable": MacroSpec(type: EquatableMacro.self, conformances: ["Equatable"]),
  "EquatableIgnored": MacroSpec(type: EquatableIgnoredMacro.self),
  "EquatableIgnoredUnsafeClosure": MacroSpec(type: EquatableIgnoredUnsafeClosureMacro.self),
]

func failureHander(_ failure: TestFailureSpec) {
  Issue.record(failure)
}

@Suite
struct EquatableMacroTests {
    @Test
    func idIsComparedFirst() async throws {
      assertMacroExpansion(
        """
        @Equatable
        struct Person {
            let name: String
            let lastName: String
            let random: String
            let id: UUID
        }
        """,
        expandedSource:
        """
        struct Person {
            let name: String
            let lastName: String
            let random: String
            let id: UUID
        }
        
        extension Person: Equatable {
            nonisolated public static func == (lhs: Person, rhs: Person) -> Bool {
                lhs.id == rhs.id && lhs.lastName == rhs.lastName && lhs.name == rhs.name && lhs.random == rhs.random
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func basicTypesComparedBeforeComplex() async throws {
      assertMacroExpansion(
        """
        struct NestedType: Equatable {
            let nestedInt: Int
        }
        @Equatable
        struct A {
            let nestedType: NestedType
            let array: [Int]
            let basicInt: Int
            let basicString: String
        }
        """,
        expandedSource:
        """
        struct NestedType: Equatable {
            let nestedInt: Int
        }
        struct A {
            let nestedType: NestedType
            let array: [Int]
            let basicInt: Int
            let basicString: String
        }
        
        extension A: Equatable {
            nonisolated public static func == (lhs: A, rhs: A) -> Bool {
                lhs.basicInt == rhs.basicInt && lhs.basicString == rhs.basicString && lhs.array == rhs.array && lhs.nestedType == rhs.nestedType
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func swiftUIWrappedPropertiesSkipped() async throws {
      assertMacroExpansion(
        """
        @Equatable
        struct TitleView: View {
            @AccessibilityFocusState var accessibilityFocusState: Bool
            @AppStorage("title") var appTitle: String = "App Title"
            @Bindable var bindable = VM()
            @Environment(\\.colorScheme) var colorScheme
            @EnvironmentObject(VM.self) var environmentObject
            @FetchRequest(sortDescriptors: [SortDescriptor(\\.time, order: .reverse)]) var quakes: FetchedResults<Quake>
            @FocusState var isFocused: Bool
            @FocusedObject var focusedObject = FocusModel()
            @FocusedValue(\\.focusedValue) var focusedValue 
            @GestureState private var isDetectingLongPress = false            
            @NSApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
            @Namespace var namespace
            @ObservedObject var anotherViewModel = AnotherViewModel()
            @PhysicalMetric(from: .meters) var twoAndAHalfMeters = 2.5
            @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
            @SceneStorage("title") var title: String = "Default Title"
            @SectionedFetchRequest<String, Quake>(sectionIdentifier: \\.day, sortDescriptors: [SortDescriptor(\\.time, order: .reverse)]) var quakes: SectionedFetchResults<String, Quake>
            @State var dataModel = TitleDataModel()
            @StateObject private var viewModel = TitleViewModel()
            @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
            @WKApplicationDelegateAdaptor var wkApplicationDelegateAdaptor: MyAppDelegate
            @WKExtensionDelegateAdaptor private var extensionDelegate: MyExtensionDelegate
            static let staticInt: Int = 42
            let title: String

            var body: some View {
                Text(title)
            }
        }
        """,
        expandedSource:
        """
        struct TitleView: View {
            @AccessibilityFocusState var accessibilityFocusState: Bool
            @AppStorage("title") var appTitle: String = "App Title"
            @Bindable var bindable = VM()
            @Environment(\\.colorScheme) var colorScheme
            @EnvironmentObject(VM.self) var environmentObject
            @FetchRequest(sortDescriptors: [SortDescriptor(\\.time, order: .reverse)]) var quakes: FetchedResults<Quake>
            @FocusState var isFocused: Bool
            @FocusedObject var focusedObject = FocusModel()
            @FocusedValue(\\.focusedValue) var focusedValue 
            @GestureState private var isDetectingLongPress = false            
            @NSApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
            @Namespace var namespace
            @ObservedObject var anotherViewModel = AnotherViewModel()
            @PhysicalMetric(from: .meters) var twoAndAHalfMeters = 2.5
            @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
            @SceneStorage("title") var title: String = "Default Title"
            @SectionedFetchRequest<String, Quake>(sectionIdentifier: \\.day, sortDescriptors: [SortDescriptor(\\.time, order: .reverse)]) var quakes: SectionedFetchResults<String, Quake>
            @State var dataModel = TitleDataModel()
            @StateObject private var viewModel = TitleViewModel()
            @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
            @WKApplicationDelegateAdaptor var wkApplicationDelegateAdaptor: MyAppDelegate
            @WKExtensionDelegateAdaptor private var extensionDelegate: MyExtensionDelegate
            static let staticInt: Int = 42
            let title: String

            var body: some View {
                Text(title)
            }
        }

        extension TitleView: Equatable {
            nonisolated public static func == (lhs: TitleView, rhs: TitleView) -> Bool {
                lhs.title == rhs.title
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func memberSwiftUIWrappedPropertiesSkipped() async throws {
      assertMacroExpansion(
        """
        @Equatable
        struct TitleView: View {
            @SwiftUI.AccessibilityFocusState var accessibilityFocusState: Bool
            @SwiftUI.AppStorage("title") var appTitle: String = "App Title"
            @SwiftUI.Bindable var bindable = VM()
            @SwiftUI.Environment(\\.colorScheme) var colorScheme
            @SwiftUI.EnvironmentObject(VM.self) var environmentObject
            @SwiftUI.FetchRequest(sortDescriptors: [SortDescriptor(\\.time, order: .reverse)]) var quakes: FetchedResults<Quake>
            @SwiftUI.FocusState var isFocused: Bool
            @SwiftUI.FocusedObject var focusedObject = FocusModel()
            @SwiftUI.FocusedValue(\\.focusedValue) var focusedValue 
            @SwiftUI.GestureState private var isDetectingLongPress = false            
            @SwiftUI.NSApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
            @SwiftUI.Namespace var namespace
            @SwiftUI.ObservedObject var anotherViewModel = AnotherViewModel()
            @SwiftUI.PhysicalMetric(from: .meters) var twoAndAHalfMeters = 2.5
            @SwiftUI.ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
            @SwiftUI.SceneStorage("title") var title: String = "Default Title"
            @SwiftUI.SectionedFetchRequest<String, Quake>(sectionIdentifier: \\.day, sortDescriptors: [SortDescriptor(\\.time, order: .reverse)]) var quakes: SectionedFetchResults<String, Quake>
            @SwiftUI.State var dataModel = TitleDataModel()
            @SwiftUI.StateObject private var viewModel = TitleViewModel()
            @SwiftUI.UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
            @SwiftUI.WKApplicationDelegateAdaptor var wkApplicationDelegateAdaptor: MyAppDelegate
            @SwiftUI.WKExtensionDelegateAdaptor private var extensionDelegate: MyExtensionDelegate
            static let staticInt: Int = 42
            let title: String

            var body: some View {
                Text(title)
            }
        }
        """,
        expandedSource:
        """
        struct TitleView: View {
            @SwiftUI.AccessibilityFocusState var accessibilityFocusState: Bool
            @SwiftUI.AppStorage("title") var appTitle: String = "App Title"
            @SwiftUI.Bindable var bindable = VM()
            @SwiftUI.Environment(\\.colorScheme) var colorScheme
            @SwiftUI.EnvironmentObject(VM.self) var environmentObject
            @SwiftUI.FetchRequest(sortDescriptors: [SortDescriptor(\\.time, order: .reverse)]) var quakes: FetchedResults<Quake>
            @SwiftUI.FocusState var isFocused: Bool
            @SwiftUI.FocusedObject var focusedObject = FocusModel()
            @SwiftUI.FocusedValue(\\.focusedValue) var focusedValue 
            @SwiftUI.GestureState private var isDetectingLongPress = false            
            @SwiftUI.NSApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
            @SwiftUI.Namespace var namespace
            @SwiftUI.ObservedObject var anotherViewModel = AnotherViewModel()
            @SwiftUI.PhysicalMetric(from: .meters) var twoAndAHalfMeters = 2.5
            @SwiftUI.ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 10
            @SwiftUI.SceneStorage("title") var title: String = "Default Title"
            @SwiftUI.SectionedFetchRequest<String, Quake>(sectionIdentifier: \\.day, sortDescriptors: [SortDescriptor(\\.time, order: .reverse)]) var quakes: SectionedFetchResults<String, Quake>
            @SwiftUI.State var dataModel = TitleDataModel()
            @SwiftUI.StateObject private var viewModel = TitleViewModel()
            @SwiftUI.UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
            @SwiftUI.WKApplicationDelegateAdaptor var wkApplicationDelegateAdaptor: MyAppDelegate
            @SwiftUI.WKExtensionDelegateAdaptor private var extensionDelegate: MyExtensionDelegate
            static let staticInt: Int = 42
            let title: String

            var body: some View {
                Text(title)
            }
        }

        extension TitleView: Equatable {
            nonisolated public static func == (lhs: TitleView, rhs: TitleView) -> Bool {
                lhs.title == rhs.title
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func markedWithEquatableIgnoredSkipped() async throws{
      assertMacroExpansion(
        """
        @Equatable
        struct BandView: View {
            @EquatableIgnored let year: Int
            let name: String

            var body: some View {
                Text(name)
                    .onTapGesture {
                        onTap()
                    }
            }
        }
        """,
        expandedSource:
        """
        struct BandView: View {
            let year: Int
            let name: String

            var body: some View {
                Text(name)
                    .onTapGesture {
                        onTap()
                    }
            }
        }

        extension BandView: Equatable {
            nonisolated public static func == (lhs: BandView, rhs: BandView) -> Bool {
                lhs.name == rhs.name
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func equatableIgnoredCannotBeAppliedToClosures() async throws {
      assertMacroExpansion(
        """
        struct CustomView: View {
            @EquatableIgnored var closure: (() -> Void)?
            var name: String

            var body: some View {
                Text("CustomView")
            }
        }
        """,
        expandedSource:
        """
        struct CustomView: View {
            var closure: (() -> Void)?
            var name: String

            var body: some View {
                Text("CustomView")
            }
        }
        """,
        diagnostics: [
          DiagnosticSpec(
            message: "@EquatableIgnored cannot be applied to closures",
            line: 2,
            column: 5
          )
        ],
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func equatableIgnoredCannotBeAppliedToBindings() async throws {
      assertMacroExpansion(
        """
        @Equatable
        struct CustomView: View {
            @EquatableIgnored @Binding var name: String
        
            var body: some View {
                Text("CustomView")
            }
        }
        """,
        expandedSource:
        """
        struct CustomView: View {
            @Binding var name: String
        
            var body: some View {
                Text("CustomView")
            }
        }
        
        extension CustomView: Equatable {
            nonisolated public static func == (lhs: CustomView, rhs: CustomView) -> Bool {
                true
            }
        }
        """,
        diagnostics: [
          DiagnosticSpec(
            message: "@EquatableIgnored cannot be applied to @Binding properties",
            line: 3,
            column: 5
          )
        ],
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func equatableIgnoredCannotBeAppliedToFocusedBindings() async throws {
      assertMacroExpansion(
        """
        @Equatable
        struct CustomView: View {
            @EquatableIgnored @FocusedBinding(\\.focusedBinding) var focusedBinding

            var body: some View {
                Text("CustomView")
            }
        }
        """,
        expandedSource:
        """
        struct CustomView: View {
            @FocusedBinding(\\.focusedBinding) var focusedBinding
        
            var body: some View {
                Text("CustomView")
            }
        }
        
        extension CustomView: Equatable {
            nonisolated public static func == (lhs: CustomView, rhs: CustomView) -> Bool {
                true
            }
        }
        """,
        diagnostics: [
          DiagnosticSpec(
            message: "@EquatableIgnored cannot be applied to @FocusedBinding properties",
            line: 3,
            column: 5
          )
        ],
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func arbitaryClosuresNotAllowed() async throws {
      // There is a bug in assertMacro somewhere and it produces the fixit with
      //
      //        @Equatable
      //        struct CustomView: View {
      //            var name: String @EquatableIgnoredUnsafeClosure
      //            let closure: (() -> Void)?
      //
      //            var body: some View {
      //                Text("CustomView")
      //            }
      //        }
      // In reality the fix it works as expected and adds a \n between the @EquatableIgnoredUnsafeClosure and name variable.
      assertMacroExpansion(
        """
        @Equatable
        struct CustomView: View {
            var name: String
            let closure: (() -> Void)?

            var body: some View {
                Text("CustomView")
            }
        }
        """,
        expandedSource:
        """
        struct CustomView: View {
            var name: String
            let closure: (() -> Void)?

            var body: some View {
                Text("CustomView")
            }
        }

        extension CustomView: Equatable {
            nonisolated public static func == (lhs: CustomView, rhs: CustomView) -> Bool {
                lhs.name == rhs.name
            }
        }
        """,
        diagnostics: [
          DiagnosticSpec(
            message: "Arbitary closures are not supported in @Equatable",
            line: 4,
            column: 5,
            fixIts: [
              FixItSpec(message: "Consider marking the closure with@EquatableIgnoredUnsafeClosure if it doesn't effect the view's body output.")
            ]
          )
        ],
        macroSpecs: macroSpecs,
        fixedSource:
        """
        @Equatable
        struct CustomView: View {
            var name: String @EquatableIgnoredUnsafeClosure 
            let closure: (() -> Void)?

            var body: some View {
                Text("CustomView")
            }
        }
        """,
        failureHandler: failureHander
      )
    }

    @Test
    func closuresMarkedWithEquatableIgnoredUnsafeClosure() async throws {
      assertMacroExpansion(
        """
        @Equatable
        struct CustomView: View {
            @EquatableIgnoredUnsafeClosure let closure: (() -> Void)?
            var name: String

            var body: some View {
                Text("CustomView")
            }
        }
        """,
        expandedSource:
        """
        struct CustomView: View {
            let closure: (() -> Void)?
            var name: String

            var body: some View {
                Text("CustomView")
            }
        }

        extension CustomView: Equatable {
            nonisolated public static func == (lhs: CustomView, rhs: CustomView) -> Bool {
                lhs.name == rhs.name
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func noEquatableProperties() async throws {
      assertMacroExpansion(
        """
        @Equatable
        struct NoProperties: View {
            @EquatableIgnoredUnsafeClosure let onTap: () -> Void
        
            var body: some View {
                Text("")
            }
        }
        """,
        expandedSource:
        """
        struct NoProperties: View {
            let onTap: () -> Void

            var body: some View {
                Text("")
            }
        }

        extension NoProperties: Equatable {
            nonisolated public static func == (lhs: NoProperties, rhs: NoProperties) -> Bool {
                true
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func noEquatablePropertiesConformingToHashable() async throws {
      assertMacroExpansion(
        """
        @Equatable
        struct NoProperties: View, Hashable {
            @EquatableIgnoredUnsafeClosure let onTap: () -> Void
        
            var body: some View {
                Text("")
            }
        }
        """,
        expandedSource:
        """
        struct NoProperties: View, Hashable {
            let onTap: () -> Void

            var body: some View {
                Text("")
            }
        }

        extension NoProperties: Equatable {
            nonisolated public static func == (lhs: NoProperties, rhs: NoProperties) -> Bool {
                true
            }
        }

        extension NoProperties {
            nonisolated public func hash(into hasher: inout Hasher) {
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func equatableMacro() async throws {
      assertMacroExpansion(
        """
        struct CustomType: Equatable {
            let name: String
            let lastName: String
            let id: UUID
        }

        class ClassType {}

        extension ClassType: Equatable {
            static func == (lhs: ClassType, rhs: ClassType) -> Bool {
                lhs === rhs
            }
        }

        @Equatable
        struct ContentView: View {
            @State private var count = 0
            let customType: CustomType
            let name: String
            let color: Color
            let id: String
            let hour: Int = 21
            @EquatableIgnored let classType: ClassType
            @EquatableIgnoredUnsafeClosure let onTapOptional: (() -> Void)?
            @EquatableIgnoredUnsafeClosure let onTap: () -> Void


            var body: some View {
                VStack {
                    Text("Hello!")
                        .foregroundColor(color)
                        .onTapGesture {
                            onTapOptional?()
                        }
                }
            }
        }
        """,
        expandedSource:
        """
        struct CustomType: Equatable {
            let name: String
            let lastName: String
            let id: UUID
        }

        class ClassType {}

        extension ClassType: Equatable {
            static func == (lhs: ClassType, rhs: ClassType) -> Bool {
                lhs === rhs
            }
        }
        struct ContentView: View {
            @State private var count = 0
            let customType: CustomType
            let name: String
            let color: Color
            let id: String
            let hour: Int = 21
            let classType: ClassType
            let onTapOptional: (() -> Void)?
            let onTap: () -> Void


            var body: some View {
                VStack {
                    Text("Hello!")
                        .foregroundColor(color)
                        .onTapGesture {
                            onTapOptional?()
                        }
                }
            }
        }

        extension ContentView: Equatable {
            nonisolated public static func == (lhs: ContentView, rhs: ContentView) -> Bool {
                lhs.id == rhs.id && lhs.hour == rhs.hour && lhs.name == rhs.name && lhs.color == rhs.color && lhs.customType == rhs.customType
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func cannotBeAppliedToNonStruct() async throws {
      assertMacroExpansion(
        """
        @Equatable
        class NotAStruct {
            let name: String
        }
        """,
        expandedSource:
        """
        class NotAStruct {
            let name: String
        }
        """,
        diagnostics: [
          DiagnosticSpec(
            message: "@Equatable can only be applied to structs",
            line: 1,
            column: 1
          )
        ],
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func arrayProperties() async throws {
      assertMacroExpansion(
        """
        @Equatable
        struct Person {
            struct NestedType: Equatable {
                let nestedInt: Int
            }
            let name: String
            let first: [Int]
            let second: Array<Int>
            let third: Swift.Array<Int>
            let nestedType: NestedType
        }
        """,
        expandedSource:
        """
        struct Person {
            struct NestedType: Equatable {
                let nestedInt: Int
            }
            let name: String
            let first: [Int]
            let second: Array<Int>
            let third: Swift.Array<Int>
            let nestedType: NestedType
        }

        extension Person: Equatable {
            nonisolated public static func == (lhs: Person, rhs: Person) -> Bool {
                lhs.name == rhs.name && lhs.first == rhs.first && lhs.second == rhs.second && lhs.third == rhs.third && lhs.nestedType == rhs.nestedType
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func dictionaryProperties() async throws {
      assertMacroExpansion(
        """
        @Equatable
        struct Person {
            struct NestedType: Equatable {
                let nestedInt: Int
            }
            let name: String
            let first: [Int:Int]
            let second: Dictionary<Int, Int>
            let third: Swift.Dictionary<Int, Int>
            let nestedType: NestedType
        }
        """,
        expandedSource:
        """
        struct Person {
            struct NestedType: Equatable {
                let nestedInt: Int
            }
            let name: String
            let first: [Int:Int]
            let second: Dictionary<Int, Int>
            let third: Swift.Dictionary<Int, Int>
            let nestedType: NestedType
        }

        extension Person: Equatable {
            nonisolated public static func == (lhs: Person, rhs: Person) -> Bool {
                lhs.name == rhs.name && lhs.first == rhs.first && lhs.second == rhs.second && lhs.third == rhs.third && lhs.nestedType == rhs.nestedType
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }

    @Test
    func testGenerateHashableConformanceWhenTypesConformsToHashable() async throws {
      assertMacroExpansion(
        """
        @Equatable
        struct User: Hashable {
          let id: Int
          @EquatableIgnored
          var name = ""
          @EquatableIgnoredUnsafeClosure
          var onTap: () -> Void
          var age: Int
          var name: String
        }
        """,
        expandedSource:
        """
        struct User: Hashable {
          let id: Int
          var name = ""
          var onTap: () -> Void
          var age: Int
          var name: String
        }

        extension User: Equatable {
            nonisolated public static func == (lhs: User, rhs: User) -> Bool {
                lhs.id == rhs.id && lhs.age == rhs.age && lhs.name == rhs.name
            }
        }

        extension User {
            nonisolated public func hash(into hasher: inout Hasher) {
                hasher.combine(id)
                hasher.combine(age)
                hasher.combine(name)
            }
        }
        """,
        macroSpecs: macroSpecs,
        failureHandler: failureHander
      )
    }
}
// swiftlint:enable all
