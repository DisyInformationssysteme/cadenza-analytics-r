# Copyright 2024 Disy Informationssysteme GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.onLoad <- function(...) {
  register_parsers_onLoad()
  register_serializer_enrichment_calculation_onLoad()
  register_serializer_visualization_onLoad()
  register_serializer_capabilities_onLoad()
  register_serializer_discovery_onLoad()
}
