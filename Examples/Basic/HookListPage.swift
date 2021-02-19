import Combine
import Hooks
import SwiftUI

typealias ColorSchemeContext = Context<Binding<ColorScheme>>

struct HookListPage: HookView {
    var hookBody: some View {
        let colorScheme = useState(useEnvironment(\.colorScheme))

        return ColorSchemeContext.Provider(value: colorScheme) {
            ScrollView {
                VStack {
                    useStateRow
                    useReducerRow
                    useEffectRow
                    useLayoutEffectRow
                    useMemoRow
                    useRefRow
                    useEnvironmentRow
                    usePublisherRow
                    usePublisherSubscribeRow
                    useContextRow
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Hook List")
            .background(Color(.systemBackground).ignoresSafeArea())
            .colorScheme(colorScheme.wrappedValue)
        }
    }

    var useStateRow: some View {
        let count = useState(0)

        return Row("useState") {
            Stepper(count.wrappedValue.description, value: count)
        }
    }

    var useReducerRow: some View {
        enum Action {
            case plus, minus, reset
        }

        func reducer(state: Int, action: Action) -> Int {
            switch action {
            case .plus: return state + 1
            case .minus: return state - 1
            case .reset: return 0
            }
        }

        let (count, dispatch) = useReducer(reducer, initialState: 0)

        return Row("useReducer") {
            Stepper(count.description, onIncrement: { dispatch(.plus) }, onDecrement: { dispatch(.minus) })
            Button("Reset") { dispatch(.reset) }
        }
    }

    var useEffectRow: some View {
        let isOn = useState(false)
        let count = useState(0)

        useEffect(.preserved(by: isOn.wrappedValue)) {
            guard isOn.wrappedValue else { return nil }

            let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                count.wrappedValue += 1
            }
            return {
                timer.invalidate()
            }
        }

        return Row("useEffect") {
            Toggle(isOn: isOn) {
                Text("\(count.wrappedValue)")
            }
        }
    }

    var useLayoutEffectRow: some View {
        let flag = useState(false)
        let random = useState(0)

        useLayoutEffect(.preserved(by: flag.wrappedValue)) {
            random.wrappedValue = Int.random(in: 0...100000)
            return nil
        }

        return Row("useLayoutEffect") {
            Text("\(random.wrappedValue)")
            Spacer()
            Button("Random") {
                flag.wrappedValue.toggle()
            }
        }
    }

    var useMemoRow: some View {
        let flag = useState(false)
        let randomColor = useMemo(.preserved(by: flag.wrappedValue)) {
            Color(hue: .random(in: 0...1), saturation: 1, brightness: 1)
        }

        return Row("useMemo") {
            Circle().fill(randomColor).frame(width: 30, height: 30)
            Spacer()
            Button("Random", action: { flag.wrappedValue.toggle() })
        }
    }

    var useRefRow: some View {
        let flag = useState(false)
        let n1 = useRef(1)
        let n2 = useRef(1)
        let fibonacci = useState(2)

        useEffect(.preserved(by: flag.wrappedValue)) {
            n2.current = n1.current
            n1.current = fibonacci.wrappedValue
            fibonacci.wrappedValue = n1.current + n2.current
            return nil
        }

        return Row("useRef") {
            Text("Fibonacci = \(fibonacci.wrappedValue)")
            Spacer()
            Button("Next", action: { flag.wrappedValue.toggle() })
        }
    }

    var useEnvironmentRow: some View {
        let locale = useEnvironment(\.locale)

        return Row("useEnvironment") {
            Text("Current Locale = \(locale.identifier)")
        }
    }

    var usePublisherRow: some View {
        let status = usePublisher(.once) {
            Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .prepend(Date())
        }

        return Row("usePublisher") {
            if case .success(let date) = status {
                Text(DateFormatter.time.string(from: date))
            }
        }
    }

    var usePublisherSubscribeRow: some View {
        let (status, subscribe) = usePublisherSubscribe {
            Just(UUID())
                .map(\.uuidString)
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
        }

        return Row("usePublisherSubscribe") {
            Group {
                switch status {
                case .running:
                    ProgressView()

                case .success(let uuid):
                    Text(uuid)

                case .pending:
                    EmptyView()
                }

                Spacer()
                Button("Random", action: subscribe)
            }
            .frame(height: 50)
        }
    }

    var useContextRow: some View {
        let colorScheme = useContext(ColorSchemeContext.self)

        return Row("useContext") {
            Picker("Color Scheme", selection: colorScheme) {
                ForEach(ColorScheme.allCases, id: \.self) { scheme in
                    Text("\(scheme)".description)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct HookListPage_Previews: PreviewProvider {
    static var previews: some View {
        HookListPage()
    }
}

private struct Row<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).bold()
            HStack { content }.padding(.vertical, 16)
            Divider()
        }
        .padding(.horizontal, 24)
    }
}

private extension DateFormatter {
    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()
}
