import Combine
import Hooks
import UIKit

func useMovieImage(for path: String?, size: NetworkImageSize) -> UIImage? {
    let service = useContext(Context<Dependency>.self).service
    let phase = useAsync(.preserved(by: [path, size.rawValue])) {
        try await service.getImage(path: path, size: size)
    }

    return phase.value ?? nil
}
