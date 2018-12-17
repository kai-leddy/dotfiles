function switchCluster --description 'change gcloud cluster'
	gcloud config set container/cluster "$argv[1]"
  gcloud container clusters --zone=us-central1-c get-credentials "$argv[1]"
  set -U __prompt_gcloud_cluster (echo "$argv[1]" | tr a-z A-Z)
end
