resource "google_dns_managed_zone" "zone" {
  name          = var.name
  dns_name      = var.dns_name
  description   = var.description == "" ? null : var.description
  project       = var.project == "" ? null : var.project
  force_destroy = var.force_destroy
  labels        = length(keys(var.labels)) < 0 ? null : var.labels 
  visibility    = !var.is_private ? "public" : "private"

  private_visibility_config {
    count = var.is_private && length(var.private_visibility_config_networks) != 0 ? 1 : 0
    dynamic "networks" {
      for_each = var.private_visibility_config_networks
      content {
        network_url = networks.value.network_url
      }
    }
  }

  forwarding_config {
    count = length(var.target_name_servers) != 0 ? 1 : 0
    dynamic "target_name_servers" {
      for_each = var.target_name_servers
      content {
        ipv4_address = target_name_servers.value.ipv4_address
        forwarding_path = target_name_servers.value.forwarding_path == null ? "default" : "private"
      }
    }
  }

  peering_config {
    count = length(var.peering_config_networks) != 0 ? 1 : 0
    dynamic "networks" {
      for_each = each.peering_config_networks
      content {
        network_url = networks.value.network_url
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