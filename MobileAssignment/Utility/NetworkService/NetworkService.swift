import Foundation
import Alamofire

// MARK: - Network Service
final class NetworkService {
    static let shared = NetworkService()

    private init() {}

    /// Generic request method using Alamofire with continuation pattern
    func request<T: Codable>(
        to url: String,
        parameters: [String: Any]?,
        method: HTTPMethod,
        encoding: APIParameterEncoding
    ) async throws -> T {

        Logger.shared.info("Making \(method.rawValue) request to: \(url)", title: "Network Service")

        let afMethod: Alamofire.HTTPMethod = {
            switch method {
            case .get: return .get
            case .post: return .post
            case .put: return .put
            case .delete: return .delete
            case .patch: return .patch
            }
        }()

        return try await withCheckedThrowingContinuation { continuation in
            let request = AF.request(
                url,
                method: afMethod,
                parameters: parameters,
                encoding: getAlamofireEncoding(encoding),
                headers: getHeaders(encoding: encoding, method: method)
            )

            request.cURLDescription { description in
                Logger.shared.info(description, title: "cURL")
            }

            request.validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let decodedResponse):
                        Logger.shared.success("Successfully decoded response", title: "Network Service")
                        continuation.resume(returning: decodedResponse)
                    case .failure(let error):
                        if let afError = error.asAFError {
                            Logger.shared.error("Alamofire error: \(afError.localizedDescription)", title: "Network Service")
                            continuation.resume(throwing: NetworkError.alamofireError(afError))
                        } else {
                            Logger.shared.error("Network error: \(error.localizedDescription)", title: "Network Service")
                            continuation.resume(throwing: NetworkError.networkError(error))
                        }
                    }
                }
        }
    }

    // MARK: - Private Helper Methods

    private func getAlamofireEncoding(_ encoding: APIParameterEncoding) -> ParameterEncoding {
        switch encoding {
        case .jsonEncoded:
            return JSONEncoding.default
        case .urlEncoded:
            return URLEncoding.default
        case .none:
            return URLEncoding.default
        }
    }

    private func getHeaders(encoding: APIParameterEncoding, method: HTTPMethod) -> HTTPHeaders {
        var headers: HTTPHeaders = []

        switch encoding {
        case .jsonEncoded:
            headers["Content-Type"] = "application/json"
        case .urlEncoded:
            headers["Content-Type"] = "application/x-www-form-urlencoded"
        case .none:
            break
        }

        // Add common headers
        headers["Accept"] = "application/json"
        headers["User-Agent"] = "MobileAssignment/1.0"

        return headers
    }
}
