package test

import (
	"fmt"
	"os"
	"testing"

	iassert "github.com/cgascoig/intersight-simple-go/assert"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestFull(t *testing.T) {
	//========================================================================
	// Setup Terraform options
	//========================================================================

	// Generate a unique name for objects created in this test to ensure we don't
	// have collisions with stale objects
	uniqueId := random.UniqueId()
	instanceName := fmt.Sprintf("test-sancon-%s", uniqueId)

	// Input variables for the TF module
	vars := map[string]interface{}{
		"apikey":        os.Getenv("IS_KEYID"),
		"secretkeyfile": os.Getenv("IS_KEYFILE"),
		"name":          instanceName,
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./full",
		Vars:         vars,
	})

	//========================================================================
	// Init and apply terraform module
	//========================================================================
	defer terraform.Destroy(t, terraformOptions) // defer to ensure that TF destroy happens automatically after tests are completed
	terraform.InitAndApply(t, terraformOptions)
	fibre_channel_adapter := terraform.Output(t, terraformOptions, "fibre_channel_adapter")
	fibre_channel_network := terraform.Output(t, terraformOptions, "fibre_channel_network")
	fibre_channel_qos := terraform.Output(t, terraformOptions, "fibre_channel_qos")
	moid := terraform.Output(t, terraformOptions, "moid")
	vhba := terraform.Output(t, terraformOptions, "vHBA-A")
	wwnn_pool := terraform.Output(t, terraformOptions, "wwnn_pool")
	wwpn_pool := terraform.Output(t, terraformOptions, "wwpn_pool")
	assert.NotEmpty(t, fibre_channel_adapter, "TF module fibre_channel_adapter moid output should not be empty")
	assert.NotEmpty(t, fibre_channel_network, "TF module fibre_channel_network moid output should not be empty")
	assert.NotEmpty(t, fibre_channel_qos, "TF module fibre_channel_qos moid output should not be empty")
	assert.NotEmpty(t, moid, "TF module moid output should not be empty")
	assert.NotEmpty(t, vhba, "TF module vnic moid output should not be empty")
	assert.NotEmpty(t, wwnn_pool, "TF module wwnn_pool moid output should not be empty")
	assert.NotEmpty(t, wwpn_pool, "TF module wwpn_pool moid output should not be empty")

	// Input variables for the TF module
	vars2 := map[string]interface{}{
		"fibre_channel_adapter": fibre_channel_adapter,
		"fibre_channel_network": fibre_channel_network,
		"fibre_channel_qos":     fibre_channel_qos,
		"san_connectivity":      moid,
		"name":                  instanceName,
		"vhba_name":             "vHBA-A",
		"wwnn_pool":             wwnn_pool,
		"wwpn_pool":             wwpn_pool,
	}

	//========================================================================
	// Make Intersight API call(s) to validate module worked
	//========================================================================

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedJSONTemplate := `
{
	"Name":        "{{ .name }}",
	"Description": "{{ .name }} SAN Connectivity Policy.",

	"PlacementMode": "custom",
	"TargetPlatform": "FIAttached",
	"WwnnAddressType": "POOL",
	"WwnnPool": {
	  "ClassId": "mo.MoRef",
	  "Moid": "{{ .wwnn_pool }}",
	  "ObjectType": "fcpool.Pool",
	  "link": "https://www.intersight.com/api/v1/fcpool/Pools/{{ .wwnn_pool }}"
	}
}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/vnic/SanConnectivityPolicies/%s", moid), expectedJSONTemplate, vars2)

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedVHBATemplate := `
{
	"Name":        "{{ .vhba_name }}",

	"FcAdapterPolicy": {
        "ClassId": "mo.MoRef",
        "Moid": "{{ .fibre_channel_adapter }}",
        "ObjectType": "vnic.FcAdapterPolicy",
        "link": "https://www.intersight.com/api/v1/vnic/FcAdapterPolicies/{{ .fibre_channel_adapter }}"
      },
      "FcNetworkPolicy": {
        "ClassId": "mo.MoRef",
        "Moid": "{{ .fibre_channel_network }}",
        "ObjectType": "vnic.FcNetworkPolicy",
        "link": "https://www.intersight.com/api/v1/vnic/FcNetworkPolicies/{{ .fibre_channel_network }}"
      },
      "FcQosPolicy": {
        "ClassId": "mo.MoRef",
        "Moid": "{{ .fibre_channel_qos }}",
        "ObjectType": "vnic.FcQosPolicy",
        "link": "https://www.intersight.com/api/v1/vnic/FcQosPolicies/{{ .fibre_channel_qos }}"
      },
      "FcZonePolicies": [],
      "Order": 0,
      "PersistentBindings": false,
      "PinGroupName": "",
      "Placement": {
        "AutoPciLink": false,
        "AutoSlotId": false,
        "ClassId": "vnic.PlacementSettings",
        "Id": "MLOM",
        "ObjectType": "vnic.PlacementSettings",
        "PciLink": 0,
        "SwitchId": "A",
        "Uplink": 0
      },
      "SanConnectivityPolicy": {
        "ClassId": "mo.MoRef",
        "Moid": "{{ .san_connectivity }}",
        "ObjectType": "vnic.SanConnectivityPolicy",
        "link": "https://www.intersight.com/api/v1/vnic/SanConnectivityPolicies/{{ .san_connectivity }}"
      },
      "SharedScope": "",
      "StaticWwpnAddress": "",
      "VifId": 0,
      "Wwpn": "",
      "WwpnAddressType": "POOL",
      "WwpnPool": {
        "ClassId": "mo.MoRef",
        "Moid": "{{ .wwpn_pool }}",
        "ObjectType": "fcpool.Pool",
        "link": "https://www.intersight.com/api/v1/fcpool/Pools/{{ .wwpn_pool }}"
      }
}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/vnic/FcIfs/%s", vhba), expectedVHBATemplate, vars2)
}
