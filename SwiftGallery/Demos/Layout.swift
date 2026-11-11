import SwiftUI

private let palette: [Color] = [.red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink, .brown]

struct StacksDemo: View {
    @State private var columns = 3.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                group("HStack, VStack, ZStack") {
                    HStack {
                        VStack(spacing: 6) {
                            tile(.red)
                            tile(.orange)
                        }
                        ZStack {
                            tile(.blue).frame(width: 90, height: 90)
                            tile(.cyan).frame(width: 60, height: 60)
                            Text("Z").font(.title.bold()).foregroundStyle(.white)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Spacer pushes").font(.caption)
                            Text("this to the edge").font(.caption)
                        }
                    }
                }
                group("Grid with alignment") {
                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                        GridRow {
                            Text("Name").bold()
                            Text("Role").bold()
                            Text("Since").bold().gridColumnAlignment(.trailing)
                        }
                        Divider().gridCellUnsizedAxes(.horizontal)
                        GridRow { Text("Ava"); Text("Design"); Text("2019") }
                        GridRow { Text("Ben"); Text("Engineering"); Text("2021") }
                        GridRow {
                            Text("A cell spanning two columns").gridCellColumns(2).foregroundStyle(.secondary)
                            Text("2024")
                        }
                    }
                }
                group("LazyVGrid (\(Int(columns)) columns)") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: Int(columns)), spacing: 8) {
                        ForEach(0..<12) { i in
                            tile(palette[i]).aspectRatio(1, contentMode: .fit)
                                .overlay(Text("\(i + 1)").bold().foregroundStyle(.white))
                        }
                    }
                    .animation(.spring, value: columns)
                    Slider(value: $columns, in: 2...6, step: 1)
                }
                group("ViewThatFits") {
                    ForEach([320.0, 180.0, 90.0], id: \.self) { width in
                        ViewThatFits {
                            Label("Download the full report", systemImage: "arrow.down.circle")
                            Label("Download", systemImage: "arrow.down.circle")
                            Image(systemName: "arrow.down.circle")
                        }
                        .frame(width: width, alignment: .leading)
                        .padding(8)
                        .background(.quaternary, in: .rect(cornerRadius: 8))
                    }
                }
                group("Overlay, background, safe padding") {
                    Text("Badge")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.blue.gradient, in: .capsule)
                        .foregroundStyle(.white)
                        .overlay(alignment: .topTrailing) {
                            Text("3").font(.caption2.bold()).foregroundStyle(.white)
                                .padding(6).background(.red, in: .circle)
                                .offset(x: 8, y: -8)
                        }
                }
            }
            .padding()
        }
    }

    private func tile(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 8).fill(color.gradient).frame(minWidth: 40, minHeight: 40)
    }

    private func group(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased()).font(.caption).foregroundStyle(.secondary)
            content()
        }
    }
}

struct ScrollDemo: View {
    @State private var page: Int? = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("PAGING").font(.caption).foregroundStyle(.secondary).padding(.horizontal)
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0) {
                            ForEach(0..<6) { i in
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(palette[i * 2].gradient)
                                    .overlay(Text("Page \(i + 1)").font(.largeTitle.bold()).foregroundStyle(.white))
                                    .padding(.horizontal)
                                    .containerRelativeFrame(.horizontal)
                                    .frame(height: 180)
                                    .id(i)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollPosition(id: $page)
                    .scrollIndicators(.hidden)
                    HStack {
                        ForEach(0..<6) { i in
                            Circle().fill(i == (page ?? 0) ? Color.accentColor : .secondary.opacity(0.4)).frame(width: 8, height: 8)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Text("SNAPPING CARDS WITH SCROLL TRANSITIONS").font(.caption).foregroundStyle(.secondary).padding(.horizontal)
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 12) {
                            ForEach(0..<10) { i in
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(palette[i].gradient)
                                    .frame(width: 140, height: 180)
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                            .opacity(phase.isIdentity ? 1 : 0.6)
                                            .rotation3DEffect(.degrees(phase.value * -20), axis: (x: 0, y: 1, z: 0))
                                    }
                            }
                        }
                        .scrollTargetLayout()
                        .padding(.horizontal)
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)

                    Text("SCROLLVIEWREADER").font(.caption).foregroundStyle(.secondary).padding(.horizontal)
                    Button("Jump to row 40") {
                        withAnimation { proxy.scrollTo("row-40", anchor: .center) }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(1...60, id: \.self) { i in
                            Text("Row \(i)")
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .background(i == 40 ? Color.yellow.opacity(0.3) : .clear)
                                .id("row-\(i)")
                            Divider()
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

struct Fruit: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var emoji: String
    var favorite = false
}

struct ListsDemo: View {
    @State private var fruits = [
        Fruit(name: "Apple", emoji: "🍎"), Fruit(name: "Banana", emoji: "🍌"), Fruit(name: "Cherry", emoji: "🍒"),
        Fruit(name: "Grapes", emoji: "🍇"), Fruit(name: "Kiwi", emoji: "🥝"), Fruit(name: "Lemon", emoji: "🍋"),
        Fruit(name: "Mango", emoji: "🥭"), Fruit(name: "Peach", emoji: "🍑"), Fruit(name: "Pear", emoji: "🍐"),
    ]
    @State private var query = ""
    @State private var style = 0
    @State private var selection = Set<UUID>()

    var body: some View {
        let shown = fruits.filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) }
        Group {
            switch style {
            case 1: list(shown).listStyle(.plain)
            case 2: list(shown).listStyle(.grouped)
            default: list(shown).listStyle(.insetGrouped)
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { EditButton() }
        }
        .safeAreaInset(edge: .bottom) {
            Picker("Style", selection: $style) {
                Text("Inset grouped").tag(0)
                Text("Plain").tag(1)
                Text("Grouped").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(.bar)
        }
    }

    private func list(_ shown: [Fruit]) -> some View {
        List(selection: $selection) {
            Section {
                ForEach(shown) { fruit in
                    HStack {
                        Text(fruit.emoji).font(.title2)
                        Text(fruit.name)
                        Spacer()
                        if fruit.favorite {
                            Image(systemName: "star.fill").foregroundStyle(.yellow)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            toggleFavorite(fruit)
                        } label: {
                            Label("Favorite", systemImage: "star")
                        }
                        .tint(.yellow)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            fruits.removeAll { $0.id == fruit.id }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove { fruits.move(fromOffsets: $0, toOffset: $1) }
            } header: {
                Text("Fruits")
            } footer: {
                Text("Swipe a row either way, tap Edit to reorder or select several.")
            }
        }
    }

    private func toggleFavorite(_ fruit: Fruit) {
        if let i = fruits.firstIndex(of: fruit) { fruits[i].favorite.toggle() }
    }
}

struct PresentationDemo: View {
    @State private var sheet = false
    @State private var fullScreen = false
    @State private var popover = false
    @State private var alert = false
    @State private var dialog = false
    @State private var inspector = false
    @State private var result = "—"
    @State private var name = ""

    var body: some View {
        Form {
            Section {
                LabeledContent("Last action", value: result)
            }
            Section("Sheets") {
                Button("Sheet with detents") { sheet = true }
                Button("Full-screen cover") { fullScreen = true }
                Button("Popover") { popover = true }
                    .popover(isPresented: $popover) {
                        Text("A popover becomes a sheet on iPhone unless it adapts.")
                            .padding()
                            .presentationCompactAdaptation(.popover)
                    }
                Button("Inspector") { inspector = true }
            }
            Section("Alerts") {
                Button("Alert with a text field") { alert = true }
                Button("Confirmation dialog") { dialog = true }
            }
        }
        .sheet(isPresented: $sheet) {
            NavigationStack {
                List(1...20, id: \.self) { Text("Item \($0)") }
                    .navigationTitle("Sheet")
                    .toolbar { Button("Done") { sheet = false } }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $fullScreen) {
            ZStack {
                LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Full screen").font(.largeTitle.bold()).foregroundStyle(.white)
                    Button("Close") { fullScreen = false }.buttonStyle(.borderedProminent).tint(.white).foregroundStyle(.indigo)
                }
            }
        }
        .inspector(isPresented: $inspector) {
            Form {
                Text("An inspector shows as a sheet on iPhone and as a trailing column on iPad.")
            }
            .presentationDetents([.height(220)])
        }
        .alert("Rename", isPresented: $alert) {
            TextField("New name", text: $name)
            Button("Cancel", role: .cancel) { result = "Rename cancelled" }
            Button("Save") { result = "Renamed to \(name)" }
        } message: {
            Text("Enter a new name for the document.")
        }
        .confirmationDialog("Delete this photo?", isPresented: $dialog, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { result = "Deleted" }
            Button("Move to album") { result = "Moved" }
        } message: {
            Text("This cannot be undone.")
        }
    }
}
