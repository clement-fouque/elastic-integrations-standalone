variable "pipelines" {
  type     = any
  default  = {}
  nullable = false

  validation {
    condition = try(can(keys(var.pipelines)) && alltrue([
      for pipeline in values(var.pipelines) :
      can(keys(pipeline)) &&
      length(setsubtract(keys(pipeline), ["description", "processors", "on_failure", "_meta"])) == 0 &&
      contains(keys(pipeline), "processors") &&
      can(concat(pipeline.processors, [])) &&
      alltrue([for processor in pipeline.processors : can(keys(processor))]) &&
      (contains(keys(pipeline), "on_failure") ? (
        can(concat(pipeline.on_failure, [])) && alltrue([for processor in pipeline.on_failure : can(keys(processor))])
      ) : true)
    ]), false)
    error_message = "Pipelines accept only description, processors, on_failure, and _meta; processors and on_failure must be arrays."
  }
}
