struct PagedResponse<T: Decodable>: Decodable {
    let page: Int
    let totalPages: Int
    let results: [T]

    var hasNextPage: Bool {
        page < totalPages
    }
}

extension PagedResponse: Equatable where T: Equatable {}
