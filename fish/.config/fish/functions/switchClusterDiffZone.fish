function switchClusterDiffZone --description 'change gcloud cluster & zone'
	gcloud config set container/cluster "$argv[1]"
  gcloud container clusters --zone=$argv[2] get-credentials "$argv[1]"
  set -U __prompt_gcloud_cluster (echo "$argv[1]" | tr a-z A-Z)
end
