import Combine
@testable import TheMovieDB_MVVM
import UIKit

final class MovieDBServiceMock: MovieDBServiceProtocol {
    var imageResult: Result<UIImage?, URLError>?
    var moviesResult: Result<[Movie], URLError>?
    var totalPages = 100

    func getImage(path _: String?, size _: NetworkImageSize) async throws -> UIImage? {
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
