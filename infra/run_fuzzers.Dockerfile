# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
# Docker image for running fuzzers on CIFuzz (the run_fuzzers action on GitHub
# actions).

FROM ghcr.io/sjors/clusterfuzzlite-build-fuzzers:llvm-22-debug AS llvm-tools
RUN echo "Using llvm tools from ghcr.io/sjors/clusterfuzzlite-build-fuzzers:llvm-22-debug"

FROM gcr.io/oss-fuzz-base/cifuzz-base:metzman-test

# Override the LLVM tools with the versions from the llvm-22 debug builder image.
COPY --from=llvm-tools /usr/local/bin/llvm-cov /usr/local/bin/llvm-cov
COPY --from=llvm-tools /usr/local/bin/llvm-profdata /usr/local/bin/llvm-profdata
COPY --from=llvm-tools /usr/local/bin/llvm-symbolizer /usr/local/bin/llvm-symbolizer

# Python file to execute when the docker container starts up.
# We can't use the env var $OSS_FUZZ_ROOT here. Since it's a constant env var,
# just expand to '/opt/oss-fuzz'.
ENTRYPOINT ["python3", "/opt/oss-fuzz/infra/cifuzz/run_fuzzers_entrypoint.py"]

WORKDIR ${OSS_FUZZ_ROOT}/infra

# Copy infra source code.
ADD . ${OSS_FUZZ_ROOT}/infra

RUN python3 -m pip install -r ${OSS_FUZZ_ROOT}/infra/cifuzz/requirements.txt
