import SwiftUI

/// Every screen of the gallery. The raw value is the id used by `-demo <id>`.
enum Demo: String, CaseIterable, Identifiable, Hashable {
    case buttons, toggles, text, indicators
    case stacks, scroll, lists, presentation
    case shapes, symbols, animation, gestures
    case charts, map, swiftdata

    var id: String { rawValue }

    var title: String {
        switch self {
        case .buttons: "Buttons & Menus"
        case .toggles: "Toggles & Pickers"
        case .text: "Text & Input"
        case .indicators: "Progress & Gauges"
        case .stacks: "Stacks & Grids"
        case .scroll: "Scroll Views"
        case .lists: "Lists"
        case .presentation: "Sheets & Alerts"
        case .shapes: "Shapes & Materials"
        case .symbols: "SF Symbols"
        case .animation: "Animation"
        case .gestures: "Gestures"
        case .charts: "Swift Charts"
        case .map: "MapKit"
        case .swiftdata: "SwiftData"
        }
    }

    var summary: String {
        switch self {
        case .buttons: "Button styles, roles, menus, ShareLink"
        case .toggles: "Toggle, Picker styles, DatePicker, ColorPicker, Slider, Stepper"
        case .text: "Fonts, Markdown, formatters, TextField, SecureField, TextEditor"
        case .indicators: "ProgressView, Gauge, timers"
        case .stacks: "HStack, VStack, ZStack, Grid, LazyVGrid, ViewThatFits"
        case .scroll: "Paging, snapping, scroll transitions, ScrollViewReader"
        case .lists: "List styles, swipe actions, search, reordering"
        case .presentation: "Sheet detents, popover, alert, confirmation dialog, full screen"
        case .shapes: "Shapes, gradients, Canvas, materials, shadows, masks"
        case .symbols: "Rendering modes, variable values, symbol effects"
        case .animation: "Springs, transitions, matched geometry, phase and keyframe animators"
        case .gestures: "Tap, long press, drag, magnify, rotate"
        case .charts: "Bar, line, area, point and sector marks"
        case .map: "Map, markers, annotations, camera, map styles"
        case .swiftdata: "A persistent @Model to-do list with @Query"
        }
    }

    var symbol: String {
        switch self {
        case .buttons: "button.programmable"
        case .toggles: "switch.2"
        case .text: "textformat"
        case .indicators: "gauge.with.dots.needle.67percent"
        case .stacks: "square.grid.3x3"
        case .scroll: "scroll"
        case .lists: "list.bullet"
        case .presentation: "rectangle.bottomhalf.inset.filled"
        case .shapes: "circle.square"
        case .symbols: "star.square.on.square"
        case .animation: "wand.and.stars"
        case .gestures: "hand.draw"
        case .charts: "chart.bar.xaxis"
        case .map: "map"
        case .swiftdata: "cylinder.split.1x2"
        }
    }

    var color: Color {
        switch self {
        case .buttons, .stacks, .shapes, .charts: .blue
        case .toggles, .scroll, .symbols, .map: .green
        case .text, .lists, .animation, .swiftdata: .orange
        case .indicators, .presentation, .gestures: .purple
        }
    }

    @ViewBuilder var destination: some View {
        switch self {
        case .buttons: ButtonsDemo()
        case .toggles: TogglesDemo()
        case .text: TextDemo()
        case .indicators: IndicatorsDemo()
        case .stacks: StacksDemo()
        case .scroll: ScrollDemo()
        case .lists: ListsDemo()
        case .presentation: PresentationDemo()
        case .shapes: ShapesDemo()
        case .symbols: SymbolsDemo()
        case .animation: AnimationDemo()
        case .gestures: GesturesDemo()
        case .charts: ChartsDemo()
        case .map: MapDemo()
        case .swiftdata: SwiftDataDemo()
        }
    }

    static let sections: [(String, [Demo])] = [
        ("Controls", [.buttons, .toggles, .text, .indicators]),
        ("Layout & Navigation", [.stacks, .scroll, .lists, .presentation]),
        ("Graphics & Motion", [.shapes, .symbols, .animation, .gestures]),
        ("Frameworks", [.charts, .map, .swiftdata]),
    ]
}

struct ContentView: View {
    @State private var path: [Demo] = []
    @State private var query = ""

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(Demo.sections, id: \.0) { section in
                    let demos = section.1.filter(matches)
                    if !demos.isEmpty {
                        Section(section.0) {
                            ForEach(demos) { demo in
                                NavigationLink(value: demo) {
                                    DemoRow(demo: demo)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("SwiftUI Gallery")
            .navigationDestination(for: Demo.self) { demo in
                demo.destination
                    .navigationTitle(demo.title)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .searchable(text: $query, prompt: "Search demos")
            .overlay {
                if Demo.allCases.filter(matches).isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
        }
        .onAppear {
            // Launch with `-demo <id>` to open a demo directly.
            if path.isEmpty, let id = UserDefaults.standard.string(forKey: "demo"), let demo = Demo(rawValue: id) {
                path = [demo]
            }
        }
    }

    private func matches(_ demo: Demo) -> Bool {
        query.isEmpty || demo.title.localizedCaseInsensitiveContains(query) || demo.summary.localizedCaseInsensitiveContains(query)
    }
}

struct DemoRow: View {
    let demo: Demo

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: demo.symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(demo.color.gradient, in: .rect(cornerRadius: 7))
            VStack(alignment: .leading, spacing: 2) {
                Text(demo.title)
                Text(demo.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    ContentView()
}
