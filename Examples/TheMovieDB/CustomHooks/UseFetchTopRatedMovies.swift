import Foundation
import Hooks

func useFetchTopRatedMovies() -> (phase: AsyncPhase<[Movie], URLError>, fetch: () -> Void) {
    useFetchPage(Movie.self, path: "movie/top_rated")
}
