struct PagedResponse<T: Decodable>: Decodable {
    let page: Int
    let results: [T]
}
