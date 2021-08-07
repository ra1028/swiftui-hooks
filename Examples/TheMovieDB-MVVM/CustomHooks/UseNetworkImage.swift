import Combine
import Hooks
import UIKit

func useNetworkImage(for path: String?, size: NetworkImageSize) -> UIImage? {
    guard let path = path else {
        return nil
    }

    func makeURL() -> URL {
        URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)")
            .unsafelyUnwrapped
            .appendingPathComponent(path)
    }

    let phase = usePublisher(.preserved(by: [path, size.rawValue])) {
        URLSession.shared.dataTaskPublisher(for: makeURL())
            .map { data, _ in UIImage(data: data) }
            .receive(on: DispatchQueue.main)
    }

    return phase.value ?? nil
}
