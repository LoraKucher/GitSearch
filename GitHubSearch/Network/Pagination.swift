import Foundation

final class Pagination {
    
    private static let parseLinksPattern = "\\s*,?\\s*<([^\\>]*)>\\s*;\\s*rel=\"([^\"]*)\""
    private static let linksRegex = try! NSRegularExpression(pattern: parseLinksPattern, options: [.allowCommentsAndWhitespace])
    
    private static func parseLinks(_ links: String) throws -> [String: String] {

          let length = (links as NSString).length
          let matches = Pagination.linksRegex.matches(in: links, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: length))

          var result: [String: String] = [:]

          for m in matches {
              let matches = (1 ..< m.numberOfRanges).map { rangeIndex -> String in
                  let range = m.range(at: rangeIndex)
                  let startIndex = links.index(links.startIndex, offsetBy: range.location)
                  let endIndex = links.index(links.startIndex, offsetBy: range.location + range.length)
                  return String(links[startIndex ..< endIndex])
              }

              if matches.count != 2 {
                  assertionFailure("Error parsing links")
              }

              result[matches[1]] = matches[0]
          }
          
          return result
      }
    
    static func parseNextURL(_ httpResponse: HTTPURLResponse) throws -> URL? {
        guard let serializedLinks = httpResponse.allHeaderFields["Link"] as? String else {
            return nil
        }

        let links = try Pagination.parseLinks(serializedLinks)

        guard let nextPageURL = links["next"] else {
            return nil
        }

        guard let nextUrl = URL(string: nextPageURL) else {
            preconditionFailure("Error parsing next url `\(nextPageURL)`")
        }

        return nextUrl
    }
}
