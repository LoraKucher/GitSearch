import Foundation

struct Repository: Decodable {
    let id: Int
    let name: String
    let url: String
    let stars: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url = "html_url"
        case stars = "stargazers_count"
    }
}

struct RepositoryResponse: Decodable {
    let items: [Repository]
}

extension Repository {
    fileprivate static func parse(_ data: Data?) throws -> [Repository] {
        guard let data = data,
            let response = try? JSONDecoder().decode(RepositoryResponse.self, from: data) else {
                return []
        }
        return response.items
    }
}
