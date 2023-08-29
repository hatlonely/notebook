package myfile

import (
	"context"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

func Provider() *schema.Provider {
	return &schema.Provider{
		Schema: map[string]*schema.Schema{
			"key1": {
				Type:        schema.TypeString,
				Required:    true,
				DefaultFunc: schema.EnvDefaultFunc("MY_FILE_KEY1", nil),
			},
			"key2": {
				Type:        schema.TypeInt,
				Required:    true,
				DefaultFunc: schema.EnvDefaultFunc("MY_FILE_KEY2", nil),
			},
		},
		ResourcesMap: map[string]*schema.Resource{
			"myfile": resourceMyFile(),
		},
		DataSourcesMap: map[string]*schema.Resource{
			"myfile": dataSourceMyFile(),
		},
		ConfigureContextFunc: providerConfigure,
	}
}

func providerConfigure(ctx context.Context, d *schema.ResourceData) (interface{}, diag.Diagnostics) {
	key1 := d.Get("key1").(string)
	key2 := d.Get("key2").(int)

	if key1 == "" {
		return nil, diag.Diagnostics{
			diag.Diagnostic{
				Severity: diag.Error,
				Summary:  "invalid argument key1",
				Detail:   "key1 should not be empty",
			},
		}
	}

	m := map[string]interface{}{
		"key1": key1,
		"key2": key2,
	}

	return m, nil
}
