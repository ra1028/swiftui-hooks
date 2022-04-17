import Hooks
import XCTest

@testable import TheMovieDB_MVVM

@MainActor
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

    func testLoad() async {
        let service = MovieDBServiceMock()
        let tester = HookTester {
            useTopRatedMoviesViewModel()
        } environment: {
            $0[Context<Dependency>.self] = Dependency(service: service)
        }

        let movies = Array(repeating: Movie.stub, count: 3)

        XCTAssertTrue(tester.value.loadPhase.isPending)

        service.moviesResult = .success(movies)
        await tester.value.load()

        XCTAssertEqual(tester.value.loadPhase.value, movies)
    }

    func testLoadNext() async {
        let service = MovieDBServiceMock()
        let tester = HookTester {
            useTopRatedMoviesViewModel()
        } environment: {
            $0[Context<Dependency>.self] = Dependency(service: service)
        }

        let movies = Array(repeating: Movie.stub, count: 3)
        service.moviesResult = .success(movies)

        XCTAssertTrue(tester.value.loadPhase.isPending)

        await tester.value.loadNext()

        XCTAssertTrue(tester.value.loadPhase.isPending)

        await tester.value.load()

        XCTAssertEqual(tester.value.loadPhase.value, movies)

        await tester.value.loadNext()

        XCTAssertEqual(tester.value.loadPhase.value, movies + movies)
    }

    func testHasNext() async {
        let service = MovieDBServiceMock()
        let tester = HookTester {
            useTopRatedMoviesViewModel()
        } environment: {
            $0[Context<Dependency>.self] = Dependency(service: service)
        }

        XCTAssertFalse(tester.value.hasNextPage)

        service.moviesResult = .success([])
        await tester.value.load()

        XCTAssertTrue(tester.value.hasNextPage)

        service.totalPages = 0
        await tester.value.load()

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
