enum SystemModeName {
    static let MCDN_ONLY = "mcdn_only"
    static let P2P_MCDN = "p2p_mcdn"
    static let P2P_P2S = "p2p_p2s"
    static let P2S_ONLY = "p2s_only"

    static let systemP2PModes: Set = [
        P2P_MCDN,
        P2P_P2S
    ]

    static let systemP2PFallbackModes = [
        [
            P2P_MCDN,
            MCDN_ONLY
        ],
        [
            P2P_P2S,
            P2S_ONLY
        ]
    ]
}
