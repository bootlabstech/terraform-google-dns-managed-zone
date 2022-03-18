resource "google_dns_managed_zone" "zone" {
  name          = var.name
  dns_name      = var.dns_name
  description   = var.description == "" ? null : var.description
  project       = var.project
  force_destroy = var.force_destroy
  labels        = length(keys(var.labels)) < 0 ? null : var.labels 
  visibility    = !var.is_private ? "public" : "private"

  private_visibility_config {
    for_each = var.is_private && length(var.private_visibility_config_networks) != 0 ? [1] : []
    content {
      dynamic "networks" {
        for_each = var.private_visibility_config_networks
        content {
          network_url = networks.value
        }
      }
    }
  }

  forwarding_config {
    for_each = length(var.forwarding_config_target_name_servers) != 0 ? [1] : []
    content {
      dynamic "target_name_servers" {
        for_each = var.forwarding_config_target_name_servers
        content {
          ipv4_address = target_name_servers.value.ipv4_address
          forwarding_path = target_name_servers.value.forwarding_path == null ? "default" : "private"
        }
      }
    }
  }

  dynamic "peering_config" {
    for_each = length(var.peering_config_networks) != 0 ? [1] : []
    content {
      dynamic "target_network" {
        for_each = var.peering_config_networks
        content {
          network_url = target_network.value
        }
      }
    }
  }
}

resource "google_dns_record_set" "record" {
  for_each      = { for record in var.records : record.name => record } 
  name         = "${each.key}.${google_dns_managed_zone.zone.dns_name}"
  managed_zone = google_dns_managed_zone.zone.name
  type         = each.value.type
  ttl          = each.value.ttl

  rrdatas = each.value.rrdatas
}