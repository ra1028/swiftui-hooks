import SwiftUI

struct IndexPage: View {
    var body: some View {
        NavigationView {
            Form {
                NavigationLink(
                    "Showcase",
                    destination: ShowcasePage()
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
