package myfile

import (
	"context"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

func dataSourceMyFile() *schema.Resource {
	return &schema.Resource{
		ReadContext: dataSourceMyFileRead,
		Schema:      nil,
	}
}

func dataSourceMyFileRead(ctx context.Context, d *schema.ResourceData, meta interface{}) diag.Diagnostics {
	return nil
}
