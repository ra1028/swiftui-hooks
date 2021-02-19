import Hooks
import SwiftUI

struct CounterPage: HookView {
    var hookBody: some View {
        let count = useState(0)
        let isAutoIncrement = useState(false)

        useEffect(.preserved(by: isAutoIncrement.wrappedValue)) {
            guard isAutoIncrement.wrappedValue else { return nil }

            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                count.wrappedValue += 1
            }

            return timer.invalidate
        }

        return VStack(spacing: 50) {
            Text(String(format: "%02d", count.wrappedValue))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .font(.system(size: 100, weight: .heavy, design: .rounded))
                .padding(30)
                .frame(width: 200, height: 200)
                .background(Color(.secondarySystemBackground))
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 3, y: 3)

            Stepper(value: count, in: 0...(.max)) { EmptyView() }.fixedSize()

            Toggle("Auto +", isOn: isAutoIncrement).fixedSize()
        }
        .navigationTitle("Counter")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

struct CounterPage_Previews: PreviewProvider {
    static var previews: some View {
        CounterPage()
    }
}
