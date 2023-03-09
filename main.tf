# Creating Load Balancer
resource "google_compute_backend_service" "backend_service" {
  depends_on = [google_compute_instance_group_manager.instance_group_manager]
  project               = var.project_id
  name                  = "${var.lb_name}-backend-service"
  protocol              = var.protocol
  health_checks         = var.health_checks
  load_balancing_scheme = var.load_balancing_scheme
  backend {
    group = var.group
  }
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  project               = var.project_id
  name                  = "${var.lb_name}-forwarding-rule"
  target                = google_compute_target_http_proxy.target-proxy.id
  ip_protocol           = var.ip_protocol
  load_balancing_scheme = var.load_balancing_scheme
  port_range            = var.port_range
  ip_address            = var.ip_address
  network               = var.network
  depends_on = [
    google_compute_target_http_proxy.target-proxy
  ]
}

resource "google_compute_target_http_proxy" "target-proxy" {
  project = var.project_id
  name    = "${var.lb_name}-target-proxy"
  url_map = google_compute_url_map.url_map.id
  depends_on = [
    google_compute_url_map.url_map
  ]
}

resource "google_compute_url_map" "url_map" {
  project         = var.project_id
  name            = "${var.lb_name}-url-map"
  default_service = google_compute_backend_service.backend_service.id
  depends_on = [
    google_compute_backend_service.backend_service
  ]
}

#Creating Pub/Sub
resource "google_pubsub_topic" "topic" {
  name    = var.topic_name
  project = var.project_id
}

#Firebase




#MIG
resource "google_compute_instance_template" "instance_template" {
  project        = var.project_id
  name_prefix    = var.instance_template_name_prefix
  machine_type   = var.machine_type
  region         = var.region
  can_ip_forward = var.can_ip_forward

  // boot disk
  disk {
    source_image = var.template_source_image
    auto_delete  = var.auto_delete
    boot         = var.boot
  }

  // networking
  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }
  scheduling {
    preemptible       = var.preemptible
    automatic_restart = var.automatic_restart
  }
  metadata = {
    gce-software-declaration = <<-EOF
    {
      "softwareRecipes": [{
        "name": "install-gce-service-proxy-agent",
        "desired_state": "INSTALLED",
        "installSteps": [{
          "scriptRun": {
            "script": "#! /bin/bash\nZONE=$(curl --silent http://metadata.google.internal/computeMetadata/v1/instance/zone -H Metadata-Flavor:Google | cut -d/ -f4 )\nexport SERVICE_PROXY_AGENT_DIRECTORY=$(mktemp -d)\nsudo gsutil cp   gs://gce-service-proxy-"$ZONE"/service-proxy-agent/releases/service-proxy-agent-0.2.tgz   "$SERVICE_PROXY_AGENT_DIRECTORY"   || sudo gsutil cp     gs://gce-service-proxy/service-proxy-agent/releases/service-proxy-agent-0.2.tgz     "$SERVICE_PROXY_AGENT_DIRECTORY"\nsudo tar -xzf "$SERVICE_PROXY_AGENT_DIRECTORY"/service-proxy-agent-0.2.tgz -C "$SERVICE_PROXY_AGENT_DIRECTORY"\n"$SERVICE_PROXY_AGENT_DIRECTORY"/service-proxy-agent/service-proxy-agent-bootstrap.sh"
          }
        }]
      }]
    }
    EOF
    enable-guest-attributes  = var.enable-guest-attributes
    enable-osconfig          = var.enable-osconfig
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "instance_group_manager" {
  project = var.project_id
  name    = var.instance_group_manager_name
  version {
    instance_template = google_compute_instance_template.instance_template.id
  }
  base_instance_name = var.base_instance_name
  zone               = var.zone
  target_size        = var.target_size

}
resource "google_compute_autoscaler" "default" {
  provider = google-beta
  project  = var.project_id
  name     = var.autoscaler_name
  zone     = var.zone
  target   = google_compute_instance_group_manager.instance_group_manager.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period

    metric {
      name                       = var.metric_name
      filter                     = var.metric_filter
      single_instance_assignment = var.single_instance_assignment
    }
  }
}

#StackDriver

#Cloud SQL
resource "random_string" "sql_server_suffix" {
  length  = 4
  special = false
  upper   = false
  lower   = true
  number  = true
}

resource "random_password" "sql_password" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  number           = true
  override_special = "-_!#^~%@"
}

resource "google_sql_user" "users" {
  name     = var.db_root_username
  project  = var.project_id
  instance = google_sql_database_instance.instance.name
  password = random_password.sql_password.result
}

resource "google_sql_database_instance" "instance" {
  #ts:skip=AC_GCP_0003 DB SSL needs application level changes
  provider            = google-beta
  name                = "${var.instance_name}-${random_string.sql_server_suffix.id}"
  database_version    = var.database_version
  region              = var.region
  project             = var.project_id
  deletion_protection = var.deletion_protection
  root_password       = random_password.sql_password.result
  encryption_key_name = var.encryption_key_name == "" ? null : var.encryption_key_name

  settings {
    tier              = var.database_tier
    availability_type = var.availability_type
    disk_size         = var.disk_size
    disk_autoresize   = var.disk_autoresize

    backup_configuration {
      enabled            = var.backup_enabled
      start_time         = var.backup_start_time
      binary_log_enabled = var.binary_log_enabled
    }

    ip_configuration {
      ipv4_enabled    = var.ipv4_enabled
      private_network = var.network
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    dynamic "insights_config" {
      for_each = var.insights_config
      content {
        query_insights_enabled  = insights_config.value.query_insights_enabled
        query_string_length     = insights_config.value.query_string_length
        record_application_tags = insights_config.value.record_application_tags
        record_client_address   = insights_config.value.record_client_address
      }
    }

    dynamic "maintenance_window" {
      for_each = var.maintenance_window
      content {
        day          = maintenance_window.value.maintenance_window_day
        hour         = maintenance_window.value.maintenance_window_hour
        update_track = maintenance_window.value.maintenance_window_update_track
      }
    }
  }

  depends_on = [
    #google_service_networking_connection.private_vpc_connection,
    google_project_service_identity.sa
  ]

}

//Create this in the first run, allow google_sql_database_instance to fail. 
//Then add iam binding for this SA in keyring rerun this module again.
resource "google_project_service_identity" "sa" {
  provider = google-beta

  project = var.project_id
  service = "sqladmin.googleapis.com"
}

#Memory store
data "google_compute_network" "redis-network" {
  name    = var.name_reserved_ip_range
  project = var.host_project_id
}
resource "google_project_service" "redisapi" {
  project = var.project_id
  service = "redis.googleapis.com"
}
resource "google_redis_instance" "gcp_redis" {
  depends_on              = [google_project_service.redisapi]
  for_each                = { for redis in var.rediscache_details : redis.name => redis }
  name                    = each.value.name
  memory_size_gb          = each.value.memory_size_gb
  authorized_network      = var.authorized_network
  redis_configs           = var.redis_configs
  redis_version           = var.redis_version
  tier                    = var.redis_tier
  region                  = var.region
  project                 = var.project_id
  auth_enabled            = var.auth_enabled
  transit_encryption_mode = var.transit_encryption_mode
  connect_mode            = var.connect_mode
  reserved_ip_range       = data.google_compute_network.redis-network.id
}


#Cloud Storage
resource "google_storage_bucket" "main" {
  name                        = var.bucket_name
  project                     = var.project_id
  location                    = var.location
  uniform_bucket_level_access = true
   lifecycle {
    ignore_changes = [
      labels
    ]
  }
}

