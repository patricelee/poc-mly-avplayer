class ValidationError: InternalError {
    var error: MessageCodeObject?
    init(_ error: MessageCodeObject) {
        super.init(error)
        self.error = error
    }
}
