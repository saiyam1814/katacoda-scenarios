## Step 6 - Validate Application Access via Ingress

With the Ingress host configured, you can now access the demo application from your browser. The Ingress controller (on NodePort 30080) will route traffic to the app.

- **Access the app:** Open [ACCESS Application]({{TRAFFIC_HOST2_30080}}) in your browser. This URL corresponds to the Ingress host you set (Killercoda routes it to port 30080 on the cluster). You should see the application's web page or API response. 🎉
