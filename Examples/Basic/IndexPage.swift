import SwiftUI

struct IndexPage: View {
    var body: some View {
        NavigationView {
            Form {
                NavigationLink(
                    "Hook List",
                    destination: HookListPage()
                )

                NavigationLink(
                    "Counter",
                    destination: CounterPage()
                )

                NavigationLink(
                    "API Request",
                    destination: APIRequestPage()
                )
            }
            .navigationTitle("Examples")
            .background(Color(.systemBackground).ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
