import Foundation

enum ThreadUIDExtractor {
    static func firstThreadUID(from searchData: Data) -> String? {
        guard let response = try? JSONDecoder().decode(SearchResponseDTO.self, from: searchData) else {
            return nil
        }
        
        guard let uid = response.segments.first?.thread.uid, !uid.isEmpty else {
            return nil
        }
        
        return uid
    }
}

private struct SearchResponseDTO: Decodable {
    let segments: [SegmentDTO]
}

private struct SegmentDTO: Decodable {
    let thread: ThreadDTO
}

private struct ThreadDTO: Decodable {
    let uid: String
}
