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

    let newStatus =
        page.current == 0
        ? status.map { _ in results.current }
        : .success(results.current)

    return (status: newStatus, fetch: fetch)
}
