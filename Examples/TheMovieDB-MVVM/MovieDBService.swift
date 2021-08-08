import Combine
import UIKit

protocol MovieDBServiceProtocol {
    func getImage(path: String?, size: NetworkImageSize) -> AnyPublisher<UIImage?, URLError>
    func getTopRated(page: Int) -> AnyPublisher<PagedResponse<Movie>, URLError>
}

struct MovieDBService: MovieDBServiceProtocol {
    private let session = URLSession(configuration: .default)
    private let baseURL = URL(string: "https://api.themoviedb.org/3")!
    private let imageBaseURL = URL(string: "https://image.tmdb.org/t/p")!
    private let apiKey = "3de15b0402484d3d089399ea0b8d98f1"
    private let jsonDecoder: JSONDecoder = {
        let formatter = DateFormatter()
        let decoder = JSONDecoder()
        formatter.dateFormat = "yyy-MM-dd"
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()

    func getImage(path: String?, size: NetworkImageSize) -> AnyPublisher<UIImage?, URLError> {
        guard let path = path else {
            return Just(nil)
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }

        let url =
            imageBaseURL
            .appendingPathComponent(size.rawValue)
            .appendingPathComponent(path)

        return session.dataTaskPublisher(for: url)
            .map { data, _ in UIImage(data: data) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func getTopRated(page: Int) -> AnyPublisher<PagedResponse<Movie>, URLError> {
        get(path: "movie/top_rated", parameters: ["page": String(page)])
    }
}

private extension MovieDBService {
    func get<Response: Decodable>(path: String, parameters: [String: String]) -> AnyPublisher<Response, URLError> {
        session.dataTaskPublisher(for: makeGetRequest(path: path, parameters: parameters))
            .map(\.data)
            .decode(type: Response.self, decoder: jsonDecoder)
            .mapError { $0 as? URLError ?? URLError(.cannotDecodeContentData) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func makeGetRequest(path: String, parameters: [String: String]) -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]

        for (name, value) in parameters {
            queryItems.append(URLQueryItem(name: name, value: value))
        }

        urlComponents.queryItems = queryItems

        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"

        return urlRequest
    }
}
