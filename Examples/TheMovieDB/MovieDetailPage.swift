import Hooks
import SwiftUI

struct MovieDetailPage: HookView {
    let movie: Movie

    var hookBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ZStack(alignment: .topLeading) {
                    backdropImage
                    closeButton

                    HStack(alignment: .top) {
                        posterImage

                        Text(movie.title)
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(Color(.label))
                            .colorInvert()
                            .padding(8)
                            .shadow(radius: 4, y: 2)
                    }
                    .padding(.top, 70)
                    .padding(.horizontal, 16)
                }

                VStack(alignment: .leading, spacing: 16) {
                    informationSection
                    overviewSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
    }

    @ViewBuilder
    var closeButton: some View {
        let presentation = useEnvironment(\.presentationMode)

        Button(action: { presentation.wrappedValue.dismiss() }) {
            ZStack {
                Color(.systemGray)
                    .opacity(0.4)
                    .clipShape(Circle())
                    .frame(width: 34, height: 34)

                Image(systemName: "xmark")
                    .imageScale(.large)
                    .font(Font.subheadline.bold())
                    .foregroundColor(Color(.systemGray))
            }
            .padding(16)
        }
    }

    @ViewBuilder
    var backdropImage: some View {
        let image = useNetworkImage(for: movie.backdropPath, size: .medium)

        ZStack {
            Color(.systemGroupedBackground)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }

            Color(.systemBackground).colorInvert().opacity(0.8)
        }
        .aspectRatio(CGSize(width: 5, height: 2), contentMode: .fit)
    }

    @ViewBuilder
    var posterImage: some View {
        let image = useNetworkImage(for: movie.posterPath, size: .medium)

        ZStack {
            Color(.systemGroupedBackground)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 150, height: 230)
        .cornerRadius(8)
        .shadow(radius: 4, y: 2)
    }

    var informationSection: some View {
        HStack {
            Text(Int(movie.voteAverage * 10).description)
                .bold()
                .font(.title)
                .foregroundColor(Color(.systemGreen))
                + Text("%")
                .bold()
                .font(.caption)
                .foregroundColor(Color(.systemGreen))

            Text(DateFormatter.shared.string(from: movie.releaseDate))
                .font(.headline)
                .foregroundColor(Color(.secondaryLabel))
        }
    }

    var overviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.title)
                .bold()

            if let overview = movie.overview {
                Text(overview)
                    .font(.system(size: 24))
                    .foregroundColor(Color(.secondaryLabel))
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
