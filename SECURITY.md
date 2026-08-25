# Security Policy

## Supported versions

The `main` branch is the actively supported development line. Development snapshots are not production-ready and may contain design or verification defects.

## Reporting a vulnerability

Do not open a public issue for a suspected security vulnerability, private key, credential, or sensitive disclosure.

Use GitHub’s private security advisory workflow when available. If it is not available, contact the repository maintainer through the private contact method on the [@Vicky-RDP GitHub profile](https://github.com/Vicky-RDP) and include `India Inference Chip security report` in the subject.

Please include:

- A short description of the issue and affected path.
- Reproduction steps or a minimal proof of concept.
- Potential impact.
- Any suggested mitigation.

We will acknowledge a report when practical, coordinate a fix and disclosure timeline with the reporter, and credit the reporter unless they prefer anonymity.

## Hardware-specific note

RTL, firmware, and compiler changes can affect isolation, memory safety, model confidentiality, and device availability. Treat security review as part of design review, not as a final packaging step.
