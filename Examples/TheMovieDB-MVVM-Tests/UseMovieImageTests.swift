import Hooks
import XCTest

@testable import TheMovieDB_MVVM

final class UseMovieImageTests: XCTestCase {
    func testSuccess() {
        let image1 = UIImage()
        let image2 = UIImage()
        let image3 = UIImage()
        let service = MovieDBServiceMock()
        let tester = HookTester(("path1", .medium)) { path, size in
            useMovieImage(for: path, size: size)
        } environment: {
            $0[Context<Dependency>.self] = Dependency(service: service)
        }

        XCTAssertNil(tester.value)

        service.imageResult = .success(image1)
        wait(timeout: 0.1)

        XCTAssertTrue(tester.value === image1)

        tester.update()
        wait(timeout: 0.1)

        XCTAssertTrue(tester.value === image1)

        tester.update(with: ("path1", .original))

        XCTAssertNil(tester.value)

        service.imageResult = .success(image2)
        wait(timeout: 0.1)

        XCTAssertTrue(tester.value === image2)

        tester.update(with: ("path2", .original))

        XCTAssertNil(tester.value)

        service.imageResult = .success(image3)
        wait(timeout: 0.1)

        XCTAssertTrue(tester.value === image3)
    }

    func testFailure() {
        let error = URLError(.badURL)
        let service = MovieDBServiceMock()
        let tester = HookTester(("path1", .medium)) { path, size in
            useMovieImage(for: path, size: size)
        } environment: {
            $0[Context<Dependency>.self] = Dependency(service: service)
        }

        XCTAssertNil(tester.value)

        service.imageResult = .failure(error)
        wait(timeout: 0.1)

        XCTAssertNil(tester.value)
    }
}
