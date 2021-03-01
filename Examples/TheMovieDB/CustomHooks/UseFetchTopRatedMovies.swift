import Foundation
import Hooks

func useFetchTopRatedMovies() -> (status: AsyncStatus<[Movie], URLError>, fetch: () -> Void) {
    useFetchPage(Movie.self, path: "movie/top_rated")
}
