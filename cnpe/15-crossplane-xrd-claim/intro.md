# Define a namespaced platform API with Crossplane v2

Create XRD `bucketapps.platform.example.io` using `apiextensions.crossplane.io/v2`:
kind `BucketApp`, scope `Namespaced`, version `v1alpha1` served and referenceable.
Require `spec.region` and `spec.size`, both strings. Do not use `claimNames`.

Apply the supplied `/root/bucket-composition.yaml`. Then create composite resource
`media-assets` in `team-apps` with `region: eu-west-1` and `size: small`, selecting
Composition `bucketapp-configmap` through `spec.crossplane.compositionRef`.

Wait for the XR to become Ready and inspect its composed ConfigMap in `team-apps`.
The ConfigMap models the requested settings; this lab does not create cloud storage
or credentials. Do not create that ConfigMap manually.
