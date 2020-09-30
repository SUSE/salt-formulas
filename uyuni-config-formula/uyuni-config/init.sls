{% for org in salt['pillar.get']('uyuni:orgs', []) %}
org_{{org['org_id']}}:
  uyuni.org_present:
    - name: {{org['org_id']}}
    - org_admin_user: {{org['org_admin_user']}}
    - org_admin_password: {{org['org_admin_password']}}
    - first_name: {{org['first_name']}}
    - last_name: {{org['last_name']}}
    - email: {{org['email']}}

{% for group in org.get('system_groups', []) %}
{{org['org_id']}}_{{group['name']}}:
  uyuni.group_present:
    - name: {{group['name']}}
    - description: {{group['description']|yaml_encode}}
    - target: {{group['target']|yaml_encode}}
    {% if 'target_type' in group %}
    - target_type: {{group['target_type']}}
    {% endif %}
    - org_admin_user: {{org['org_admin_user']}}
    - org_admin_password: {{org['org_admin_password']}}
{% endfor %}

{% for user in org.get('users', []) %}
{{org['org_id']}}_{{user['name']}}:
  uyuni.user_present:
    - name: {{user['name']}}
    - password: {{user['password']}}
    - email: {{user['email']}}
    - first_name: {{user['first_name']}}
    - last_name: {{user['last_name']}}
    - roles: {{user.get('roles', [])}}
    - system_groups: {{user.get('system_groups', [])}}
    - org_admin_user: {{org['org_admin_user']}}
    - org_admin_password: {{org['org_admin_password']}}

{{org['org_id']}}_{{user['name']}}_channels:
  uyuni.user_channels:
    - name: {{user['name']}}
    - password: {{user['password']}}
    - org_admin_user: {{org['org_admin_user']}}
    - org_admin_password: {{org['org_admin_password']}}
    - manageable_channels: {{user.get('manageable_channels',[])}}
    - subscribable_channels: {{user.get('subscribable_channels', [])}}

{% endfor %}

{% for ak in org.get('activation_keys', []) %}

# HACK do to limitation on the form framework we had to have a list of objects, instead of a list o string.
# This was needed to allow the usage of select instead of free text.
# the next lines convert the system_types back to a list of strings, as expected on the salt stated
{% set system_types = [] %}
{% for ak in ak.get('system_types', []) %}
    {% set system_types = system_types.append(ak['type']) %}
{% endfor %}

{{org['org_id']}}_{{ak['name']}}:
  uyuni.activation_key_present:
    - name: {{ak['name']}}
    - description: {{ak['description']}}
    - org_admin_user: {{org['org_admin_user']}}
    - org_admin_password: {{org['org_admin_password']}}
    - base_channel: {{ak['base_channel']}}
    - child_channels: {{ak['child_channels']}}
    - configuration_channels: {{ak['configuration_channels']}}
    - packages: {{ak['packages']}}
    - server_groups: {{ak['server_groups']}}
    - usage_limit: {{ak['usage_limit']}}
    - system_types: {{system_types}}
    - contact_method: {{ak['contact_method']}}
    - universal_default: {{ak.get('universal_default', false)}}
    - configure_after_registration: {{ak.get('configure_after_registration', false)}}

{% endfor %}

{% endfor %}
