group "default" {
    targets = [
        "211-py310-cuda1211-devel-ubuntu2204-vllm",
    ]
}

target "211-py310-cuda1211-devel-ubuntu2204-vllm" {
    dockerfile = "Dockerfile"
    tags = ["joennlae/pytorch:2.1.1-py3.10-cuda12.1.1-devel-ubuntu22.04-vllm"]
    contexts = {
        scripts = "../../container-template"
        proxy = "../../container-template/proxy"
        logo = "../../container-template"
    }
    args = {
        BASE_IMAGE = "nvidia/cuda:12.1.1-devel-ubuntu22.04"
        PYTHON_VERSION = "3.10"
        TORCH = "git+https://github.com/joennlae/vllm@nice-logging accelerate torch==2.1.2"
    }
}
