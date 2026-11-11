import SwiftUI

struct ButtonsDemo: View {
    @State private var taps = 0
    @State private var sort = "Name"
    @State private var favorite = false

    var body: some View {
        Form {
            Section {
                Text("Tapped \(taps) time\(taps == 1 ? "" : "s")")
                    .contentTransition(.numericText())
                    .animation(.default, value: taps)
            }
            Section("Styles") {
                HStack {
                    Button("Plain") { taps += 1 }.buttonStyle(.plain)
                    Spacer()
                    Button("Borderless") { taps += 1 }.buttonStyle(.borderless)
                }
                HStack {
                    Button("Bordered") { taps += 1 }.buttonStyle(.bordered)
                    Spacer()
                    Button("Prominent") { taps += 1 }.buttonStyle(.borderedProminent)
                }
                HStack {
                    Button("Capsule") { taps += 1 }.buttonStyle(.bordered).buttonBorderShape(.capsule)
                    Spacer()
                    Button("Tinted") { taps += 1 }.buttonStyle(.borderedProminent).tint(.pink)
                }
                Button("Disabled") {}.buttonStyle(.borderedProminent).disabled(true)
            }
            Section("Sizes") {
                HStack {
                    ForEach([ControlSize.mini, .small, .regular, .large], id: \.self) { size in
                        Button("Go") { taps += 1 }.buttonStyle(.bordered).controlSize(size)
                    }
                }
            }
            Section("Roles and labels") {
                Button(role: .destructive) { taps = 0 } label: {
                    Label("Reset counter", systemImage: "trash")
                }
                Button { favorite.toggle() } label: {
                    Label(favorite ? "Favorited" : "Favorite", systemImage: favorite ? "heart.fill" : "heart")
                }
                .symbolEffect(.bounce, value: favorite)
            }
            Section("Menu") {
                Menu {
                    Picker("Sort by", selection: $sort) {
                        ForEach(["Name", "Date", "Size"], id: \.self) { Text($0) }
                    }
                    Divider()
                    Button("Duplicate", systemImage: "plus.square.on.square") {}
                    Button("Delete", systemImage: "trash", role: .destructive) {}
                } label: {
                    Label("Sorted by \(sort)", systemImage: "arrow.up.arrow.down")
                }
                Text("Long-press me for a context menu")
                    .contextMenu {
                        Button("Copy", systemImage: "doc.on.doc") {}
                        Button("Share", systemImage: "square.and.arrow.up") {}
                    }
            }
            Section("Links") {
                Link(destination: URL(string: "https://developer.apple.com/documentation/swiftui")!) {
                    Label("SwiftUI documentation", systemImage: "safari")
                }
                ShareLink(item: URL(string: "https://github.com/kxbuild/swift-gallery")!) {
                    Label("Share this project", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}

struct TogglesDemo: View {
    @State private var wifi = true
    @State private var bluetooth = false
    @State private var flavor = "Vanilla"
    @State private var size = 1
    @State private var date = Date()
    @State private var color = Color.orange
    @State private var volume = 0.6
    @State private var quantity = 2

    private let flavors = ["Vanilla", "Chocolate", "Strawberry"]

    var body: some View {
        Form {
            Section("Toggle") {
                Toggle("Wi-Fi", systemImage: "wifi", isOn: $wifi)
                Toggle("Bluetooth", isOn: $bluetooth).tint(.green)
                Toggle(isOn: $wifi) { Text("Button style") }.toggleStyle(.button)
            }
            Section("Picker") {
                Picker("Menu", selection: $flavor) {
                    ForEach(flavors, id: \.self) { Text($0) }
                }
                Picker("Segmented", selection: $size) {
                    Text("S").tag(0)
                    Text("M").tag(1)
                    Text("L").tag(2)
                }
                .pickerStyle(.segmented)
                Picker("Wheel", selection: $flavor) {
                    ForEach(flavors, id: \.self) { Text($0) }
                }
                .pickerStyle(.wheel)
                .frame(height: 110)
                Picker("Inline", selection: $flavor) {
                    ForEach(flavors, id: \.self) { Text($0) }
                }
                .pickerStyle(.inline)
            }
            Section("Date") {
                DatePicker("Compact", selection: $date)
                DatePicker("Time only", selection: $date, displayedComponents: .hourAndMinute)
                DatePicker("Graphical", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            Section("ColorPicker") {
                ColorPicker("Accent", selection: $color)
                RoundedRectangle(cornerRadius: 10).fill(color.gradient).frame(height: 40)
            }
            Section("Slider and Stepper") {
                HStack {
                    Image(systemName: "speaker.fill")
                    Slider(value: $volume)
                    Image(systemName: "speaker.wave.3.fill")
                }
                Text("Volume \(volume, format: .percent.precision(.fractionLength(0)))")
                Stepper("Quantity: \(quantity)", value: $quantity, in: 0...10)
            }
        }
    }
}

struct TextDemo: View {
    @State private var name = ""
    @State private var password = ""
    @State private var amount = 42.5
    @State private var notes = "TextEditor grows with its content.\nIt supports several lines."
    @FocusState private var focused: Bool

    var body: some View {
        Form {
            Section("Fonts") {
                Text("Large Title").font(.largeTitle.bold())
                Text("Title, rounded").font(.title.weight(.semibold)).fontDesign(.rounded)
                Text("Headline, serif").font(.headline).fontDesign(.serif)
                Text("Body, monospaced").font(.body.monospaced())
                Text("Caption, italic").font(.caption).italic()
                Text("Gradient text").font(.title2.bold())
                    .foregroundStyle(LinearGradient(colors: [.purple, .pink, .orange], startPoint: .leading, endPoint: .trailing))
            }
            Section("Markdown and styles") {
                Text("**Bold**, *italic*, ~~strike~~, `code` and [a link](https://swift.org).")
                Text("Kerning").kerning(6)
                Text("A long line that gets truncated in the middle because it does not fit")
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text("Highlighted") + Text(" with ") + Text("concatenation").foregroundStyle(.blue).bold()
            }
            Section("Formatters") {
                LabeledContent("Currency", value: amount, format: .currency(code: "USD"))
                LabeledContent("Percent", value: 0.256, format: .percent)
                LabeledContent("Date", value: Date(), format: .dateTime.weekday(.wide).day().month())
                LabeledContent("Relative") { Text(Date().addingTimeInterval(-3600), style: .relative) }
                LabeledContent("Measurement", value: Measurement(value: 12.5, unit: UnitLength.kilometers).formatted(.measurement(width: .wide)))
                LabeledContent("List", value: ["Swift", "SwiftUI", "Charts"].formatted(.list(type: .and)))
            }
            Section("Input") {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .focused($focused)
                SecureField("Password", text: $password)
                TextField("Amount", value: $amount, format: .number)
                    .keyboardType(.decimalPad)
                if !name.isEmpty {
                    Text("Hello, \(name)!")
                }
            }
            Section("TextEditor") {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
                Text("\(notes.count) characters").font(.caption).foregroundStyle(.secondary)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focused = false }
            }
        }
    }
}

struct IndicatorsDemo: View {
    @State private var progress = 0.35
    @State private var start = Date()

    var body: some View {
        Form {
            Section("ProgressView") {
                ProgressView()
                ProgressView("Loading…")
                ProgressView(value: progress) {
                    Text("Download")
                } currentValueLabel: {
                    Text(progress, format: .percent.precision(.fractionLength(0)))
                }
                ProgressView(timerInterval: start...start.addingTimeInterval(30), countsDown: true) {
                    Text("30-second timer")
                }
                Slider(value: $progress)
            }
            Section("Gauge") {
                HStack(spacing: 24) {
                    Gauge(value: progress) {
                        Text("CPU")
                    } currentValueLabel: {
                        Text(Int(progress * 100), format: .number)
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(Gradient(colors: [.green, .yellow, .red]))
                    Gauge(value: progress) { Text("Battery") }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .tint(.green)
                    Gauge(value: progress, in: 0...1) {
                        Image(systemName: "thermometer.medium")
                    }
                    .gaugeStyle(.accessoryLinear)
                }
                Gauge(value: progress) {
                    Text("Storage")
                } currentValueLabel: {
                    Text("\(Int(progress * 256)) GB of 256 GB")
                }
            }
            Section("Timers") {
                Text(start, style: .timer).font(.largeTitle.monospacedDigit())
                Button("Restart") { start = Date() }
            }
        }
    }
}
