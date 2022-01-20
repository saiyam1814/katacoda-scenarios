The chaos dashboard is accessible via a NodePort. For this scenario we need the nodePort at a specific value, rather than its current random port number. Set the nodePort to a specific port:

`kubectl patch service chaos-dashboard -n chaos-mesh --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":31111}]'`{{execute}}

With the correct port value set, the web interface for Chaos Mesh dashboard can be seen from the tab _Chaos Mesh_ above the command-line area or this link: https://[[HOST_SUBDOMAIN]]-31111-[[KATACODA_HOST]].environments.katacoda.com/.

There are no experiments yet, but take a few moments to explore the general layout of the dashboard. There is a way through the user interface to create, update, and delete experiments. In the next steps, you will define and submit an experiment through a YAML manifest rather than this interface.

Leave the dashboard tab open so you can reference it again once you have some experiments running.
