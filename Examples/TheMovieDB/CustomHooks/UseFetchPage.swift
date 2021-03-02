import Foundation
import Hooks

func useFetchPage<Response: Decodable>(
    _: Response.Type,
    path: String,
    parameters: [String: String] = [:]
) -> (status: AsyncStatus<[Response], URLError>, fetch: () -> Void) {
    let page = useRef(0)
    let results = useRef([Response]())

    var parameters = parameters
    parameters["page"] = String(page.current + 1)

    let (status, fetch) = useFetch(PagedResponse<Response>.self, path: path, parameters: parameters) { response in
        page.current = response.page
        results.current += response.results
    }

    guard page.current == 0 else {
        return (status: .success(results.current), fetch: fetch)
    }

    switch status {
    case .pending:
        return (status: .pending, fetch: fetch)

    case .running:
        return (status: .running, fetch: fetch)

    case .success:
        return (status: .success(results.current), fetch: fetch)

    case .failure(let error):
        return (status: .failure(error), fetch: fetch)
    }
}
