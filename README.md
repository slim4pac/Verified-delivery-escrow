Verified-Delivery-Escrow

A secure milestone-based escrow smart contract built in **Clarity** for the **Stacks Blockchain**.

---

Overview

**Verified-Delivery-Escrow (VDE)** is a decentralized escrow contract that enables secure peer-to-peer transactions where funds are released only after verified proof of delivery.

The contract locks funds in escrow and enforces deterministic release conditions. Delivery confirmation can be validated by the buyer, a third-party verifier, or through time-based fallback logic.

This model reduces counterparty risk and increases trust in digital service agreements, supply chains, freelance work, and DAO procurement workflows.

---

Problem Statement

Traditional escrow arrangements rely on:
- Centralized intermediaries
- Manual dispute resolution
- Weak enforcement of delivery conditions
- Poor transparency

Verified-Delivery-Escrow solves this by:
- Locking funds directly on-chain
- Enforcing structured state transitions
- Allowing deterministic verification logic
- Providing transparent and auditable execution

---

 Architecture

 Built With
- **Language:** Clarity
- **Blockchain:** Stacks
- **Framework:** Clarinet

Supported Assets
- Native STX
- Extendable to SIP-010 fungible tokens

---

Roles

1. Buyer
- Initiates escrow
- Deposits funds
- Confirms delivery (if buyer-validated model)

2. Seller
- Accepts escrow agreement
- Submits proof of delivery
- Receives funds upon approval

3. Verifier / Arbiter (Optional)
- Confirms delivery independently
- Resolves disputes
- Approves or rejects delivery claims

---

Escrow Lifecycle

1. Buyer creates escrow and deposits funds.
2. Seller accepts the escrow agreement.
3. Seller submits proof of delivery.
4. Delivery is validated by:
   - Buyer confirmation, or
   - Third-party verifier approval, or
   - Time-based auto-release (if configured).
5. Funds are released to seller or refunded to buyer.
6. All state transitions are recorded on-chain.

---

 Core Features

- Secure on-chain escrow custody
- Buyer-funded deposits
- Seller delivery confirmation flow
- Optional third-party verification
- Time-based auto-release or refund
- Structured dispute handling (optional)
- Deterministic state transitions
- Transparent event logging
- Clarinet-compatible project structure

---

Security Design Principles

- Explicit escrow state lifecycle
- No premature fund withdrawal
- Controlled release and refund paths
- Deterministic validation checks
- Minimal external dependencies
- Audit-ready architecture

---

Development & Testing

1. Install Clarinet
Follow official Stacks documentation to install Clarinet.

2. Initialize Project
```bash
clarinet new verified-delivery-escrow


















