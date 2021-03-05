import Combine
import Hooks
import UIKit

func useNetworkImage(for path: String, size: NetworkImageSize) -> UIImage? {
    func makeURL() -> URL {
        URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)").unsafelyUnwrapped.appendingPathComponent(path)
    }

    let status = usePublisher(.preserved(by: [path, size.rawValue])) {
        URLSession.shared.dataTaskPublisher(for: makeURL())
            .map { data, _ in UIImage(data: data) }
            .catch { _ in Just(nil) }
            .receive(on: DispatchQueue.main)
    }

    return try? status.get() ?? nil
}
