import Foundation

public enum MMXHttpError: Int {
    case Ok = 200
    case BadRequest = 400
    case Conflict = 409
    case NotFound = 404
    case ServerError = 500
    case ServerUnavailable = 503
    case ServerTimeout = 504
    case Unauthorized = 401
    case Offline = -1009
}