environment = "prod"
region      = "us-east-1"

# resilient: NAT per AZ, 2+ instances per tier, Multi-AZ DB, replicated cache
single_nat_gateway = false
web_instance_type  = "t3.medium"
web_min_size       = 2
web_max_size       = 6
web_desired_size   = 2
app_instance_type  = "t3.medium"
app_min_size       = 2
app_max_size       = 6
app_desired_size   = 2

db_instance_class   = "db.t3.medium"
db_allocated_storage = 50
db_multi_az         = true
db_backup_retention = 14

cache_node_type = "cache.t3.small"
cache_num_nodes = 2

protect_resources = true

# enable_dns  = true
# domain_name = "novacart.app"
# alarm_email = "devops@novacart.app"
# ses_email_identities = ["no-reply@novacart.app"]
