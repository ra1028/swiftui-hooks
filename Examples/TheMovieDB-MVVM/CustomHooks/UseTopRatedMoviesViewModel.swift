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

    useLayoutEffect(.prevented(by: loadPhase.isSuccess)) {
        nextMovies.current = []
        return nil
    }

    useLayoutEffect(.prevented(by: loadNextPhase.isSuccess)) {
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
