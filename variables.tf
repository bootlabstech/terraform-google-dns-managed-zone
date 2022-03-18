//required variables
variable "name" {
  type        = string
  description = "User assigned name for this resource. Must be unique within the project."
}

variable "dns_name" {
	type				= string
	description = "The DNS name of this managed zone, for instance example.com."
}

//optional variables
variable "description" {
	type				= string
	description = "A textual description field. Defaults to 'Managed by Terraform'."
	default = ""
}

variable "project" {
	type				= string
	description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
}

variable "labels" {
	type				= map
	description = "A set of key/value label pairs to assign to this ManagedZone."
	default = {}
}

variable "force_destroy" {
	type				= bool
	description = "Set this true to delete all records in the zone."
	default = false
}

variable "is_private" {
	type				= bool
	description = "The zone's visibility: public zones are exposed to the Internet, while private zones are visible only to Virtual Private Cloud resources."
	default = false
}

variable "private_visibility_config_networks" {
	type				= list(string)
	description = "For privately visible zones, the set of Virtual Private Cloud resources that the zone is visible from."
	default = []
}

variable "forwarding_config_target_name_servers" {
	type				= list(any)	
	description = "List of target name servers to forward to. Cloud DNS will select the best available name server if more than one target is given."
	default = []
}

variable "peering_config_networks" {
	type				= list(any)	
	description = "List of target name servers to forward to. Cloud DNS will select the best available name server if more than one target is given."
	default = []
}

variable "records" {
	type = list(object({
      name                 = string,
      rrdatas              = list(string),
	  type				   = string,
	  ttl				   = number
  	}))
	description = "List of dns records that needs to be created."
	default = []
}