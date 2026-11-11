import Charts
import MapKit
import SwiftData
import SwiftUI

// MARK: - Swift Charts

struct Sale: Identifiable {
    let id = UUID()
    let month: String
    let product: String
    let units: Int
}

private let sales: [Sale] = {
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
    let base: [String: [Int]] = ["Phones": [42, 55, 48, 62, 70, 81], "Tablets": [20, 18, 26, 30, 28, 35], "Watches": [12, 16, 22, 19, 27, 31]]
    return base.flatMap { product, values in values.enumerated().map { Sale(month: months[$0.offset], product: product, units: $0.element) } }
}()

struct ChartsDemo: View {
    @State private var kind = 0
    @State private var selectedMonth: String?

    private var totals: [(product: String, units: Int)] {
        Dictionary(grouping: sales, by: \.product).map { ($0.key, $0.value.reduce(0) { $0 + $1.units }) }.sorted { $0.units > $1.units }
    }

    var body: some View {
        Form {
            Section {
                Picker("Chart", selection: $kind) {
                    Text("Bar").tag(0)
                    Text("Line").tag(1)
                    Text("Area").tag(2)
                }
                .pickerStyle(.segmented)
                chart
                    .frame(height: 240)
                    .animation(.smooth, value: kind)
            } header: {
                Text("Units sold per month")
            } footer: {
                Text(selectedMonth.map { m in "\(m): \(sales.filter { $0.month == m }.reduce(0) { $0 + $1.units }) units" } ?? "Drag across the chart to inspect a month.")
            }
            Section("Share of total (SectorMark)") {
                Chart(totals, id: \.product) { item in
                    SectorMark(angle: .value("Units", item.units), innerRadius: .ratio(0.55), angularInset: 2)
                        .foregroundStyle(by: .value("Product", item.product))
                        .cornerRadius(5)
                        .annotation(position: .overlay) {
                            Text("\(item.units)").font(.caption.bold()).foregroundStyle(.white)
                        }
                }
                .frame(height: 220)
            }
            Section("Points with a rule") {
                Chart {
                    ForEach(sales.filter { $0.product == "Phones" }) { sale in
                        PointMark(x: .value("Month", sale.month), y: .value("Units", sale.units))
                            .symbolSize(120)
                    }
                    RuleMark(y: .value("Target", 60))
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .annotation(position: .top, alignment: .leading) { Text("Target 60").font(.caption).foregroundStyle(.red) }
                }
                .frame(height: 180)
            }
        }
    }

    @ViewBuilder private var chart: some View {
        Chart(sales) { sale in
            switch kind {
            case 1:
                LineMark(x: .value("Month", sale.month), y: .value("Units", sale.units))
                    .foregroundStyle(by: .value("Product", sale.product))
                    .symbol(by: .value("Product", sale.product))
                    .interpolationMethod(.catmullRom)
            case 2:
                AreaMark(x: .value("Month", sale.month), y: .value("Units", sale.units))
                    .foregroundStyle(by: .value("Product", sale.product))
                    .interpolationMethod(.catmullRom)
            default:
                BarMark(x: .value("Month", sale.month), y: .value("Units", sale.units))
                    .foregroundStyle(by: .value("Product", sale.product))
            }
            if let selectedMonth {
                RuleMark(x: .value("Month", selectedMonth)).foregroundStyle(.gray.opacity(0.4))
            }
        }
        .chartXSelection(value: $selectedMonth)
    }
}

// MARK: - MapKit

struct Landmark: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let coordinate: CLLocationCoordinate2D
}

private let landmarks = [
    Landmark(name: "Golden Gate Bridge", symbol: "road.lanes", coordinate: .init(latitude: 37.8199, longitude: -122.4783)),
    Landmark(name: "Alcatraz Island", symbol: "building.columns", coordinate: .init(latitude: 37.8270, longitude: -122.4230)),
    Landmark(name: "Golden Gate Park", symbol: "tree", coordinate: .init(latitude: 37.7694, longitude: -122.4862)),
    Landmark(name: "Ferry Building", symbol: "ferry", coordinate: .init(latitude: 37.7955, longitude: -122.3937)),
]

struct MapDemo: View {
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(center: .init(latitude: 37.80, longitude: -122.44), span: .init(latitudeDelta: 0.12, longitudeDelta: 0.12)))
    @State private var style = 0
    @State private var selection: UUID?

    var body: some View {
        Map(position: $position, selection: $selection) {
            ForEach(landmarks) { place in
                Marker(place.name, systemImage: place.symbol, coordinate: place.coordinate)
                    .tint(.orange)
                    .tag(place.id)
            }
            Annotation("Downtown", coordinate: .init(latitude: 37.7880, longitude: -122.4075)) {
                Image(systemName: "star.fill")
                    .padding(8)
                    .background(.yellow.gradient, in: .circle)
                    .foregroundStyle(.white)
            }
            MapPolyline(coordinates: landmarks.map(\.coordinate))
                .stroke(.blue.opacity(0.6), lineWidth: 4)
        }
        .mapStyle(style == 0 ? .standard(elevation: .realistic) : style == 1 ? .imagery(elevation: .realistic) : .hybrid)
        .mapControls {
            MapCompass()
            MapScaleView()
            MapPitchToggle()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                if let place = landmarks.first(where: { $0.id == selection }) {
                    Label(place.name, systemImage: place.symbol).font(.headline)
                }
                Picker("Style", selection: $style) {
                    Text("Standard").tag(0)
                    Text("Satellite").tag(1)
                    Text("Hybrid").tag(2)
                }
                .pickerStyle(.segmented)
                HStack {
                    ForEach(landmarks) { place in
                        Button {
                            withAnimation { position = .camera(MapCamera(centerCoordinate: place.coordinate, distance: 1800, pitch: 60)) }
                            selection = place.id
                        } label: {
                            Image(systemName: place.symbol).frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
        }
    }
}

// MARK: - SwiftData

@Model
final class TodoItem {
    var title: String
    var done: Bool
    var created: Date

    init(title: String, done: Bool = false, created: Date = .now) {
        self.title = title
        self.done = done
        self.created = created
    }
}

struct SwiftDataDemo: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TodoItem.created, order: .reverse) private var allItems: [TodoItem]
    @State private var draft = ""

    /// Open tasks first, newest first within each group.
    private var items: [TodoItem] { allItems.filter { !$0.done } + allItems.filter(\.done) }

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("New task", text: $draft)
                        .onSubmit(add)
                    Button("Add", action: add).disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } footer: {
                Text("Stored with SwiftData (@Model and @Query); tasks stay after the app restarts.")
            }
            Section("\(items.filter { !$0.done }.count) open of \(items.count)") {
                ForEach(items) { item in
                    Button {
                        withAnimation { item.done.toggle() }
                    } label: {
                        HStack {
                            Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.done ? .green : .secondary)
                                .contentTransition(.symbolEffect(.replace))
                            Text(item.title).strikethrough(item.done).foregroundStyle(item.done ? .secondary : .primary)
                            Spacer()
                            Text(item.created, format: .dateTime.hour().minute()).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    for i in offsets { context.delete(items[i]) }
                }
            }
        }
        .toolbar {
            Button("Samples") {
                for title in ["Buy groceries", "Call the dentist", "Book flights", "Water the plants"] {
                    context.insert(TodoItem(title: title))
                }
            }
        }
        .overlay {
            if items.isEmpty {
                ContentUnavailableView("No tasks", systemImage: "checklist", description: Text("Add one above or tap Samples."))
            }
        }
    }

    private func add() {
        let title = draft.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        withAnimation { context.insert(TodoItem(title: title)) }
        draft = ""
    }
}
