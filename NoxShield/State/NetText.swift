import Foundation

/// What went wrong on the network, in one sentence per cause, the same as on Android, so a failed
/// send says whether Tor had no route yet, the connection dropped, or the other side refused.
func network(_ error: NetError) -> String {
    switch error {
    case .WrongChain: return "A server answered for the wrong network. Nothing was signed."
    case .WrongRelayer: return "The relayer answered as someone else. Nothing was sent."
    case .Rejected(let code): return "The network refused that (code \(code)). Nothing changed."
    case .ProxyUnreachable: return "Tor is still starting. Try again in a moment. Nothing was sent."
    case .ProxyRefused:
        return "Tor could not open a route there yet. Try again in a moment. Nothing was sent."
    case .Transport: return "The connection over Tor dropped before an answer came. Try again."
    case .ReplyShape, .ReplyTooLarge:
        return "A server answered in a form the wallet does not read. Nothing changed."
    default: return "The network could not be reached over Tor. Nothing was sent."
    }
}
