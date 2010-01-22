# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.  The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.


Gem::Specification.new do |spec|
  spec.name           = 'buildr-findBugs'
  spec.version        = '0.1.0'
  spec.author         = 'Antoine Toulme'
  spec.email          = "atoulme@intalio.com"
  spec.homepage       = "http://www.github.com/intalio/buildr-findBugs"
  spec.summary        = "A plugin for adding FindBugs support to Buildr."
  spec.description    = <<-TEXT
Adds a task to help run FindBugs over your code.
TEXT
  spec.files          = Dir['{lib}/**/*', '*.{gemspec}'] +
                        ['LICENSE', 'NOTICE', 'README.rdoc']
  spec.require_paths  = ['lib']
  spec.has_rdoc         = true
  spec.extra_rdoc_files = 'README.rdoc', 'LICENSE', 'NOTICE'
  spec.add_dependency("buildr", ">= 1.3.5")
end