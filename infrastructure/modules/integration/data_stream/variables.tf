variable "data_streams" {
  description = "Data stream definitions; the JSON filename stem is the remote name."
  type        = any
  default     = {}
  nullable    = false

  validation {
    condition     = try(can(keys(var.data_streams)) && alltrue([for definition in values(var.data_streams) : can(keys(definition)) && length(keys(definition)) == 0]), false)
    error_message = "elasticstack 0.16.5 creates a data stream by name only; data_streams JSON bodies must be empty objects."
  }
}
