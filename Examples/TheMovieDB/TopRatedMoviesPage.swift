import Hooks
import SwiftUI

struct TopRatedMoviesPage: HookView {
    var hookBody: some View {
        let (status, fetch) = useFetchTopRatedMovies()
        let selectedMovie = useState(nil as Movie?)

        NavigationView {
            Group {
                switch status {
                case .success(let page):
                    moviesList(page, onLoadMore: fetch) { movie in
                        selectedMovie.wrappedValue = movie
                    }

                case .failure(let error):
                    failure(error, onReload: fetch)

                case .pending, .running:
                    loading
                }
            }
            .navigationTitle("Top Rated Movies")
            .background(Color(.secondarySystemBackground).ignoresSafeArea())
            .sheet(item: selectedMovie, onDismiss: { selectedMovie.wrappedValue = nil }) { movie in
                MovieDetailPage(movie: movie)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: fetch)
    }

    var loading: some View {
        ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func failure(_ error: URLError, onReload: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Text("Failed to fetch movies")
            Button("Reload", action: onReload)
        }
    }

    @ViewBuilder
    func moviesList(
        _ movies: [Movie],
        onLoadMore: @escaping () -> Void,
        onSelect: @escaping (Movie) -> Void
    ) -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(movies) { movie in
                    movieCard(movie) {
                        onSelect(movie)
                    }
                }

                Color.clear.onAppear(perform: onLoadMore)
            }
            .padding(8)
        }
    }

    @ViewBuilder
    func movieCard(_ movie: Movie, onPressed: @escaping () -> Void) -> some View {
        HookScope {
            let image = useNetworkImage(for: movie.posterPath, size: .medium)

            Button(action: onPressed) {
                VStack(alignment: .leading, spacing: .zero) {
                    ZStack {
                        Color(.systemGroupedBackground)

                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                    .aspectRatio(CGSize(width: 3, height: 4), contentMode: .fit)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.title)
                            .bold()
                            .foregroundColor(Color(.label))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(alignment: .bottom) {
                            Text(Int(movie.voteAverage * 10).description)
                                .bold()
                                .font(.callout)
                                .foregroundColor(Color(.systemGreen))
                                + Text("%")
                                .bold()
                                .font(.caption2)
                                .foregroundColor(Color(.systemGreen))

                            Text(DateFormatter.shared.string(from: movie.releaseDate))
                                .font(.callout)
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    }
                    .padding(8)
                    .frame(height: 100, alignment: .top)

                    Spacer(minLength: .zero)
                }
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 4, y: 2)
            }
        }
    }
}

private extension DateFormatter {
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
