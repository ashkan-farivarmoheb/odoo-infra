variable "aws_region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_account_id" {
  description = "aws account id"
  type = string
}

variable "environment" {
  description = "environment"
  type = string
}

variable "project" {
  description = "Project name"
  type = string
}

variable "engine_version" {
  type = string
  description = "engine version"
}

variable "instance_class" {
  type = string
  description = "instance class"
}

variable "storage_type" {
  type = string
  description = "storage type"
}

variable "username" {
  type = string
  description = "username"
}

variable "password" {
  type = string
  description = "password"
}

variable "connection_borrow_timeout" {
  type        = number
  default     = 120
  description = "The number of seconds for a proxy to wait for a connection to become available in the connection pool. Only applies when the proxy has opened its maximum number of connections and all connections are busy with client sessions"
}

variable "init_query" {
  type        = string
  default     = null
  description = "One or more SQL statements for the proxy to run when opening each new database connection"
}

variable "max_connections_percent" {
  type        = number
  default     = 100
  description = "The maximum size of the connection pool for each target in a target group"
}

variable "max_idle_connections_percent" {
  type        = number
  default     = 50
  description = "Controls how actively the proxy closes idle database connections in the connection pool. A high value enables the proxy to leave a high percentage of idle connections open. A low value causes the proxy to close idle client connections and return the underlying database connections to the connection pool"
}

variable "session_pinning_filters" {
  type        = list(string)
  default     = null
  description = "Each item in the list represents a class of SQL operations that normally cause all later statements in a session using a proxy to be pinned to the same underlying database connection"
}

variable "proxy_create_timeout" {
  type        = string
  default     = "30m"
  description = "Proxy creation timeout"
}

variable "proxy_update_timeout" {
  type        = string
  default     = "30m"
  description = "Proxy update timeout"
}

variable "proxy_delete_timeout" {
  type        = string
  default     = "60m"
  description = "Proxy delete timeout"
}

variable "debug_logging" {
  type        = bool
  default     = false
  description = "Whether the proxy includes detailed information about SQL statements in its logs"
}

variable "idle_client_timeout" {
  type        = number
  default     = 1800
  description = "The number of seconds that a connection to the proxy can be inactive before the proxy disconnects it"
}

variable "require_tls" {
  type        = bool
  default     = false
  description = "A Boolean parameter that specifies whether Transport Layer Security (TLS) encryption is required for connections to the proxy. By enabling this setting, you can enforce encrypted TLS connections to the proxy"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
    Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).
    Neither the tag keys nor the tag values will be modified by this module.
    EOT
}