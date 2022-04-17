import Combine
import UIKit

@testable import TheMovieDB_MVVM

final class MovieDBServiceMock: MovieDBServiceProtocol {
    var imageResult: Result<UIImage?, URLError>?
    var moviesResult: Result<[Movie], URLError>?
    var totalPages = 100

    func getImage(path: String?, size: NetworkImageSize) async throws -> UIImage? {
        try imageResult?.get()
    }

    func getTopRated(page: Int) async throws -> PagedResponse<Movie> {
        try PagedResponse(
            page: page,
            totalPages: totalPages,
            results: moviesResult?.get() ?? []
        )
    }
}
