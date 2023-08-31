package myfile

import (
	"context"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"io/ioutil"
)

func dataSourceMyFile() *schema.Resource {
	return &schema.Resource{
		ReadContext: dataSourceMyFileRead,
		Schema: map[string]*schema.Schema{
			"directory": {
				Type:     schema.TypeString,
				Required: true,
			},
			"files": {
				Type:     schema.TypeList,
				Computed: true,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"id": {
							Type:     schema.TypeString,
							Computed: true,
						},
						"name": {
							Type:     schema.TypeString,
							Computed: true,
						},
					},
				},
			},
		},
	}
}

func dataSourceMyFileRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	directory := d.Get("directory").(string)

	infos, err := ioutil.ReadDir(directory)
	if err != nil {
		return diag.FromErr(err)
	}

	var files []map[string]interface{}
	for _, info := range infos {
		if info.IsDir() {
			continue
		}

		files = append(files, map[string]interface{}{
			"id":   info.Name(),
			"name": info.Name(),
		})
	}

	if err := d.Set("files", files); err != nil {
		return diag.FromErr(err)
	}

	d.SetId(directory)

	return nil
}
