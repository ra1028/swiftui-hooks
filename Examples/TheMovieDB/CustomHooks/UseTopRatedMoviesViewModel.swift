import Hooks
import SwiftUI

struct TopRatedMoviesViewModel {
    let loadPhase: AsyncPhase<[Movie], URLError>
    let selectedMovie: Binding<Movie?>
    let hasNextPage: Bool
    let load: () -> Void
    let loadNext: () -> Void
}

func useTopRatedMoviesViewModel() -> TopRatedMoviesViewModel {
    let loadPhase = useRef(AsyncPhase<PagedResponse<Movie>, URLError>.pending)
    let selectedMovie = useState(nil as Movie?)
    let (newLoadPhase, load) = useLoadMovies()

    useLayoutEffect(.preserved(by: newLoadPhase.map(\.page))) {
        if !loadPhase.current.isSuccess {
            loadPhase.current = newLoadPhase
        }
        else if case .success(let response) = newLoadPhase {
            let lastResults = loadPhase.current.value?.results ?? []
            let response = PagedResponse(
                page: response.page,
                totalPages: response.totalPages,
                results: lastResults + response.results
            )
            loadPhase.current = .success(response)
        }
        return nil
    }

    return TopRatedMoviesViewModel(
        loadPhase: loadPhase.current.map(\.results),
        selectedMovie: selectedMovie,
        hasNextPage: loadPhase.current.value?.hasNextPage ?? false,
        load: {
            loadPhase.current = .pending
            load(1)
        },
        loadNext: {
            guard let page = loadPhase.current.value?.page else {
                return
            }
            load(page + 1)
        }
    )
}

private func useLoadMovies() -> (phase: AsyncPhase<PagedResponse<Movie>, URLError>, load: (Int) -> Void) {
    let page = useRef(0)
    let (phase, load) = usePublisherSubscribe {
        URLSession.shared.dataTaskPublisher(for: makeMoviesRequest(page: page.current))
            .map(\.data)
            .decode(type: PagedResponse<Movie>.self, decoder: jsonDecoder)
            .mapError { $0 as? URLError ?? URLError(.cannotDecodeContentData) }
            .receive(on: DispatchQueue.main)
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
