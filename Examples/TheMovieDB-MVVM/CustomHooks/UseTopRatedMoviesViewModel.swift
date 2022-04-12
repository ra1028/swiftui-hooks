import Hooks
import SwiftUI

struct TopRatedMoviesViewModel {
    let selectedMovie: Binding<Movie?>
    let loadPhase: AsyncPhase<[Movie], Error>
    let hasNextPage: Bool
    let load: () async -> Void
    let loadNext: () async -> Void
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
        load: {
            await load(1)
        },
        loadNext: {
            if let currentPage = latestResponse?.page {
                await loadNext(currentPage + 1)
            }
        }
    )
}

private func useLoadMovies() -> (phase: AsyncPhase<PagedResponse<Movie>, Error>, load: (Int) async -> Void) {
    let page = useRef(0)
    let service = useContext(Context<Dependency>.self).service
    let (phase, load) = useAsyncPerform {
        try await service.getTopRated(page: page.current)
    }

    return (
        phase: phase,
        load: { newPage in
            page.current = newPage
            await load()
        }
    )
}
