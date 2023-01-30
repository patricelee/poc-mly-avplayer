enum MessageCode {
    static let ESC000 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC000", "550", "Kernel core: Internal error.",
        "File request has been aborted.")
    static let ESC001 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC001", "550", "Kernel core: Internal error.",
        "File downloader has been aborted.")
    static let ESC010 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC010", "550", "Kernel core: Internal error.",
        "HTTP downloader proxy request failed.")
    static let ESC011 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC011", "550", "Kernel core: Internal error.",
        "HTTP downloader proxy cannot handle the response.")
    static let ESC012 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC012", "550", "Kernel core: Internal error.",
        "MCDN downloader proxy is not available within timeout.")
    static let ESC020 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC020", "550", "Kernel core: Internal error.",
        "Node downloader proxy cannot fetch available node daemon.")
    static let ESC021 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC021", "550", "Kernel core: Internal error.",
        "Node downloader proxy is detected with no progress.")
    static let ESC030 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC030", "550", "Kernel core: Internal error.",
        "User downloader proxy cannot handle the unshareable resource.")
    static let ESC031 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC031", "550", "Kernel core: Internal error.",
        "User downloader proxy cannot handle the urgent resource.")
    static let ESC032 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC032", "550", "Kernel core: Internal error.",
        "User downloader proxy is not chosen this time.")
    static let ESC033 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC033", "550", "Kernel core: Internal error.",
        "User downloader proxy cannot fetch available user daemon.")
    static let ESC034 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESC034", "550", "Kernel core: Internal error.",
        "User downloader proxy is detected with no progress.")

    // Kernel protocol
    static let ISP200 = MessageCodeObject(
        StatusCodes.OK,
        "ISP200", "200", "Kernel protocol: OK.",
        "OK.")
    static let ESP000 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESP000", "560", "Kernel protocol: External API error.",
        "An error response is received.")
    static let ESP001 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESP001", "562", "Kernel protocol: Internal error.",
        "An error occurred while processing a request.")
    static let ESP010 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESP010", "560", "Kernel protocol: Internal error.",
        "Peer broker cannot be found.")
    static let ESP011 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESP011", "560", "Kernel protocol: Internal error.",
        "Node broker cannot be found.")
    static let ESP012 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESP012", "560", "Kernel protocol: Internal error.",
        "Tracker broker cannot be found.")
    static let WSP020 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WSP020", "561", "Kernel protocol: Invalid parameter.",
        "Resource cache cannot be found.")

    // Kernel service
    static let ESS000 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESS000", "570", "Kernel service: Internal error.",
        "Peer broker has been closed.")
    static let ESS001 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESS001", "570", "Kernel service: Internal error.",
        "Peer daemon has exited.")
    static let WSS002 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WSS002", "571", "Kernel service: Invalid parameter.",
        "Peer daemon cannot handle the action.")
    static let ESS003 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESS003", "570", "Kernel service: Internal error.",
        "Peer daemon cannot handle the command.")
    static let ESS005 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESS005", "572", "Kernel service: Internal error.",
        "User manager has reached max peer connections.")
    static let ESS006 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESS006", "572", "Kernel service: Internal error.",
        "User manager rejected a peer which had failed.")
    static let ESS007 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESS007", "572", "Kernel service: Internal error.",
        "User manager rejected a peer which is in use.")
    static let ESS010 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESS010", "570", "Kernel service: Internal error.",
        "Swarm daemon cannot be found.")
    static let ESS011 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESS011", "570", "Kernel service: Internal error.",
        "Swarm daemon cannot handle the command.")
    static let ESS020 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESS020", "570", "Kernel service: Internal error.",
        "Tracker broker has been closed.")
    static let ESS021 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESS021", "570", "Kernel service: Internal error.",
        "Tracker daemon has exited.")
    static let ESS022 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESS022", "570", "Kernel service: Internal error.",
        "Tracker launcher cannot handle the feedback.")

    // System booter
    static let ESB000 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESB000", "450", "System booter: Internal error.",
        "System component activate failed.")
    static let WSB010 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WSB010", "460", "System booter: Invalid parameter.",
        "Kernel parameters cannot be validated successfully.")
    static let WSB011 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WSB011", "460", "System booter: Invalid parameter.",
        "Kernel parameter must be configured.")
    static let WSB012 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WSB012", "460", "System booter: Invalid parameter.",
        "Kernel parameter cannot be configured again.")

    // Driver essential
    static let WSV000 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WSV000", "601", "Driver essential: Invalid environ.",
        "Driver manager cannot activate without WebRTC support.")
    static let WSV001 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WSV001", "601", "Driver essential: Invalid procedure.",
        "Driver manager cannot activate before properly configured.")
    static let WSV002 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WSV002", "601", "Driver essential: Invalid procedure.",
        "Driver manager cannot be operated before it is activated.")

    // Driver integration
    static let WSV050 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WSV050", "621", "Driver integration: Invalid parameter.",
        "HLS loader cannot handle the response type.")
    static let ESV051 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESV051", "621", "Driver integration: Internal error.",
        "HLS controller cannot buffer a play segment which is aborted.")

    // Driver peripheral
    static let ESV100 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESV100", "650", "Driver peripheral: Internal error.",
        "Video.js plugin method has never been implemented.")
    static let ESV101 = MessageCodeObject(
        StatusCodes.INTERNAL_SERVER_ERROR,
        "ESV101", "650", "Driver peripheral: Internal error.",
        "Video.js source handler method has never been implemented.")
    static let WSV110 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WSV110", "651", "Driver peripheral: Invalid environ.",
        "Video.js HLS plugin cannot be registered because its version is incompatible.")
    static let WSV111 = MessageCodeObject(
        StatusCodes.BAD_REQUEST,
        "WSV111", "651", "Driver peripheral: Invalid environ.",
        "Video.js HLS plugin cannot be registered because HLS protocol is not supported.")
}
