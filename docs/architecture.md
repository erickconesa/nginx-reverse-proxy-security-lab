# Architecture — Nginx Reverse Proxy & Web Security Lab

## 1. Overview

This lab demonstrates the implementation of a secure web entry point using **Nginx as a reverse proxy** on Ubuntu Server.

The infrastructure combines HTTPS termination, Layer 7 routing, HTTP security headers and IP-based request limiting to protect internal containerized services.

The project was developed during my second year of the Higher Vocational Training Programme in Network Computer Systems Administration (ASIR).

## 2. Architecture Diagram

```text
              HTTPS CLIENT
                   |
                   | HTTPS / TLS
                   v
        +-----------------------+
        | Ubuntu Server         |
        | Nginx Reverse Proxy   |
        |-----------------------|
        | TLS Termination       |
        | HTTP Security Headers |
        | IP Rate Limiting      |
        +-----------------------+
                   |
                   | HTTP via loopback
                   v
        +-----------------------+
        | Docker Network        |
        | Internal Web Proxy    |
        +-----------------------+
                   |
                   | Internal routing
                   v
        +-----------------------+
        | Private Application   |
        | Service               |
        +-----------------------+
                   |
                   | Private network
                   v
        +-----------------------+
        | Database Service      |
        | No public DB ports    |
        +-----------------------+
```

*The diagram is intentionally generic and does not expose the real laboratory network or application.*

## 3. Components and Responsibilities

| Component | Responsibility |
|---|---|
| Ubuntu Server | Hosts and manages the infrastructure |
| Nginx (host) | HTTPS termination and Layer 7 reverse proxy |
| Docker | Isolates application services |
| Internal web proxy | Routes traffic to backend services |
| Private backend | Processes application requests |
| Database service | Provides persistent data storage |

The public-facing web entry point is separated from the containerized backend. The internal web proxy is accessible only through the server's loopback interface.

## 4. Request Flow

A typical request follows this sequence:

1. The client establishes an HTTPS connection to the perimeter Nginx server.
2. Nginx validates the TLS configuration and processes the HTTP request.
3. Security headers are added to the response.
4. Application requests are subject to IP-based rate limiting.
5. Nginx forwards the request to an internal web proxy through loopback.
6. The internal proxy routes the request to the backend service.
7. The response returns through the same proxy chain.

This approach centralizes TLS termination and HTTP security controls without exposing the internal application or database directly.

## 5. Security Controls

### HTTPS and TLS

- HTTPS termination using a Let's Encrypt certificate.
- Support for TLS 1.2 and TLS 1.3.
- Local verification of HTTP 301 redirection to HTTPS.
- TLS certificate verification using curl without disabling certificate checks.

### HTTP Security Headers

The following headers were configured and tested:

- **Strict-Transport-Security:** `max-age=300`, deliberately short for laboratory testing.
- **X-Frame-Options:** `DENY`.
- **X-Content-Type-Options:** `nosniff`.
- **Content-Security-Policy:** restricts permitted sources for scripts, styles, fonts and other browser resources.

### Rate Limiting

The reverse proxy implements application-level request limiting:

| Parameter | Value |
|---|---|
| Identification | Client IP |
| Nominal rate | 5 requests/second |
| Burst | 10 requests |
| Burst processing | `nodelay` |
| Rejection code | HTTP 429 |

The limiting policy applies to application requests, while static resources are excluded from this specific limit.

### Troubleshooting

During testing, the initial rate-limiting configuration caused legitimate static resources to receive HTTP 429 responses.

I investigated the issue using browser developer tools and Nginx logs, then adjusted the configuration so that CSS, JavaScript and images could load correctly without removing the application-level protection.

## 6. Validation

The laboratory was validated using:

- `nginx -t` to check configuration syntax.
- `systemctl` to verify Nginx service status.
- `curl` to test HTTPS, redirects, headers and HTTP responses.
- `docker ps` to inspect container health.
- ApacheBench to generate controlled concurrent requests.
- Nginx access logs to confirm HTTP 200 and HTTP 429 results.
- Browser developer tools to check static assets and Content Security Policy behavior.

**Final controlled rate-limit test:**

| Metric | Result |
|---|---|
| Requests | 40 |
| Concurrency | 4 |
| HTTP 200 responses | 14 |
| HTTP 429 responses | 26 |
| Duration | 0.775 seconds |

These results demonstrate the operation of the configured limiter under a controlled local test. They do not establish sustainable production capacity or protection against distributed denial-of-service attacks.

## 7. Design Decisions

**Why use Nginx on the host?**

It provides a central point for TLS termination and HTTP security controls while retaining the existing containerized architecture.

**Why keep the internal proxy bound to loopback?**

It prevents direct access to the internal web proxy through a published network interface.

**Why exclude static resources from rate limiting?**

Browsers request multiple files concurrently. Applying the same restrictive threshold to all assets caused legitimate requests to be rejected.

**Why use a short HSTS duration?**

A short duration is appropriate for initial testing and avoids prematurely enforcing a long-term browser policy during configuration changes.

## 8. Limitations

This project was validated in a controlled educational environment.

- It does not demonstrate distributed high availability.
- Local rate-limiting tests do not represent real Internet traffic.
- The limiter is not a complete DDoS mitigation solution.
- TLS and HTTP security settings would require further review before production deployment.
- The published configuration files are sanitized educational examples, not an exported copy of the operational server.

## 9. Skills Demonstrated

- Linux server administration.
- Nginx configuration and troubleshooting.
- Layer 7 routing and reverse proxy architecture.
- TLS certificate management.
- HTTP security configuration.
- Docker networking fundamentals.
- Log analysis and functional testing.
- Diagnosing and resolving service availability issues.

---

**Author:** Erick Conesa Pérez  
**Training:** Higher Vocational Training in Network Computer Systems Administration (ASIR)
