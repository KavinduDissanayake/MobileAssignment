import Foundation

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - API Parameter Encoding
enum APIParameterEncoding {
    case urlEncoded
    case jsonEncoded
    case none
}
