import Foundation
import Hooks

func useFetchPage<Response: Decodable>(
    _: Response.Type,
    path: String,
    parameters: [String: String] = [:]
) -> (phase: AsyncPhase<[Response], URLError>, fetch: () -> Void) {
    let page = useRef(0)
    let results = useRef([Response]())

    var parameters = parameters
    parameters["page"] = String(page.current + 1)

    let (phase, fetch) = useFetch(PagedResponse<Response>.self, path: path, parameters: parameters) { response in
        page.current = response.page
        results.current += response.results
    }

    let newPhase =
        page.current == 0
        ? phase.map { _ in results.current }
        : .success(results.current)

    return (phase: newPhase, fetch: fetch)
}
