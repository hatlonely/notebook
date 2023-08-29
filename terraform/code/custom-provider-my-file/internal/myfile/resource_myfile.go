package myfile

import (
	"context"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

func resourceMyFile() *schema.Resource {
	return &schema.Resource{
		CreateContext: resourceMyFileCreate,
		ReadContext:   resourceMyFileRead,
		UpdateContext: resourceMyFileUpdate,
		DeleteContext: resourceMyFileDelete,

		Schema: map[string]*schema.Schema{
			"file_name": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"file_content": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
		},
	}
}

func resourceMyFileCreate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	return nil
}

func resourceMyFileRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	return nil
}

func resourceMyFileUpdate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	return nil
}

func resourceMyFileDelete(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	return nil
}
