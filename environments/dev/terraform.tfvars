environment = "dev"
region      = "us-east-1"

# cheap: one NAT, single instances, single-AZ DB
single_nat_gateway = true
web_instance_type  = "t3.small"
app_instance_type  = "t3.small"
db_instance_class  = "db.t3.micro"
db_multi_az        = false
cache_node_type    = "cache.t3.micro"
cache_num_nodes    = 1
protect_resources  = false

# enable_dns  = true
# domain_name = "novacart.app"
# alarm_email = "devops@novacart.app"
# ses_email_identities = ["no-reply@novacart.app"]
