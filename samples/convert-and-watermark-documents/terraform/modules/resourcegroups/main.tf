resource "aws_resourcegroups_group" "this" {
  name = "${var.project_name}-${var.environment}"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        { Key = "Environment", Values = [var.environment] },
        { Key = "Project", Values = [var.project_name] }
      ]
    })
    type = "TAG_FILTERS_1_0"
  }
}
