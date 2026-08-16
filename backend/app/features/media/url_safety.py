import ipaddress
import socket
from urllib.parse import urlparse

ALLOWED_SCHEMES = {"http", "https"}


def is_safe_url(url: str) -> bool:
    """Reject URLs that could be used for SSRF: non-http(s) schemes, or
    hosts that resolve to private/loopback/link-local/reserved IP ranges."""
    try:
        parsed = urlparse(url)
    except ValueError:
        return False

    if parsed.scheme not in ALLOWED_SCHEMES or not parsed.hostname:
        return False

    try:
        addr_infos = socket.getaddrinfo(parsed.hostname, None)
    except socket.gaierror:
        return False

    for _, _, _, _, sockaddr in addr_infos:
        ip = ipaddress.ip_address(sockaddr[0])
        if (
            ip.is_private
            or ip.is_loopback
            or ip.is_link_local
            or ip.is_reserved
            or ip.is_multicast
            or ip.is_unspecified
        ):
            return False

    return True
