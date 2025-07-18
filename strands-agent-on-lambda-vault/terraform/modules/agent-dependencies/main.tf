resource "null_resource" "build_layer_zip" {
  provisioner "local-exec" {
    command = <<EOT
      docker build -t build-layer ./modules/agent-dependencies
      docker run --rm -v ${path.root}/tmp/dependencies-layer:/opt/out build-layer
      docker rmi build-layer
    EOT
  }

  triggers = {
    when_requirements_change = filebase64sha256("${path.module}/requirements.txt")
  }
}

data "local_file" "dependencies_layer_zip" {
  depends_on = [null_resource.build_layer_zip]
  filename   = "${path.root}/tmp/dependencies-layer/layer.zip"
}

resource "aws_lambda_layer_version" "dependencies_layer" {
  layer_name          = "travel-agent-dependencies"
  compatible_runtimes = ["python3.13"]
  # compatible_architectures = [var.fn_architecture]

  filename         = data.local_file.dependencies_layer_zip.filename
  source_code_hash = data.local_file.dependencies_layer_zip.content_base64sha256
}

output "dependencies_layer_arn" {
  value = aws_lambda_layer_version.dependencies_layer.arn
}