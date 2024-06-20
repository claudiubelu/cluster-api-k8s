//go:build !ignore_autogenerated

/*


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

// Code generated by controller-gen. DO NOT EDIT.

package v1beta2

import (
	"k8s.io/apimachinery/pkg/runtime"
	"sigs.k8s.io/cluster-api/api/v1beta1"
)

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *CK8sConfig) DeepCopyInto(out *CK8sConfig) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	in.ObjectMeta.DeepCopyInto(&out.ObjectMeta)
	in.Spec.DeepCopyInto(&out.Spec)
	in.Status.DeepCopyInto(&out.Status)
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new CK8sConfig.
func (in *CK8sConfig) DeepCopy() *CK8sConfig {
	if in == nil {
		return nil
	}
	out := new(CK8sConfig)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *CK8sConfig) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *CK8sConfigList) DeepCopyInto(out *CK8sConfigList) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	in.ListMeta.DeepCopyInto(&out.ListMeta)
	if in.Items != nil {
		in, out := &in.Items, &out.Items
		*out = make([]CK8sConfig, len(*in))
		for i := range *in {
			(*in)[i].DeepCopyInto(&(*out)[i])
		}
	}
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new CK8sConfigList.
func (in *CK8sConfigList) DeepCopy() *CK8sConfigList {
	if in == nil {
		return nil
	}
	out := new(CK8sConfigList)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *CK8sConfigList) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *CK8sConfigSpec) DeepCopyInto(out *CK8sConfigSpec) {
	*out = *in
	if in.Files != nil {
		in, out := &in.Files, &out.Files
		*out = make([]File, len(*in))
		for i := range *in {
			(*in)[i].DeepCopyInto(&(*out)[i])
		}
	}
	if in.BootCommands != nil {
		in, out := &in.BootCommands, &out.BootCommands
		*out = make([]string, len(*in))
		copy(*out, *in)
	}
	if in.PreRunCommands != nil {
		in, out := &in.PreRunCommands, &out.PreRunCommands
		*out = make([]string, len(*in))
		copy(*out, *in)
	}
	if in.PostRunCommands != nil {
		in, out := &in.PostRunCommands, &out.PostRunCommands
		*out = make([]string, len(*in))
		copy(*out, *in)
	}
	in.ControlPlaneConfig.DeepCopyInto(&out.ControlPlaneConfig)
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new CK8sConfigSpec.
func (in *CK8sConfigSpec) DeepCopy() *CK8sConfigSpec {
	if in == nil {
		return nil
	}
	out := new(CK8sConfigSpec)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *CK8sConfigStatus) DeepCopyInto(out *CK8sConfigStatus) {
	*out = *in
	if in.BootstrapData != nil {
		in, out := &in.BootstrapData, &out.BootstrapData
		*out = make([]byte, len(*in))
		copy(*out, *in)
	}
	if in.DataSecretName != nil {
		in, out := &in.DataSecretName, &out.DataSecretName
		*out = new(string)
		**out = **in
	}
	if in.Conditions != nil {
		in, out := &in.Conditions, &out.Conditions
		*out = make(v1beta1.Conditions, len(*in))
		for i := range *in {
			(*in)[i].DeepCopyInto(&(*out)[i])
		}
	}
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new CK8sConfigStatus.
func (in *CK8sConfigStatus) DeepCopy() *CK8sConfigStatus {
	if in == nil {
		return nil
	}
	out := new(CK8sConfigStatus)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *CK8sConfigTemplate) DeepCopyInto(out *CK8sConfigTemplate) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	in.ObjectMeta.DeepCopyInto(&out.ObjectMeta)
	in.Spec.DeepCopyInto(&out.Spec)
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new CK8sConfigTemplate.
func (in *CK8sConfigTemplate) DeepCopy() *CK8sConfigTemplate {
	if in == nil {
		return nil
	}
	out := new(CK8sConfigTemplate)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *CK8sConfigTemplate) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *CK8sConfigTemplateList) DeepCopyInto(out *CK8sConfigTemplateList) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	in.ListMeta.DeepCopyInto(&out.ListMeta)
	if in.Items != nil {
		in, out := &in.Items, &out.Items
		*out = make([]CK8sConfigTemplate, len(*in))
		for i := range *in {
			(*in)[i].DeepCopyInto(&(*out)[i])
		}
	}
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new CK8sConfigTemplateList.
func (in *CK8sConfigTemplateList) DeepCopy() *CK8sConfigTemplateList {
	if in == nil {
		return nil
	}
	out := new(CK8sConfigTemplateList)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *CK8sConfigTemplateList) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *CK8sConfigTemplateResource) DeepCopyInto(out *CK8sConfigTemplateResource) {
	*out = *in
	in.Spec.DeepCopyInto(&out.Spec)
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new CK8sConfigTemplateResource.
func (in *CK8sConfigTemplateResource) DeepCopy() *CK8sConfigTemplateResource {
	if in == nil {
		return nil
	}
	out := new(CK8sConfigTemplateResource)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *CK8sConfigTemplateSpec) DeepCopyInto(out *CK8sConfigTemplateSpec) {
	*out = *in
	in.Template.DeepCopyInto(&out.Template)
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new CK8sConfigTemplateSpec.
func (in *CK8sConfigTemplateSpec) DeepCopy() *CK8sConfigTemplateSpec {
	if in == nil {
		return nil
	}
	out := new(CK8sConfigTemplateSpec)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *CK8sControlPlaneConfig) DeepCopyInto(out *CK8sControlPlaneConfig) {
	*out = *in
	if in.ExtraSANs != nil {
		in, out := &in.ExtraSANs, &out.ExtraSANs
		*out = make([]string, len(*in))
		copy(*out, *in)
	}
	if in.NodeTaints != nil {
		in, out := &in.NodeTaints, &out.NodeTaints
		*out = make([]string, len(*in))
		copy(*out, *in)
	}
	if in.ExtraKubeAPIServerArgs != nil {
		in, out := &in.ExtraKubeAPIServerArgs, &out.ExtraKubeAPIServerArgs
		*out = make(map[string]*string, len(*in))
		for key, val := range *in {
			var outVal *string
			if val == nil {
				(*out)[key] = nil
			} else {
				inVal := (*in)[key]
				in, out := &inVal, &outVal
				*out = new(string)
				**out = **in
			}
			(*out)[key] = outVal
		}
	}
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new CK8sControlPlaneConfig.
func (in *CK8sControlPlaneConfig) DeepCopy() *CK8sControlPlaneConfig {
	if in == nil {
		return nil
	}
	out := new(CK8sControlPlaneConfig)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *File) DeepCopyInto(out *File) {
	*out = *in
	if in.ContentFrom != nil {
		in, out := &in.ContentFrom, &out.ContentFrom
		*out = new(FileSource)
		**out = **in
	}
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new File.
func (in *File) DeepCopy() *File {
	if in == nil {
		return nil
	}
	out := new(File)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *FileSource) DeepCopyInto(out *FileSource) {
	*out = *in
	out.Secret = in.Secret
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new FileSource.
func (in *FileSource) DeepCopy() *FileSource {
	if in == nil {
		return nil
	}
	out := new(FileSource)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *SecretFileSource) DeepCopyInto(out *SecretFileSource) {
	*out = *in
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new SecretFileSource.
func (in *SecretFileSource) DeepCopy() *SecretFileSource {
	if in == nil {
		return nil
	}
	out := new(SecretFileSource)
	in.DeepCopyInto(out)
	return out
}
