# Zero trust, the Linkerd way! 🎉

Same outcome as lab 24, three small objects instead of one big one - and you saw the
sharpest edge in Linkerd policy: **a Server alone denies everything on its port.**

## Key facts to remember

- Linkerd identity format:
  `<sa>.<ns>.serviceaccount.identity.linkerd.cluster.local`
- The policy trio: **Server** (which port), **MeshTLSAuthentication** (which
  identities), **AuthorizationPolicy** (glue: targetRef + requiredAuthenticationRefs)
- Server without authorization = **deny-all** - create the authz in the same change,
  or schedule a very short outage
- mTLS is on by default in Linkerd - no PeerAuthentication equivalent needed
- Namespaces join the mesh via the `linkerd.io/inject: enabled` **annotation**
  (Istio uses a *label* - the exam loves that distinction)
- `linkerd check` is the first command for any mesh weirdness

📖 This lab is **Chapter 27** (bonus) of the *CNPE Scenarios and Solutions* book.

🏁 That completes all 27 labs - including every tool named in the official CNPE
curriculum. Go get certified.
