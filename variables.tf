variable "project_id" {
  description = "the ID of the project where the resources will be created"
  type        = string
}
#forwarding_rule
variable "ip_protocol" {
  type        = string
  description = "The IP protocol to which this rule applies.  Possible values are TCP, UDP, ESP, AH, SCTP, and ICMP."
}
variable "load_balancing_scheme" {
  type        = string
  description = "This signifies what the GlobalForwardingRule will be used.The value of INTERNAL_SELF_MANAGED means that this will be used for Internal Global HTTP(S) LB. The value of EXTERNAL means that this will be used for External Global Load Balancing (HTTP(S) LB, External TCP/UDP LB, SSL Proxy). The value of EXTERNAL_MANAGED means that this will be used for Global external HTTP(S) load balancers.  Possible values are EXTERNAL, EXTERNAL_MANAGED, and INTERNAL_SELF_MANAGED"
}
variable "port_range" {
  type        = string
  description = "This field is used along with the target field https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule#port_range"
}
# variable "ip_address" {
#   type        = string
#   description = "The IP address that this forwarding rule serves. When a client sends traffic to this IP address, the forwarding rule directs the traffic to the target that you specify in the forwarding rule"
# }

variable "lb_name" {
  type        = string
  description = "Name of the resource; provided by the client when the resource is created"
}
#backend service
variable "protocol" {
  type        = string
  description = "The protocol this BackendService uses to communicate with backends.Possible values are HTTP, HTTPS, HTTP2, TCP, SSL, and GRPC"
}
variable "network" {
  type        = string
  description = "Network for  load balancer."
}

# variable "health_checks" {
#   type        = list(string)
#   description = "The health_checks"
# }

## Pub Sub variables

variable "topic_name" {
  type        = string
  description = "The Pub/Sub topic name."
}

#Cloud SQL
variable "db_root_username" {
  type        = string
  description = "The root username for the database instance"
}

variable "instance_name" {
  description = "The name of the database instance"
  type        = string
}

variable "database_version" {
  description = "The MySQL, PostgreSQL or SQL Server version to use. Supported values include MYSQL_5_6, MYSQL_5_7, MYSQL_8_0, POSTGRES_9_6,POSTGRES_10, POSTGRES_11, POSTGRES_12, POSTGRES_13, SQLSERVER_2017_STANDARD, SQLSERVER_2017_ENTERPRISE, SQLSERVER_2017_EXPRESS, SQLSERVER_2017_WEB. SQLSERVER_2019_STANDARD, SQLSERVER_2019_ENTERPRISE, SQLSERVER_2019_EXPRESS, SQLSERVER_2019_WEB"
  type        = string
}

variable "region" {
  description = "The region the instance will sit in"
  type        = string
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance"
  type        = bool
}

variable "database_tier" {
  description = "The machine type to use"
  type        = string
}

variable "availability_type" {
  description = "The availability type of the Cloud SQL instance, high availability (REGIONAL) or single zone (ZONAL)"
  type        = string
}

variable "disk_size" {
  description = "The size of data disk, in GB. Size of a running instance cannot be reduced but can be increased"
  type        = string
}

variable "disk_autoresize" {
  description = "Configuration to increase storage size automatically"
  type        = bool
}

variable "backup_enabled" {
  description = "True if backup configuration is enabled"
  type        = bool
}

variable "binary_log_enabled" {
  description = "True if backup configuration is enabled"
  type        = bool
}

variable "ipv4_enabled" {
  description = "True if backup configuration is enabled"
  type        = bool
  default     = false
}

variable "backup_start_time" {
  description = "HH:MM format time indicating when backup configuration starts"
  type        = string
}

variable "database_flags" {
  description = "The id of the vpc"
  type = list(object({
    name  = string
    value = string
  }))
}

variable "insights_config" {
  description = "The id of the vpc"
  type = list(object({
    query_insights_enabled  = bool
    query_string_length     = number
    record_application_tags = bool
    record_client_address   = bool
  }))
}

variable "maintenance_window" {
  description = "Subblock for instances declares a one-hour maintenance window when an Instance can automatically restart to apply updates"
  type = list(object({
    maintenance_window_day          = number
    maintenance_window_hour         = number
    maintenance_window_update_track = string
  }))
}

variable "shared_vpc_project_id" {
  description = "Shared VPC project"
  type        = string
}



variable "private_ip_address_name" {
  description = "The name of the static private ip for the database"
  type        = string
}

# variable "reserved_peering_ranges" {
#   description = "List of peering ranges"
#   type        = list(string)
# }

variable "encryption_key_name" {
  type        = string
  description = "the Customer Managed Encryption Key used to encrypt the boot disk attached to each node in the node pool"
  default     = ""
}

# Redis store
//required variables
variable "redis_name" {
  type        = string
  description = "Name of redis instance"
}
variable "redis_memory_size_gb" {
  type        = number
  description = "redis_memory_size_gb"
}


variable "authorized_network" {
  description = "The full name of the Google Compute Engine network to which the instance is connected. If left unspecified, the default network will be used."
  type        = string
}

//optional variables


variable "redis_configs" {
  description = "Redis configuration parameters, according to http://redis.io/topics/config. Please check Memorystore documentation for the list of supported parameters"
  type        = map(string)
  default     = {}
}

variable "redis_version" {
  description = "The version of Redis software. If not provided, latest supported version will be used. Please check the API documentation linked at the top for the latest valid values."
  type        = string
  default     = "REDIS_6_X"
}

variable "redis_tier" {
  description = "The service tier of the instance. Must be one of these values:Basic or Standard_ha"
  type        = string
  default     = "STANDARD_HA"
}

variable "auth_enabled" {
  description = "Indicates whether OSS Redis AUTH is enabled for the instance. If set to true AUTH is enabled on the instance."
  type        = bool
  default     = false
}

variable "transit_encryption_mode" {
  description = "The TLS mode of the Redis instance"
  type        = string
  default     = "SERVER_AUTHENTICATION"
}
variable "connect_mode" {
  description = "The connect mode of the Redis instance"
  type        = string
  default     = "PRIVATE_SERVICE_ACCESS"
}

variable "name_reserved_ip_range" {
  type        = string
  description = "For PRIVATE_SERVICE_ACCESS mode value must be the name of an allocated address range associated with the private service access connection,"
}

variable "host_project_id" {
  type        = string
  description = "The project id of the host project"
}

#MIG

variable "instance_template_name_prefix" {
  description = "prfix for the instance template"
  type        = string
}
variable "machine_type" {
  description = "machine type of the instances"
  type        = string
}

variable "can_ip_forward" {
  description = "ip-forward configuration of the template"
  type        = bool
  default     = false
}
variable "auto_delete" {
  description = "auto-delete configuration of the template-disk"
  type        = bool
  default     = true
}
variable "boot" {
  description = "boot configuration of the template-disk"
  type        = bool
  default     = true
}
# variable "network" {
#   description = "network for the instance template"
#   type        = string
# }
variable "subnetwork" {
  description = "sub-network for the instance template"
  type        = string
}
variable "preemptible" {
  description = "Name of the disk"
  type        = bool
}
variable "automatic_restart" {
  description = "Name of the disk"
  type        = bool
  default     = true
}
variable "enable-guest-attributes" {
  description = "enable-guest-attributes config"
  type        = bool
  default     = true
}
variable "enable-osconfig" {
  description = "enable-osconfig"
  type        = bool
  default     = true
}
variable "instance_group_manager_name" {
  description = "instance_group_manager_name"
  type        = string
}
variable "base_instance_name" {
  description = "base_instance_name"
  type        = string
}
variable "zone" {
  description = "Zone of the MIG"
  type        = string
}
variable "target_size" {
  description = "Target size of the MIG"
  type        = string
}
variable "template_source_image" {
  description = "Source image self_link for the instance template"
  type        = string
}
variable "autoscaler_name" {
  description = "Name for the autoscaler"
  type        = string
}
variable "max_replicas" {
  description = "Maximum number of replicas for the autoscaler"
  type        = number
}
variable "min_replicas" {
  description = "Minimum number of replicas for the autoscaler"
  type        = number
}
variable "cooldown_period" {
  description = "The cooldown period for the autoscaler"
  type        = number
}
variable "metric_name" {
  description = "The metric name for the autoscaler"
  type        = string
}
variable "metric_filter" {
  description = "The metric filter for the autoscaler"
  type        = string
}
variable "single_instance_assignment" {
  description = "single_instance_assignment for the autoscaler"
  type        = number
}
##### Variables for GCS bucket #####

variable "bucket_name" {
  type = string
}


variable "force_destroy" {
  description = "option to delete all objects in a bucket while deleting a bucket"
  type        = bool
  default     = false
}

variable "location" {
  description = "the location of the bucket"
  type        = string
}



variable "storage_class" {
  description = "the Storage Class of the new bucket"
  type        = string
  default     = null
}

variable "labels" {
  description = "a map of key/value label pairs to assign to the bucket"
  type        = map(string)
  default     = null
}

variable "uniform_bucket_level_access" {
  description = "enables uniform bucket level access to a bucket"
  type        = bool
  default     = true
}

variable "lifecycle_rule" {
  description = "lifecycle rule for a gcs bucket"
  type = list(object({
    action    = any
    condition = any
  }))
  default = []
}

variable "bucket_object_versioning" {
  description = "enabling versioning can help retain a noncurrent object version"
  type        = bool
  default     = true
}

variable "cors" {
  description = "cors configuration for the bucket"
  type        = any
  default     = []
}

variable "retention_policy" {
  description = "configuration of the bucket's data retention policy for how long objects in the bucket should be retained"
  type = object({
    is_locked        = bool
    retention_period = number
  })
  default = null
}

variable "log_object_bucket" {
  description = "a gcs bucket that can receive log objects"
  type        = string
  default     = null
}

variable "log_object_prefix" {
  description = "the object prefix for log objects which defaults to gcs bucket name"
  type        = string
  default     = null
}

variable "encryption" {
  description = "a cloud KMS key that will be used to encrypt objects inserted into this bucket"
  type = object({
    kms_key_name = string
  })
  default = null
}