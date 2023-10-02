group "default" {
  targets = [
    "2_3_15_4_alpine3_15",
    "2_3_15_4_alpine3_16",
    "2_3_15_4_alpine3_17",
    "2_3_15_4_debian"
  ]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/aarch64"]
}

target "build-common" {
  pull = true
}

######################
# Define the variables
######################

variable "REGISTRY_CACHE" {
  default = "docker.io/nlss/xinetd-cache"
}

######################
# Define the functions
######################

# Get the arguments for the build
function "get-args" {
  params = [xinetd_version, alpine_version]
  result = {
    ALPINE_VERSION = alpine_version
    XINETD_VERSION = xinetd_version
  }
}

# Get the cache-from configuration
function "get-cache-from" {
  params = [version]
  result = [
    "type=gha,scope=${version}_${BAKE_LOCAL_PLATFORM}",
    "type=registry,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get the cache-to configuration
function "get-cache-to" {
  params = [version]
  result = [
    "type=registry,mode=max,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get list of image tags and registries
# Takes a version and a list of extra versions to tag
# eg. get-tags("2.3.15.4", ["2.3", "latest"])
function "get-tags" {
  params = [version, extra_versions]
  result = concat(
    [
      "docker.io/nlss/xinetd:${version}",
      "ghcr.io/n0rthernl1ghts/xinetd:${version}"
    ],
    flatten([
      for extra_version in extra_versions : [
        "docker.io/nlss/xinetd:${extra_version}",
        "ghcr.io/n0rthernl1ghts/xinetd:${extra_version}"
      ]
    ])
  )
}

##########################
# Define the build targets
##########################

target "2_3_15_4_alpine3_15" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("2.3.15.4-alpine3.15")
  cache-to   = get-cache-to("2.3.15.4-alpine3.15")
  tags       = get-tags("2.3.15.4-alpine3.15", ["alpine3.15"])
  args       = get-args("2.3.15.4", "3.15")
}

target "2_3_15_4_alpine3_16" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("2.3.15.4-alpine3.16")
  cache-to   = get-cache-to("2.3.15.4-alpine3.16")
  tags       = get-tags("2.3.15.4-alpine3.16", ["alpine3.16"])
  args       = get-args("2.3.15.4", "3.16")
}

target "2_3_15_4_alpine3_17" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("2.3.15.4-alpine3.17")
  cache-to   = get-cache-to("2.3.15.4-alpine3.17")
  tags       = get-tags("2.3.15.4-alpine3.17", ["alpine", "alpine3.17", "latest", "2.3", "2"])
  args       = get-args("2.3.15.4", "3.17")
}

# Version might differ depending of package "xinetd" in Debian
target "2_3_15_4_debian" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  dockerfile = "Dockerfile.debian"
  cache-from = get-cache-from("2.3.15.4")
  cache-to   = get-cache-to("2.3.15.4")
  tags       = get-tags("2.3.15.4-debian", ["debian", "2.3-debian", "2-debian"])
}

