import SwiftUI

struct ShapesDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                titled("Shapes") {
                    HStack(spacing: 12) {
                        Circle().fill(.red)
                        Capsule().fill(.orange)
                        RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.yellow)
                        Ellipse().stroke(.green, lineWidth: 4)
                        UnevenRoundedRectangle(topLeadingRadius: 20, bottomTrailingRadius: 20).fill(.blue)
                    }
                    .frame(height: 56)
                    HStack(spacing: 12) {
                        Star(points: 5).fill(.yellow.gradient)
                        Star(points: 8, inset: 0.6).stroke(.purple, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                        Circle().trim(from: 0.1, to: 0.8).stroke(.teal, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        RoundedRectangle(cornerRadius: 10).stroke(.pink, style: StrokeStyle(lineWidth: 3, dash: [8, 5]))
                    }
                    .frame(height: 64)
                }
                titled("Gradients") {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12).fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        RoundedRectangle(cornerRadius: 12).fill(RadialGradient(colors: [.yellow, .orange, .red], center: .center, startRadius: 4, endRadius: 50))
                        RoundedRectangle(cornerRadius: 12).fill(AngularGradient(colors: [.red, .yellow, .green, .blue, .purple, .red], center: .center))
                    }
                    .frame(height: 80)
                    MeshGradientSample()
                }
                titled("Canvas") {
                    TimelineView(.animation) { timeline in
                        Canvas { context, size in
                            let t = timeline.date.timeIntervalSinceReferenceDate
                            for i in 0..<40 {
                                let a = Double(i) / 40 * .pi * 2 + t * 0.6
                                let r = size.height * 0.38 * (0.6 + 0.4 * sin(t * 1.3 + Double(i) * 0.4))
                                let p = CGPoint(x: size.width / 2 + cos(a) * r * 1.6, y: size.height / 2 + sin(a) * r)
                                let rect = CGRect(x: p.x - 6, y: p.y - 6, width: 12, height: 12)
                                context.fill(Path(ellipseIn: rect), with: .color(Color(hue: Double(i) / 40, saturation: 0.8, brightness: 0.95)))
                            }
                            context.draw(Text("Canvas + TimelineView").font(.headline), at: CGPoint(x: size.width / 2, y: size.height / 2))
                        }
                    }
                    .frame(height: 160)
                    .background(.quaternary, in: .rect(cornerRadius: 12))
                }
                titled("Materials") {
                    ZStack {
                        LinearGradient(colors: [.pink, .orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                        HStack(spacing: 8) {
                            ForEach([("Ultra thin", Material.ultraThinMaterial), ("Thin", .thinMaterial), ("Regular", .regularMaterial), ("Thick", .thickMaterial)], id: \.0) { item in
                                Text(item.0).font(.caption.bold())
                                    .frame(maxWidth: .infinity, minHeight: 70)
                                    .background(item.1, in: .rect(cornerRadius: 10))
                            }
                        }
                        .padding(10)
                    }
                    .frame(height: 100)
                    .clipShape(.rect(cornerRadius: 14))
                }
                titled("Shadows, blend modes and masks") {
                    HStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 14).fill(.white)
                            .frame(width: 70, height: 70)
                            .shadow(color: .black.opacity(0.25), radius: 10, y: 6)
                        ZStack {
                            Circle().fill(.red).frame(width: 50).offset(x: -12)
                            Circle().fill(.blue).frame(width: 50).offset(x: 12).blendMode(.multiply)
                        }
                        .frame(width: 80, height: 70)
                        Text("MASK").font(.system(size: 34, weight: .black))
                            .foregroundStyle(.clear)
                            .background(AngularGradient(colors: [.red, .yellow, .green, .blue, .purple, .red], center: .center))
                            .mask(Text("MASK").font(.system(size: 34, weight: .black)))
                    }
                }
            }
            .padding()
        }
    }

    private func titled(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased()).font(.caption).foregroundStyle(.secondary)
            content()
        }
    }
}

/// A star with a configurable number of points, drawn as a custom Shape.
struct Star: Shape {
    var points: Int
    var inset: Double = 0.45

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        var path = Path()
        for i in 0..<(points * 2) {
            let r = i.isMultiple(of: 2) ? outer : outer * inset
            let a = Double(i) * .pi / Double(points) - .pi / 2
            let p = CGPoint(x: center.x + cos(a) * r, y: center.y + sin(a) * r)
            i == 0 ? path.move(to: p) : path.addLine(to: p)
        }
        path.closeSubpath()
        return path
    }
}

struct MeshGradientSample: View {
    var body: some View {
        if #available(iOS 18.0, *) {
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                MeshGradient(width: 3, height: 3, points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [Float(0.5 + 0.2 * sin(t)), Float(0.5 + 0.2 * cos(t * 0.8))], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1],
                ], colors: [.indigo, .purple, .pink, .blue, .mint, .orange, .teal, .cyan, .yellow])
            }
            .frame(height: 110)
            .clipShape(.rect(cornerRadius: 12))
            .overlay(alignment: .bottomLeading) {
                Text("MeshGradient (iOS 18)").font(.caption.bold()).foregroundStyle(.white).padding(8)
            }
        } else {
            Text("MeshGradient needs iOS 18.").font(.caption).foregroundStyle(.secondary)
        }
    }
}

struct SymbolsDemo: View {
    @State private var level = 0.6
    @State private var bounce = 0
    @State private var active = true
    private let names = ["cloud.sun.rain.fill", "heart.text.square.fill", "person.crop.circle.badge.checkmark", "wifi.router.fill", "flame.fill", "sparkles"]

    var body: some View {
        Form {
            Section("Rendering modes") {
                ForEach([("Monochrome", SymbolRenderingMode.monochrome), ("Hierarchical", .hierarchical), ("Palette", .palette), ("Multicolor", .multicolor)], id: \.0) { mode in
                    HStack {
                        Text(mode.0).frame(width: 110, alignment: .leading)
                        ForEach(names.prefix(4), id: \.self) { name in
                            Image(systemName: name)
                                .symbolRenderingMode(mode.1)
                                .foregroundStyle(.blue, .orange, .green)
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            Section("Variable value") {
                HStack {
                    ForEach(["speaker.wave.3.fill", "wifi", "cellularbars", "chart.bar.fill"], id: \.self) { name in
                        Image(systemName: name, variableValue: level).font(.title).frame(maxWidth: .infinity)
                    }
                }
                Slider(value: $level)
            }
            Section("Symbol effects") {
                HStack {
                    Image(systemName: "bell.badge.fill").symbolEffect(.bounce, value: bounce)
                    Image(systemName: "antenna.radiowaves.left.and.right").symbolEffect(.variableColor.iterative, isActive: active)
                    Image(systemName: "heart.fill").foregroundStyle(.red).symbolEffect(.pulse, isActive: active)
                    Image(systemName: "arrow.clockwise").symbolEffect(.bounce.down, value: bounce)
                    Image(systemName: active ? "play.fill" : "pause.fill").contentTransition(.symbolEffect(.replace))
                }
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                HStack {
                    Button("Bounce") { bounce += 1 }
                    Spacer()
                    Toggle("Animate", isOn: $active).fixedSize()
                }
                .buttonStyle(.bordered)
            }
            Section("Weights and scales") {
                HStack {
                    ForEach([Font.Weight.ultraLight, .regular, .semibold, .black], id: \.self) { w in
                        Image(systemName: "star.circle").fontWeight(w).font(.title).frame(maxWidth: .infinity)
                    }
                }
                HStack {
                    ForEach([Image.Scale.small, .medium, .large], id: \.self) { s in
                        Image(systemName: "folder.fill").imageScale(s).frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

struct AnimationDemo: View {
    @State private var expanded = false
    @State private var showBadge = true
    @State private var count = 0
    @State private var selected = 0
    @State private var phaseTrigger = 0
    @State private var keyframeTrigger = 0
    @Namespace private var namespace

    var body: some View {
        Form {
            Section("Springs") {
                HStack {
                    ForEach([("smooth", Animation.smooth), ("snappy", .snappy), ("bouncy", .bouncy)], id: \.0) { item in
                        VStack {
                            RoundedRectangle(cornerRadius: 10).fill(.blue.gradient)
                                .frame(width: 40, height: expanded ? 110 : 40)
                                .animation(item.1, value: expanded)
                            Text(item.0).font(.caption)
                        }
                        .frame(maxWidth: .infinity, minHeight: 130, alignment: .bottom)
                    }
                }
                Button(expanded ? "Shrink" : "Grow") { expanded.toggle() }
            }
            Section("Transitions") {
                ZStack {
                    if showBadge {
                        Label("New message", systemImage: "envelope.fill")
                            .padding()
                            .background(.green.gradient, in: .capsule)
                            .foregroundStyle(.white)
                            .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .move(edge: .trailing).combined(with: .opacity)))
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                Button(showBadge ? "Dismiss" : "Show") { withAnimation(.spring) { showBadge.toggle() } }
            }
            Section("Numeric text") {
                Text("\(count)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .contentTransition(.numericText(value: Double(count)))
                    .frame(maxWidth: .infinity)
                HStack {
                    Button("−10") { withAnimation { count -= 10 } }
                    Spacer()
                    Button("+1") { withAnimation { count += 1 } }
                    Spacer()
                    Button("+100") { withAnimation { count += 100 } }
                }
                .buttonStyle(.bordered)
            }
            Section("Matched geometry") {
                HStack(spacing: 0) {
                    ForEach(Array(["Day", "Week", "Month", "Year"].enumerated()), id: \.offset) { index, title in
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selected == index ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background {
                                if selected == index {
                                    Capsule().fill(.indigo).matchedGeometryEffect(id: "pill", in: namespace)
                                }
                            }
                            .contentShape(.rect)
                            .onTapGesture { withAnimation(.snappy) { selected = index } }
                    }
                }
            }
            Section("PhaseAnimator") {
                Image(systemName: "bell.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.orange)
                    .phaseAnimator([0.0, -20.0, 20.0, -10.0, 0.0], trigger: phaseTrigger) { content, angle in
                        content.rotationEffect(.degrees(angle), anchor: .top)
                    }
                    .frame(maxWidth: .infinity)
                Button("Ring") { phaseTrigger += 1 }
            }
            Section("KeyframeAnimator") {
                Text("🏀")
                    .font(.system(size: 44))
                    .keyframeAnimator(initialValue: BallFrame(), trigger: keyframeTrigger) { content, frame in
                        content.offset(y: frame.y).scaleEffect(x: frame.squash, y: 1 / frame.squash)
                    } keyframes: { _ in
                        KeyframeTrack(\.y) {
                            CubicKeyframe(-90, duration: 0.35)
                            CubicKeyframe(0, duration: 0.35)
                            CubicKeyframe(-40, duration: 0.25)
                            CubicKeyframe(0, duration: 0.25)
                        }
                        KeyframeTrack(\.squash) {
                            LinearKeyframe(1, duration: 0.68)
                            SpringKeyframe(1.3, duration: 0.1)
                            SpringKeyframe(1, duration: 0.3)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 130, alignment: .bottom)
                Button("Bounce") { keyframeTrigger += 1 }
            }
        }
    }
}

struct BallFrame {
    var y = 0.0
    var squash = 1.0
}

struct GesturesDemo: View {
    @State private var taps = 0
    @State private var pressed = false
    @State private var offset = CGSize.zero
    @GestureState private var dragging = CGSize.zero
    @State private var scale = 1.0
    @State private var angle = Angle.zero
    @GestureState private var pinch = 1.0
    @GestureState private var twist = Angle.zero

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack {
                    Circle().fill(pressed ? .orange : .blue)
                        .frame(width: 90, height: 90)
                        .scaleEffect(pressed ? 1.2 : 1)
                        .animation(.spring, value: pressed)
                        .onTapGesture(count: 2) { taps += 2 }
                        .onTapGesture { taps += 1 }
                        .onLongPressGesture(minimumDuration: 0.4) { pressed.toggle() }
                    Text("Taps: \(taps) · tap, double-tap, long-press").font(.caption).foregroundStyle(.secondary)
                }
                VStack {
                    RoundedRectangle(cornerRadius: 16).fill(.green.gradient)
                        .frame(width: 100, height: 100)
                        .overlay(Text("Drag").bold().foregroundStyle(.white))
                        .offset(x: offset.width + dragging.width, y: offset.height + dragging.height)
                        .gesture(
                            DragGesture()
                                .updating($dragging) { value, state, _ in state = value.translation }
                                .onEnded { value in
                                    withAnimation(.spring) {
                                        offset.width += value.translation.width
                                        offset.height += value.translation.height
                                    }
                                }
                        )
                    Button("Reset position") { withAnimation(.spring) { offset = .zero } }.font(.caption)
                }
                .frame(height: 220)
                VStack {
                    RoundedRectangle(cornerRadius: 20).fill(.purple.gradient)
                        .frame(width: 140, height: 140)
                        .overlay(Text("Pinch & rotate").bold().foregroundStyle(.white))
                        .scaleEffect(scale * pinch)
                        .rotationEffect(angle + twist)
                        .gesture(
                            MagnifyGesture()
                                .updating($pinch) { value, state, _ in state = value.magnification }
                                .onEnded { scale *= $0.magnification }
                                .simultaneously(with:
                                    RotateGesture()
                                        .updating($twist) { value, state, _ in state = value.rotation }
                                        .onEnded { angle += $0.rotation }
                                )
                        )
                    Text("Scale \(scale * pinch, format: .number.precision(.fractionLength(2))) · \(Int((angle + twist).degrees))°")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .frame(height: 260)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}
