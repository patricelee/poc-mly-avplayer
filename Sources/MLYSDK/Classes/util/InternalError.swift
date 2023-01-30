class InternalError: Error {

    var _code: MessageCodeObject
    var _cause: Error?
    var _params: [String: Any]?

    init (
        _ _code: MessageCodeObject,
        _ _cause: Error? = nil,
        _ _params: [String: Any]? = nil) {
        self._code = _code
        self._cause = _cause
        self._params = _params
    }

    var name: String {
        return "\(type(of: self))"
    }

    var message: String {
        return "<\(name)| \(self._code.logContent)> caused from: \(self._cause?.localizedDescription ?? "")"
    }

    var code: MessageCodeObject {
        return self._code
    }

    var cause: Error? {
        return self._cause
    }

    var params: [String: Any]? {
        return self._params
    }
}

class UnexpectedError: InternalError {
    static func  aggravate(_ error: Error) -> Error {
        if let err = error as? ValidationError {
            return UnexpectedError(err.code, err.cause, err.params)
        }
        return error
    }
}
