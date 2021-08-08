import Hooks
import XCTest

@testable import TheMovieDB_MVVM

final class UseTopRatedMoviesViewModelTests: XCTestCase {
    func testSelectedMovie() {
        let tester = HookTester {
            useTopRatedMoviesViewModel()
        } environment: {
            $0[Context<Dependency>.self] = Dependency(
                service: MovieDBServiceMock()
            )
        }

        XCTAssertNil(tester.value.selectedMovie.wrappedValue)

        tester.value.selectedMovie.wrappedValue = .stub

        XCTAssertEqual(tester.value.selectedMovie.wrappedValue, .stub)
    }

    func testLoad() {
        let service = MovieDBServiceMock()
        let tester = HookTester {
            useTopRatedMoviesViewModel()
        } environment: {
            $0[Context<Dependency>.self] = Dependency(service: service)
        }

        let movies = Array(repeating: Movie.stub, count: 3)

        XCTAssertEqual(tester.value.loadPhase, .pending)

        tester.value.load()

        XCTAssertEqual(tester.value.loadPhase, .running)

        service.moviesSubject.send(movies)

        XCTAssertEqual(tester.value.loadPhase, .success(movies))

        tester.value.load()

        XCTAssertEqual(tester.value.loadPhase, .running)

        service.moviesSubject.send(movies)

        XCTAssertEqual(tester.value.loadPhase, .success(movies))
    }

    func testLoadNext() {
        let service = MovieDBServiceMock()
        let tester = HookTester {
            useTopRatedMoviesViewModel()
        } environment: {
            $0[Context<Dependency>.self] = Dependency(service: service)
        }

        let movies = Array(repeating: Movie.stub, count: 3)

        XCTAssertEqual(tester.value.loadPhase, .pending)

        tester.value.loadNext()

        XCTAssertEqual(tester.value.loadPhase, .pending)

        tester.value.load()
        service.moviesSubject.send(movies)

        XCTAssertEqual(tester.value.loadPhase, .success(movies))

        tester.value.loadNext()

        XCTAssertEqual(tester.value.loadPhase, .success(movies))

        service.moviesSubject.send(movies)

        XCTAssertEqual(tester.value.loadPhase, .success(movies + movies))
    }

    func testHasNext() {
        let service = MovieDBServiceMock()
        let tester = HookTester {
            useTopRatedMoviesViewModel()
        } environment: {
            $0[Context<Dependency>.self] = Dependency(service: service)
        }

        XCTAssertFalse(tester.value.hasNextPage)

        tester.value.load()
        service.moviesSubject.send([])

        XCTAssertTrue(tester.value.hasNextPage)

        service.totalPages = 0

        tester.value.load()
        service.moviesSubject.send([])

        XCTAssertFalse(tester.value.hasNextPage)
    }
}

private extension Movie {
    static let stub = Movie(
        id: 0,
        title: "",
        overview: nil,
        posterPath: nil,
        backdropPath: nil,
        voteAverage: 0,
        releaseDate: Date(timeIntervalSince1970: 0)
    )
}
