package myfile

import (
	"context"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"io/ioutil"
	"os"
)

func resourceMyFile() *schema.Resource {
	return &schema.Resource{
		CreateContext: resourceMyFileCreate,
		ReadContext:   resourceMyFileRead,
		UpdateContext: resourceMyFileUpdate,
		DeleteContext: resourceMyFileDelete,

		Schema: map[string]*schema.Schema{
			"name": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
			"content": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
		},
	}
}

func resourceMyFileCreate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	name := d.Get("name").(string)
	content := d.Get("content").(string)

	if err := ioutil.WriteFile(name, []byte(content), 0644); err != nil {
		return diag.FromErr(err)
	}

	d.SetId(name)

	return nil
}

func resourceMyFileRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	name := d.Id()
	buf, err := ioutil.ReadFile(name)
	if err != nil {
		return diag.FromErr(err)
	}

	if err := d.Set("content", string(buf)); err != nil {
		return diag.FromErr(err)
	}

	return nil
}

func resourceMyFileUpdate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	name := d.Id()
	content := d.Get("content").(string)

	if err := ioutil.WriteFile(name, []byte(content), 0644); err != nil {
		return diag.Diagnostics{
			diag.Diagnostic{
				Severity: diag.Error,
				Summary:  "ioutil.WriteFileFailed",
				Detail:   err.Error(),
			},
		}
	}

	return nil
}

func resourceMyFileDelete(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	name := d.Id()

	if err := os.RemoveAll(name); err != nil {
		return diag.FromErr(err)
	}

	return nil
}
