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
    - expression: {{group['expression']|yaml_encode}}
    {% if 'target' in group %}
    - target: {{group['target']}}
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

{% endfor %}
