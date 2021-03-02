import Foundation
import Hooks

func useFetch<Response: Decodable>(
    _: Response.Type,
    path: String,
    parameters: [String: String] = [:],
    onReceiveResponse: ((Response) -> Void)? = nil
) -> (status: AsyncStatus<Response, URLError>, fetch: () -> Void) {
    func makeURLRequest() -> URLRequest {
        let url = URL(string: "https://api.themoviedb.org/3").unsafelyUnwrapped.appendingPathComponent(path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true).unsafelyUnwrapped

        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: "3de15b0402484d3d089399ea0b8d98f1")
        ]

        for (name, value) in parameters {
            urlComponents.queryItems?.append(URLQueryItem(name: name, value: value))
        }

        var urlRequest = URLRequest(url: urlComponents.url.unsafelyUnwrapped)
        urlRequest.httpMethod = "GET"

        return urlRequest
    }

    let (status, subscribe) = usePublisherSubscribe {
        URLSession.shared.dataTaskPublisher(for: makeURLRequest())
            .map(\.data)
            .decode(type: Response.self, decoder: jsonDecoder)
            .mapError { $0 as? URLError ?? URLError(.cannotDecodeContentData) }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: onReceiveResponse)
    }

    return (status: status, fetch: subscribe)
}

private let jsonDecoder: JSONDecoder = {
    let formatter = DateFormatter()
    let decoder = JSONDecoder()
    formatter.dateFormat = "yyy-MM-dd"
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .formatted(formatter)
    return decoder
}()
