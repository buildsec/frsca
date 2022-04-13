# Setting up the EFK stack

This script will instantiate Elastic, Fluent-bit and Kibana in your cluster. By default, the installation of Fluent-bit will capture all the logs from the k8s cluster. A ClusterRole is created that allows for it to capture logs from each pod created in all the namespaces. As the Tekton TaskRuns are individual pods, the logs from the specific TaskRuns, Tekton Controller and the Kyverno controller will be aggregated.

> :warning: This EFk deployment is not intended for production environment. Current it does not use proper certificate for TLS and does not limit the logs collected. Ensure you follow best security practices when using in production environment.

## Visualizing via Kibana

Once Kibana has successfully deployed, run the following command to port-forward 5601

```bash
kubectl port-forward -n logging deployment/kibana-kibana 5601
```
Navigate to localhost:5601 from your web browser to view the the Kibana Dashboard

## Configuring Kibana

1. On the left-hand navigation menu click on **Analytics - Discover**
2. A prompt will popup asking to configure the index pattern
3. For now, we’ll just use the `*` wildcard pattern to capture all the log data in our Elasticsearch cluster
4. In the dropdown, select the `@timestamp` field, and hit Create index pattern
5. Go back to **Analytics - Discover** on the left-hand navigation menu to start viewing the recent log entries