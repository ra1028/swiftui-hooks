import Combine
import Hooks
import UIKit

func useMovieImage(for path: String?, size: NetworkImageSize) -> UIImage? {
    let service = useContext(Context<Dependency>.self).service
    let phase = usePublisher(.prevented(by: [path, size.rawValue])) {
        service.getImage(path: path, size: size)
    }

    return phase.value ?? nil
}
