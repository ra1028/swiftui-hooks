import Hooks
import SwiftUI

@main
struct TheMovieDBApp: App {
    var dependency: Dependency {
        Dependency(
            service: MovieDBService()
        )
    }

    var body: some Scene {
        WindowGroup {
            Context.Provider(value: dependency) {
                TopRatedMoviesPage()
            }
        }
    }
}
