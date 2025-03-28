/*
Copyright 2022.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package cloudinit

import (
	"bytes"

	"gopkg.in/yaml.v3"
)

var (
	// templateFuncsMap is a map of functions that will be available for rendering templates.
	templateFuncsMap = map[string]any{
		"ToYAML": templateToYAML,
	}
)

func templateToYAML(v interface{}) (string, error) {
	buf := &bytes.Buffer{}
	en := yaml.NewEncoder(buf)
	en.SetIndent(defaultYamlIndent)

	err := en.Encode(v)
	if err != nil {
		return "", err
	}
	return buf.String(), nil
}
