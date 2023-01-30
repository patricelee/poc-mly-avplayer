extension MessageCode {
    static var WMV400 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WMV400", "400", "Restful view: Bad request.",
        "Bad request.")
    static var WMV403 = MessageCodeObject(
        StatusCodes.FORBIDDEN,
        "WMV403", "403", "Restful view: Forbidden.",
        "Forbidden.")
    static var WMV404 = MessageCodeObject(
        StatusCodes.NOT_FOUND,
        "WMV404", "404", "Restful view: Not found.",
        "Not found.")
    static var EMV500 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMV500", "500", "Restful view: Internal server error.",
        "Internal server error.")

    // Auxiliary util
    static var EMU000 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU000", "520", "Auxiliary util: Internal error.",
        "Backoff operation has been exhausted.")
    static var EMU010 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU010", "520", "Auxiliary util: Internal error.",
        "Future operation timeout exceeded.")
    static var EMU011 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU011", "520", "Auxiliary util: Internal error.",
        "Future condition has been done.")
    static var EMU012 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU012", "520", "Auxiliary util: Internal error.",
        "Future condition has never been done.")
    static var EMU013 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU013", "520", "Auxiliary util: Internal error.",
        "Future precondition has been done.")
    static var EMU014 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU014", "520", "Auxiliary util: Internal error.",
        "Future task has been cancelled.")
    static var EMU015 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU015", "520", "Auxiliary util: Internal error.",
        "Future task loop has been cancelled.")
    static var EMU016 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU016", "520", "Auxiliary util: Internal error.",
        "Future task retry exceeded.")
    static var EMU017 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU017", "520", "Auxiliary util: Internal error.",
        "Future task manager has been aborted.")
    static var EMU018 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU018", "520", "Auxiliary util: Internal error.",
        "Future lock has been released.")
    static var EMU019 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU019", "520", "Auxiliary util: Internal error.",
        "Future channel has been closed.")
    static var EMU050 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU050", "520", "Auxiliary util: Internal error.",
        "Flow key to a value must be in flow storage.")
    static var EMU060 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU060", "520", "Auxiliary util: Internal error.",
        "Graceful processor received some process errors.")
    static var EMU070 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "EMU070", "525", "Auxiliary util: Internal error.",
        "Request carrier encountered an error before response.")
    static var EMU071 = MessageCodeObject(
        StatusCodes.SERVICE_UNAVAILABLE,
        "EMU071", "526", "Auxiliary util: External API error.",
        "Request carrier received unexpected failure response.")
    static var WMU072 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WMU072", "527", "Auxiliary util: External API error.",
        "Request carrier received validation failure response.")
}
