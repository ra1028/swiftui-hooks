import Hooks
import SwiftUI

struct TopRatedMoviesViewModel {
    let selectedMovie: Binding<Movie?>
    let loadPhase: AsyncPhase<[Movie], URLError>
    let hasNextPage: Bool
    let load: () -> Void
    let loadNext: () -> Void
}

func useTopRatedMoviesViewModel() -> TopRatedMoviesViewModel {
    let selectedMovie = useState(nil as Movie?)
    let nextMovies = useRef([Movie]())
    let (loadPhase, load) = useLoadMovies()
    let (loadNextPhase, loadNext) = useLoadMovies()
    let latestResponse = loadNextPhase.value ?? loadPhase.value

    useLayoutEffect(.preserved(by: loadPhase.isSuccess)) {
        nextMovies.current = []
        return nil
    }

    useLayoutEffect(.preserved(by: loadNextPhase.isSuccess)) {
        nextMovies.current += loadNextPhase.value?.results ?? []
        return nil
    }

    return TopRatedMoviesViewModel(
        selectedMovie: selectedMovie,
        loadPhase: loadPhase.map {
            $0.results + nextMovies.current
        },
        hasNextPage: latestResponse?.hasNextPage ?? false,
        load: { load(1) },
        loadNext: {
            if let currentPage = latestResponse?.page {
                loadNext(currentPage + 1)
            }
        }
    )
}

private func useLoadMovies() -> (phase: AsyncPhase<PagedResponse<Movie>, URLError>, load: (Int) -> Void) {
    let page = useRef(0)
    let service = useContext(Context<Dependency>.self).service
    let (phase, load) = usePublisherSubscribe {
        service.getTopRated(page: page.current)
    }

    return (
        phase: phase,
        load: { newPage in
            page.current = newPage
            load()
        }
    )
}

private func makeMoviesRequest(page: Int) -> URLRequest {
    let url = URL(string: "https://api.themoviedb.org/3").unsafelyUnwrapped.appendingPathComponent("movie/top_rated")
    var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true).unsafelyUnwrapped

    urlComponents.queryItems = [
        URLQueryItem(name: "api_key", value: "3de15b0402484d3d089399ea0b8d98f1"),
        URLQueryItem(name: "page", value: String(page)),
    ]

    var urlRequest = URLRequest(url: urlComponents.url.unsafelyUnwrapped)
    urlRequest.httpMethod = "GET"

    return urlRequest
}

private let jsonDecoder: JSONDecoder = {
    let formatter = DateFormatter()
    let decoder = JSONDecoder()
    formatter.dateFormat = "yyy-MM-dd"
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .formatted(formatter)
    return decoder
}()
