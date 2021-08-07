import Hooks
import SwiftUI

struct TopRatedMoviesPage: HookView {
    var hookBody: some View {
        let viewModel = useTopRatedMoviesViewModel()

        NavigationView {
            ZStack {
                switch viewModel.loadPhase {
                case .success(let movies):
                    moviesList(data: movies, viewModel: viewModel)

                case .failure(let error):
                    failure(error, viewModel: viewModel)

                case .pending, .running:
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Top Rated Movies")
            .background(Color(.secondarySystemBackground).ignoresSafeArea())
            .sheet(item: viewModel.selectedMovie) { movie in
                MovieDetailPage(movie: movie)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: viewModel.load)
    }

    func failure(_ error: URLError, viewModel: TopRatedMoviesViewModel) -> some View {
        VStack(spacing: 24) {
            Text("Failed to load movies").font(.system(.title2))

            Button(action: viewModel.load) {
                Text("Retry").font(.system(.title3)).bold()
            }
        }
    }

    func moviesList(data movies: [Movie], viewModel: TopRatedMoviesViewModel) -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                Section(
                    footer: Group {
                        if viewModel.hasNextPage {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .onAppear(perform: viewModel.loadNext)
                        }
                    },
                    content: {
                        ForEach(movies) { movie in
                            movieCard(movie) {
                                viewModel.selectedMovie.wrappedValue = movie
                            }
                        }
                    }
                )
            }
            .padding(8)
        }
    }

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
