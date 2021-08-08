import Hooks
import XCTest

@testable import TheMovieDB_MVVM

final class UseMovieImageTests: XCTestCase {
    func testSuccess() {
        let service = MovieDBServiceMock()
        let tester = HookTester(("path1", .medium)) { path, size in
            useMovieImage(for: path, size: size)
        } environment: {
            $0[Context<Dependency>.self] = Dependency(service: service)
        }

        let image1 = UIImage()
        let image2 = UIImage()
        let image3 = UIImage()

        XCTAssertNil(tester.value)

        service.imageSubject.send(image1)

        XCTAssertTrue(tester.value === image1)

        tester.update()

        XCTAssertTrue(tester.value === image1)

        tester.update(with: ("path1", .original))

        XCTAssertNil(tester.value)

        service.imageSubject.send(image2)

        XCTAssertTrue(tester.value === image2)

        tester.update(with: ("path2", .original))

        XCTAssertNil(tester.value)

        service.imageSubject.send(image3)

        XCTAssertTrue(tester.value === image3)
    }

    func testFailure() {
        let service = MovieDBServiceMock()
        let tester = HookTester(("path1", .medium)) { path, size in
            useMovieImage(for: path, size: size)
        } environment: {
            $0[Context<Dependency>.self] = Dependency(service: service)
        }

        let error = URLError(.badURL)

        XCTAssertNil(tester.value)

        service.imageSubject.send(completion: .failure(error))

        XCTAssertNil(tester.value)
    }
}
