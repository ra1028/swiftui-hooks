import Combine
import UIKit

@testable import TheMovieDB_MVVM

final class MovieDBServiceMock: MovieDBServiceProtocol {
    let imageSubject = PassthroughSubject<UIImage?, URLError>()
    let moviesSubject = PassthroughSubject<[Movie], URLError>()
    var totalPages = 100

    func getImage(path: String?, size: NetworkImageSize) -> AnyPublisher<UIImage?, URLError> {
        imageSubject.eraseToAnyPublisher()
    }

    func getTopRated(page: Int) -> AnyPublisher<PagedResponse<Movie>, URLError> {
        moviesSubject
            .map { [totalPages] movies in
                PagedResponse(
                    page: page,
                    totalPages: totalPages,
                    results: movies
                )
            }
            .eraseToAnyPublisher()
    }
}
