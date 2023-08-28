package myfile

import (
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

func Provider() *schema.Provider {
	return &schema.Provider{
		Schema: map[string]*schema.Schema{
			"api_url": {
				Type:        schema.TypeString,
				Required:    true,
				DefaultFunc: schema.EnvDefaultFunc("HASHICUPS_API_URL", nil),
			},
		},
		ResourcesMap: map[string]*schema.Resource{
			"myfile_order": resourceOrder(),
		},
		DataSourcesMap: map[string]*schema.Resource{
			"myfile_coffees": dataSourceCoffees(),
		},
		ConfigureContextFunc: providerConfigure,
	}
}
